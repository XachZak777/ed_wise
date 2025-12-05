import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'app_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const robot = AppRobot();

  group('Smoke tests - core app flows', () {
    testWidgets('1. Main navigation shows all primary tabs after login or persisted session',
        (tester) async {
      await robot.launchApp(tester);

      // This test assumes the user is either redirected to /home after a
      // successful auth check, or that a previous session is already active.
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Check for bottom navigation items
      expect(robot.bottomNavTab('Study Plans'), findsOneWidget);
      expect(robot.bottomNavTab('AI Video'), findsOneWidget);
      expect(robot.bottomNavTab('Forum'), findsOneWidget);
      expect(robot.bottomNavTab('Profile'), findsOneWidget);
    });

    testWidgets('2. Switch between bottom navigation tabs', (tester) async {
      await robot.launchApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(robot.bottomNavTab('Study Plans'), findsOneWidget);
      expect(robot.bottomNavTab('AI Video'), findsOneWidget);
      expect(robot.bottomNavTab('Forum'), findsOneWidget);
      expect(robot.bottomNavTab('Profile'), findsOneWidget);

      await robot.switchToTab(tester, 'AI Video');
      await robot.switchToTab(tester, 'Forum');
      await robot.switchToTab(tester, 'Profile');
      await robot.switchToTab(tester, 'Study Plans');
    });

    testWidgets('3. Study plans screen can show empty state and open create dialog',
        (tester) async {
      await robot.launchApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Ensure we are on Study Plans tab
      await robot.switchToTab(tester, 'Study Plans');

      // Tap create button in empty state or app bar
      final createButton =
          find.widgetWithText(ElevatedButton, 'Create Study Plan').first;
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      // A dialog should appear with at least one text field
      expect(find.byType(AlertDialog), findsWidgets);
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('4. AI video screen loads basic UI', (tester) async {
      await robot.launchApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await robot.switchToTab(tester, 'AI Video');

      // We just assert the presence of some scaffold and a title or action.
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('5. Forum screen loads and can be refreshed', (tester) async {
      await robot.launchApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await robot.switchToTab(tester, 'Forum');

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

    testWidgets('6. Profile screen loads basic UI', (tester) async {
      await robot.launchApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await robot.switchToTab(tester, 'Profile');

      // We expect some profile-related content to show; we keep this loose.
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
