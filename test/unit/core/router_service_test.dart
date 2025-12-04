import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ed_wise/core/services/router_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppRouter', () {
    test('has expected initial location', () {
      expect(AppRouter.router.configuration.initialLocation, '/login');
    });

    test('contains core top-level routes', () {
      final routes =
          AppRouter.router.configuration.routes.whereType<GoRoute>().toList();
      final paths = routes.map((r) => r.path).toList();

      expect(paths, contains('/login'));
      expect(paths, contains('/register'));
      expect(paths, contains('/home'));
    });

    test('home route exposes expected nested routes', () {
      final routes =
          AppRouter.router.configuration.routes.whereType<GoRoute>().toList();
      final homeRoute = routes.firstWhere(
        (route) => route.path == '/home',
      );

      final nestedPaths = homeRoute.routes
          .whereType<GoRoute>()
          .map((route) => route.path)
          .toList();

      expect(nestedPaths, contains('study-plans'));
      expect(nestedPaths, contains('ai-video'));
      expect(nestedPaths, contains('forum'));
      expect(nestedPaths, contains('ai-agent'));
      expect(nestedPaths, contains('profile'));
      expect(nestedPaths, contains('settings'));
    });
  });
}




