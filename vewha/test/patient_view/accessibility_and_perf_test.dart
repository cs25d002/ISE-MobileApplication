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
import 'package:Vewha/logging/performance_tracker.dart';
import 'package:Vewha/Screens/patient_view/patient_entry_screen.dart';
import 'package:Vewha/Screens/patient_view/medication_detail_screen.dart';
import 'package:Vewha/Screens/patient_view/plain_text_condition_screen.dart';
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

  group('UX Accessibility & Conditional Module Loading Tests', () {
    testWidgets('Trilingual Language Switcher translates setup screen', (WidgetTester tester) async {
      await tester.pumpWidget(wrap(const PatientEntryScreen()));

      expect(find.text(locRepo.getUiString('study_setup')), findsOneWidget);
      expect(find.text(locRepo.getUiString('launch_study')), findsOneWidget);

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('हिन्दी').last);
      await tester.pumpAndSettle();

      expect(find.text('अध्ययन सेटअप'), findsOneWidget);
      expect(find.text('अध्ययन शुरू करें'), findsOneWidget);
      expect(find.text('चित्र + आवाज़'), findsOneWidget);
    });

    testWidgets('Accessibility preview cards for Condition A vs B render with visual icons', (WidgetTester tester) async {
      await tester.pumpWidget(wrap(const PatientEntryScreen()));

      expect(find.byIcon(Icons.image), findsOneWidget);
      expect(find.byIcon(Icons.volume_up), findsOneWidget);
      expect(find.byIcon(Icons.description), findsOneWidget);
      expect(find.byIcon(Icons.table_chart), findsOneWidget);
    });

    testWidgets('STRICT CONDITIONAL LOADING: Condition B must NOT initialize TTS or SVG rendering', (WidgetTester tester) async {
      setupMockChannels(tester);
      PatientModuleRegistry.reset();

      expect(PatientModuleRegistry.isTtsInitialized, isFalse);
      expect(PatientModuleRegistry.isSvgInitialized, isFalse);

      final drug = dataRepo.studyDrugs[0]; 

      await tester.pumpWidget(wrap(PlainTextConditionScreen(drug: drug, initialLanguage: 'en')));
      await tester.pumpAndSettle();

      expect(PatientModuleRegistry.isTtsInitialized, isFalse);
      expect(PatientModuleRegistry.isSvgInitialized, isFalse);
    });

    testWidgets('STRICT CONDITIONAL LOADING: Condition A initializes TTS and SVG rendering correctly', (WidgetTester tester) async {
      setupMockChannels(tester);
      PatientModuleRegistry.reset();

      expect(PatientModuleRegistry.isTtsInitialized, isFalse);
      expect(PatientModuleRegistry.isSvgInitialized, isFalse);

      final drug = dataRepo.studyDrugs[0]; 

      await tester.pumpWidget(wrap(TickerMode(
        enabled: false,
        child: MedicationDetailScreen(drug: drug, initialLanguage: 'en'),
      )));
      
      int pumps = 0;
      while (find.byType(CircularProgressIndicator).evaluate().isNotEmpty && pumps < 50) {
        await tester.pump(const Duration(milliseconds: 100));
        pumps++;
      }

      expect(PatientModuleRegistry.isTtsInitialized, isTrue);
      expect(PatientModuleRegistry.isSvgInitialized, isTrue);

      // Cleanup to cancel pending timers
      await tester.pumpWidget(Container());
      await PatientTtsService().stop();
    });
  });
}
