import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: _PrivacyContent(),
      ),
    );
  }
}

class _PrivacyContent extends StatelessWidget {
  const _PrivacyContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('1. Introduction'),
        const SizedBox(height: 8),
        const Text(
          'Welcome to Mawqif. We value your privacy and strive to protect your personal information. This policy explains what data we collect, how it is used, and your rights.',
          style: TextStyle(height: 1.5),
        ),
        const SizedBox(height: 16),

        _buildHeader('2. Information We Collect'),
        const SizedBox(height: 8),
        const Text(
          'We collect information when you:\n'
          '- Register or create an account\n'
          '- Place orders or make payments\n'
          '- Interact with customer support\n'
          '- Subscribe to newsletters or promotional messages',
          style: TextStyle(height: 1.5),
        ),
        const SizedBox(height: 16),

        _buildHeader('3. Use of Information'),
        const SizedBox(height: 8),
        const Text(
          'We use your information to:\n'
          '- Process and fulfill orders\n'
          '- Send updates and marketing communication\n'
          '- Improve our services and personalize your experience\n'
          '- Protect against fraud and unauthorized activity',
          style: TextStyle(height: 1.5),
        ),
        const SizedBox(height: 16),

        _buildHeader('4. Sharing of Information'),
        const SizedBox(height: 8),
        const Text(
          'We do not sell your personal data to third parties. We may share data with:\n'
          '- Service providers (payment processors, delivery partners)\n'
          '- Legal authorities when required by law\n'
          '- Affiliates and business partners to provide services',
          style: TextStyle(height: 1.5),
        ),
        const SizedBox(height: 16),

        _buildHeader('5. Your Rights'),
        const SizedBox(height: 8),
        const Text(
          'You have the right to:\n'
          '- Access and update your personal information\n'
          '- Request deletion of your account\n'
          '- Opt out of promotional communication\n'
          '- Raise concerns via our customer support',
          style: TextStyle(height: 1.5),
        ),
        const SizedBox(height: 16),

        _buildHeader('6. Security'),
        const SizedBox(height: 8),
        const Text(
          'We implement industry-standard measures to secure your data, including encryption and secure servers. However, no method is 100% secure.',
          style: TextStyle(height: 1.5),
        ),
        const SizedBox(height: 16),

        _buildHeader('7. Changes to This Policy'),
        const SizedBox(height: 8),
        const Text(
          'We may update this policy from time to time. We will notify you of major changes via email or in-app notifications.',
          style: TextStyle(height: 1.5),
        ),
        const SizedBox(height: 16),

        _buildHeader('8. Contact Us'),
        const SizedBox(height: 8),
        const Text(
          'If you have any questions regarding this policy, please contact us at mawqif6@gmail.com.',
          style: TextStyle(height: 1.5),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildHeader(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Colors.brown.shade800,
      ),
    );
  }
}
