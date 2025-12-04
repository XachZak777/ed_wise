import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Helper class for testing BLoCs
class TestHelper {
  /// Creates a widget with BLoC provider for testing
  static Widget createTestWidget({
    required Widget child,
    List<BlocProvider>? blocProviders,
  }) {
    if (blocProviders == null || blocProviders.isEmpty) {
      return MaterialApp(home: child);
    }
    
    return MaterialApp(
      home: MultiBlocProvider(
        providers: blocProviders,
        child: child,
      ),
    );
  }

  /// Waits for all pending timers to complete
  static Future<void> waitForPendingTimers(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
  }
}

/// Mock user data for testing
class MockUserData {
  static const String testUserId = 'test_user_123';
  static const String testUserEmail = 'test@example.com';
  static const String testUserName = 'Test User';
  
  static Map<String, dynamic> toMap() {
    return {
      'uid': testUserId,
      'email': testUserEmail,
      'displayName': testUserName,
    };
  }
}

