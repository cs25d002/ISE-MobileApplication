import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:Vewha/repositories/data_repository.dart';
import 'package:Vewha/repositories/localization_repository.dart';
import 'package:Vewha/logging/study_logger.dart';
import 'package:Vewha/Screens/patient_view/comprehension_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DataRepository dataRepo;
  late LocalizationRepository locRepo;

  setUpAll(() async {
    dataRepo = DataRepository();
    await dataRepo.init();
    locRepo = LocalizationRepository();
    await locRepo.init();
    await locRepo.loadLanguage('en');
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

  group('Adaptive Comprehension Flow', () {
    testWidgets('Incorrect answer triggers recovery mode and displays explanation', (WidgetTester tester) async {
      setupMockChannels(tester);
      final drug = dataRepo.studyDrugs[0]; 
      StudyLogger().startSession('P33', 'B');

      await tester.pumpWidget(wrap(TickerMode(
        enabled: false,
        child: ComprehensionScreen(
          drug: drug,
          timeOnScreenMs: 3000,
          audioPlayed: false,
          language: 'en',
          showVisuals: true,
        ),
      )));

      expect(find.text(locRepo.getClinicalEntry(drug.questions[0].questionKey)), findsOneWidget);

      final incorrectIndex = (drug.questions[0].correctIndex + 1) % 3;
      final options = locRepo.getQuizStringList(drug.questions[0].optionsKey);
      
      await tester.tap(find.text(options[incorrectIndex]));
      await tester.pumpAndSettle();

      expect(find.text(locRepo.getUiString('lets_review_info')), findsOneWidget);
    });
  });
}
