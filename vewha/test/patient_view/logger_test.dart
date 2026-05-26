// ignore_for_file: depend_on_referenced_packages
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:Vewha/logging/study_logger.dart';

class MockPathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '.';
  }
  @override
  Future<String?> getTemporaryPath() async {
    return '.';
  }
}

void main() {
  group('StudyLogger Unit Tests', () {
    setUpAll(() {
      PathProviderPlatform.instance = MockPathProviderPlatform();
    });

    test('Verify session initialization and append-only behavior', () {
      final logger = StudyLogger();
      
      // Start a session
      logger.startSession('P05', 'A');
      
      expect(logger.sessionId.isNotEmpty, isTrue);
      expect(logger.condition, equals('A'));
      expect(logger.entries.isEmpty, isTrue);

      // Log first answer
      logger.logAnswer(
        drugId: 'metformin_01',
        questionId: 'q_name',
        answer: 'Metformin',
        correct: true,
        timeOnScreenMs: 3500,
        audioPlayed: false,
        language: 'en',
      );

      expect(logger.entries.length, equals(1));
      final entry1 = logger.entries.first;
      expect(entry1.participantCode, equals('P05'));
      expect(entry1.drugId, equals('metformin_01'));
      expect(entry1.correct, isTrue);
      expect(entry1.timeOnScreenMs, equals(3500));
      expect(entry1.audioPlayed, isFalse);

      // Log second answer to test append-only
      logger.logAnswer(
        drugId: 'metformin_01',
        questionId: 'q_dose',
        answer: '250mg', // incorrect
        correct: false,
        timeOnScreenMs: 1200,
        audioPlayed: true,
        language: 'te',
      );

      expect(logger.entries.length, equals(2));
      final entry2 = logger.entries.last;
      expect(entry2.questionId, equals('q_dose'));
      expect(entry2.correct, isFalse);
      expect(entry2.audioPlayed, isTrue);
      expect(entry2.language, equals('te'));
      expect(entry2.timestamp.isAfter(entry1.timestamp) || entry2.timestamp.isAtSameMomentAs(entry1.timestamp), isTrue);
    });

    test('Verify CSV and JSON exporting successfully creates files on disk', () async {
      final logger = StudyLogger();
      logger.startSession('P05', 'B');
      logger.logAnswer(
        drugId: 'salbutamol_01',
        questionId: 'q_freq',
        answer: 'As needed',
        correct: true,
        timeOnScreenMs: 2500,
        audioPlayed: false,
        language: 'en',
      );

      // Export CSV
      final csvPath = await logger.exportToCsv();
      expect(csvPath.isNotEmpty, isTrue);
      final csvFile = File(csvPath);
      expect(csvFile.existsSync(), isTrue);
      
      final csvContent = csvFile.readAsStringSync();
      expect(csvContent.contains('sessionId,participantCode,condition,drugId,questionId'), isTrue);
      expect(csvContent.contains('salbutamol_01'), isTrue);
      expect(csvContent.contains('As needed'), isTrue);
      
      // Clean up
      csvFile.deleteSync();

      // Export JSON
      final jsonPath = await logger.exportToJson();
      expect(jsonPath.isNotEmpty, isTrue);
      final jsonFile = File(jsonPath);
      expect(jsonFile.existsSync(), isTrue);

      final jsonContent = jsonFile.readAsStringSync();
      expect(jsonContent.contains('P05'), isTrue);
      expect(jsonContent.contains('salbutamol_01'), isTrue);

      // Clean up
      jsonFile.deleteSync();
    });
  });
}
