import 'package:flutter_test/flutter_test.dart';
import 'package:Vewha/data/prescriptions.dart';
import 'package:Vewha/data/plain_language_map.dart';

void main() {
  group('Prescription Data & Localization Validation', () {
    test('Validate all 7 medications exist and are unique with multilingual detail fields', () {
      expect(studyDrugs.length, equals(7));

      final Set<String> drugIds = {};
      for (final drug in studyDrugs) {
        expect(drug.drugId.isNotEmpty, isTrue);
        expect(drug.name.isNotEmpty, isTrue);
        expect(drug.nameTe.isNotEmpty, isTrue);
        expect(drug.nameHi.isNotEmpty, isTrue);
        expect(drug.dose.isNotEmpty, isTrue);
        expect(drug.doseTe.isNotEmpty, isTrue);
        expect(drug.doseHi.isNotEmpty, isTrue);
        
        expect(drug.questions.length, greaterThan(0));
        for (final q in drug.questions) {
            expect(q.optionsEn.length, greaterThanOrEqualTo(2));
            expect(q.optionsTe.length, equals(q.optionsEn.length));
            expect(q.optionsHi.length, equals(q.optionsEn.length));
            expect(q.correctIndex, greaterThanOrEqualTo(0));
            expect(q.correctIndex, lessThan(q.optionsEn.length));
        }

        expect(drugIds.contains(drug.drugId), isFalse, reason: 'Duplicate drug ID detected: ${drug.drugId}');
        drugIds.add(drug.drugId);
      }
    });

    test('Validate complete translations for all 7 languages for all study drugs', () {
      for (final drug in studyDrugs) {
        final key = drug.plainLanguageKey;
        expect(plainLanguageMap.containsKey(key), isTrue, reason: 'Missing translation map for plainLanguageKey: $key');

        final entry = plainLanguageMap[key]!;
        
        expect(entry.containsKey('en'), isTrue);
        expect(entry.containsKey('te'), isTrue);
        expect(entry.containsKey('hi'), isTrue);
        expect(entry.containsKey('kn'), isTrue);
        expect(entry.containsKey('ta'), isTrue);
        expect(entry.containsKey('mr'), isTrue);
        expect(entry.containsKey('bn'), isTrue);
      }
    });
  });
}
