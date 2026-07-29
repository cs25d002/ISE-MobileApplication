// ignore_for_file: depend_on_referenced_packages, unnecessary_import
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:provider/provider.dart';

import 'package:Vewha/repositories/data_repository.dart';
import 'package:Vewha/repositories/localization_repository.dart';
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
import 'package:Vewha/data/plain_lang_entry.dart';
import 'package:Vewha/services/patient_tts_service.dart';
import 'package:Vewha/services/translation_service.dart';

class MockPathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '.';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DataRepository dataRepo;
  late LocalizationRepository locRepo;

  setUpAll(() async {
    PathProviderPlatform.instance = MockPathProviderPlatform();
    dataRepo = DataRepository();
    await dataRepo.init();
    locRepo = LocalizationRepository();
    await locRepo.init();
    await TranslationService().loadLanguage('en');
    await locRepo.loadLanguage('en');
  });

  tearDown(() async {
    await PatientTtsService().stop();
  });

  Widget wrap(Widget child) {
    return MultiProvider(
      providers: [
        Provider<DataRepository>.value(value: dataRepo),
        Provider<LocalizationRepository>.value(value: locRepo),
      ],
      child: MaterialApp(home: child),
    );
  }

  void setupMockChannels(WidgetTester tester) {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'speak') {
          tester.binding.defaultBinaryMessenger.handlePlatformMessage(
            'flutter_tts',
            const StandardMethodCodec().encodeMethodCall(
              const MethodCall('speak.onStart'),
            ),
            null,
          );
        } else if (methodCall.method == 'pause') {
          tester.binding.defaultBinaryMessenger.handlePlatformMessage(
            'flutter_tts',
            const StandardMethodCodec().encodeMethodCall(
              const MethodCall('speak.onPause'),
            ),
            null,
          );
        } else if (methodCall.method == 'stop') {
          tester.binding.defaultBinaryMessenger.handlePlatformMessage(
            'flutter_tts',
            const StandardMethodCodec().encodeMethodCall(
              const MethodCall('speak.onComplete'),
            ),
            null,
          );
        }
        return 1;
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

      expect(find.byType(ProgressStepper), findsOneWidget);
      expect(find.byType(GestureDetector), findsNWidgets(5));

      await tester.tap(find.byType(GestureDetector).at(2));
      await tester.pump();

      expect(tappedIndex, equals(2));
    });

    testWidgets('AnatomyViewer loads SVG schematically', (WidgetTester tester) async {
      setupMockChannels(tester);
      await tester.pumpWidget(wrap(const Scaffold(
        body: AnatomyViewer(bodySystem: 'BodySystem.respiratory'),
      )));
      expect(find.byType(AnatomyViewer), findsOneWidget);
    });

    testWidgets('MedicationCard renders prescription values', (WidgetTester tester) async {
      final drug = dataRepo.studyDrugs[0]; 
      await tester.pumpWidget(wrap(Scaffold(
        body: MedicationCard(drug: drug, language: 'en'),
      )));

      expect(find.text(locRepo.getClinicalEntry(drug.nameKey)), findsOneWidget);
      expect(find.text(locRepo.getClinicalEntry(drug.doseKey)), findsOneWidget);
      expect(find.text(locRepo.getClinicalEntry(drug.routeKey)), findsOneWidget);
    });

    testWidgets('AudioNarration renders play button and toggles state', (WidgetTester tester) async {
      setupMockChannels(tester);
      bool isPlaying = false;
      const dummyEntry = PlainLangEntry(
        whatItIsFor: 'Test Purpose',
        howToTake: 'Test Usage',
        audioText: 'Test Audio text',
        mechanismSteps: ['Step 1', 'Step 2'],
        pictograms: ['inhale'],
      );
      await tester.pumpWidget(wrap(Scaffold(
        body: AudioNarration(
          entry: dummyEntry,
          languageCode: 'en-IN',
          onPlayStateChanged: (p) => isPlaying = p,
        ),
      )));

      expect(find.text('Listen'), findsOneWidget);
      expect(find.byIcon(Icons.volume_up), findsOneWidget);

      await tester.tap(find.byType(AudioNarration));
      await tester.pumpAndSettle();

      expect(isPlaying, isTrue);
      
      await PatientTtsService().stop();
    });
  });

  group('Patient-View Screens Tests', () {
    testWidgets('PatientEntryScreen interactive options', (WidgetTester tester) async {
      await tester.pumpWidget(wrap(const PatientEntryScreen()));

      expect(find.text(locRepo.getUiString('study_setup')), findsOneWidget);
      expect(find.text(locRepo.getUiString('participant_code')), findsOneWidget);
      expect(find.text(locRepo.getUiString('pictures_voice')), findsOneWidget);
      expect(find.text(locRepo.getUiString('basic_text_table')), findsOneWidget);

      await tester.tap(find.text(locRepo.getUiString('basic_text_table')));
      await tester.pump();

      await tester.tap(find.text(locRepo.getUiString('launch_study')));
      await tester.pump();
      expect(find.text(locRepo.getUiString('enter_participant_code')), findsOneWidget);
    });

    testWidgets('MedicationListScreen disclosure list next/previous operations', (WidgetTester tester) async {
      await tester.pumpWidget(wrap(const MedicationListScreen(condition: 'A', language: 'en')));

      expect(find.text(locRepo.getUiString('medication_count', params: {'0': '1', '1': '7'})), findsOneWidget);
      expect(find.text(locRepo.getUiString('previous')), findsNothing);
      expect(find.text(locRepo.getUiString('next')), findsOneWidget);

      await tester.tap(find.text(locRepo.getUiString('next')));
      await tester.pump();

      expect(find.text(locRepo.getUiString('medication_count', params: {'0': '2', '1': '7'})), findsOneWidget);
      expect(find.text(locRepo.getUiString('previous')), findsOneWidget);
    });

    testWidgets('MedicationDetailScreen renders Enhancement View components', (WidgetTester tester) async {
      setupMockChannels(tester);
      final drug = dataRepo.studyDrugs[1]; 
      await tester.pumpWidget(wrap(TickerMode(
        enabled: false,
        child: MedicationDetailScreen(drug: drug, initialLanguage: 'en'),
      )));
      
      int pumps = 0;
      while (find.byType(CircularProgressIndicator).evaluate().isNotEmpty && pumps < 50) {
        await tester.pump(const Duration(milliseconds: 100));
        pumps++;
      }

      debugDumpApp();
      expect(find.byType(AnatomyViewer), findsOneWidget);
      expect(find.byType(AudioNarration), findsOneWidget);
      expect(find.byType(MedicationCard), findsOneWidget);
      expect(find.text('English'), findsWidgets);

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('తెలుగు').last);
      
      pumps = 0;
      while (find.byType(CircularProgressIndicator).evaluate().isNotEmpty && pumps < 50) {
        await tester.pump(const Duration(milliseconds: 100));
        pumps++;
      }
      
      expect(find.text('తెలుగు'), findsWidgets);

      // Cleanup to cancel pending timers
      await tester.pumpWidget(Container());
      await PatientTtsService().stop();
    });

    testWidgets('PlainTextConditionScreen renders simple data table', (WidgetTester tester) async {
      final drug = dataRepo.studyDrugs[3]; 
      await tester.pumpWidget(wrap(PlainTextConditionScreen(drug: drug, initialLanguage: 'en')));

      expect(find.byType(Table), findsOneWidget);
      expect(find.text(locRepo.getUiString('field')), findsOneWidget);
      expect(find.text(locRepo.getUiString('details')), findsOneWidget);
      expect(find.text(locRepo.getUiString('medicine')), findsOneWidget);
      expect(find.text(locRepo.getClinicalEntry(drug.nameKey)), findsOneWidget);
      expect(find.byType(AnatomyViewer), findsNothing); 
    });

    testWidgets('ComprehensionScreen progression flow', (WidgetTester tester) async {
      final drug = dataRepo.studyDrugs[0]; 
      StudyLogger().startSession('P22', 'A');
      await tester.pumpWidget(wrap(ComprehensionScreen(
        drug: drug,
        timeOnScreenMs: 3000,
        audioPlayed: false,
        language: 'en',
        showVisuals: true,
      )));

      expect(find.text(locRepo.getClinicalEntry(drug.questions[0].questionKey)), findsOneWidget);
      
      final correctIndex = drug.questions[0].correctIndex;
      final options = locRepo.getQuizStringList(drug.questions[0].optionsKey);
      await tester.tap(find.text(options[correctIndex]));
      await tester.pumpAndSettle();

      expect(find.text(locRepo.getClinicalEntry(drug.questions[1].questionKey)), findsOneWidget);
    });
  });
}
