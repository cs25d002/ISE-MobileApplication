import 'package:flutter/material.dart';
import '../../data/prescriptions.dart';
import '../../data/plain_language_map.dart';
import '../../components/patient_view/anatomy_viewer.dart';
import '../../components/patient_view/audio_narration.dart';
import '../../components/patient_view/medication_card.dart';
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

  String _t(String en, String te, String hi) {
    if (_lang == 'hi') return hi;
    if (_lang == 'te') return te;
    return en;
  }

  @override
  void initState() {
    super.initState();
    _lang = widget.initialLanguage;
    _screenOpenTime = DateTime.now();
  }

  PlainLangEntry get _entry =>
      plainLanguageMap[widget.drug.plainLanguageKey]?[_lang] ??
      plainLanguageMap[widget.drug.plainLanguageKey]!['en']!;

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
    final isTe = _lang == 'te';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _t(widget.drug.name, widget.drug.nameTe, widget.drug.nameHi),
          style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF555555)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          DropdownButton<String>(
            value: _lang,
            underline: const SizedBox(),
            icon: const Icon(Icons.language, color: Color(0xFF1D9E75)),
            style: const TextStyle(color: Color(0xFF1D9E75), fontWeight: FontWeight.bold, fontSize: 16),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() => _lang = newValue);
              }
            },
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'te', child: Text('తెలుగు')),
              DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
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
            // Anatomy viewer
            Center(child: AnatomyViewer(bodySystem: widget.drug.bodySystem, height: 240)),
            const SizedBox(height: 10),
            Center(
              child: Text(
                _t('Where this medicine works in your body', 'ఇది మీ శరీరంలో ఎక్కడ పని చేస్తుంది', 'यह दवा आपके शरीर में कहाँ काम करती है'),
                style: const TextStyle(fontSize: 13, color: Color(0xFF888888), fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 28),
            // Plain language what it's for
            _section(_t('What this medicine is for', 'ఈ మందు దేనికి వాడతారు', 'यह दवा किसलिए है'), _entry.whatItIsFor),
            const SizedBox(height: 20),
            _section(_t('How to take it', 'ఎలా వాడాలి', 'इसे कैसे लेना है'), _entry.howToTake),
            const SizedBox(height: 28),
            // Audio button
            Center(
              child: AudioNarration(
                text: _entry.audioText,
                languageCode: _ttsLang,
                onPlayStateChanged: (playing) {
                  if (playing) setState(() => _audioPlayed = true);
                },
              ),
            ),
            const SizedBox(height: 32),
            // Clinical summary card
            Text(
              _t('Clinical details', 'క్లినికల్ వివరాలు', 'नैदानिक विवरण'),
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
                  _t('Answer questions about this medicine', 'ప్రశ్నలకు సమాధానం ఇవ్వండి', 'इस दवा के बारे में सवालों के जवाब दें'),
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
