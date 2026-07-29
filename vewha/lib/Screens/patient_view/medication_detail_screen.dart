import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:Vewha/models/study_drug.dart';
import '../../data/plain_lang_entry.dart';
import '../../Services/translation_service.dart';
import '../../repositories/localization_repository.dart';
import '../../components/patient_view/anatomy_viewer.dart';
import '../../components/patient_view/mechanism_animator.dart';
import '../../components/patient_view/audio_narration.dart';
import '../../components/patient_view/medication_card.dart';
import '../../components/patient_view/pictogram_row.dart';
import '../../services/patient_tts_service.dart';
import '../../logging/performance_tracker.dart';
import 'comprehension_screen.dart';

class MedicationDetailScreen extends StatefulWidget {
  final StudyDrug drug;
  final String initialLanguage;

  const MedicationDetailScreen({
    super.key,
    required this.drug,
    this.initialLanguage = 'en',
  });

  @override
  State<MedicationDetailScreen> createState() => _MedicationDetailScreenState();
}

class _MedicationDetailScreenState extends State<MedicationDetailScreen> {
  String _lang = 'en';
  bool _audioPlayed = false;
  late final DateTime _screenOpenTime;
  final ValueNotifier<int> _activeStepNotifier = ValueNotifier<int>(-1);
  Timer? _autoPlayTimer;
  final GlobalKey<AnatomyViewerState> _anatomyKey = GlobalKey<AnatomyViewerState>();

  PlainLangEntry? _entry;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _lang = widget.initialLanguage;
    _screenOpenTime = DateTime.now();
    PatientModuleRegistry.isTtsInitialized = true;
    PatientModuleRegistry.isSvgInitialized = true;
    _loadLanguage(_lang);
  }

  Future<void> _loadLanguage(String lang) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    // Load clinical entry
    await TranslationService().loadLanguage(lang);
    
    // Load UI localization
    final loc = context.read<LocalizationRepository>();
    if (loc.currentLanguage != lang) {
      await loc.loadLanguage(lang);
    }
    
    if (mounted) {
      setState(() {
        _entry = TranslationService().getEntry(widget.drug.plainLanguageKey, lang) ?? 
                 TranslationService().getEntry(widget.drug.plainLanguageKey, 'en');
        _isLoading = false;
      });
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _activeStepNotifier.value = 0;
      _autoPlayTimer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
        if (!mounted || _audioPlayed || _entry == null) {
          timer.cancel();
          return;
        }
        if (_activeStepNotifier.value < _entry!.mechanismSteps.length - 1) {
          _activeStepNotifier.value++;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    PatientTtsService().stop();
    _activeStepNotifier.dispose();
    super.dispose();
  }

  String get _ttsLang => _lang == 'te' ? 'te-IN' : (_lang == 'hi' ? 'hi-IN' : 'en-IN');

  void _openComprehension() {
    final elapsed = DateTime.now().difference(_screenOpenTime).inMilliseconds;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ComprehensionScreen(
        drug: widget.drug,
        timeOnScreenMs: elapsed,
        audioPlayed: _audioPlayed,
        language: _lang,
        showVisuals: true,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF1D9E75))));
    }
    
    final loc = context.read<LocalizationRepository>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          loc.getClinicalEntry(widget.drug.nameKey),
          style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF555555)),
          onPressed: () {
            PatientTtsService().stop();
            Navigator.of(context).pop();
          },
        ),
        actions: [
          DropdownButton<String>(
            value: _lang,
            underline: const SizedBox(),
            icon: const Icon(Icons.language, color: Color(0xFF1D9E75)),
            style: const TextStyle(color: Color(0xFF1D9E75), fontWeight: FontWeight.bold, fontSize: 16),
            onChanged: (String? newValue) {
              if (newValue != null && newValue != _lang) {
                setState(() => _lang = newValue);
                _loadLanguage(newValue);
              }
            },
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'te', child: Text('鈰戈�鈰耜�鈰鉮�')),
              DropdownMenuItem(value: 'hi', child: Text('鄐嫩凶鄐兒�鄐舟�')),
              DropdownMenuItem(value: 'kn', child: Text('鉦𨫼疏鈳温疏鉦�')),
              DropdownMenuItem(value: 'ta', child: Text('鉈戈悅鉈賴捎鉒�')),
              DropdownMenuItem(value: 'mr', child: Text('鄐桌什鄐擒�鄍�')),
              DropdownMenuItem(value: 'bn', child: Text('鄏眇汙鄏�曳鄏�')),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Anatomy viewer with visual storyboard overlays integrated
            Center(
              child: AnatomyViewer(
                key: _anatomyKey,
                bodySystem: widget.drug.bodySystem.toString(),
                height: MediaQuery.of(context).size.height * 0.40,
                config: widget.drug.anatomyConfig,
                activeStepNotifier: _activeStepNotifier,
              ),
            ),
            const SizedBox(height: 16),
            
            // Mechanism Animator (Visual + Text) synchronized
            MechanismAnimator(
              storyboardSteps: widget.drug.anatomyConfig.storyboardSteps,
              steps: _entry!.mechanismSteps,
              language: _lang,
              activeStepNotifier: _activeStepNotifier,
            ),
            const SizedBox(height: 24),

            // ���� Pictogram row for illiterate users ����������������������������������������������
            PictogramRow(
              codes: _entry!.pictograms,
              language: _lang,
            ),
            const SizedBox(height: 28),
            
            // Plain language what it's for
            _section(loc.getUiString('what_is_this_for'), _entry!.whatItIsFor),
            const SizedBox(height: 20),
            _section(loc.getUiString('how_to_take_it'), _entry!.howToTake),
            const SizedBox(height: 28),
            
            // Audio button
            Center(
              child: AudioNarration(
                entry: _entry!,
                languageCode: _ttsLang,
                activeStepNotifier: _activeStepNotifier,
                onPlayStateChanged: (playing) {
                  if (playing) {
                    setState(() => _audioPlayed = true);
                    _anatomyKey.currentState?.restartAnimation();
                  }
                },
              ),
            ),
            const SizedBox(height: 32),
            
            // Clinical summary card
            Text(
              loc.getUiString('clinical_details'),
              style: const TextStyle(fontSize: 14, color: Color(0xFF888888), fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            MedicationCard(drug: widget.drug, language: _lang),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _openComprehension,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF534AB7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: Text(
                  loc.getUiString('answer_questions'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1D9E75)),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 16, color: Color(0xFF333333), height: 1.5),
        ),
      ],
    );
  }
}痕鈳温盒鉦嗣�鉦兒�鉦鉮眾鉦賴�鈳� 鉦凼略鈳温略鉦啤窒鉦詮窒', '鉈�悄鉒温恕 鉈桌扇鉒�悄鉒温恕鉒� 鉈芹拳鉒温拳鉈賴悖 鉈𨫼�鉈喪�鉈菽挪鉈𨫼拿鉒��鉒温�鉒� 鉈芹恕鉈賴挈鉈喪挪鉈𨫼�鉈𨫼挾鉒�悅鉒�', '鄐能冗 鄐𠰍仄鄐抉冗鄐眇丹鄍温丹鄐� 鄐芹�鄐啤介鄍温尹鄐擒�鄐𠼭� 鄐凼中鄍温中鄐啤� 鄐舟�鄐能冗', '鄏𥐰� 鄏㮙朵鄑�戍 鄏詮旨鄑温扛鄏啤�鄏𨫼� 鄏芹�鄏啤朱鄑温成鄑�旭 鄏凼忖鄑温忖鄏� 鄏舟江鄏�'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1D9E75)),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 18, color: Color(0xFF333333), height: 1.6),
        ),
      ],
    );
  }
}
