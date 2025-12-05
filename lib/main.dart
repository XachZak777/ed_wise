import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/auth/bloc/auth_event.dart';
import 'firebase_options.dart';
import 'core/services/router_service.dart';
import 'core/theme/app_theme.dart';
import 'core/services/env_service.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/profile/bloc/profile_bloc.dart';
import 'features/profile/bloc/certificate_bloc.dart';
import 'features/study_plans/bloc/study_plan_bloc.dart';
import 'features/ai_video/bloc/ai_video_bloc.dart';
import 'features/forum/bloc/forum_bloc.dart';
import 'features/ai_agent/bloc/ai_agent_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EnvService.initialize();

  // Initialize Firebase only if not already initialized
  // On Android, Firebase may auto-initialize if google-services.json exists
  try {
    // Check if Firebase is already initialized
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    // Handle duplicate-app error (Firebase may already be initialized on Android)
    final errorMessage = e.toString();
    
    // Check for duplicate-app error or if Firebase is already initialized
    if (errorMessage.contains('duplicate-app') || 
        errorMessage.contains('already exists') ||
        Firebase.apps.isNotEmpty) {
      // Firebase is already initialized (likely by Android auto-init)
      // This is fine, we can continue
      debugPrint('Firebase already initialized, continuing...');
    } else {
      // Real initialization error, re-throw
      debugPrint('Firebase initialization failed: $e');
      rethrow;
    }
  }

  runApp(const EdWiseApp());
}

class EdWiseApp extends StatelessWidget {
  const EdWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final bloc = AuthBloc();
            bloc.add(const AuthCheckRequested());
            return bloc;
          },
        ),
        BlocProvider(create: (_) => ProfileBloc()),
        BlocProvider(create: (_) => CertificateBloc()),
        BlocProvider(create: (_) => StudyPlanBloc()),
        BlocProvider(create: (_) => AiVideoBloc()),
        BlocProvider(create: (_) => ForumBloc()),
        BlocProvider(create: (_) => AiAgentBloc()),
      ],
      child: MaterialApp.router(
        title: 'EdWise',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}