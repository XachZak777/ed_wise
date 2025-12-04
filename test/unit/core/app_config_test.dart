import 'package:flutter_test/flutter_test.dart';

import 'package:ed_wise/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    test('has expected mock configuration flags', () {
      expect(AppConfig.useMockAuth, isFalse);
      expect(AppConfig.useMockStudyPlans, isTrue);
      expect(AppConfig.useMockForum, isTrue);
      expect(AppConfig.useMockData, isFalse);
    });

    test('mockDataDelay remains a positive duration in milliseconds', () {
      expect(AppConfig.mockDataDelay, greaterThan(0));
      // Concrete value check so accidental changes are caught
      expect(AppConfig.mockDataDelay, 500);
    });
  });
}



