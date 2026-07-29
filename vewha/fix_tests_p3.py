import os, re

def fix_widget_test():
    file = 'test/patient_view/widget_test.dart'
    if not os.path.exists(file): return
    with open(file, 'r', encoding='utf-8') as f:
        c = f.read()

    c = c.replace("import 'package:Vewha/data/prescriptions.dart';", "import 'package:Vewha/repositories/data_repository.dart';\nimport 'package:Vewha/repositories/localization_repository.dart';\nimport 'package:provider/provider.dart';")
    c = c.replace("void main() {", "void main() {\n  TestWidgetsFlutterBinding.ensureInitialized();\n  late DataRepository dataRepo;\n  late LocalizationRepository locRepo;")
    c = c.replace("setUpAll(() {", "setUpAll(() async {\n    PathProviderPlatform.instance = MockPathProviderPlatform();\n    dataRepo = DataRepository();\n    await dataRepo.init();\n    locRepo = LocalizationRepository();\n    await locRepo.init();\n    await locRepo.loadLanguage('en');\n  });")
    c = c.replace("PathProviderPlatform.instance = MockPathProviderPlatform();\n  });", "")

    c = c.replace("studyDrugs[0]", "dataRepo.studyDrugs[0]")
    c = c.replace("studyDrugs[1]", "dataRepo.studyDrugs[1]")
    c = c.replace("studyDrugs[3]", "dataRepo.studyDrugs[3]")
    c = c.replace("drug.name", "locRepo.getClinicalEntry(drug.nameKey)")
    c = c.replace("drug.dose", "locRepo.getClinicalEntry(drug.doseKey)")
    c = c.replace("drug.route", "locRepo.getClinicalEntry(drug.routeKey)")
    c = c.replace("drug.questions[0].questionEn", "locRepo.getClinicalEntry(drug.questions[0].questionKey)")
    c = c.replace("drug.questions[1].questionEn", "locRepo.getClinicalEntry(drug.questions[1].questionKey)")
    c = c.replace("drug.questions[0].optionsEn", "locRepo.getQuizStringList(drug.questions[0].optionsKey)")

    multi_provider_prefix = "MultiProvider(\n          providers: [\n            Provider<DataRepository>.value(value: dataRepo),\n            Provider<LocalizationRepository>.value(value: locRepo),\n          ],\n          child: "

    c = re.sub(r'await tester\.pumpWidget\((const )?MaterialApp\(', lambda m: 'await tester.pumpWidget(' + multi_provider_prefix + 'MaterialApp(', c)
    c = re.sub(r'(await tester\.pumpWidget.*)\)\);\n', r'\1)));\n', c)

    with open(file, 'w', encoding='utf-8') as f:
        f.write(c)


def fix_golden_test():
    file = 'test/patient_view/golden_test.dart'
    if not os.path.exists(file): return
    with open(file, 'r', encoding='utf-8') as f:
        c = f.read()

    c = c.replace("import 'package:Vewha/data/prescriptions.dart';", "import 'package:Vewha/repositories/data_repository.dart';\nimport 'package:Vewha/repositories/localization_repository.dart';\nimport 'package:provider/provider.dart';")
    c = c.replace("void main() {", "void main() {\n  TestWidgetsFlutterBinding.ensureInitialized();\n  late DataRepository dataRepo;\n  late LocalizationRepository locRepo;\n\n  setUpAll(() async {\n    dataRepo = DataRepository();\n    await dataRepo.init();\n    locRepo = LocalizationRepository();\n    await locRepo.init();\n    await locRepo.loadLanguage('en');\n  });")
    c = c.replace("studyDrugs[0]", "dataRepo.studyDrugs[0]")
    c = c.replace("studyDrugs[3]", "dataRepo.studyDrugs[3]")

    multi_provider_prefix = "MultiProvider(\n          providers: [\n            Provider<DataRepository>.value(value: dataRepo),\n            Provider<LocalizationRepository>.value(value: locRepo),\n          ],\n          child: "
    c = re.sub(r'await tester\.pumpWidget\((const )?MaterialApp\(', lambda m: 'await tester.pumpWidget(' + multi_provider_prefix + 'MaterialApp(', c)
    c = re.sub(r'(await tester\.pumpWidget.*)\)\);\n', r'\1)));\n', c)

    with open(file, 'w', encoding='utf-8') as f:
        f.write(c)


def fix_condition_split_test():
    file = 'test/patient_view/condition_split_test.dart'
    if not os.path.exists(file): return
    with open(file, 'r', encoding='utf-8') as f:
        c = f.read()

    c = c.replace("import 'package:Vewha/data/prescriptions.dart';", "import 'package:Vewha/repositories/data_repository.dart';\nimport 'package:Vewha/repositories/localization_repository.dart';\nimport 'package:provider/provider.dart';")
    c = c.replace("void main() {", "void main() {\n  TestWidgetsFlutterBinding.ensureInitialized();\n  late DataRepository dataRepo;\n  late LocalizationRepository locRepo;\n\n  setUpAll(() async {\n    dataRepo = DataRepository();\n    await dataRepo.init();\n    locRepo = LocalizationRepository();\n    await locRepo.init();\n    await locRepo.loadLanguage('en');\n  });")
    
    multi_provider_prefix = "MultiProvider(\n          providers: [\n            Provider<DataRepository>.value(value: dataRepo),\n            Provider<LocalizationRepository>.value(value: locRepo),\n          ],\n          child: "
    c = re.sub(r'await tester\.pumpWidget\((const )?MaterialApp\(', lambda m: 'await tester.pumpWidget(' + multi_provider_prefix + 'MaterialApp(', c)
    c = re.sub(r'(await tester\.pumpWidget.*)\)\);\n', r'\1)));\n', c)

    with open(file, 'w', encoding='utf-8') as f:
        f.write(c)


def fix_perf_test():
    file = 'test/patient_view/accessibility_and_perf_test.dart'
    if not os.path.exists(file): return
    with open(file, 'r', encoding='utf-8') as f:
        c = f.read()

    c = c.replace("import 'package:Vewha/data/prescriptions.dart';", "import 'package:Vewha/repositories/data_repository.dart';\nimport 'package:Vewha/repositories/localization_repository.dart';\nimport 'package:provider/provider.dart';")
    c = c.replace("void main() {", "void main() {\n  TestWidgetsFlutterBinding.ensureInitialized();\n  late DataRepository dataRepo;\n  late LocalizationRepository locRepo;\n\n  setUpAll(() async {\n    dataRepo = DataRepository();\n    await dataRepo.init();\n    locRepo = LocalizationRepository();\n    await locRepo.init();\n    await locRepo.loadLanguage('en');\n  });\n")
    c = c.replace("setUpAll(() {\n    PathProviderPlatform.instance = MockPathProviderPlatform();\n  });", "  setUpAll(() {\n    PathProviderPlatform.instance = MockPathProviderPlatform();\n  });")

    c = c.replace("studyDrugs[0]", "dataRepo.studyDrugs[0]")
    
    multi_provider_prefix = "MultiProvider(\n          providers: [\n            Provider<DataRepository>.value(value: dataRepo),\n            Provider<LocalizationRepository>.value(value: locRepo),\n          ],\n          child: "
    c = re.sub(r'await tester\.pumpWidget\((const )?MaterialApp\(', lambda m: 'await tester.pumpWidget(' + multi_provider_prefix + 'MaterialApp(', c)
    
    # In perf_test, there are some `));` inside the `ByteData` that get matched if we're not careful. Let's make sure we only replace `));` at the end of `await tester.pumpWidget` calls!
    # A safe regex:
    lines = c.split('\n')
    out = []
    in_pump = False
    for line in lines:
        if 'await tester.pumpWidget(' in line:
            in_pump = True
        if in_pump and line.strip().endswith('));'):
            line = line.replace('));', ')));')
            in_pump = False
        out.append(line)
    c = '\n'.join(out)
    
    # Fix the missing named parameter error in PlainTextConditionScreen and MedicationDetailScreen!
    c = c.replace("PlainTextConditionScreen(drug: drug)", "PlainTextConditionScreen(drug: drug, initialLanguage: 'en')")
    c = c.replace("MedicationDetailScreen(drug: drug)", "MedicationDetailScreen(drug: drug, initialLanguage: 'en')")

    with open(file, 'w', encoding='utf-8') as f:
        f.write(c)

def fix_routing_test():
    file = 'test/patient_view/routing_test.dart'
    if not os.path.exists(file): return
    with open(file, 'w', encoding='utf-8') as f:
        f.write('''import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:Vewha/main.dart';
import 'package:Vewha/Screens/Welcome/splash_screen.dart';
import 'package:Vewha/Screens/patient_view/patient_entry_screen.dart';
import 'package:Vewha/Screens/patient_view/medication_list_screen.dart';
import 'package:Vewha/repositories/data_repository.dart';
import 'package:Vewha/repositories/localization_repository.dart';

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

  group('Routing & Startup Bypass Tests', () {
    testWidgets('Clinician mode renders SplashScreen by default', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const MyApp());
      
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(PatientEntryScreen), findsNothing);

      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('PatientEntryScreen launches directly without Welcome/Login gate', (WidgetTester tester) async {
      await tester.pumpWidget(MultiProvider(
        providers: [
          Provider<DataRepository>.value(value: dataRepo),
          Provider<LocalizationRepository>.value(value: locRepo),
        ],
        child: const MaterialApp(home: PatientEntryScreen()),
      ));

      expect(find.byType(PatientEntryScreen), findsOneWidget);
      expect(find.text('Study Setup'), findsOneWidget);
      expect(find.text('Participant code'), findsOneWidget);
      expect(find.text('Select study instructions style'), findsOneWidget);

      expect(find.text('Login'), findsNothing);
      expect(find.text('Sign Up'), findsNothing);
    });

    testWidgets('Route stack isolation: Patient Entry leads cleanly to Medication List', (WidgetTester tester) async {
      await tester.pumpWidget(MultiProvider(
        providers: [
          Provider<DataRepository>.value(value: dataRepo),
          Provider<LocalizationRepository>.value(value: locRepo),
        ],
        child: const MaterialApp(home: PatientEntryScreen()),
      ));

      await tester.enterText(find.byType(TextField), 'P99');
      await tester.pump();

      await tester.tap(find.text('Launch Study'));
      await tester.pump(const Duration(milliseconds: 200)); 
      await tester.pumpAndSettle();

      expect(find.byType(MedicationListScreen), findsOneWidget);
      expect(find.text('Medication 1 of 7'), findsOneWidget);
      expect(find.byType(PatientEntryScreen), findsNothing);
    });
  });
}''')


fix_widget_test()
fix_golden_test()
fix_condition_split_test()
fix_perf_test()
fix_routing_test()
