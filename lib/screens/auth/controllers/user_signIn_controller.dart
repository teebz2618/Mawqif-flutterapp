import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawqif/models/brand_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../models/app_user.dart';
import '../../../routes/app_routes.dart';

class SignInController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final obscurePassword = true.obs;
  final rememberMe = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  void signIn() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please fill in all fields");
      return;
    }

    EasyLoading.show(status: "Signing in...");
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // Admin
      final adminDoc = await _firestore.collection('admin').doc(uid).get();
      if (adminDoc.exists) {
        await _saveUserData(uid, 'admin', email, password);
        Get.offAllNamed(AppRoutes.adminDashboard);
        return;
      }

      // Brand
      final brandDoc = await _firestore.collection('brands').doc(uid).get();
      if (brandDoc.exists) {
        final brandUser = BrandUser.fromMap(uid, brandDoc.data()!);

        if (brandUser.status == 'pending' || brandUser.status == 'rejected') {
          await _clearPrefs();
          Get.offAllNamed(
            brandUser.status == 'pending'
                ? AppRoutes.brandPending
                : AppRoutes.brandReject,
            arguments: brandUser.rejectionReason,
          );
          return;
        }

        if (brandUser.logoUrl == null || brandUser.logoUrl!.isEmpty) {
          await _clearPrefs();
          Get.offAllNamed(AppRoutes.logoUpload);
          return;
        }

        await _saveUserData(uid, 'brand', email, password);
        Get.offAllNamed(AppRoutes.brandDashboard);
        return;
      }

      // User
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        EasyLoading.dismiss();
        Get.snackbar("Error", "User record not found");
        return;
      }

      final user = AppUser.fromMap(uid, userDoc.data()!);
      await _saveUserData(uid, user.role, email, password);
      _navigateByRole(user.role);
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();
      Get.snackbar("Sign In Failed", e.message ?? "An error occurred");
    } finally {
      if (EasyLoading.isShow) EasyLoading.dismiss();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      EasyLoading.show(status: "Signing in with Google...");
      await _googleSignIn.signOut(); // Force account picker
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        EasyLoading.dismiss();
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;
      final uid = user.uid;

      // Admin
      final adminDoc = await _firestore.collection('admin').doc(uid).get();
      if (adminDoc.exists) {
        await _saveUserData(uid, 'admin', user.email!, null);
        Get.offAllNamed(AppRoutes.adminDashboard);
        return;
      }

      // Brand
      final brandDoc = await _firestore.collection('brands').doc(uid).get();
      if (brandDoc.exists) {
        final brandUser = BrandUser.fromMap(uid, brandDoc.data()!);

        if (brandUser.status == 'pending' || brandUser.status == 'rejected') {
          await _clearPrefs();
          Get.offAllNamed(
            brandUser.status == 'pending'
                ? AppRoutes.brandPending
                : AppRoutes.brandReject,
            arguments: brandUser.rejectionReason,
          );
          return;
        }

        if (brandUser.logoUrl == null || brandUser.logoUrl!.isEmpty) {
          await _clearPrefs();
          Get.offAllNamed(AppRoutes.logoUpload);
          return;
        }

        await _saveUserData(uid, 'brand', user.email!, null);
        Get.offAllNamed(AppRoutes.brandDashboard);
        return;
      }

      // User
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        EasyLoading.dismiss();
        Get.offAllNamed(AppRoutes.passwordPrompt);
        return;
      }

      final userData = AppUser.fromMap(uid, userDoc.data()!);
      await _saveUserData(uid, userData.role, user.email!, null);
      _navigateByRole(userData.role);
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar("Google Sign-In Failed", e.toString());
    } finally {
      if (EasyLoading.isShow) EasyLoading.dismiss();
    }
  }

  Future<void> _saveUserData(
    String uid,
    String role,
    String email,
    String? password,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userId", uid);
    await prefs.setString("userType", role);
    await prefs.setString("email", email);
    if (rememberMe.value && password != null) {
      await prefs.setString("password", password);
    }
  }

  Future<void> _clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userType');
    await prefs.remove('email');
    await prefs.remove('password');
  }

  void _navigateByRole(String role) {
    switch (role) {
      case 'admin':
        Get.offAllNamed(AppRoutes.adminDashboard);
        break;
      case 'brand':
        Get.offAllNamed(AppRoutes.brandDashboard);
        break;
      default:
        Get.offAllNamed(AppRoutes.userDashboard);
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
