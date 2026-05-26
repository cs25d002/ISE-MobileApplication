// ignore_for_file: depend_on_referenced_packages, unnecessary_import, unused_import
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:Vewha/data/prescriptions.dart';
import 'package:Vewha/components/patient_view/anatomy_viewer.dart';
import 'package:Vewha/components/patient_view/audio_narration.dart';
import 'package:Vewha/components/patient_view/medication_card.dart';
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

  group('Condition A vs Condition B Split Tests', () {
    testWidgets('Condition A (Enhanced UI) MUST contain SVG, Audio, and Plain Language Explanation', (WidgetTester tester) async {
      setupMockChannels(tester);
      final drug = studyDrugs[0]; // Metformin
      
      await tester.pumpWidget(MaterialApp(
        home: MedicationDetailScreen(drug: drug),
      ));

      // 1. Verify anatomy SVG renders
      expect(find.byType(AnatomyViewer), findsOneWidget);

      // 2. Verify audio narration button renders
      expect(find.byType(AudioNarration), findsOneWidget);

      // 3. Verify plain language explanation content is shown
      expect(find.text('What this medicine is for'), findsOneWidget);
      expect(find.text('This medicine helps control the amount of sugar in your blood.'), findsOneWidget);
      expect(find.text('How to take it'), findsOneWidget);
      expect(find.text('Take one tablet twice a day. Always take it with your meals.'), findsOneWidget);
    });

    testWidgets('Condition B (Plain Clinical UI) MUST contain ONLY a plain text table with NO SVG, NO Audio, and NO enhanced UI', (WidgetTester tester) async {
      final drug = studyDrugs[0]; // Metformin
      
      await tester.pumpWidget(MaterialApp(
        home: PlainTextConditionScreen(drug: drug),
      ));

      // 1. Verify plain text table is rendered
      expect(find.byType(Table), findsOneWidget);
      expect(find.text('Medicine'), findsOneWidget);
      expect(find.text('Metformin 500mg'), findsOneWidget);

      // 2. Verify NO anatomy SVG is present
      expect(find.byType(AnatomyViewer), findsNothing);

      // 3. Verify NO audio narration button is present
      expect(find.byType(AudioNarration), findsNothing);

      // 4. Verify NO enhanced UI headings/texts are present
      expect(find.text('What this medicine is for'), findsNothing);
      expect(find.text('How to take it'), findsNothing);
      expect(find.text('Listen'), findsNothing);
    });
  });
}
