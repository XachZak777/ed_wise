import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
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
              '1. Acceptance of Terms',
              '''By accessing and using EdWise, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to these Terms, please do not use our service.''',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '2. Use License',
              '''Permission is granted to temporarily use EdWise for personal, non-commercial educational purposes. This license does not include:
• Commercial use or resale
• Modification of the software
• Reverse engineering or decompilation
• Removing copyright or proprietary notations''',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '3. User Accounts',
              '''When you create an account, you agree to:
• Provide accurate and complete information
• Maintain the security of your password
• Accept responsibility for all activities under your account
• Notify us immediately of any unauthorized use''',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '4. User Content',
              '''You retain ownership of content you create. By posting content, you grant us:
• A license to store and display your content
• The right to use, modify, and distribute content for app functionality
• You are responsible for ensuring you have rights to post content''',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '5. Prohibited Uses',
              '''You agree not to:
• Use the service for illegal purposes
• Post harmful, offensive, or inappropriate content
• Attempt to gain unauthorized access
• Interfere with or disrupt the service
• Violate any applicable laws or regulations''',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '6. Termination',
              '''We reserve the right to:
• Terminate or suspend your account at any time
• Remove content that violates these Terms
• Take legal action for violations
You may delete your account at any time through Settings.''',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '7. Disclaimer',
              '''EdWise is provided "as is" without warranties. We do not guarantee:
• Uninterrupted or error-free service
• Accuracy of AI-generated content
• Suitability for specific educational purposes''',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '8. Limitation of Liability',
              '''To the maximum extent permitted by law, EdWise shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the service.''',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '9. Changes to Terms',
              '''We reserve the right to modify these Terms at any time. We will notify users of significant changes. Continued use after changes constitutes acceptance of new Terms.''',
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

