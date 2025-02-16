import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PasswordPromptScreen extends StatefulWidget {
  const PasswordPromptScreen({super.key});

  @override
  State<PasswordPromptScreen> createState() => _PasswordPromptScreenState();
}

class _PasswordPromptScreenState extends State<PasswordPromptScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _setPassword() async {
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      Get.snackbar("Error", "Please fill in both fields");
      return;
    }

    if (password != confirm) {
      Get.snackbar("Error", "Passwords do not match");
      return;
    }

    try {
      EasyLoading.show(status: "Setting password...");
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        EasyLoading.dismiss();
        Get.snackbar("Error", "No user is currently signed in");
        return;
      }

      await user.updatePassword(password);
      await user.reload();

      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);

      await userDoc.set({
        'name': user.displayName ?? '',
        'email': user.email,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      EasyLoading.dismiss();
      Get.snackbar("Success", "Password set successfully");
      Get.offAllNamed(AppRoutes.userDashboard);
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();
      Get.snackbar("Failed", e.message ?? "An error occurred");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Set Your Password"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.offAllNamed(AppRoutes.login),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscure = !_obscure;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: _setPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Set Password",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Get.offAllNamed(AppRoutes.login),
              child: Text(
                "Back to Login",
                style: TextStyle(
                  color: Colors.brown.shade600,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
