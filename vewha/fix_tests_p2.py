import os, re

def fix_widget_test():
    file = 'test/patient_view/widget_test.dart'
    if not os.path.exists(file): return
    with open(file, 'r', encoding='utf-8') as f:
        c = f.read()

    # Imports
    c = c.replace("import 'package:Vewha/data/prescriptions.dart';", "import 'package:Vewha/repositories/data_repository.dart';\nimport 'package:Vewha/repositories/localization_repository.dart';\nimport 'package:provider/provider.dart';")
    
    # Setup
    c = c.replace("void main() {", "void main() {\n  TestWidgetsFlutterBinding.ensureInitialized();\n  late DataRepository dataRepo;\n  late LocalizationRepository locRepo;")
    c = c.replace("setUpAll(() {", "setUpAll(() async {\n    PathProviderPlatform.instance = MockPathProviderPlatform();\n    dataRepo = DataRepository();\n    await dataRepo.init();\n    locRepo = LocalizationRepository();\n    await locRepo.init();\n    await locRepo.loadLanguage('en');\n  });")
    c = c.replace("PathProviderPlatform.instance = MockPathProviderPlatform();\n  });", "")

    # Fix properties
    c = c.replace("studyDrugs[0]", "dataRepo.studyDrugs[0]")
    c = c.replace("studyDrugs[1]", "dataRepo.studyDrugs[1]")
    c = c.replace("studyDrugs[3]", "dataRepo.studyDrugs[3]")

    c = c.replace("drug.name", "locRepo.getClinicalEntry(drug.nameKey)")
    c = c.replace("drug.dose", "locRepo.getClinicalEntry(drug.doseKey)")
    c = c.replace("drug.route", "locRepo.getClinicalEntry(drug.routeKey)")
    c = c.replace("drug.questions[0].questionEn", "locRepo.getClinicalEntry(drug.questions[0].questionKey)")
    c = c.replace("drug.questions[1].questionEn", "locRepo.getClinicalEntry(drug.questions[1].questionKey)")
    c = c.replace("drug.questions[0].optionsEn", "locRepo.getQuizStringList(drug.questions[0].optionsKey)")

    # Wrap widgets with MultiProvider. We replace `MaterialApp(` with `MultiProvider(providers: [Provider<DataRepository>.value(value: dataRepo), Provider<LocalizationRepository>.value(value: locRepo)], child: MaterialApp(`
    multi_provider_prefix = "MultiProvider(\n          providers: [\n            Provider<DataRepository>.value(value: dataRepo),\n            Provider<LocalizationRepository>.value(value: locRepo),\n          ],\n          child: "

    c = re.sub(r'await tester\.pumpWidget\((const )?MaterialApp\(', 
               lambda m: 'await tester.pumpWidget(' + multi_provider_prefix + 'MaterialApp(', 
               c)
    
    # Need to add matching parenthesis for each MultiProvider.
    # Because we added `MultiProvider(`, we need to change `));` to `)));`
    # We will just replace `));` with `)));` at the end of the line.
    c = re.sub(r'\)\);\n', r')));\n', c)

    # Some widgets are inside Scaffold without MaterialApp?
    # No, all widgets in widget_test use MaterialApp except maybe ProgressStepper which also uses MaterialApp.

    with open(file, 'w', encoding='utf-8') as f:
        f.write(c)


def fix_golden_test():
    file = 'test/patient_view/golden_test.dart'
    if not os.path.exists(file): return
    with open(file, 'r', encoding='utf-8') as f:
        c = f.read()

    # Imports
    c = c.replace("import 'package:Vewha/data/prescriptions.dart';", "import 'package:Vewha/repositories/data_repository.dart';\nimport 'package:Vewha/repositories/localization_repository.dart';\nimport 'package:provider/provider.dart';")
    
    # Setup
    c = c.replace("void main() {", "void main() {\n  TestWidgetsFlutterBinding.ensureInitialized();\n  late DataRepository dataRepo;\n  late LocalizationRepository locRepo;\n\n  setUpAll(() async {\n    dataRepo = DataRepository();\n    await dataRepo.init();\n    locRepo = LocalizationRepository();\n    await locRepo.init();\n    await locRepo.loadLanguage('en');\n  });")
    
    # Fix properties
    c = c.replace("studyDrugs[0]", "dataRepo.studyDrugs[0]")
    c = c.replace("studyDrugs[3]", "dataRepo.studyDrugs[3]")

    multi_provider_prefix = "MultiProvider(\n          providers: [\n            Provider<DataRepository>.value(value: dataRepo),\n            Provider<LocalizationRepository>.value(value: locRepo),\n          ],\n          child: "

    c = re.sub(r'await tester\.pumpWidget\((const )?MaterialApp\(', 
               lambda m: 'await tester.pumpWidget(' + multi_provider_prefix + 'MaterialApp(', 
               c)
    c = re.sub(r'\)\);\n', r')));\n', c)

    with open(file, 'w', encoding='utf-8') as f:
        f.write(c)


def fix_condition_split_test():
    file = 'test/patient_view/condition_split_test.dart'
    if not os.path.exists(file): return
    with open(file, 'r', encoding='utf-8') as f:
        c = f.read()

    # Imports
    c = c.replace("import 'package:Vewha/data/prescriptions.dart';", "import 'package:Vewha/repositories/data_repository.dart';\nimport 'package:Vewha/repositories/localization_repository.dart';\nimport 'package:provider/provider.dart';")
    
    # Setup
    c = c.replace("void main() {", "void main() {\n  TestWidgetsFlutterBinding.ensureInitialized();\n  late DataRepository dataRepo;\n  late LocalizationRepository locRepo;\n\n  setUpAll(() async {\n    dataRepo = DataRepository();\n    await dataRepo.init();\n    locRepo = LocalizationRepository();\n    await locRepo.init();\n    await locRepo.loadLanguage('en');\n  });")
    
    multi_provider_prefix = "MultiProvider(\n          providers: [\n            Provider<DataRepository>.value(value: dataRepo),\n            Provider<LocalizationRepository>.value(value: locRepo),\n          ],\n          child: "

    c = re.sub(r'await tester\.pumpWidget\((const )?MaterialApp\(', 
               lambda m: 'await tester.pumpWidget(' + multi_provider_prefix + 'MaterialApp(', 
               c)
    c = re.sub(r'\)\);\n', r')));\n', c)

    with open(file, 'w', encoding='utf-8') as f:
        f.write(c)


def fix_perf_test():
    file = 'test/patient_view/accessibility_and_perf_test.dart'
    if not os.path.exists(file): return
    with open(file, 'r', encoding='utf-8') as f:
        c = f.read()

    # Imports
    c = c.replace("import 'package:Vewha/data/prescriptions.dart';", "import 'package:Vewha/repositories/data_repository.dart';\nimport 'package:Vewha/repositories/localization_repository.dart';\nimport 'package:provider/provider.dart';")
    
    # Setup
    c = c.replace("void main() {", "void main() {\n  TestWidgetsFlutterBinding.ensureInitialized();\n  late DataRepository dataRepo;\n  late LocalizationRepository locRepo;\n\n  setUpAll(() async {\n    dataRepo = DataRepository();\n    await dataRepo.init();\n    locRepo = LocalizationRepository();\n    await locRepo.init();\n    await locRepo.loadLanguage('en');\n  });")

    c = c.replace("studyDrugs[0]", "dataRepo.studyDrugs[0]")
    
    multi_provider_prefix = "MultiProvider(\n          providers: [\n            Provider<DataRepository>.value(value: dataRepo),\n            Provider<LocalizationRepository>.value(value: locRepo),\n          ],\n          child: "

    c = re.sub(r'await tester\.pumpWidget\((const )?MaterialApp\(', 
               lambda m: 'await tester.pumpWidget(' + multi_provider_prefix + 'MaterialApp(', 
               c)
    c = re.sub(r'\)\);\n', r')));\n', c)

    with open(file, 'w', encoding='utf-8') as f:
        f.write(c)


fix_widget_test()
fix_golden_test()
fix_condition_split_test()
fix_perf_test()
