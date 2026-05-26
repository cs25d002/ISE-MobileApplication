import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Vewha/main.dart';
import 'package:Vewha/Screens/Welcome/splash_screen.dart';
import 'package:Vewha/Screens/patient_view/patient_entry_screen.dart';
import 'package:Vewha/Screens/patient_view/medication_list_screen.dart';

void main() {
  group('Routing & Startup Bypass Tests', () {
    testWidgets('Clinician mode renders SplashScreen by default', (WidgetTester tester) async {
      // Avoid RenderFlex overflow on SplashScreen due to high logo dimensions (550px height) in 600px default test viewport
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // By default in test compilation, patient_mode/MODE is false/empty
      await tester.pumpWidget(const MyApp());
      
      // Verify that MyApp starts with SplashScreen
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(PatientEntryScreen), findsNothing);

      // Fast-forward the delayed splash screen redirect timer to prevent timersPending failure
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('PatientEntryScreen launches directly without Welcome/Login gate', (WidgetTester tester) async {
      // Pump PatientEntryScreen directly as the home screen to verify isolation
      await tester.pumpWidget(const MaterialApp(
        home: PatientEntryScreen(),
      ));

      // Verify that PatientEntryScreen is rendered and fully operational
      expect(find.byType(PatientEntryScreen), findsOneWidget);
      expect(find.text('Study Setup'), findsOneWidget);
      expect(find.text('Participant code'), findsOneWidget);
      expect(find.text('Select study instructions style'), findsOneWidget);

      // Verify that no Login or clinician screen or auth flow is loaded
      expect(find.text('Login'), findsNothing);
      expect(find.text('Sign Up'), findsNothing);
    });

    testWidgets('Route stack isolation: Patient Entry leads cleanly to Medication List', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: PatientEntryScreen(),
      ));

      // Enter participant code
      await tester.enterText(find.byType(TextField), 'P99');
      await tester.pump();

      // Launch Condition A (default)
      await tester.tap(find.text('Launch Study'));
      await tester.pumpAndSettle();

      // Verify that we navigated to the MedicationListScreen and are on Medication 1
      expect(find.byType(MedicationListScreen), findsOneWidget);
      expect(find.text('Medication 1 of 5'), findsOneWidget);
      expect(find.byType(PatientEntryScreen), findsNothing);
    });
  });
}
