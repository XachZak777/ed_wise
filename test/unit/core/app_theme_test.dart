import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ed_wise/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('lightTheme uses light brightness and primary colors', () {
      final theme = AppTheme.lightTheme;

      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, AppTheme.primaryColor);
      expect(theme.colorScheme.secondary, AppTheme.secondaryColor);
      expect(theme.colorScheme.error, AppTheme.errorColor);
      expect(theme.colorScheme.surface, AppTheme.lightSurface);

      expect(
        theme.appBarTheme.backgroundColor,
        AppTheme.lightSurface,
      );
      expect(
        theme.bottomNavigationBarTheme.selectedItemColor,
        AppTheme.primaryColor,
      );
    });

    test('darkTheme uses dark brightness and background colors', () {
      final theme = AppTheme.darkTheme;

      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, AppTheme.primaryColor);
      expect(theme.colorScheme.secondary, AppTheme.secondaryColor);
      expect(theme.colorScheme.error, AppTheme.errorColor);
      expect(theme.colorScheme.surface, AppTheme.darkSurface);
      expect(theme.colorScheme.background, AppTheme.darkBackground);

      expect(
        theme.appBarTheme.backgroundColor,
        AppTheme.darkSurface,
      );
      expect(
        theme.bottomNavigationBarTheme.selectedItemColor,
        AppTheme.primaryColor,
      );
    });
  });
}



