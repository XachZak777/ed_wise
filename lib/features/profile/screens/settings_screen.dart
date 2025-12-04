import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:io';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/repositories/auth_repository.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';
import '../widgets/change_password_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'en';
  bool _dataUsageEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Try to load from Firebase first
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final authRepo = AuthRepository.instance;
        final profile = await authRepo.getUserProfile(user.uid);
        if (profile != null && profile['preferences'] != null) {
          final preferences = profile['preferences'] as Map<String, dynamic>;
          setState(() {
            _notificationsEnabled = preferences['notifications'] ?? prefs.getBool('notifications_enabled') ?? true;
            _emailNotifications = preferences['emailNotifications'] ?? prefs.getBool('email_notifications') ?? true;
            _pushNotifications = preferences['pushNotifications'] ?? prefs.getBool('push_notifications') ?? true;
            _darkModeEnabled = preferences['darkMode'] ?? prefs.getBool('dark_mode_enabled') ?? false;
            _selectedLanguage = preferences['language'] ?? prefs.getString('selected_language') ?? 'en';
            _dataUsageEnabled = preferences['dataUsage'] ?? prefs.getBool('data_usage_enabled') ?? true;
          });
          // Sync to local storage
          await prefs.setBool('notifications_enabled', _notificationsEnabled);
          await prefs.setBool('email_notifications', _emailNotifications);
          await prefs.setBool('push_notifications', _pushNotifications);
          await prefs.setBool('dark_mode_enabled', _darkModeEnabled);
          await prefs.setString('selected_language', _selectedLanguage);
          await prefs.setBool('data_usage_enabled', _dataUsageEnabled);
          return;
        }
      } catch (e) {
        debugPrint('Failed to load settings from Firebase: $e');
      }
    }
    
    // Fallback to local storage
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _emailNotifications = prefs.getBool('email_notifications') ?? true;
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
      _selectedLanguage = prefs.getString('selected_language') ?? 'en';
      _dataUsageEnabled = prefs.getBool('data_usage_enabled') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('email_notifications', _emailNotifications);
    await prefs.setBool('push_notifications', _pushNotifications);
    await prefs.setBool('dark_mode_enabled', _darkModeEnabled);
    await prefs.setString('selected_language', _selectedLanguage);
    await prefs.setBool('data_usage_enabled', _dataUsageEnabled);
    await _syncSettingsToFirebase();
  }

  Future<void> _syncSettingsToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final authRepo = AuthRepository.instance;
      await authRepo.updateUserProfile(user.uid, {
        'preferences': {
          'notifications': _notificationsEnabled,
          'emailNotifications': _emailNotifications,
          'pushNotifications': _pushNotifications,
          'darkMode': _darkModeEnabled,
          'language': _selectedLanguage,
          'dataUsage': _dataUsageEnabled,
        },
      });
    } catch (e) {
      // Silently fail - settings are still saved locally
      debugPrint('Failed to sync settings to Firebase: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          // Notifications Section
          _buildSectionHeader('Notifications'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  subtitle: const Text('Receive notifications about your activities'),
                  value: _notificationsEnabled,
                  onChanged: (value) async {
                    setState(() {
                      _notificationsEnabled = value;
                      if (!value) {
                        _emailNotifications = false;
                        _pushNotifications = false;
                      }
                    });
                    await _saveSettings();
                  },
                ),
                if (_notificationsEnabled) ...[
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Email Notifications'),
                    subtitle: const Text('Receive updates via email'),
                    value: _emailNotifications,
                  onChanged: (value) async {
                    setState(() {
                      _emailNotifications = value;
                    });
                    await _saveSettings();
                  },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Push Notifications'),
                    subtitle: const Text('Receive push notifications on your device'),
                    value: _pushNotifications,
                  onChanged: (value) async {
                    setState(() {
                      _pushNotifications = value;
                    });
                    await _saveSettings();
                  },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Appearance Section
          _buildSectionHeader('Appearance'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Use dark theme'),
                  value: _darkModeEnabled,
                  onChanged: (value) async {
                    setState(() {
                      _darkModeEnabled = value;
                    });
                    await _saveSettings();
                    await _syncSettingsToFirebase();
                    // Show message that app restart may be needed for full theme change
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value 
                              ? 'Dark mode enabled. App will use system theme or restart to see full changes.'
                              : 'Light mode enabled. App will use system theme or restart to see full changes.',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Language'),
                  subtitle: Text(_getLanguageName(_selectedLanguage)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showLanguageDialog(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Privacy Section
          _buildSectionHeader('Privacy'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Privacy Policy'),
                  leading: const Icon(Icons.privacy_tip),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Terms of Service'),
                  leading: const Icon(Icons.description),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsOfServiceScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Data Usage'),
                  subtitle: const Text('Allow data usage for better experience'),
                  value: _dataUsageEnabled,
                  onChanged: (value) async {
                    setState(() {
                      _dataUsageEnabled = value;
                    });
                    await _saveSettings();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Account Section
          _buildSectionHeader('Account'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Change Password'),
                  leading: const Icon(Icons.lock),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ChangePasswordDialog(),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Export Data'),
                  leading: const Icon(Icons.download),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _handleExportData(),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Delete Account'),
                  leading: const Icon(Icons.delete, color: AppTheme.errorColor),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  textColor: AppTheme.errorColor,
                  onTap: () => _showDeleteAccountDialog(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader('About'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('App Version'),
                  subtitle: Text('Version ${AppConstants.appVersion}'),
                  leading: const Icon(Icons.info),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('About EdWise'),
                  leading: const Icon(Icons.help_outline),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showAboutDialog(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      default:
        return 'English';
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                _saveSettings();
                _syncSettingsToFirebase();
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('Español'),
              value: 'es',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                _saveSettings();
                _syncSettingsToFirebase();
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('Français'),
              value: 'fr',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                _saveSettings();
                _syncSettingsToFirebase();
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('Deutsch'),
              value: 'de',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                _saveSettings();
                _syncSettingsToFirebase();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleDeleteAccount();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExportData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to export data'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exporting your data...'),
          duration: Duration(seconds: 2),
        ),
      );

      // Get user profile
      final authRepo = AuthRepository.instance;
      final profile = await authRepo.getUserProfile(user.uid);

      // Get user's study plans, forum posts, etc.
      final firestore = FirebaseFirestore.instance;
      final studyPlansSnapshot = await firestore
          .collection(AppConstants.studyPlansCollection)
          .where('userId', isEqualTo: user.uid)
          .get();
      
      final forumPostsSnapshot = await firestore
          .collection(AppConstants.forumPostsCollection)
          .where('userId', isEqualTo: user.uid)
          .get();

      // Compile export data
      final exportData = {
        'exportDate': DateTime.now().toIso8601String(),
        'userProfile': profile,
        'studyPlans': studyPlansSnapshot.docs.map((doc) => doc.data()).toList(),
        'forumPosts': forumPostsSnapshot.docs.map((doc) => doc.data()).toList(),
      };

      // Request storage permission
      if (Platform.isAndroid || Platform.isIOS) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          throw Exception('Storage permission denied');
        }
      }

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/edwise_export_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonEncode(exportData));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data exported successfully!\nLocation: ${file.path}'),
            backgroundColor: AppTheme.successColor,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deleting account...'),
          duration: Duration(seconds: 2),
        ),
      );

      // Delete user data from Firestore
      final firestore = FirebaseFirestore.instance;
      
      // Delete user profile
      await firestore.collection(AppConstants.usersCollection).doc(user.uid).delete();

      // Delete user's study plans
      final studyPlansSnapshot = await firestore
          .collection(AppConstants.studyPlansCollection)
          .where('userId', isEqualTo: user.uid)
          .get();
      for (var doc in studyPlansSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete user's forum posts
      final forumPostsSnapshot = await firestore
          .collection(AppConstants.forumPostsCollection)
          .where('userId', isEqualTo: user.uid)
          .get();
      for (var doc in forumPostsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete user's comments
      final commentsSnapshot = await firestore
          .collection(AppConstants.forumCommentsCollection)
          .where('userId', isEqualTo: user.uid)
          .get();
      for (var doc in commentsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete Firebase Auth user
      await user.delete();

      // Sign out
      if (mounted) {
        context.read<AuthBloc>().add(const AuthSignOutRequested());
        context.go('/login');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
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
            const SizedBox(height: 16),
            const Text(
              'EdWise is your educational companion for creating study plans, generating AI videos, and connecting with fellow learners.',
            ),
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
}

