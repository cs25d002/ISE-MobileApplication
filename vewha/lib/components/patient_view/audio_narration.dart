import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../logging/performance_tracker.dart';

class AudioNarration extends StatefulWidget {
  final String text;
  final String languageCode; // 'en-IN' or 'te-IN'
  final ValueChanged<bool>? onPlayStateChanged; // true = playing

  const AudioNarration({
    super.key,
    required this.text,
    required this.languageCode,
    this.onPlayStateChanged,
  });

  @override
  State<AudioNarration> createState() => _AudioNarrationState();
}

class _AudioNarrationState extends State<AudioNarration> {
  final FlutterTts _tts = FlutterTts();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    PatientModuleRegistry.isTtsInitialized = true;
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isPlaying = false);
      widget.onPlayStateChanged?.call(false);
    });
  }

  Future<void> _play() async {
    await _tts.setLanguage(widget.languageCode);
    await _tts.setSpeechRate(0.45);
    await _tts.speak(widget.text);
    if (mounted) setState(() => _isPlaying = true);
    widget.onPlayStateChanged?.call(true);
  }

  Future<void> _stop() async {
    await _tts.stop();
    if (mounted) setState(() => _isPlaying = false);
    widget.onPlayStateChanged?.call(false);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String listenText = 'Listen';
    String stopText = 'Stop';
    if (widget.languageCode.startsWith('te')) {
      listenText = 'వినండి';
      stopText = 'ఆపండి';
    } else if (widget.languageCode.startsWith('hi')) {
      listenText = 'सुनें';
      stopText = 'रुकें';
    }

    return ElevatedButton.icon(
      onPressed: _isPlaying ? _stop : _play,
      icon: Icon(_isPlaying ? Icons.stop : Icons.volume_up),
      label: Text(_isPlaying ? stopText : listenText),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1D9E75),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}
