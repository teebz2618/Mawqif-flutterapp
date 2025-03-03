import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: Colors.brown,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: const Text("""Privacy Policy for Brands

At Mawqif, we value the privacy of our partner brands and are committed to protecting your data.

1. Information Collection:
We collect brand information such as company name, contact details, product catalog, and shipping/return policies when you register.

2. Use of Information:
We use your data to manage brand listings, process orders, and enhance platform performance. Your data will never be sold to third parties.

3. Data Storage:
All brand information is securely stored using Firebase services and protected against unauthorized access.

4. Communication:
We may send you updates about orders, product approvals, and policy changes via email or app notifications.

5. Your Rights:
You may request data updates or deletion at any time by contacting our support team.

6. Changes to Policy:
We may update this Privacy Policy periodically. Continued use of the platform means you accept these changes.

For any questions, contact: brands@mawqif.com
          """, style: TextStyle(fontSize: 16, height: 1.5)),
      ),
    );
  }
}
