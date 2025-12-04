import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper functions for testing BLoCs
class BlocTestHelper {
  /// Creates a test description for a BLoC test
  static String testDescription(String blocName, String testCase) {
    return '$blocName: $testCase';
  }
  
  /// Common test patterns for BLoC loading states
  static void expectLoadingState(dynamic state) {
    expect(state.toString(), contains('Loading'));
  }
  
  /// Common test patterns for BLoC error states
  static void expectErrorState(dynamic state, String? expectedMessage) {
    expect(state.toString(), contains('Error'));
    if (expectedMessage != null) {
      expect(state.toString(), contains(expectedMessage));
    }
  }
}

