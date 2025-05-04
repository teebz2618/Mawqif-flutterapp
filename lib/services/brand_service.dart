import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../models/brand_model.dart';
import 'email_service.dart';

class BrandService {
  static final _brandsCollection = FirebaseFirestore.instance.collection(
    'brands',
  );

  /// Approve brand
  Future<void> approveBrand(BrandUser brand) async {
    await _updateStatus(brand, newStatus: 'approved');
  }

  /// Reject brand with reason
  Future<void> rejectBrand(BrandUser brand, String rejectionReason) async {
    await _updateStatus(
      brand,
      newStatus: 'rejected',
      rejectionReason: rejectionReason,
    );
  }

  Future<void> _updateStatus(
    BrandUser brand, {
    required String newStatus,
    String? rejectionReason,
  }) async {
    try {
      final docRef = _brandsCollection.doc(brand.uid);

      // Prepare Firestore update
      final updateData = <String, dynamic>{'status': newStatus};
      if (rejectionReason != null && rejectionReason.isNotEmpty) {
        updateData['rejectionReason'] = rejectionReason;
      } else {
        updateData['rejectionReason'] = FieldValue.delete();
      }

      // Update Firestore
      await docRef.update(updateData);

      // Send email
      try {
        await sendEmail(
          email: brand.email,
          brandName: brand.name,
          isAccepted: newStatus == 'approved',
          rejectionReason: rejectionReason,
        );
      } catch (e) {
        debugPrint("Email sending failed: $e");
      }

      // Snackbar feedback
      Get.snackbar(
        "Success",
        newStatus == 'approved' ? "Brand approved" : "Brand rejected",
        backgroundColor: newStatus == 'approved' ? Colors.green : Colors.red,
        colorText: white,
        snackPosition: SnackPosition.BOTTOM,
      );

      Future.delayed(const Duration(seconds: 1), () {
        Get.back();
      });
    } catch (e) {
      debugPrint("BrandService Error: $e");
      Get.snackbar("Error", "Something went wrong: $e");
    }
  }
}
