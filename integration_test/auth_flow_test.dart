import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'app_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const robot = AppRobot();

  group('Authentication Flow', () {
    testWidgets('Login screen shows core elements on app start', (tester) async {
      await robot.launchApp(tester);

      // Basic structure
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));

      // Auth-specific actions
      expect(robot.loginButton, findsOneWidget);
      expect(robot.loginToRegisterLink, findsOneWidget);
      expect(robot.googleSignInText, findsWidgets);
    });

    testWidgets('User can navigate from login to register and back', (tester) async {
      await robot.launchApp(tester);

      // Go to register
      await robot.goToRegisterFromLogin(tester);

      // Register screen should have 4 fields and a primary action button
      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(robot.registerCreateAccountButton, findsOneWidget);
      expect(robot.registerToLoginLink, findsOneWidget);

      // Go back to login
      await robot.goToLoginFromRegister(tester);

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(robot.loginButton, findsOneWidget);
      expect(robot.loginToRegisterLink, findsOneWidget);
    });

    testWidgets('Submitting empty login form shows validation errors', (tester) async {
      await robot.launchApp(tester);

      await tester.tap(robot.loginButton);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('Submitting empty register form shows validation errors', (tester) async {
      await robot.launchApp(tester);
      await robot.goToRegisterFromLogin(tester);

      await tester.tap(robot.registerCreateAccountButton);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your full name'), findsOneWidget);
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
      expect(find.text('Please confirm your password'), findsOneWidget);
    });

    testWidgets('Google sign-in button is visible on login screen', (tester) async {
      await robot.launchApp(tester);

      expect(robot.googleSignInText, findsWidgets);
    });
  });
}

