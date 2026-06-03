// lib/components/patient_view/audio_narration.dart
// Reactive UI controls linked directly to singular prewarmed PatientTtsService singleton.
// Observes value notifications, handles Pause/Resume/Replay/Stop commands.
// Adheres fully to the minimum 48x48 tap target and screen-reader accessibility rules.

import 'package:flutter/material.dart';
import '../../data/plain_language_map.dart';
import '../../services/patient_tts_service.dart';

class AudioNarration extends StatefulWidget {
  final PlainLangEntry entry;
  final String languageCode; // 'en-IN', 'te-IN', 'hi-IN'
  final ValueChanged<bool>? onPlayStateChanged; // true = playing
  final ValueNotifier<int>? activeStepNotifier;

  const AudioNarration({
    super.key,
    required this.entry,
    required this.languageCode,
    this.onPlayStateChanged,
    this.activeStepNotifier,
  });

  @override
  State<AudioNarration> createState() => _AudioNarrationState();
}

class _AudioNarrationState extends State<AudioNarration> {
  final PatientTtsService _ttsService = PatientTtsService();
  int _currentChunkIndex = 0;

  @override
  void initState() {
    super.initState();
    _ttsService.prewarm();
    _ttsService.stateNotifier.addListener(_onTtsStateChange);
  }

  @override
  void dispose() {
    _ttsService.stateNotifier.removeListener(_onTtsStateChange);
    super.dispose();
  }

  void _onTtsStateChange() {
    if (mounted) {
      setState(() {});
      final isPlaying = _ttsService.stateNotifier.value == PatientTtsState.playing;
      widget.onPlayStateChanged?.call(isPlaying);
      if (!isPlaying && _ttsService.stateNotifier.value == PatientTtsState.idle) {
         if (widget.activeStepNotifier != null) {
           widget.activeStepNotifier!.value = -1;
         }
      }
    }
  }

  List<String> _getChunks() {
    return [
      '${widget.entry.whatItIsFor.trim()} ${widget.entry.howToTake.trim()}',
      ...widget.entry.mechanismSteps.map((s) => s.trim())
    ];
  }

  Future<void> _play() async {
    final chunks = _getChunks();
    _currentChunkIndex = 0;
    await _ttsService.speakChunked(chunks, widget.languageCode, (index) {
      _currentChunkIndex = index;
      if (widget.activeStepNotifier != null) {
        widget.activeStepNotifier!.value = index - 1;
      }
    });
  }

  Future<void> _pause() async {
    await _ttsService.pause();
  }

  Future<void> _resume() async {
    // Basic resume: re-speak the current chunk and let the loop continue
    final chunks = _getChunks();
    if (_currentChunkIndex < chunks.length) {
       _ttsService.stateNotifier.value = PatientTtsState.playing;
       await _ttsService.resume(chunks[_currentChunkIndex], widget.languageCode);
    }
  }

  Future<void> _stop() async {
    await _ttsService.stop();
    if (widget.activeStepNotifier != null) {
      widget.activeStepNotifier!.value = -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    String listenText = 'Listen';
    String pauseText = 'Pause';
    String resumeText = 'Resume';
    String stopText = 'Stop';

    if (widget.languageCode.startsWith('te')) {
      listenText = 'వినండి';
      pauseText = 'ఆపండి';
      resumeText = 'మళ్లీ వినండి';
      stopText = 'ముగించు';
    } else if (widget.languageCode.startsWith('hi')) {
      listenText = 'सुनें';
      pauseText = 'विराम';
      resumeText = 'फिर सुनें';
      stopText = 'बंद करें';
    }

    final ttsState = _ttsService.stateNotifier.value;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: 'Voice guidance controls',
          hint: 'Play, pause, or stop medication details read aloud',
          container: true,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              // Play/Resume Button
              if (ttsState == PatientTtsState.idle)
                _buildActionButton(
                  onPressed: _play,
                  icon: Icons.volume_up,
                  label: listenText,
                  color: const Color(0xFF1D9E75),
                  semanticsLabel: 'Play voice instructions',
                )
              else if (ttsState == PatientTtsState.paused)
                _buildActionButton(
                  onPressed: _resume,
                  icon: Icons.play_arrow,
                  label: resumeText,
                  color: const Color(0xFF1D9E75),
                  semanticsLabel: 'Resume voice instructions',
                )
              else
                _buildActionButton(
                  onPressed: _pause,
                  icon: Icons.pause,
                  label: pauseText,
                  color: Colors.orange,
                  semanticsLabel: 'Pause voice instructions',
                ),

              // Stop Button
              if (ttsState != PatientTtsState.idle)
                _buildActionButton(
                  onPressed: _stop,
                  icon: Icons.stop,
                  label: stopText,
                  color: Colors.redAccent,
                  semanticsLabel: 'Stop voice instructions',
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
    required String semanticsLabel,
  }) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 120, minHeight: 48), // Ensure >= 48px target
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          label: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
