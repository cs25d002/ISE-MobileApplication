import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Vewha/Screens/Welcome/welcome_screen.dart';
import 'package:Vewha/Screens/Welcome/Login/login_screen.dart';
import 'package:Vewha/Screens/Welcome/Signup/signup_screen.dart';
import 'package:Vewha/Screens/Home/doc_provider.dart';

void main() {
  group('Clinician Flow Regression Tests', () {
    testWidgets('Verify WelcomeScreen renders clinician login/signup options', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: WelcomeScreen(),
      ));

      // Check WelcomeScreen branding and options
      expect(find.text('WELCOME TO VEWHA'), findsOneWidget);
      expect(find.text('LOGIN'), findsOneWidget);
      expect(find.text('SIGN UP'), findsOneWidget);
    });

    testWidgets('Verify LoginScreen form layout', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: LoginScreen(),
      ));

      // Checks for login components and inputs
      expect(find.text('LOGIN'), findsWidgets);
      expect(find.byType(TextField), findsNWidgets(2)); // Email and Password inputs
    });

    testWidgets('Verify SignupScreen form layout', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: SignUpScreen(),
      ));

      // Checks for signup components and inputs
      expect(find.text('SIGN UP'), findsWidgets);
      expect(find.byType(TextField), findsNWidgets(3)); // Name, Email, and Password inputs
    });

    testWidgets('Verify doc provider still initializes cleanly', (WidgetTester tester) async {
      final docProvider = DocIDProvider();
      expect(docProvider, isNotNull);
      // Verify initial state
      expect(docProvider.docID, isNull);
    });
  });
}
