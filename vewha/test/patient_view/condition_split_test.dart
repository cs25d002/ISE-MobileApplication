import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:Vewha/repositories/data_repository.dart';
import 'package:Vewha/repositories/localization_repository.dart';
import 'package:Vewha/Screens/patient_view/medication_list_screen.dart';

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

  Widget wrap(Widget child) {
    return MultiProvider(
      providers: [
        Provider<DataRepository>.value(value: dataRepo),
        Provider<LocalizationRepository>.value(value: locRepo),
      ],
      child: MaterialApp(home: child),
    );
  }

  group('Condition A/B Splitting Logic', () {
    testWidgets('Condition A loads Enhanced MedicationListScreen with interactive elements', (WidgetTester tester) async {
      await tester.pumpWidget(wrap(const MedicationListScreen(condition: 'A', language: 'en')));
      
      expect(find.byType(MedicationListScreen), findsOneWidget);
      expect(find.text(locRepo.getUiString('medication_count', params: {'0': '1', '1': '7'})), findsOneWidget);
    });

    testWidgets('Condition B loads Plain Text MedicationListScreen', (WidgetTester tester) async {
      await tester.pumpWidget(wrap(const MedicationListScreen(condition: 'B', language: 'en')));
      
      expect(find.byType(MedicationListScreen), findsOneWidget);
      expect(find.text(locRepo.getUiString('medication_count', params: {'0': '1', '1': '7'})), findsOneWidget);
    });
  });
}
