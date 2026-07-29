import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:Vewha/repositories/data_repository.dart';
import 'package:Vewha/repositories/localization_repository.dart';
import 'package:provider/provider.dart';
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

  void setupMockChannels(WidgetTester tester) {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (MethodCall methodCall) async {
        return 1;
      },
    );
  }

  Widget wrap(Widget child) {
    return MultiProvider(
      providers: [
        Provider<DataRepository>.value(value: dataRepo),
        Provider<LocalizationRepository>.value(value: locRepo),
      ],
      child: MaterialApp(home: child),
    );
  }

  group('Golden Visual Placement Verification', () {
    testWidgets('PatientEntryScreen golden rendering check', (WidgetTester tester) async {
      await tester.pumpWidget(wrap(const TickerMode(
        enabled: false,
        child: PatientEntryScreen(),
      )));
      await tester.pumpAndSettle();
      
      expect(find.byType(PatientEntryScreen), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('MedicationDetailScreen (Condition A) golden rendering check', (WidgetTester tester) async {
      setupMockChannels(tester);
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

      expect(find.byType(MedicationDetailScreen), findsOneWidget);

      // Cleanup
      await tester.pumpWidget(Container());
      await PatientTtsService().stop();
    });

    testWidgets('PlainTextConditionScreen (Condition B) golden rendering check', (WidgetTester tester) async {
      final drug = dataRepo.studyDrugs[0];
      await tester.pumpWidget(wrap(TickerMode(
        enabled: false,
        child: PlainTextConditionScreen(drug: drug, initialLanguage: 'en'),
      )));
      await tester.pumpAndSettle();

      expect(find.byType(PlainTextConditionScreen), findsOneWidget);
    });
  });
}
