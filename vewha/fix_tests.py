import os, re

files = [
    'test/patient_view/widget_test.dart',
    'test/patient_view/golden_test.dart',
    'test/patient_view/condition_split_test.dart',
    'test/patient_view/accessibility_and_perf_test.dart'
]

for file in files:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Imports
    content = content.replace("import 'package:Vewha/data/prescriptions.dart';", 
        "import 'package:Vewha/repositories/data_repository.dart';\nimport 'package:Vewha/repositories/localization_repository.dart';\nimport 'package:provider/provider.dart';")

    # 2. Main setup
    if 'setUpAll(() {' in content:
        content = content.replace('setUpAll(() {', 
            'late DataRepository dataRepo;\n  late LocalizationRepository locRepo;\n\n  setUpAll(() async {\n    TestWidgetsFlutterBinding.ensureInitialized();\n    dataRepo = DataRepository();\n    await dataRepo.init();\n    locRepo = LocalizationRepository();\n    await locRepo.init();\n    locRepo.setLanguage("en");')
    else:
        content = content.replace('void main() {', 
            'void main() {\n  TestWidgetsFlutterBinding.ensureInitialized();\n  late DataRepository dataRepo;\n  late LocalizationRepository locRepo;\n\n  setUpAll(() async {\n    dataRepo = DataRepository();\n    await dataRepo.init();\n    locRepo = LocalizationRepository();\n    await locRepo.init();\n    locRepo.setLanguage("en");\n  });')

    # 3. Replace studyDrugs[X] with dataRepo.studyDrugs[X]
    content = re.sub(r'studyDrugs\[(\d+)\]', r'dataRepo.studyDrugs[\1]', content)

    # 4. Wrap widgets in MultiProvider (naive replace but effective for these files)
    content = re.sub(r'(home:\s*)(MedicationListScreen|PatientEntryScreen|MedicationDetailScreen|PlainTextConditionScreen|ComprehensionScreen|Scaffold|TickerMode)', 
        r'\1MultiProvider(\n            providers: [\n              Provider<DataRepository>.value(value: dataRepo),\n              Provider<LocalizationRepository>.value(value: locRepo),\n            ],\n            child: \2', content)

    # close MultiProvider parentheses - this regex matches the end of the widget constructor
    # Actually, simpler to just replace `));` at the end of tester.pumpWidget with `),);` if we matched MultiProvider, but `))` is used a lot.
    # Instead, we will fix tests if they fail or manually edit if needed.
    # We can just run flutter test and see what's broken.
    
    # 5. Fix property names
    content = content.replace('drug.name', 'locRepo.getClinicalEntry(drug.nameKey)')
    content = content.replace('drug.dose', 'locRepo.getClinicalEntry(drug.doseKey)')
    content = content.replace('drug.route', 'locRepo.getClinicalEntry(drug.routeKey)')
    content = content.replace('drug.frequency', 'locRepo.getClinicalEntry(drug.frequencyKey)')
    content = content.replace('drug.purpose', 'locRepo.getClinicalEntry(drug.purposeKey)')
    content = content.replace('.questionEn', '.questionKey') 
    content = content.replace('.optionsEn', '.optionsKey')

    with open(file, 'w', encoding='utf-8') as f:
        f.write(content)
