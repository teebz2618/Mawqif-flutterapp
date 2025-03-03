import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../constants/app_colors.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  final List<XFile> productImages = [];
  final List<String> selectedColors = [];
  final List<String> selectedSizes = [];

  final List<String> availableColors = [
    'Black',
    'White',
    'Beige',
    'Brown',
    'Blue',
  ];
  final List<String> availableSizes = ['S', 'M', 'L', 'XL', 'XXL'];

  final ImagePicker picker = ImagePicker();

  Future<void> pickImages() async {
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        productImages.addAll(images);
      });
    }
  }

  void toggleSelection(List<String> list, String value) {
    setState(() {
      list.contains(value) ? list.remove(value) : list.add(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        backgroundColor: themeColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Images
            Text(
              "Product Images",
              style: TextStyle(fontWeight: FontWeight.bold, color: themeColor),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ...productImages.map(
                  (img) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(img.path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap:
                              () => setState(() => productImages.remove(img)),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: pickImages,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: themeColor, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.add_a_photo, color: themeColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Product Title
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Product Title'),
            ),
            const SizedBox(height: 10),

            // Description
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 10),

            // Price
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
            const SizedBox(height: 20),

            // Colors
            Text(
              "Available Colors",
              style: TextStyle(fontWeight: FontWeight.bold, color: themeColor),
            ),
            Wrap(
              spacing: 8,
              children:
                  availableColors.map((color) {
                    final isSelected = selectedColors.contains(color);
                    return ChoiceChip(
                      label: Text(color),
                      selected: isSelected,
                      selectedColor: themeColor.withOpacity(0.8),
                      backgroundColor: Colors.grey[200],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                      onSelected: (_) => toggleSelection(selectedColors, color),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 20),

            // Sizes
            Text(
              "Available Sizes",
              style: TextStyle(fontWeight: FontWeight.bold, color: themeColor),
            ),
            Wrap(
              spacing: 8,
              children:
                  availableSizes.map((size) {
                    final isSelected = selectedSizes.contains(size);
                    return ChoiceChip(
                      label: Text(size),
                      selected: isSelected,
                      selectedColor: themeColor.withOpacity(0.8),
                      backgroundColor: Colors.grey[200],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                      onSelected: (_) => toggleSelection(selectedSizes, size),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 30),

            // Add Product Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  if (titleController.text.isEmpty ||
                      descriptionController.text.isEmpty ||
                      priceController.text.isEmpty ||
                      productImages.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please fill all fields and add at least one image',
                        ),
                      ),
                    );
                    return;
                  }

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder:
                        (_) => const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    List<String> imageUrls = [];
                    for (var img in productImages) {
                      final ref = FirebaseStorage.instance
                          .ref()
                          .child('product_images')
                          .child(
                            '${DateTime.now().millisecondsSinceEpoch}_${img.name}',
                          );
                      await ref.putFile(File(img.path));
                      final url = await ref.getDownloadURL();
                      imageUrls.add(url);
                    }

                    Map<String, dynamic> productData = {
                      'brandId': FirebaseAuth.instance.currentUser!.uid,
                      'title': titleController.text.trim(),
                      'description': descriptionController.text.trim(),
                      'price': double.parse(priceController.text.trim()),
                      'images': imageUrls,
                      'colors': selectedColors,
                      'sizes': selectedSizes,
                      'createdAt': FieldValue.serverTimestamp(),
                    };

                    await FirebaseFirestore.instance
                        .collection('products')
                        .add(productData);

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Product added successfully'),
                      ),
                    );

                    setState(() {
                      titleController.clear();
                      descriptionController.clear();
                      priceController.clear();
                      productImages.clear();
                      selectedColors.clear();
                      selectedSizes.clear();
                    });
                  } catch (e) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add product: $e')),
                    );
                  }
                },
                icon: const Icon(Icons.add_circle, color: Colors.white),
                label: const Text(
                  "Add Product",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
