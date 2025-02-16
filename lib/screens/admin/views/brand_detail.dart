import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/brand_model.dart';

class BrandDetailScreen extends StatelessWidget {
  const BrandDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Get.arguments;
    final BrandUser brand = BrandUser.fromMap(data['docId'], data['brand']);
    final docId = brand.uid;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Brand Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.brown),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Brand Logo
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.transparent,
              child: ClipOval(
                child:
                    (brand.logoUrl != null && brand.logoUrl!.isNotEmpty)
                        ? Image.network(
                          brand.logoUrl!,
                          width: 100,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/placeholder.png',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                        : Image.asset(
                          'assets/images/placeholder.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
              ),
            ),

            const SizedBox(height: 12),

            // Upload Logo (Only if approved & logo is not uploaded yet)
            if (brand.status == 'approved' &&
                (brand.logoUrl == null || brand.logoUrl!.isEmpty))
              ElevatedButton.icon(
                onPressed: () => uploadBrandLogo(brand),
                icon: const Icon(Icons.upload),
                label: const Text("Upload Logo"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Brand Info Fields
            _buildField("Brand Name", brand.name),
            _buildField("Email", brand.email),
            if (brand.contact != null) _buildField("Contact", brand.contact!),
            if (brand.country != null) _buildField("Country", brand.country!),
            if (brand.description != null)
              _buildField("Description", brand.description!),
            if (brand.shippingInfo != null)
              _buildField(
                "Shipping Info",
                _formatShippingInfo(brand.shippingInfo),
              ),
            if (brand.status == 'rejected' && brand.rejectionReason != null)
              _buildField("Rejection Reason", brand.rejectionReason!),

            const SizedBox(height: 15),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus("approved", docId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Approve",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => rejectBrand(docId, brand.logoUrl),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade400,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Reject",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15.5,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          margin: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.brown.shade100),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 14.5, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  String _formatShippingInfo(dynamic shippingInfo) {
    if (shippingInfo is List) {
      return shippingInfo.join(', ');
    }
    return shippingInfo.toString();
  }

  Future<void> _updateStatus(String newStatus, String docId) async {
    try {
      await FirebaseFirestore.instance.collection('brands').doc(docId).update({
        'status': newStatus,
        'rejectionReason': FieldValue.delete(),
      });

      Get.back();
      Get.snackbar(
        "Success",
        newStatus == 'approved' ? "Brand approved" : "Brand rejected",
        backgroundColor: newStatus == 'approved' ? Colors.green : Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Error", "Something went wrong");
    }
  }

  Future<void> rejectBrand(String brandId, String? logoUrl) async {
    final TextEditingController reasonController = TextEditingController();

    String? rejectionReason = await Get.dialog<String>(
      AlertDialog(
        title: const Text("Reject Brand"),
        content: TextFormField(
          controller: reasonController,
          maxLines: 3,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: "Reason for rejection",
            hintText: "Enter the reason here",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                Get.snackbar("Error", "Please enter a rejection reason.");
                return;
              }
              Get.back(result: reason);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
            child: const Text("Submit"),
          ),
        ],
      ),
    );

    if (rejectionReason == null || rejectionReason.isEmpty) return;

    final docRef = FirebaseFirestore.instance.collection('brands').doc(brandId);

    // Delete logo if it exists
    if (logoUrl != null && logoUrl.isNotEmpty) {
      try {
        final ref = FirebaseStorage.instance.refFromURL(logoUrl);
        await ref.delete();
      } catch (e) {
        debugPrint("⚠️ Failed to delete logo: $e");
      }
    }

    try {
      await docRef.update({
        "logoUrl": FieldValue.delete(),
        "status": "rejected",
        "rejectionReason": rejectionReason,
      });

      Get.back();
      Get.snackbar(
        "Rejected",
        "Brand has been rejected",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to reject brand");
    }
  }

  Future<void> uploadBrandLogo(BrandUser brand) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    final ref = FirebaseStorage.instance.ref().child(
      'brand_logos/${brand.uid}.jpg',
    );

    try {
      await ref.putFile(file);
      final logoUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('brands')
          .doc(brand.uid)
          .update({'logoUrl': logoUrl});

      Get.snackbar(
        'Logo Uploaded',
        'The brand logo has been uploaded.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Logo upload failed: ${e.toString()}');
    }
  }
}
