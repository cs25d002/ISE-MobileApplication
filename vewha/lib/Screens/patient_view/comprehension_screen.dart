import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Vewha/models/study_drug.dart';
import '../../logging/study_logger.dart';
import '../../components/patient_view/anatomy_viewer.dart';
import '../../services/patient_tts_service.dart';
import '../../Services/translation_service.dart';
import '../../repositories/localization_repository.dart';

class ComprehensionScreen extends StatefulWidget {
  final StudyDrug drug;
  final int timeOnScreenMs;
  final bool audioPlayed;
  final String language;
  final bool showVisuals;

  const ComprehensionScreen({
    super.key,
    required this.drug,
    required this.timeOnScreenMs,
    required this.audioPlayed,
    required this.language,
    required this.showVisuals,
  });

  @override
  State<ComprehensionScreen> createState() => _ComprehensionScreenState();
}

class _ComprehensionScreenState extends State<ComprehensionScreen> {
  int _currentQ = 0;
  bool _recoveryMode = false;
  final PatientTtsService _ttsService = PatientTtsService();

  McqQuestion get _currentQuestion => widget.drug.questions[_currentQ];

  @override
  void initState() {
    super.initState();
    if (widget.showVisuals) {
      _ttsService.prewarm();
      _ttsService.stateNotifier.addListener(_onTtsStateChange);
    }
  }

  @override
  void dispose() {
    if (widget.showVisuals) {
      _ttsService.stateNotifier.removeListener(_onTtsStateChange);
      _ttsService.stop();
    }
    super.dispose();
  }

  void _onTtsStateChange() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _playRecoveryAudio() async {
    try {
      String langCode = 'en-IN';
      if (widget.language == 'te') langCode = 'te-IN';
      if (widget.language == 'hi') langCode = 'hi-IN';
      if (widget.language == 'kn') langCode = 'kn-IN';
      if (widget.language == 'ta') langCode = 'ta-IN';
      if (widget.language == 'mr') langCode = 'mr-IN';
      if (widget.language == 'bn') langCode = 'bn-IN';
      
      final entry = TranslationService().getEntry(widget.drug.plainLanguageKey, widget.language);
      if (entry == null) return;
      
      final textToSpeak = "${entry.whatItIsFor.trim()} ${entry.howToTake.trim()} ${entry.mechanismSteps.join(' ').trim()}";
      await _ttsService.speak(textToSpeak, langCode);
    } catch (e) {
      debugPrint("[TTS COMPREHENSION ERROR] $e");
    }
  }

  void _submitOption(int selectedIndex) {
    final q = _currentQuestion;
    final bool correct = selectedIndex == q.correctIndex;

    // Log the answer
    StudyLogger().logAnswer(
      drugId: widget.drug.drugId,
      questionId: q.id,
      answer: "Option $selectedIndex",
      correct: correct,
      timeOnScreenMs: widget.timeOnScreenMs,
      audioPlayed: widget.audioPlayed,
      language: widget.language,
    );

    if (correct) {
      if (_currentQ < widget.drug.questions.length - 1) {
        setState(() {
          _currentQ++;
          _recoveryMode = false;
        });
      } else {
        Navigator.of(context).pop(); 
        Navigator.of(context).pop(); 
      }
    } else {
      if (!_recoveryMode) {
        setState(() {
          _recoveryMode = true;
        });
        if (widget.showVisuals) {
          _playRecoveryAudio();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _currentQuestion;
    final loc = context.read<LocalizationRepository>();

    List<String> options = loc.translateList(q.optionsKey);
    final isSpeaking = _ttsService.stateNotifier.value == PatientTtsState.playing;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          loc.translate('study_eval_quiz'),
          style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF555555)),
          onPressed: () {
            _ttsService.stop();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: (_currentQ + 1) / widget.drug.questions.length,
                backgroundColor: const Color(0xFFE0E0E0),
                color: const Color(0xFF1D9E75),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 18),
              Text(
                loc.translate('question_progress', params: {'current': '${_currentQ + 1}', 'total': '${widget.drug.questions.length}'}),
                style: const TextStyle(fontSize: 14, color: Color(0xFF888888), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 28),
              
              if (_recoveryMode) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFEeba)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: Color(0xFF856404)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              loc.translate('lets_review'),
                              style: const TextStyle(color: Color(0xFF856404), fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (widget.showVisuals) ...[
                        Center(
                          child: AnatomyViewer(
                            bodySystem: widget.drug.bodySystem.toString(),
                            height: 180,
                            config: widget.drug.anatomyConfig,
                            language: widget.language,
                            isRecoveryMode: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isSpeaking ? Icons.volume_up : Icons.volume_mute, 
                              color: isSpeaking ? const Color(0xFF1D9E75) : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isSpeaking 
                                ? loc.translate('playing_explanation') 
                                : loc.translate('explanation_finished'),
                              style: TextStyle(
                                color: isSpeaking ? const Color(0xFF1D9E75) : Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        loc.translate('medicine_helps_with'),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF856404)),
                      ),
                      Text(
                        loc.translate(widget.drug.purposeKey),
                        style: const TextStyle(color: Color(0xFF856404)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
              ],

              Text(
                loc.translate(q.questionKey),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 28),
              
              ...List.generate(options.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: const Color(0xFFF8F9FA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFDEE2E6)),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _submitOption(index),
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 60),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        child: Text(
                          options[index],
                          style: const TextStyle(fontSize: 18, height: 1.4, color: Color(0xFF1A1A2E)),
                          softWrap: true,
                          maxLines: null,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
