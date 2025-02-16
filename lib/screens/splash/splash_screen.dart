import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/app_user.dart';
import '../../models/brand_model.dart';
import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateUser();
  }

  Future<void> _navigateUser() async {
    await Future.delayed(const Duration(seconds: 2));

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    if (!userDoc.exists) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    final appUser = AppUser.fromMap(user.uid, userDoc.data()!);

    if (appUser.role == 'admin') {
      Get.offAllNamed(AppRoutes.adminDashboard);
    } else if (appUser.role == 'user') {
      Get.offAllNamed(AppRoutes.userDashboard);
    } else if (appUser.role == 'brand') {
      final brandDoc =
          await FirebaseFirestore.instance
              .collection('brands')
              .doc(user.uid)
              .get();
      if (!brandDoc.exists) {
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      final brandUser = BrandUser.fromMap(user.uid, brandDoc.data()!);

      switch (brandUser.status) {
        case 'pending':
          await FirebaseAuth.instance.signOut();
          Get.offAllNamed(AppRoutes.brandPending);
          return;
        case 'rejected':
          await FirebaseAuth.instance.signOut();
          Get.offAllNamed(
            AppRoutes.brandReject,
            arguments: brandUser.rejectionReason,
          );
          return;
        case 'approved':
          if (brandUser.logoUrl != null && brandUser.logoUrl!.isNotEmpty) {
            Get.offAllNamed(AppRoutes.brandDashboard);
          } else {
            // Check Firebase Storage to confirm logo file exists
            try {
              final ref = FirebaseStorage.instance.ref().child(
                'brandLogos/${user.uid}.jpg',
              );
              final url = await ref.getDownloadURL();
              if (url.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('brands')
                    .doc(user.uid)
                    .update({'logoUrl': url});
                Get.offAllNamed(AppRoutes.brandDashboard);
              } else {
                Get.offAllNamed(AppRoutes.logoUpload);
              }
            } catch (e) {
              Get.offAllNamed(AppRoutes.logoUpload);
            }
          }
          return;
        default:
          await FirebaseAuth.instance.signOut();
          Get.offAllNamed(AppRoutes.login);
          return;
      }
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
