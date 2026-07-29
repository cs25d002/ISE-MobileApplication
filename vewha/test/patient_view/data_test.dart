import 'package:flutter_test/flutter_test.dart';
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

  group('Prescription Data & Localization Validation', () {
    test('Validate all 7 medications exist and are unique with valid keys', () {
      expect(dataRepo.studyDrugs.length, equals(7));

      final Set<String> drugIds = {};
      for (final drug in dataRepo.studyDrugs) {
        expect(drug.drugId.isNotEmpty, isTrue);
        expect(drug.nameKey.isNotEmpty, isTrue);
        expect(drug.doseKey.isNotEmpty, isTrue);
        
        expect(drug.questions.length, greaterThan(0));
        for (final q in drug.questions) {
            expect(q.optionsKey.isNotEmpty, isTrue);
            expect(q.correctIndex, greaterThanOrEqualTo(0));
            expect(q.correctIndex, lessThan(3)); // we assume 3 options usually
        }

        expect(drugIds.contains(drug.drugId), isFalse, reason: 'Duplicate drug ID detected: ${drug.drugId}');
        drugIds.add(drug.drugId);
      }
    });
  });
}
