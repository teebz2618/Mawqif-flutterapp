import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../constants/app_colors.dart';
import '../../../routes/app_routes.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountController = TextEditingController();

  final List<XFile> productImages = [];
  final List<Color> selectedColors = [];
  final List<String> selectedSizes = [];
  final List<String> selectedAccessories = [];

  String? selectedCategory;
  final List<String> availableCategories = [
    'Thobes',
    'Abayas',
    'Shemagh/Keffiyeh',
    'Kaftan',
    'Scarfs',
    'Niqab',
    'ScarfPins',
  ];

  String? selectedGender;
  final List<String> availableGenders = ['Male', 'Female'];

  final List<String> availableSizes = ['S', 'M', 'L', 'XL', 'XXL'];

  bool isFlashSale = false;
  bool isNewCollection = false;
  bool isBestSeller = false;
  bool get _hasChanges {
    return titleController.text.isNotEmpty ||
        descriptionController.text.isNotEmpty ||
        priceController.text.isNotEmpty ||
        discountController.text.isNotEmpty ||
        selectedCategory != null ||
        selectedGender != null ||
        productImages.isNotEmpty ||
        selectedColors.isNotEmpty ||
        selectedSizes.isNotEmpty ||
        selectedAccessories.isNotEmpty ||
        isFlashSale ||
        isNewCollection ||
        isBestSeller;
  }

  Future<bool> _onWillPop() async {
    if (_hasChanges) {
      final discard = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Discard Changes?'),
              content: const Text(
                'You have unsaved changes. Do you want to discard them and leave?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Wait',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: themeColor),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Discard',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
      );
      return discard ?? false;
    }
    return true; // no changes, allow pop
  }

  List<String> get availableAccessories {
    if (selectedCategory == 'Thobes' && selectedGender == 'Male') {
      return ['Keffiyeh/Shemagh'];
    } else if (selectedCategory == 'Thobes' && selectedGender == 'Female') {
      return ['Keffiyeh/Shemagh', 'Scarfs', 'Scarf Pins', 'Niqab', 'Kaftan'];
    } else if (selectedCategory == 'Abayas') {
      return ['Keffiyeh/Shemagh', 'Scarfs', 'Scarf Pins', 'Niqab', 'Kaftan'];
    }
    return [];
  }

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

  void toggleColorSelection(Color color) {
    setState(() {
      selectedColors.contains(color)
          ? selectedColors.remove(color)
          : selectedColors.add(color);
    });
  }

  void showColorPicker() {
    Color currentColor = Colors.brown;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (Color color) {
                currentColor = color;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: themeColor),
              child: const Text(
                'Add Color',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                toggleColorSelection(currentColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void onCategoryChanged(String? category) {
    setState(() {
      selectedCategory = category;
      selectedAccessories.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            'Add Product',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.brown,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// CATEGORY
              Text(
                "Product Category",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    hint: Text(
                      'Select Category',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    isExpanded: true,
                    items:
                        availableCategories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                    onChanged: onCategoryChanged,
                  ),
                ),
              ),

              /// GENDER for Thobes
              if (selectedCategory == 'Thobes') ...[
                const SizedBox(height: 20),
                Text(
                  "Select Gender",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedGender,
                      hint: Text(
                        'Select Gender',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      isExpanded: true,
                      items:
                          availableGenders.map((String gender) {
                            return DropdownMenuItem<String>(
                              value: gender,
                              child: Text(gender),
                            );
                          }).toList(),
                      onChanged: (gender) {
                        setState(() {
                          selectedGender = gender;
                          selectedAccessories.clear();
                        });
                      },
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),

              /// IMAGES
              Text(
                "Product Images",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
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

              /// TITLE
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Product Title'),
              ),
              const SizedBox(height: 10),

              /// DESCRIPTION
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                ),
              ),
              const SizedBox(height: 10),

              /// PRICE
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price (\$)'),
              ),
              const SizedBox(height: 20),

              /// COLORS
              Text(
                "Available Colors",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...selectedColors.map((color) {
                    return Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: () => toggleColorSelection(color),
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  GestureDetector(
                    onTap: showColorPicker,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: themeColor, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.add, color: themeColor, size: 24),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              /// SIZES
              Text(
                "Available Sizes",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
              const SizedBox(height: 8),
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
              const SizedBox(height: 20),

              /// ACCESSORIES
              if (selectedCategory != null &&
                  selectedGender != null &&
                  availableAccessories.isNotEmpty) ...[
                Text(
                  "Accessories (Optional)",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children:
                      availableAccessories.map((accessory) {
                        final isSelected = selectedAccessories.contains(
                          accessory,
                        );
                        return ChoiceChip(
                          label: Text(accessory),
                          selected: isSelected,
                          selectedColor: themeColor.withOpacity(0.8),
                          backgroundColor: Colors.grey[200],
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                          onSelected:
                              (_) => toggleSelection(
                                selectedAccessories,
                                accessory,
                              ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 10),
              ],

              /// FLAGS
              SwitchListTile(
                title: const Text(
                  "Flash Sale",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                value: isFlashSale,
                activeColor: themeColor,
                onChanged: (value) {
                  setState(() {
                    isFlashSale = value;
                    if (!value) {
                      discountController.clear();
                    }
                  });
                },
              ),
              if (isFlashSale) ...[
                TextField(
                  controller: discountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Discount % (0-100)',
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      final numValue = int.tryParse(value) ?? -1;
                      if (numValue < 0) {
                        discountController.text = '0';
                      } else if (numValue > 100) {
                        discountController.text = '100';
                      }
                      discountController.selection = TextSelection.fromPosition(
                        TextPosition(offset: discountController.text.length),
                      );
                    }
                  },
                ),
              ],
              SwitchListTile(
                title: const Text(
                  "New Collection",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                value: isNewCollection,
                activeColor: themeColor,
                onChanged: (value) => setState(() => isNewCollection = value),
              ),
              SwitchListTile(
                title: const Text(
                  "Best Seller",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                value: isBestSeller,
                activeColor: themeColor,
                onChanged: (value) => setState(() => isBestSeller = value),
              ),
              const SizedBox(height: 20),

              /// ADD BUTTON
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
                        priceController.text.isEmpty ||
                        productImages.isEmpty ||
                        selectedCategory == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please fill title, price, select a category, and add at least one image',
                          ),
                        ),
                      );
                      return;
                    }

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder:
                          (_) =>
                              const Center(child: CircularProgressIndicator()),
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
                        'category': selectedCategory,
                        'accessories': selectedAccessories,
                        'images': imageUrls,
                        'colors':
                            selectedColors.map((color) => color.value).toList(),
                        'sizes': selectedSizes,
                        'createdAt': FieldValue.serverTimestamp(),
                        'isFlashSale': isFlashSale,
                        'isNewCollection': isNewCollection,
                        'isBestSeller': isBestSeller,
                        'discount':
                            isFlashSale && discountController.text.isNotEmpty
                                ? double.parse(discountController.text.trim())
                                : null,
                      };

                      await FirebaseFirestore.instance
                          .collection('products')
                          .add(productData);

                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, AppRoutes.brandDashboard);
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
      ),
    );
  }
}
