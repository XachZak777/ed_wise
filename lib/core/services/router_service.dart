import 'dart:convert';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/study_plans/screens/study_plans_screen.dart';
import '../../features/ai_video/screens/ai_video_screen.dart';
import '../../features/forum/screens/forum_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/certificates_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/profile/screens/privacy_policy_screen.dart';
import '../../features/profile/screens/terms_of_service_screen.dart';
import '../../features/ai_agent/screens/ai_agent_screen.dart';
import '../../shared/widgets/main_navigation.dart';

class AppRouter {
  /// The initial location for the app router.
  static const String initialLocation = '/login';

  /// The route configuration used by the app.
  ///
  /// Keeping this list separate from the [GoRouter] instance makes it easier
  /// to inspect and test without relying on `GoRouter`'s internal API.
  static final List<RouteBase> routes = [
    // Auth Routes
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // Main App Routes
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainNavigation(),
      routes: [
        GoRoute(
          path: 'study-plans',
          builder: (context, state) => const StudyPlansScreen(),
        ),
        GoRoute(
          path: 'ai-video',
          builder: (context, state) => const AiVideoScreen(),
        ),
        GoRoute(
          path: 'forum',
          builder: (context, state) => const ForumScreen(),
        ),
        GoRoute(
          path: 'ai-agent',
          builder: (context, state) => const AiAgentScreen(),
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) => const ProfileScreen(),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) {
                final profileParam = state.uri.queryParameters['profile'];

                Map<String, dynamic>? initialProfile;
                if (profileParam != null && profileParam.isNotEmpty) {
                  try {
                    final decoded = jsonDecode(profileParam);
                    if (decoded is Map<String, dynamic>) {
                      initialProfile = decoded;
                    }
                  } catch (_) {
                    // If parsing fails, fall back to null so the screen can
                    // still be opened without crashing.
                    initialProfile = null;
                  }
                }

                return EditProfileScreen(
                  initialProfile: initialProfile,
                );
              },
            ),
            GoRoute(
              path: 'certificates',
              builder: (context, state) => const CertificatesScreen(),
            ),
          ],
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ];

  /// The shared [GoRouter] instance for the app.
  static final GoRouter router = GoRouter(
    initialLocation: initialLocation,
    routes: routes,
  );
}
