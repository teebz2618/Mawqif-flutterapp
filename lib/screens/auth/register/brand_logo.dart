import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mawqif/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_routes.dart';

class UploadLogoScreen extends StatefulWidget {
  const UploadLogoScreen({super.key});

  @override
  State<UploadLogoScreen> createState() => _UploadLogoScreenState();
}

class _UploadLogoScreenState extends State<UploadLogoScreen> {
  File? _image;
  bool isUploading = false;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> uploadLogo() async {
    if (_image == null) {
      Get.snackbar(
        "Error",
        "Please select an image first.",
        colorText: Colors.red,
      );
      return;
    }

    setState(() => isUploading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final ref = FirebaseStorage.instance.ref().child(
        'brand_logos/$uid/logo.jpg',
      );

      await ref.putFile(_image!);
      final logoUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('brands').doc(uid).update({
        'logoUrl': logoUrl,
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('logoUrl', logoUrl);

      Get.snackbar("Success", "Logo uploaded successfully");
      Get.offAllNamed(AppRoutes.brandDashboard);
    } catch (e) {
      Get.snackbar(
        "Upload Failed",
        e.toString(),
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      setState(() => isUploading = false);
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Brand Logo",
          style: TextStyle(fontWeight: FontWeight.bold, color: themeColor),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: themeColor),
            tooltip: "Logout",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              "Upload Your Brand Logo",
              style: theme.textTheme.headlineSmall?.copyWith(color: themeColor),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            Text(
              "A professional logo helps customers recognize your brand.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.grey[200],
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child:
                    _image == null
                        ? Icon(
                          Icons.add_a_photo,
                          size: 40,
                          color: Colors.grey[600],
                        )
                        : null,
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                onPressed: isUploading ? null : uploadLogo,
                child:
                    isUploading
                        ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text(
                          "Upload Logo",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
