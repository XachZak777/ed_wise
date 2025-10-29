import 'package:flutter/material.dart';
import '../../features/study_plans/screens/study_plans_screen.dart';
import '../../features/ai_video/screens/ai_video_screen.dart';
import '../../features/forum/screens/forum_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.school_outlined,
      activeIcon: Icons.school,
      label: 'Study Plans',
      route: '/home/study-plans',
    ),
    NavigationItem(
      icon: Icons.video_library_outlined,
      activeIcon: Icons.video_library,
      label: 'AI Video',
      route: '/home/ai-video',
    ),
    NavigationItem(
      icon: Icons.forum_outlined,
      activeIcon: Icons.forum,
      label: 'Forum',
      route: '/home/forum',
    ),
    NavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
      route: '/home/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _navigationItems.map((item) {
          return Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => _getScreenForRoute(item.route),
                settings: settings,
              );
            },
          );
        }).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _navigationItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            activeIcon: Icon(item.activeIcon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }

  Widget _getScreenForRoute(String route) {
    switch (route) {
      case '/home/study-plans':
        return const StudyPlansScreen();
      case '/home/ai-video':
        return const AiVideoScreen();
      case '/home/forum':
        return const ForumScreen();
      case '/home/profile':
        return const ProfileScreen();
      default:
        return const StudyPlansScreen();
    }
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}

