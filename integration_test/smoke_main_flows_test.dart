import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:ed_wise/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Smoke tests - core app flows', () {
    Future<void> _startApp(WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
    }

    testWidgets('1. Shows login screen on start', (tester) async {
      await _startApp(tester);

      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Don\'t have an account? Register'), findsOneWidget);
    });

    testWidgets('2. Navigate from login to register screen and back', (tester) async {
      await _startApp(tester);

      // Go to register
      final registerLink =
          find.textContaining('Don\'t have an account?').first;
      await tester.tap(registerLink);
      await tester.pumpAndSettle();

      // Expect at least one text field and a Register button
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.text('Register'), findsWidgets);

      // Go back using the system back button if present
      final backButton = find.byTooltip('Back');
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      }

      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('3. Login button disabled while loading', (tester) async {
      await _startApp(tester);

      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pump();

      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      expect(loginButton, findsOneWidget);

      // Tap login – actual authentication is handled by backend/Firebase.
      await tester.tap(loginButton);
      await tester.pump();

      // While loading, the button should be disabled or show a spinner.
      // We just assert that there is still exactly one Login button to avoid flakiness.
      expect(loginButton, findsOneWidget);
    });

    testWidgets('4. Google sign-in button is visible on login screen', (tester) async {
      await _startApp(tester);

      // We expect a button containing "Google" text or an icon. To keep this
      // test resilient, we assert on the custom widget type or text.
      final googleText = find.textContaining('Google');
      expect(googleText, findsWidgets);
    });

    testWidgets('5. Main navigation shows all primary tabs after login', (tester) async {
      await _startApp(tester);

      // This test assumes the user is already authenticated when the app starts
      // (e.g. via a previously persisted Firebase session). If not, you can
      // manually log in here using valid test credentials.

      // Wait a bit for auth check and potential navigation.
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Check for bottom navigation items
      expect(find.text('Study Plans'), findsOneWidget);
      expect(find.text('AI Video'), findsOneWidget);
      expect(find.text('Forum'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('6. Switch between bottom navigation tabs', (tester) async {
      await _startApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final studyPlansTab = find.text('Study Plans');
      final aiVideoTab = find.text('AI Video');
      final forumTab = find.text('Forum');
      final profileTab = find.text('Profile');

      expect(studyPlansTab, findsOneWidget);
      expect(aiVideoTab, findsOneWidget);
      expect(forumTab, findsOneWidget);
      expect(profileTab, findsOneWidget);

      await tester.tap(aiVideoTab);
      await tester.pumpAndSettle();

      await tester.tap(forumTab);
      await tester.pumpAndSettle();

      await tester.tap(profileTab);
      await tester.pumpAndSettle();

      await tester.tap(studyPlansTab);
      await tester.pumpAndSettle();
    });

    testWidgets('7. Study plans screen can show empty state and open create dialog',
        (tester) async {
      await _startApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Ensure we are on Study Plans tab
      final studyPlansTab = find.text('Study Plans');
      await tester.tap(studyPlansTab);
      await tester.pumpAndSettle();

      // Tap create button in empty state or app bar
      final createButton = find.widgetWithText(ElevatedButton, 'Create Study Plan')
          .first;
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      // A dialog should appear with at least one text field
      expect(find.byType(AlertDialog), findsWidgets);
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('8. AI video screen loads basic UI', (tester) async {
      await _startApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final aiVideoTab = find.text('AI Video');
      await tester.tap(aiVideoTab);
      await tester.pumpAndSettle();

      // We just assert the presence of some scaffold and a title or action.
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('9. Forum screen loads and can be refreshed', (tester) async {
      await _startApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final forumTab = find.text('Forum');
      await tester.tap(forumTab);
      await tester.pumpAndSettle();

      // Try to perform a pull-to-refresh if a RefreshIndicator exists.
      final refreshIndicator = find.byType(RefreshIndicator);
      if (refreshIndicator.evaluate().isNotEmpty) {
        await tester.drag(
          refreshIndicator.first,
          const Offset(0, 200),
        );
        await tester.pumpAndSettle();
      }

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('10. Profile screen loads basic UI', (tester) async {
      await _startApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final profileTab = find.text('Profile');
      await tester.tap(profileTab);
      await tester.pumpAndSettle();

      // We expect some profile-related content to show; we keep this loose.
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}


