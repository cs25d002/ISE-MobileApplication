// lib/logging/study_logger.dart
// Append-only local study logger. No Firebase. No network.
// Writes to app documents directory via path_provider.

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class LogEntry {
  final String sessionId;
  final String participantCode;
  final String condition;
  final String drugId;
  final String questionId;
  final String answer;
  final bool correct;
  final int timeOnScreenMs;
  final bool audioPlayed;
  final String language;
  final DateTime timestamp;

  LogEntry({
    required this.sessionId,
    required this.participantCode,
    required this.condition,
    required this.drugId,
    required this.questionId,
    required this.answer,
    required this.correct,
    required this.timeOnScreenMs,
    required this.audioPlayed,
    required this.language,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'participantCode': participantCode,
    'condition': condition,
    'drugId': drugId,
    'questionId': questionId,
    'answer': answer,
    'correct': correct,
    'timeOnScreenMs': timeOnScreenMs,
    'audioPlayed': audioPlayed,
    'language': language,
    'timestamp': timestamp.toIso8601String(),
  };

  String toCsvRow() =>
    '"$sessionId","$participantCode","$condition","$drugId","$questionId",'
    '"${answer.replaceAll('"', '""')}","$correct","$timeOnScreenMs",'
    '"$audioPlayed","$language","${timestamp.toIso8601String()}"';
}

class StudyLogger {
  static final StudyLogger _instance = StudyLogger._internal();
  factory StudyLogger() => _instance;
  StudyLogger._internal();

  String _sessionId = '';
  String _participantCode = '';
  String _condition = '';
  final List<LogEntry> _entries = [];
  static const String _csvHeader =
    'sessionId,participantCode,condition,drugId,questionId,'
    'answer,correct,timeOnScreenMs,audioPlayed,language,timestamp';

  void startSession(String participantCode, String condition) {
    _sessionId = const Uuid().v4();
    _participantCode = participantCode;
    _condition = condition;
    _entries.clear();
  }

  void logAnswer({
    required String drugId,
    required String questionId,
    required String answer,
    required bool correct,
    required int timeOnScreenMs,
    required bool audioPlayed,
    required String language,
  }) {
    _entries.add(LogEntry(
      sessionId: _sessionId,
      participantCode: _participantCode,
      condition: _condition,
      drugId: drugId,
      questionId: questionId,
      answer: answer,
      correct: correct,
      timeOnScreenMs: timeOnScreenMs,
      audioPlayed: audioPlayed,
      language: language,
      timestamp: DateTime.now(),
    ));
  }

  Future<String> exportToCsv() async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'study_log_${_participantCode}_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File('${dir.path}/$fileName');
    final lines = [_csvHeader, ..._entries.map((e) => e.toCsvRow())];
    await file.writeAsString(lines.join('\n'));
    return file.path;
  }

  Future<String> exportToJson() async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'study_log_${_participantCode}_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(jsonEncode(_entries.map((e) => e.toJson()).toList()));
    return file.path;
  }

  String get sessionId => _sessionId;
  String get condition => _condition;
  List<LogEntry> get entries => List.unmodifiable(_entries);
}
