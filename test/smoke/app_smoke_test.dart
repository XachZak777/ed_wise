import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ed_wise/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Smoke Tests', () {
    testWidgets('App starts without crashing', (WidgetTester tester) async {
      // This is a smoke test - just verify the app can start
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      // If we get here without exceptions, the app started successfully
      expect(find.byType(app.EdWiseApp), findsOneWidget);
    });

    testWidgets('App shows login screen initially', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      // Check for login screen elements
      expect(find.text('Login'), findsWidgets);
      expect(find.text('Register'), findsWidgets);
    });
  });
}

