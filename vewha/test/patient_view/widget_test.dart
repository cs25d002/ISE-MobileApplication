// ignore_for_file: depend_on_referenced_packages, unnecessary_import
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:Vewha/data/prescriptions.dart';
import 'package:Vewha/logging/study_logger.dart';
import 'package:Vewha/components/patient_view/anatomy_viewer.dart';
import 'package:Vewha/components/patient_view/audio_narration.dart';
import 'package:Vewha/components/patient_view/progress_stepper.dart';
import 'package:Vewha/components/patient_view/medication_card.dart';
import 'package:Vewha/Screens/patient_view/patient_entry_screen.dart';
import 'package:Vewha/Screens/patient_view/medication_list_screen.dart';
import 'package:Vewha/Screens/patient_view/medication_detail_screen.dart';
import 'package:Vewha/Screens/patient_view/plain_text_condition_screen.dart';
import 'package:Vewha/Screens/patient_view/comprehension_screen.dart';

class MockPathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '.';
  }
}

void main() {
  setUpAll(() {
    PathProviderPlatform.instance = MockPathProviderPlatform();
  });

  // Mock methods for system bindings
  void setupMockChannels(WidgetTester tester) {
    // Mock flutter_tts method channel
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (MethodCall methodCall) async {
        return 1;
      },
    );

    // Mock asset loader binary message handler
    tester.binding.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (ByteData? message) async {
        if (message == null) return null;
        final String key = utf8.decode(message.buffer.asUint8List(message.offsetInBytes, message.lengthInBytes));
        if (key.startsWith('assets/anatomy/')) {
          final String svg = '<svg viewBox="0 0 200 400"><rect width="200" height="400" fill="gray"/></svg>';
          final Uint8List bytes = Uint8List.fromList(utf8.encode(svg));
          return ByteData.view(bytes.buffer);
        }
        return null;
      },
    );
  }

  group('Patient-View Reusable Components Tests', () {
    testWidgets('ProgressStepper renders and transitions', (WidgetTester tester) async {
      int tappedIndex = -1;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ProgressStepper(
            currentIndex: 1,
            total: 5,
            onTap: (i) => tappedIndex = i,
          ),
        ),
      ));

      // Verify progress dots exist
      expect(find.byType(ProgressStepper), findsOneWidget);
      expect(find.byType(GestureDetector), findsNWidgets(5));

      // Tap on dot 3 (index 2)
      await tester.tap(find.byType(GestureDetector).at(2));
      await tester.pump();

      expect(tappedIndex, equals(2));
    });

    testWidgets('AnatomyViewer loads SVG schematically', (WidgetTester tester) async {
      setupMockChannels(tester);
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: AnatomyViewer(bodySystem: BodySystem.respiratory),
        ),
      ));
      expect(find.byType(AnatomyViewer), findsOneWidget);
    });

    testWidgets('MedicationCard renders prescription values', (WidgetTester tester) async {
      final drug = studyDrugs[0]; // Metformin
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MedicationCard(drug: drug, language: 'en'),
        ),
      ));

      expect(find.text(drug.name), findsOneWidget);
      expect(find.text(drug.dose), findsOneWidget);
      expect(find.text(drug.route), findsOneWidget);
    });

    testWidgets('AudioNarration renders play button and toggles state', (WidgetTester tester) async {
      setupMockChannels(tester);
      bool isPlaying = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AudioNarration(
            text: 'Hello World',
            languageCode: 'en-IN',
            onPlayStateChanged: (p) => isPlaying = p,
          ),
        ),
      ));

      // Button exists with volume icon and 'Listen' text
      expect(find.text('Listen'), findsOneWidget);
      expect(find.byIcon(Icons.volume_up), findsOneWidget);

      // Tap to speak
      await tester.tap(find.byType(AudioNarration));
      await tester.pump();

      // Audio state should change
      expect(isPlaying, isTrue);
    });
  });

  group('Patient-View Screens Tests', () {
    testWidgets('PatientEntryScreen interactive options', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: PatientEntryScreen(),
      ));

      expect(find.text('Study Setup'), findsOneWidget);
      expect(find.text('Participant code'), findsOneWidget);
      expect(find.text('Pictures + Voice'), findsOneWidget);
      expect(find.text('Basic Text Table'), findsOneWidget);

      // Toggle Condition B
      await tester.tap(find.text('Basic Text Table'));
      await tester.pump();

      // Select Launch with blank code shows SnackBar
      await tester.tap(find.text('Launch Study'));
      await tester.pump();
      expect(find.text('Please enter a participant code'), findsOneWidget);
    });

    testWidgets('MedicationListScreen disclosure list next/previous operations', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: MedicationListScreen(condition: 'A', language: 'en'),
      ));

      // Medication 1 is visible
      expect(find.text('Medication 1 of 5'), findsOneWidget);
      expect(find.text('Previous'), findsNothing); // First item, no previous button
      expect(find.text('Next'), findsOneWidget);

      // Navigate to Medication 2
      await tester.tap(find.text('Next'));
      await tester.pump();

      expect(find.text('Medication 2 of 5'), findsOneWidget);
      expect(find.text('Previous'), findsOneWidget);
    });

    testWidgets('MedicationDetailScreen renders Enhancement View components', (WidgetTester tester) async {
      setupMockChannels(tester);
      final drug = studyDrugs[1]; // Salbutamol
      await tester.pumpWidget(MaterialApp(
        home: TickerMode(
          enabled: false,
          child: MedicationDetailScreen(drug: drug, initialLanguage: 'en'),
        ),
      ));

      expect(find.byType(AnatomyViewer), findsOneWidget);
      expect(find.byType(AudioNarration), findsOneWidget);
      expect(find.byType(MedicationCard), findsOneWidget);
      expect(find.text('English'), findsWidgets);

      // Open Dropdown
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Toggle Language to Telugu
      await tester.tap(find.text('తెలుగు').last);
      await tester.pumpAndSettle();
      
      expect(find.text('తెలుగు'), findsWidgets);
    });

    testWidgets('PlainTextConditionScreen renders simple data table', (WidgetTester tester) async {
      final drug = studyDrugs[3]; // Amlodipine
      await tester.pumpWidget(MaterialApp(
        home: PlainTextConditionScreen(drug: drug, initialLanguage: 'en'),
      ));

      expect(find.byType(Table), findsOneWidget);
      expect(find.text('Field'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Medicine'), findsOneWidget);
      expect(find.text(drug.name), findsOneWidget);
      expect(find.byType(AnatomyViewer), findsNothing); // Decoupled: NO anatomy visualization
    });

    testWidgets('ComprehensionScreen progression flow', (WidgetTester tester) async {
      final drug = studyDrugs[0]; // Metformin
      StudyLogger().startSession('P22', 'A');
      await tester.pumpWidget(MaterialApp(
        home: ComprehensionScreen(
          drug: drug,
          timeOnScreenMs: 3000,
          audioPlayed: false,
          language: 'en',
          showVisuals: true,
        ),
      ));

      expect(find.text(drug.questions[0].questionEn), findsOneWidget);
      
      // Submit correct answer
      final correctIndex = drug.questions[0].correctIndex;
      await tester.tap(find.text(drug.questions[0].optionsEn[correctIndex]));
      await tester.pumpAndSettle();

      // Progresses to next question
      expect(find.text(drug.questions[1].questionEn), findsOneWidget);
    });
  });
}
