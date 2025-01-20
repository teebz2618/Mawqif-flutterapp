import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/app_user.dart';
import '../../../routes/app_routes.dart';

class SignInController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxBool rememberMe = false.obs;

  void signIn() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please fill in all fields");
      return;
    }

    try {
      // Show loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        Get.back(); // remove loading
        Get.snackbar("Error", "Sign-in failed. Try again.");
        return;
      }

      // Check if email is verified
      if (!user.emailVerified) {
        Get.back();
        Get.snackbar(
          "Email Not Verified",
          "Please verify your email before logging in.",
          backgroundColor: Colors.orange.shade100,
        );
        return;
      }

      // Get user data from Firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        Get.back();
        Get.snackbar("Error", "User record not found in Firestore");
        return;
      }

      final appUser = AppUser.fromMap(user.uid, doc.data()!);

      // Save credentials if remember me
      if (rememberMe.value) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('email', email);
        prefs.setString('password', password); // ⚠️ Use securely in production
      }

      Get.back(); // remove loading

      // Navigate based on role
      switch (appUser.role) {
        case 'admin':
          Get.offAllNamed(AppRoutes.adminDashboard);
          break;
        case 'brand':
          Get.offAllNamed(AppRoutes.brandDashboard);
          break;
        default:
          Get.offAllNamed(AppRoutes.userDashboard);
      }
    } on FirebaseAuthException catch (e) {
      Get.back();
      Get.snackbar(
        "Sign In Failed",
        e.message ?? "An error occurred",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
    } catch (e) {
      Get.back();
      Get.snackbar("Error", "Unexpected error occurred");
    }
  }

  Future<void> loadRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    emailController.text = prefs.getString('email') ?? '';
    passwordController.text = prefs.getString('password') ?? '';
  }

  @override
  void onInit() {
    super.onInit();
    loadRememberedCredentials();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
