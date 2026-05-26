import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Architecture Isolation Tests', () {
    test('Patient layer must NOT import Firebase or clinician modules', () {
      final List<String> directoriesToScan = [
        'lib/screens/patient_view',
        'lib/components/patient_view',
        'lib/logging',
        'lib/data',
        'lib/i18n',
      ];

      // Clean single-line regex that covers all forbidden packages
      final RegExp forbiddenImportPattern = RegExp(
        r'''import\s+['"].*(firebase_auth|cloud_firestore|firebase_core|Screens/Home|Screens/Welcome|Services/auth|Services/database|chatbot).*''',
        caseSensitive: false,
      );

      int filesScanned = 0;

      for (final dirPath in directoriesToScan) {
        final dir = Directory(dirPath);
        if (!dir.existsSync()) continue;

        final files = dir.listSync(recursive: true);
        for (final file in files) {
          if (file is File && file.path.endsWith('.dart')) {
            filesScanned++;
            final content = file.readAsStringSync();
            final matches = forbiddenImportPattern.allMatches(content);
            
            if (matches.isNotEmpty) {
              final forbiddenImports = matches.map((m) => m.group(0)).toList();
              fail('Architecture Isolation Violation: File ${file.path} contains forbidden imports: $forbiddenImports');
            }
          }
        }
      }

      print('Architecture Isolation Passed: Scanned $filesScanned Dart files successfully.');
      expect(filesScanned, greaterThan(0));
    });
  });
}
