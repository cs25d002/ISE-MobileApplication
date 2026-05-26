import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Vewha/Screens/patient_view/comprehension_screen.dart';
import 'package:Vewha/data/prescriptions.dart';

void main() {
  group('Adaptive Comprehension Flow', () {
    testWidgets('Incorrect answer triggers recovery mode and displays explanation', (WidgetTester tester) async {
      final drug = studyDrugs[0]; // Metformin
      
      await tester.pumpWidget(MaterialApp(
        home: ComprehensionScreen(
          drug: drug,
          timeOnScreenMs: 5000,
          audioPlayed: false,
          language: 'en',
          showVisuals: true,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 50));

      // Initially no recovery mode info
      expect(find.text('Let\'s review the information:'), findsNothing);

      // Tap the wrong option (assuming option 0 is correct, tap option 1)
      final wrongOption = drug.questions[0].correctIndex == 0 ? 1 : 0;
      await tester.tap(find.text(drug.questions[0].optionsEn[wrongOption]));
      
      // Use pump instead of pumpAndSettle due to infinite animation
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Recovery mode should be active
      expect(find.text('Let\'s review the information:'), findsOneWidget);
      expect(find.text(drug.purpose), findsOneWidget);
    });

    testWidgets('Correct answer progresses to next question', (WidgetTester tester) async {
      final drug = studyDrugs[0];
      
      await tester.pumpWidget(MaterialApp(
        home: ComprehensionScreen(
          drug: drug,
          timeOnScreenMs: 5000,
          audioPlayed: false,
          language: 'en',
          showVisuals: false,
        ),
      ));

      final firstQ = drug.questions[0].questionEn;
      expect(find.text(firstQ), findsOneWidget);

      final correctIndex = drug.questions[0].correctIndex;
      await tester.tap(find.text(drug.questions[0].optionsEn[correctIndex]));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should move to the second question
      final secondQ = drug.questions[1].questionEn;
      expect(find.text(secondQ), findsOneWidget);
      
      // No recovery mode info
      expect(find.text('Let\'s review the information:'), findsNothing);
    });
  });
}
