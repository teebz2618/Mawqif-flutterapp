import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class PromotionalBanner extends StatefulWidget {
  const PromotionalBanner({super.key});

  @override
  State<PromotionalBanner> createState() => _PromotionalBannerState();
}

class _PromotionalBannerState extends State<PromotionalBanner> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  bool _linkToProduct = false; // toggle for hybrid linking
  String? _selectedProductId; // chosen product id

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<String?> _uploadImage(File imageFile, String brandId) async {
    try {
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      final ref = FirebaseStorage.instance.ref().child(
        "banners/$brandId/$fileName",
      );
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      EasyLoading.showError("Image upload failed: $e");
      return null;
    }
  }

  Future<void> _saveBanner() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      EasyLoading.showError("Please select an image");
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      EasyLoading.showError("Not logged in");
      return;
    }

    if (_linkToProduct &&
        (_selectedProductId == null || _selectedProductId!.isEmpty)) {
      EasyLoading.showError("Please select a product to link");
      return;
    }

    EasyLoading.show(status: "Uploading...");
    final imageUrl = await _uploadImage(_selectedImage!, user.uid);
    if (imageUrl == null) return;

    final isProduct = _linkToProduct && _selectedProductId != null;

    final bannerData = {
      "imageUrl": imageUrl,
      "brandId": user.uid,
      "title": _titleController.text.trim(),
      "subtitle": _subtitleController.text.trim(),
      // structured link that your app can route from safely
      "link": {
        "type": isProduct ? "product" : "brand",
        "targetId": isProduct ? _selectedProductId : user.uid,
        "linkPath":
            isProduct ? "products/$_selectedProductId" : "brands/${user.uid}",
      },
      "createdAt": FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection("promotional_banners")
          .add(bannerData);

      EasyLoading.showSuccess("Banner Added!");
      _formKey.currentState!.reset();
      setState(() {
        _selectedImage = null;
        _linkToProduct = false;
        _selectedProductId = null;
      });
      _titleController.clear();
      _subtitleController.clear();
    } catch (e) {
      EasyLoading.showError("Failed to save: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        // white background
        centerTitle: true,
        // center the title
        title: const Text(
          "Add Promotional Banner",
          style: TextStyle(
            color: Colors.brown, // brown text
            fontWeight: FontWeight.bold, // bold
            fontSize: 20,
          ),
        ),
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      _selectedImage == null
                          ? const Center(
                            child: Text(
                              "Tap to select banner image",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                          : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImage!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  hintText: "New Collection",
                  hintStyle: TextStyle(color: Colors.grey), // light hint
                  border: OutlineInputBorder(),
                ),
                validator:
                    (v) => (v == null || v.isEmpty) ? "Enter title" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subtitleController,
                decoration: const InputDecoration(
                  labelText: "Subtitle",
                  hintText: "Discover our latest arrivals",
                  hintStyle: TextStyle(color: Colors.grey), // light hint
                  border: OutlineInputBorder(),
                ),
                validator:
                    (v) => (v == null || v.isEmpty) ? "Enter subtitle" : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile.adaptive(
                title: const Text("Link to a specific product"),
                value: _linkToProduct,
                onChanged: (val) {
                  setState(() {
                    _linkToProduct = val;
                    if (!val) _selectedProductId = null;
                  });
                },
              ),
              if (_linkToProduct && user != null) ...[
                const SizedBox(height: 8),
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection("products")
                          .where("brandId", isEqualTo: user.uid)
                          .orderBy("createdAt", descending: true)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text(
                        "No products found for this brand.\nThe banner will link to your brand page.",
                        style: TextStyle(color: Colors.grey),
                      );
                    }

                    final docs = snapshot.data!.docs;

                    return DropdownButtonFormField<String>(
                      value: _selectedProductId,
                      decoration: const InputDecoration(
                        labelText: "Select Product",
                        border: OutlineInputBorder(),
                      ),
                      items:
                          docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final productTitle =
                                (data['title'] ??
                                        data['name'] ??
                                        'Untitled product')
                                    .toString();
                            return DropdownMenuItem<String>(
                              value: doc.id,
                              child: Text(
                                productTitle,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                      onChanged:
                          (val) => setState(() => _selectedProductId = val),
                      validator: (val) {
                        if (_linkToProduct && (val == null || val.isEmpty)) {
                          return "Please select a product";
                        }
                        return null;
                      },
                    );
                  },
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveBanner,
                icon: const Icon(Icons.campaign_outlined),
                label: const Text("Save Banner"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 24),

              // Show uploaded banners
              Text(
                "Uploaded Banners",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),

              const SizedBox(height: 12),

              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection("promotional_banners")
                        .orderBy("createdAt", descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text(
                      "No banners uploaded yet.",
                      style: TextStyle(color: Colors.grey),
                    );
                  }

                  final banners = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: banners.length,
                    itemBuilder: (context, index) {
                      final data =
                          banners[index].data() as Map<String, dynamic>;
                      final bannerId = banners[index].id;
                      final createdAt = data['createdAt'] as Timestamp?;
                      final formattedTime =
                          createdAt != null
                              ? "${createdAt.toDate().day}/${createdAt.toDate().month}/${createdAt.toDate().year} ${createdAt.toDate().hour}:${createdAt.toDate().minute}"
                              : "N/A";

                      return GestureDetector(
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.bannerDetail,
                            arguments: {'bannerData': data},
                          );
                        },
                        child: Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading:
                                data['imageUrl'] != null
                                    ? Image.network(
                                      data['imageUrl'],
                                      width: 60,
                                      fit: BoxFit.cover,
                                    )
                                    : const Icon(Icons.image, size: 60),
                            title: Text(data['title'] ?? "No Title"),
                            subtitle: Text(formattedTime),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
