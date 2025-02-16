import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      Get.snackbar("Error", "Please select an image first.");
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Your Brand Logo"),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_image!, height: 150),
                )
                : const Text(
                  "No image selected",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Pick Logo"),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isUploading ? null : uploadLogo,
              icon:
                  isUploading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.cloud_upload),
              label: Text(isUploading ? "Uploading..." : "Upload Logo"),
            ),
          ],
        ),
      ),
    );
  }
}
