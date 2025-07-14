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
  final _formKey = GlobalKey<FormState>();
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

  final ImagePicker picker = ImagePicker();

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
    return true;
  }

  List<String> get availableAccessories {
    if (selectedCategory == 'Thobes' && selectedGender == 'Male') {
      return ['Keffiyeh/Shemagh'];
    } else if (selectedCategory == 'Thobes' && selectedGender == 'Female') {
      return ['Keffiyeh/Shemagh', 'Scarfs', 'Scarf Pins', 'Niqab'];
    } else if (selectedCategory == 'Abayas') {
      return ['Keffiyeh/Shemagh', 'Scarfs', 'Scarf Pins', 'Niqab'];
    }
    return [];
  }

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
      builder:
          (context) => AlertDialog(
            title: const Text('Pick a color'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: currentColor,
                onColorChanged: (Color color) => currentColor = color,
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
          ),
    );
  }

  void onCategoryChanged(String? category) {
    setState(() {
      selectedCategory = category;
      selectedAccessories.clear();
    });
  }

  String? validateDiscountInput() {
    if (!isFlashSale) return null;

    if (discountController.text.isEmpty) return 'Discount is required';
    final discount = int.tryParse(discountController.text);
    if (discount == null) return 'Enter a valid number';
    if (discount < 10) return 'Discount cannot be below 10%';
    if (discount > 100) return 'Discount cannot be above 100%';

    final price = double.tryParse(priceController.text.trim());
    if (price != null) {
      final discountedPrice = price - (price * discount / 100);
      if (discountedPrice < 1) return 'Discount not applicable for this price';
    }

    return null;
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CATEGORY
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
                          availableCategories
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                      onChanged: onCategoryChanged,
                    ),
                  ),
                ),

                // GENDER FOR THOBES
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
                            availableGenders
                                .map(
                                  (g) => DropdownMenuItem(
                                    value: g,
                                    child: Text(g),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (g) => setState(() {
                              selectedGender = g;
                              selectedAccessories.clear();
                            }),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                // IMAGES
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
                                  () =>
                                      setState(() => productImages.remove(img)),
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

                // TITLE, DESCRIPTION, PRICE
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Product Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Product title is required';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price (\Rs. (Delivery charges included))',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Price is required';
                    if (double.tryParse(value) == null)
                      return 'Enter a valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // COLORS
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
                    ...selectedColors.map(
                      (color) => Container(
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
                      ),
                    ),
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

                // SIZES
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
                          onSelected:
                              (_) => toggleSelection(selectedSizes, size),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 20),

                // ACCESSORIES
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

                // FLASH SALE
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
                      if (!value) discountController.clear();
                    });
                  },
                ),
                if (isFlashSale) ...[
                  TextFormField(
                    controller: discountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Discount % (10-100)',
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // NEW COLLECTION
                SwitchListTile(
                  title: const Text(
                    "New Collection",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  value: isNewCollection,
                  activeColor: themeColor,
                  onChanged: (value) => setState(() => isNewCollection = value),
                ),
                // BEST SELLER
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

                // ADD PRODUCT BUTTON
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
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text(
                      "Add Product",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () async {
                      FocusScope.of(context).unfocus();

                      // Parse price first
                      final price = double.tryParse(
                        priceController.text.trim(),
                      );
                      if (price == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Enter a valid price')),
                        );
                        return;
                      }

                      // Validate discount logic
                      if (isFlashSale) {
                        final discount = int.tryParse(
                          discountController.text.trim(),
                        );
                        if (discount == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Enter a valid discount'),
                            ),
                          );
                          return;
                        }
                        if (discount < 10) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Discount cannot be below 10%'),
                            ),
                          );
                          return;
                        }
                        if (discount > 100) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Discount cannot be above 100%'),
                            ),
                          );
                          return;
                        }
                        final discountedPrice =
                            price - (price * discount / 100);
                        if (discountedPrice < 1) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Discount not applicable for this price',
                              ),
                            ),
                          );
                          return; // **STOP product addition**
                        }
                      }

                      // Other validations...
                      if (!_formKey.currentState!.validate()) return;
                      if (selectedCategory == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a category'),
                          ),
                        );
                        return;
                      }
                      if (selectedCategory == 'Thobes' &&
                          selectedGender == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a gender for Thobes'),
                          ),
                        );
                        return;
                      }
                      if (productImages.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'At least one product image is required',
                            ),
                          ),
                        );
                        return;
                      }

                      double? discountValue;
                      if (isFlashSale)
                        discountValue = double.parse(
                          discountController.text.trim(),
                        );

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder:
                            (_) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                      );

                      try {
                        // Upload images
                        List<String> imageUrls = [];
                        for (var img in productImages) {
                          final ref = FirebaseStorage.instance
                              .ref()
                              .child('product_images')
                              .child(
                                '${DateTime.now().millisecondsSinceEpoch}_${img.name}',
                              );
                          await ref.putFile(File(img.path));
                          imageUrls.add(await ref.getDownloadURL());
                        }

                        final brandId = FirebaseAuth.instance.currentUser!.uid;
                        final brandDoc =
                            await FirebaseFirestore.instance
                                .collection('brands')
                                .doc(brandId)
                                .get();
                        final brandName =
                            brandDoc.exists
                                ? (brandDoc.data()?['name'] ?? 'Unknown Brand')
                                : 'Unknown Brand';

                        Map<String, dynamic> productData = {
                          'brandId': brandId,
                          'brandName': brandName,
                          'title': titleController.text.trim(),
                          'description': descriptionController.text.trim(),
                          'price': price,
                          'category': selectedCategory,
                          'gender':
                              selectedCategory == 'Thobes'
                                  ? selectedGender
                                  : null,
                          'accessories': selectedAccessories,
                          'images': imageUrls,
                          'colors': selectedColors.map((c) => c.value).toList(),
                          'sizes': selectedSizes,
                          'createdAt': FieldValue.serverTimestamp(),
                          'isFlashSale': isFlashSale,
                          'isNewCollection': isNewCollection,
                          'isBestSeller': isBestSeller,
                        };

                        if (isFlashSale)
                          productData['discount'] = discountValue;

                        await FirebaseFirestore.instance
                            .collection('products')
                            .add(productData);
                        Navigator.of(context).pop(); // close loader

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Product added successfully'),
                          ),
                        );
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.brandDashboard,
                          (route) => false,
                        );
                      } catch (e) {
                        Navigator.of(context).pop(); // close loader
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to add product: $e')),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
