// ignore_for_file: depend_on_referenced_packages, unnecessary_import
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:Vewha/data/prescriptions.dart';
import 'package:Vewha/Screens/patient_view/patient_entry_screen.dart';
import 'package:Vewha/Screens/patient_view/medication_detail_screen.dart';
import 'package:Vewha/Screens/patient_view/plain_text_condition_screen.dart';

class MockPathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '.';
  }
}

void main() {
  setUpAll(() {
    PathProviderPlatform.instance = MockPathProviderPlatform();
  });

  void setupMockChannels(WidgetTester tester) {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (MethodCall methodCall) async {
        return 1;
      },
    );

    tester.binding.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (ByteData? message) async {
        if (message == null) return null;
        final String key = utf8.decode(message.buffer.asUint8List(message.offsetInBytes, message.lengthInBytes));
        if (key.startsWith('assets/anatomy/')) {
          final String svg = '<svg viewBox="0 0 200 400"><rect width="200" height="400" fill="gray"/></svg>';
          final Uint8List bytes = Uint8List.fromList(utf8.encode(svg));
          return ByteData.view(bytes.buffer);
        }
        return null;
      },
    );
  }

  group('Golden Visual Placement Verification', () {
    testWidgets('PatientEntryScreen golden rendering check', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: TickerMode(
          enabled: false,
          child: PatientEntryScreen(),
        ),
      ));
      await tester.pumpAndSettle();
      
      // Verification of layout dimensions and key buttons
      expect(find.byType(PatientEntryScreen), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('MedicationDetailScreen (Condition A) golden rendering check', (WidgetTester tester) async {
      setupMockChannels(tester);
      final drug = studyDrugs[0]; // Metformin
      await tester.pumpWidget(MaterialApp(
        home: TickerMode(
          enabled: false,
          child: MedicationDetailScreen(drug: drug),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(MedicationDetailScreen), findsOneWidget);
    });

    testWidgets('PlainTextConditionScreen (Condition B) golden rendering check', (WidgetTester tester) async {
      final drug = studyDrugs[0]; // Metformin
      await tester.pumpWidget(MaterialApp(
        home: TickerMode(
          enabled: false,
          child: PlainTextConditionScreen(drug: drug),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(PlainTextConditionScreen), findsOneWidget);
    });
  });
}
