import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/study_plans/screens/study_plans_screen.dart';
import '../../features/ai_video/screens/ai_video_screen.dart';
import '../../features/forum/screens/forum_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../shared/widgets/main_navigation.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
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
            path: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
}
