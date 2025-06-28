import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import '../../../constants/app_colors.dart';

class EditProductScreen extends StatefulWidget {
  final String? productId;
  final Map<String, dynamic>? productData;

  const EditProductScreen({super.key, this.productId, this.productData});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  bool isLoading = false;
  late String productId;
  late Map<String, dynamic> productData;

  // original values for discard check
  Map<String, dynamic> originalData = {};

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountController = TextEditingController();

  final List<XFile> productImages = [];
  final List<Color> selectedColors = [];
  final List<String> selectedSizes = [];
  final List<String> selectedAccessories = [];

  String? selectedCategory;
  String? selectedGender;

  bool isFlashSale = false;
  bool isNewCollection = false;
  bool isBestSeller = false;
  bool _isLoading = false;

  final ImagePicker picker = ImagePicker();

  // Constants aligned with AddProduct
  final List<String> availableCategories = const [
    'Thobes',
    'Abayas',
    'Shemagh/Keffiyeh',
    'Kaftan',
    'Scarfs',
    'Niqab',
    'ScarfPins',
  ];
  final List<String> availableGenders = const ['Male', 'Female'];
  final List<String> allSizes = const ['S', 'M', 'L', 'XL', 'XXL'];

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

  @override
  void initState() {
    super.initState();

    // Prefer constructor; fallback to Get.arguments
    final args = (Get.arguments is Map) ? Get.arguments as Map : {};
    productId = (widget.productId ?? args['productId'] ?? '').toString();

    final rawProductData = widget.productData ?? args['productData'];
    if (rawProductData is Map) {
      productData = Map<String, dynamic>.from(rawProductData);
      _fillControllersFromData(productData);
      originalData = Map<String, dynamic>.from(productData);
    } else {
      productData = {};
      if (productId.isNotEmpty) {
        _loadProductData();
      }
    }
  }

  void _fillControllersFromData(Map<String, dynamic> data) {
    titleController.text = data['title']?.toString() ?? '';
    descriptionController.text = data['description']?.toString() ?? '';
    priceController.text = data['price']?.toString() ?? '';
    discountController.text = data['discount']?.toString() ?? '';

    selectedCategory = data['category']?.toString();
    selectedGender = data['gender']?.toString();
    isFlashSale = data['isFlashSale'] == true;
    isNewCollection = data['isNewCollection'] == true;
    isBestSeller = data['isBestSeller'] == true;

    // Colors
    if (data['colors'] is List) {
      selectedColors.addAll(
        (data['colors'] as List)
            .where((c) => c != null)
            .map((c) => Color((c as num).toInt())),
      );
    }

    // Images
    if (data['images'] is List) {
      for (var img in (data['images'] as List)) {
        if (img != null) {
          productImages.add(XFile(img.toString()));
        }
      }
    }

    // Sizes
    if (data['sizes'] is List) {
      selectedSizes.addAll((data['sizes'] as List).map((e) => e.toString()));
    }

    // Accessories
    if (data['accessories'] is List) {
      selectedAccessories.addAll(
        (data['accessories'] as List).map((e) => e.toString()),
      );
    }
  }

  Future<void> _loadProductData() async {
    setState(() => isLoading = true);

    final doc =
    await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      productData = Map<String, dynamic>.from(data);
      _fillControllersFromData(productData);
      originalData = Map<String, dynamic>.from(productData);
    }

    setState(() => isLoading = false);
  }

  bool get _hasChanges {
    final currentData = {
      'title': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'price': priceController.text.trim(),
      'discount': discountController.text.trim(),
      'category': selectedCategory,
      'gender': selectedGender,
      'colors': selectedColors.map((c) => c.value).toList(),
      'sizes': selectedSizes,
      'accessories': selectedAccessories,
      'isFlashSale': isFlashSale,
      'isNewCollection': isNewCollection,
      'isBestSeller': isBestSeller,
      'images': productImages.map((x) => x.path).toList(),
    };
    return currentData.toString() != originalData.toString();
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

  Future<void> pickImages() async {
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => productImages.addAll(images));
    }
  }

  void removeImage(XFile img) => setState(() => productImages.remove(img));

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

  void showColorPicker([Color? existingColor]) {
    Color currentColor = existingColor ?? Colors.brown;
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
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (existingColor != null) {
                final idx = selectedColors.indexOf(existingColor);
                if (idx != -1)
                  setState(() => selectedColors[idx] = currentColor);
              } else {
                toggleColorSelection(currentColor);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add Color'),
          ),
        ],
      ),
    );
  }

  Future<void> updateProduct() async {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product title is required')),
      );
      return;
    }

    if (priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Price is required')));
      return;
    }
    final double? price = double.tryParse(priceController.text.trim());
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Price must be a valid number')),
      );
      return;
    }

    if (selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }
    if (selectedCategory == 'Thobes' && selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a gender for Thobes')),
      );
      return;
    }
    if (productImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one product image is required')),
      );
      return;
    }

    double? discount;
    if (isFlashSale) {
      if (discountController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Discount is required for Flash Sale')),
        );
        return;
      }
      discount = double.tryParse(discountController.text.trim());
      if (discount == null || discount < 0 || discount > 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Discount must be between 0 and 100')),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final List<String> imageUrls = [];
      for (final img in productImages) {
        final file = File(img.path);
        if (file.existsSync()) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('product_images')
              .child('${DateTime.now().millisecondsSinceEpoch}_${img.name}');
          await ref.putFile(file);
          final url = await ref.getDownloadURL();
          imageUrls.add(url);
        } else {
          imageUrls.add(img.path);
        }
      }

      final updatedData = <String, dynamic>{
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'price': price,
        'category': selectedCategory,
        'gender': selectedCategory == 'Thobes' ? selectedGender : null,
        'images': imageUrls,
        'colors': selectedColors.map((c) => c.value).toList(),
        'sizes': selectedSizes,
        'accessories': selectedAccessories,
        'isFlashSale': isFlashSale,
        'discount': isFlashSale ? discount : null,
        'isNewCollection': isNewCollection,
        'isBestSeller': isBestSeller,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully')),
      );
      Navigator.of(context).pop(updatedData);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update product: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Edit Product',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.brown,
            ),
          ),
          backgroundColor: Colors.white,
        ),
        body:
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Dropdown
              Text(
                'Product Category',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
              const SizedBox(height: 8),
              _boxed(
                DropdownButtonHideUnderline(
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
                          (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      ),
                    )
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        selectedCategory = v;
                        if (selectedCategory != 'Thobes')
                          selectedGender = null;
                        selectedAccessories.clear();
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Gender (Thobes only)
              if (selectedCategory == 'Thobes') ...[
                Text(
                  'Select Gender',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  ),
                ),
                const SizedBox(height: 8),
                _boxed(
                  DropdownButtonHideUnderline(
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
                      onChanged: (g) {
                        setState(() {
                          selectedGender = g;
                          selectedAccessories.clear();
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Title
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Product Title',
                ),
              ),
              const SizedBox(height: 12),

              // Description
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
              const SizedBox(height: 12),

              // Price
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price (\$)',
                ),
              ),
              const SizedBox(height: 12),

              // Accessories
              if (availableAccessories.isNotEmpty) ...[
                Text(
                  'Accessories (Optional)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
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
                        color:
                        isSelected
                            ? Colors.white
                            : Colors.black,
                      ),
                      onSelected:
                          (_) => toggleSelection(
                        selectedAccessories,
                        accessory,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],

              // Images
              Text(
                'Product Images',
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
                  ...productImages.map((img) {
                    final file = File(img.path);
                    final widgetImage =
                    file.existsSync()
                        ? Image.file(
                      file,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                        : Image.network(
                      img.path,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image,
                        ),
                      ),
                    );
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: widgetImage,
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => removeImage(img),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(2),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
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
              const SizedBox(height: 16),

              // Colors
              Text(
                'Available Colors',
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
                    return GestureDetector(
                      onTap: () => showColorPicker(color),
                      child: Stack(
                        children: [
                          Container(
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
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap:
                                  () => setState(
                                    () => selectedColors.remove(color),
                              ),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(2),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  GestureDetector(
                    onTap: () => showColorPicker(),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: themeColor, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.add, color: themeColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sizes
              Text(
                'Available Sizes',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                allSizes.map((size) {
                  final isSelected = selectedSizes.contains(size);
                  return ChoiceChip(
                    label: Text(size),
                    selected: isSelected,
                    selectedColor: themeColor.withOpacity(0.8),
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color:
                      isSelected ? Colors.white : Colors.black,
                    ),
                    onSelected:
                        (_) => toggleSelection(selectedSizes, size),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Flash Sale
              SwitchListTile(
                title: const Text("Flash Sale"),
                value: isFlashSale,
                activeColor: themeColor,
                onChanged:
                    (v) => setState(() {
                  isFlashSale = v;
                  if (!v) discountController.clear();
                }),
              ),
              if (isFlashSale)
                TextField(
                  controller: discountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Discount (%)',
                  ),
                ),
              const SizedBox(height: 16),

              // New Collection & Best Seller
              SwitchListTile(
                title: const Text("New Collection"),
                value: isNewCollection,
                activeColor: themeColor,
                onChanged: (v) => setState(() => isNewCollection = v),
              ),
              SwitchListTile(
                title: const Text("Best Seller"),
                value: isBestSeller,
                activeColor: themeColor,
                onChanged: (v) => setState(() => isBestSeller = v),
              ),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: updateProduct,
                  child: const Text(
                    "Update Product",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _boxed(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
