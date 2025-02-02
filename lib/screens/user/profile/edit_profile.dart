import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final numberController = TextEditingController();
  final addressController = TextEditingController();

  bool isLoading = true;
  File? _imageFile;
  String? _photoUrl;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    final data = doc.data();
    if (data != null) {
      nameController.text = data['name'] ?? '';
      emailController.text = user.email ?? '';
      numberController.text = data['phone'] ?? '';
      addressController.text = data['address'] ?? '';
      _photoUrl = user.photoURL;
    }

    setState(() => isLoading = false);
  }

  Future<void> _pickImage() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Choose Image Source"),
            content: const Text("Select where to get your photo from."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, ImageSource.camera),
                child: const Text("Camera"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, ImageSource.gallery),
                child: const Text("Gallery"),
              ),
            ],
          ),
    );

    if (source == null) return;

    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
      await _uploadToFirebase();
    }
  }

  Future<void> _uploadToFirebase() async {
    if (_imageFile == null) return;

    final user = FirebaseAuth.instance.currentUser;
    final ref = FirebaseStorage.instance
        .ref()
        .child("user_profile_images")
        .child("${user!.uid}.jpg");

    await ref.putFile(_imageFile!);
    final downloadUrl = await ref.getDownloadURL();

    await user.updatePhotoURL(downloadUrl);
    await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
      'photoUrl': downloadUrl,
    });

    setState(() => _photoUrl = downloadUrl);
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'name': nameController.text.trim(),
            'phone': numberController.text.trim(),
            'address': addressController.text.trim(),
          });

      await user.updateDisplayName(nameController.text.trim());

      Get.snackbar("Success", "Profile updated successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to update profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown.shade800,
        elevation: 0,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage:
                                    _imageFile != null
                                        ? FileImage(_imageFile!)
                                        : _photoUrl != null
                                        ? NetworkImage(_photoUrl!)
                                        : const AssetImage(
                                              "assets/images/default_user.png",
                                            )
                                            as ImageProvider,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.brown.shade400,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        "Full Name",
                        nameController,
                        Icons.person,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        "Email",
                        emailController,
                        Icons.email,
                        readOnly: true,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        "Phone Number",
                        numberController,
                        Icons.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Phone number is required";
                          } else if (!RegExp(
                            r'^\+?\d{10,15}$',
                          ).hasMatch(value)) {
                            return "Enter a valid phone number";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        "Address",
                        addressController,
                        Icons.home,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Address is required";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.brown.shade700,
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.brown.shade400),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _updateProfile,
                        child: const Text(
                          "Update Profile",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.brown.shade700),
        labelText: label,
        labelStyle: TextStyle(color: Colors.brown.shade800),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}
