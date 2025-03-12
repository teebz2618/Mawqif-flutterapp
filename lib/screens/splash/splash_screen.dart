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
    // small delay for splash feel
    await Future.delayed(const Duration(seconds: 2));

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    try {
      // Try to find a 'users' doc first (regular users/admins)
      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      final userDoc = await userDocRef.get();

      String? role;
      AppUser? appUser;
      BrandUser? brandUser;

      if (userDoc.exists) {
        appUser = AppUser.fromMap(user.uid, userDoc.data()!);
        role = appUser.role;
      } else {
        // If no users doc, check 'brands' collection (brand-only accounts)
        final brandDoc =
            await FirebaseFirestore.instance
                .collection('brands')
                .doc(user.uid)
                .get();
        if (brandDoc.exists) {
          brandUser = BrandUser.fromMap(user.uid, brandDoc.data()!);
          role = 'brand';
        } else {
          // No relevant docs found -> treat as invalid account (sign out)
          debugPrint('No user or brand document found for uid: ${user.uid}');
          await FirebaseAuth.instance.signOut();
          Get.offAllNamed(AppRoutes.login);
          return;
        }
      }

      // Route according to role
      if (role == 'admin') {
        Get.offAllNamed(AppRoutes.adminDashboard);
        return;
      }

      if (role == 'user') {
        Get.offAllNamed(AppRoutes.userDashboard);
        return;
      }

      if (role == 'brand') {
        // If brandUser wasn't initialized from 'brands' earlier, try to fetch it now.
        if (brandUser == null) {
          final brandDoc =
              await FirebaseFirestore.instance
                  .collection('brands')
                  .doc(user.uid)
                  .get();
          if (!brandDoc.exists) {
            debugPrint(
              'Brand doc missing although role says brand. uid: ${user.uid}',
            );
            // Inconsistent state — sign out to be safe
            await FirebaseAuth.instance.signOut();
            Get.offAllNamed(AppRoutes.login);
            return;
          }
          brandUser = BrandUser.fromMap(user.uid, brandDoc.data()!);
        }

        // Handle brand statuses -- do NOT sign out here, keep the auth state
        switch (brandUser.status) {
          case 'pending':
            Get.offAllNamed(AppRoutes.brandPending);
            return;

          case 'rejected':
            Get.offAllNamed(
              AppRoutes.brandReject,
              arguments: brandUser.rejectionReason,
            );
            return;

          case 'approved':
            // If logoUrl already set, go to dashboard
            if (brandUser.logoUrl != null && brandUser.logoUrl!.isNotEmpty) {
              Get.offAllNamed(AppRoutes.brandDashboard);
              return;
            }

            // Otherwise check Firebase Storage for logo; if found update doc
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
                return;
              } else {
                Get.offAllNamed(AppRoutes.logoUpload);
                return;
              }
            } catch (e) {
              // No logo in storage: navigate to logo upload (do not sign out)
              debugPrint('Logo not found in storage for ${user.uid}: $e');
              Get.offAllNamed(AppRoutes.logoUpload);
              return;
            }

          default:
            // Unknown status — sign out to avoid inconsistent app state
            debugPrint(
              'Unknown brand status (${brandUser.status}) for uid: ${user.uid}',
            );
            await FirebaseAuth.instance.signOut();
            Get.offAllNamed(AppRoutes.login);
            return;
        }
      }

      // Fallback (shouldn't normally hit)
      Get.offAllNamed(AppRoutes.login);
    } catch (e, st) {
      debugPrint('Error in splash navigation: $e\n$st');
      // Prefer to keep auth intact unless clearly broken.
      // Redirect to login to let user reauthenticate or give a fresh start.
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
