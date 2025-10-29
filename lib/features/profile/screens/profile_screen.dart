import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileProvider _provider = ProfileProvider();
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final profile = await _provider.getUserProfile(user.uid);
      setState(() {
        _userProfile = profile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view your profile'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: _showSettingsDialog,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            // Profile Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Text(
                        user.displayName?.isNotEmpty == true 
                            ? user.displayName![0].toUpperCase()
                            : user.email![0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.displayName ?? 'User',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _showEditProfileDialog,
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Study Statistics
            if (_userProfile != null) ...[
              _buildStatsSection(context),
              const SizedBox(height: 24),
            ],

            // Quick Actions
            _buildQuickActionsSection(context),
            const SizedBox(height: 24),

            // Settings
            _buildSettingsSection(context),
            const SizedBox(height: 24),

            // Sign Out
            Card(
              child: ListTile(
                leading: const Icon(Icons.logout, color: AppTheme.errorColor),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(color: AppTheme.errorColor),
                ),
                onTap: _showSignOutConfirmation,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final stats = _userProfile?['studyStats'] ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Study Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total Study Time',
                    '${stats['totalStudyTime'] ?? 0} min',
                    Icons.timer,
                    AppTheme.primaryColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Completed Tasks',
                    '${stats['completedTasks'] ?? 0}',
                    Icons.check_circle,
                    AppTheme.successColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Active Plans',
                    '${stats['activePlans'] ?? 0}',
                    Icons.school,
                    AppTheme.warningColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Forum Posts',
                    '${stats['forumPosts'] ?? 0}',
                    Icons.forum,
                    AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionTile(
              context,
              'Create Study Plan',
              'Start a new study plan',
              Icons.add_circle_outline,
              () => context.go('/home/study-plans'),
            ),
            _buildActionTile(
              context,
              'Generate AI Video',
              'Create educational content',
              Icons.video_call,
              () => context.go('/home/ai-video'),
            ),
            _buildActionTile(
              context,
              'Browse Forum',
              'Join discussions',
              Icons.forum,
              () => context.go('/home/forum'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingsTile(
              context,
              'Notifications',
              'Manage notification preferences',
              Icons.notifications,
              () => _showNotificationSettings(),
            ),
            _buildSettingsTile(
              context,
              'Privacy',
              'Control your privacy settings',
              Icons.privacy_tip,
              () => _showPrivacySettings(),
            ),
            _buildSettingsTile(
              context,
              'About',
              'App version and information',
              Icons.info,
              () => _showAboutDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showEditProfileDialog() {
    // TODO: Implement edit profile dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit profile coming soon')),
    );
  }

  void _showSettingsDialog() {
    // TODO: Implement settings dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings coming soon')),
    );
  }

  void _showNotificationSettings() {
    // TODO: Implement notification settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification settings coming soon')),
    );
  }

  void _showPrivacySettings() {
    // TODO: Implement privacy settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy settings coming soon')),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About EdWise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: ${AppConstants.appVersion}'),
            const SizedBox(height: 8),
            const Text('EdWise is your educational companion for creating study plans, generating AI videos, and connecting with fellow learners.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSignOutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _provider.signOut();
              if (mounted) {
                context.go('/login');
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
