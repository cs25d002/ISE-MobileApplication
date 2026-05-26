import 'package:flutter_test/flutter_test.dart';
import 'package:Vewha/data/prescriptions.dart';
import 'package:Vewha/data/plain_language_map.dart';

void main() {
  group('Prescription Data & Localization Validation', () {
    test('Validate all 5 medications exist and are unique with trilingual detail fields', () {
      expect(studyDrugs.length, equals(5));

      final Set<String> drugIds = {};
      for (final drug in studyDrugs) {
        expect(drug.drugId.isNotEmpty, isTrue);
        expect(drug.name.isNotEmpty, isTrue);
        expect(drug.nameTe.isNotEmpty, isTrue);
        expect(drug.nameHi.isNotEmpty, isTrue);
        expect(drug.dose.isNotEmpty, isTrue);
        expect(drug.doseTe.isNotEmpty, isTrue);
        expect(drug.doseHi.isNotEmpty, isTrue);
        
        expect(drug.questions.length, equals(6));
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

    test('Validate complete English, Telugu, and Hindi translations for all study drugs', () {
      for (final drug in studyDrugs) {
        final key = drug.plainLanguageKey;
        expect(plainLanguageMap.containsKey(key), isTrue, reason: 'Missing translation map for plainLanguageKey: $key');

        final entry = plainLanguageMap[key]!;
        
        expect(entry.containsKey('en'), isTrue);
        expect(entry.containsKey('te'), isTrue);
        expect(entry.containsKey('hi'), isTrue);
      }
    });
  });
}
