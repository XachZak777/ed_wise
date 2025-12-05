import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ed_wise/main.dart' as app;

/// A simple robot/helper class to keep integration tests structured and readable.
///
/// This class encapsulates the common actions and finders used across
/// the integration tests so that each test focuses on describing a
/// user journey rather than low-level widget details.
class AppRobot {
  const AppRobot();

  /// Launches the full application using the real `main()` entrypoint.
  ///
  /// This ensures that Firebase, environment variables, routing and BLoCs
  /// are all wired exactly as in production.
  Future<void> launchApp(WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
  }

  // ---------------------------------------------------------------------------
  // Auth screen helpers
  // ---------------------------------------------------------------------------

  /// Email and password fields on the login screen.
  Finder get loginEmailField => find.byType(TextFormField).at(0);
  Finder get loginPasswordField => find.byType(TextFormField).at(1);

  /// Primary login button on the login screen.
  Finder get loginButton =>
      find.widgetWithText(ElevatedButton, 'Login');

  /// "Don't have an account? Register" link on the login screen.
  Finder get loginToRegisterLink =>
      find.text('Don\'t have an account? Register');

  /// Google sign-in button text.
  Finder get googleSignInText =>
      find.textContaining('Google');

  /// All form fields on the register screen.
  Finder get registerNameField => find.byType(TextFormField).at(0);
  Finder get registerEmailField => find.byType(TextFormField).at(1);
  Finder get registerPasswordField => find.byType(TextFormField).at(2);
  Finder get registerConfirmPasswordField => find.byType(TextFormField).at(3);

  /// Primary "Create Account" button on the register screen.
  Finder get registerCreateAccountButton =>
      find.widgetWithText(ElevatedButton, 'Create Account');

  /// "Already have an account? Login" link on the register screen.
  Finder get registerToLoginLink =>
      find.text('Already have an account? Login');

  /// Navigates from the login screen to the register screen.
  Future<void> goToRegisterFromLogin(WidgetTester tester) async {
    await tester.tap(loginToRegisterLink);
    await tester.pumpAndSettle();
  }

  /// Navigates from the register screen back to the login screen.
  Future<void> goToLoginFromRegister(WidgetTester tester) async {
    // Prefer the explicit "Already have an account? Login" link.
    if (registerToLoginLink.evaluate().isNotEmpty) {
      await tester.tap(registerToLoginLink);
    } else {
      // Fallback to the system back button if present.
      final backButton = find.byTooltip('Back');
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton.first);
      }
    }
    await tester.pumpAndSettle();
  }

  // ---------------------------------------------------------------------------
  // Main navigation helpers
  // ---------------------------------------------------------------------------

  Finder bottomNavTab(String label) => find.text(label);

  Future<void> switchToTab(WidgetTester tester, String label) async {
    final tab = bottomNavTab(label);
    expect(tab, findsOneWidget);
    await tester.tap(tab);
    await tester.pumpAndSettle();
  }
}


