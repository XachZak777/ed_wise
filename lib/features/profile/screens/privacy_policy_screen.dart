import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Last Updated: ${DateTime.now().year}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '1. Information We Collect',
              '''We collect information that you provide directly to us, including:
• Name and email address when you create an account
• Profile information and preferences
• Study plans and educational content you create
• Forum posts and comments
• Usage data and app interactions''',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '2. How We Use Your Information',
              '''We use the information we collect to:
• Provide, maintain, and improve our services
• Personalize your learning experience
• Communicate with you about your account and our services
• Analyze usage patterns and improve our app
• Ensure security and prevent fraud''',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '3. Data Storage and Security',
              '''We use Firebase services to store your data securely:
• Your data is encrypted in transit and at rest
• We follow industry best practices for data security
• Regular security audits and updates
• Access controls to protect your personal information''',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '4. Your Rights',
              '''You have the right to:
• Access your personal data
• Update or correct your information
• Delete your account and associated data
• Export your data
• Opt-out of certain data collection''',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '5. Third-Party Services',
              '''We use third-party services that may collect information:
• Firebase (Authentication, Firestore, Storage)
• Google Analytics (usage analytics)
• These services have their own privacy policies''',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '6. Contact Us',
              '''If you have questions about this Privacy Policy, please contact us at:
• Email: privacy@edwise.app
• Support: support@edwise.app''',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

