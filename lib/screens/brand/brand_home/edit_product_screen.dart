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
  late String originalName;
  late String originalDescription;
  late double originalPrice;
  late double originalOriginalPrice;
  late int originalDiscount;
  late bool originalFlashSale;
  late bool originalNewCollection;
  late bool originalBestSeller;
  late String productId;
  late Map<String, dynamic> productData;

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
    _loadProductData();
    super.initState();

    // Prefer constructor; fallback to Get.arguments to avoid route breakage
    final args = (Get.arguments is Map) ? Get.arguments as Map : {};
    productId = (widget.productId ?? args['productId'] ?? '').toString();

    final rawProductData = widget.productData ?? args['productData'];
    if (rawProductData is Map) {
      productData = Map<String, dynamic>.from(rawProductData);
    } else {
      productData = {};
    }

    _loadProductData();
  }

  Future<void> _loadProductData() async {
    setState(() => isLoading = true);

    final doc =
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .get();

    if (!doc.exists) {
      // Handle product not found
      return;
    }

    final data = doc.data()!;
    originalName = data['name'];
    originalDescription = data['description'];
    originalPrice = (data['price'] as num).toDouble();
    originalOriginalPrice = (data['originalPrice'] as num).toDouble();
    originalDiscount = data['discount'] ?? 0;
    originalFlashSale = data['isFlashSale'] ?? false;
    originalNewCollection = data['isNewCollection'] ?? false;
    originalBestSeller = data['isBestSeller'] ?? false;
    titleController.text = productData['title']?.toString() ?? '';
    descriptionController.text = productData['description']?.toString() ?? '';
    priceController.text = productData['price']?.toString() ?? '';
    discountController.text = productData['discount']?.toString() ?? '';

    selectedCategory = productData['category']?.toString();
    selectedGender = productData['gender']?.toString();
    isFlashSale = productData['isFlashSale'] == true;
    isNewCollection = productData['isNewCollection'] == true;
    isBestSeller = productData['isBestSeller'] == true;

    // Colors
    if (productData['colors'] is List) {
      selectedColors.addAll(
        (productData['colors'] as List)
            .where((c) => c != null)
            .map((c) => Color((c as num).toInt())),
      );
    }

    // Images (wrap URL strings into XFile for unified handling)
    if (productData['images'] is List) {
      for (var img in (productData['images'] as List)) {
        if (img == null) continue;
        productImages.add(XFile(img.toString()));
      }
    }

    // Sizes
    if (productData['sizes'] is List) {
      selectedSizes.addAll(
        (productData['sizes'] as List).map((e) => e.toString()),
      );
    }

    // Accessories
    if (productData['accessories'] is List) {
      selectedAccessories.addAll(
        (productData['accessories'] as List).map((e) => e.toString()),
      );
    }
  }

  Future<void> pickImages() async {
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => productImages.addAll(images));
    }
  }

  void removeImage(XFile img) {
    setState(() => productImages.remove(img));
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
                    if (idx != -1) {
                      setState(() => selectedColors[idx] = currentColor);
                    }
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
    if (titleController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        selectedCategory == null ||
        productImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill title, price, select a category, and add at least one image',
          ),
        ),
      );
      return;
    }

    // safe parsing
    final double? price = double.tryParse(priceController.text.trim());
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Price must be a valid number')),
      );
      return;
    }

    double? discount;
    if (isFlashSale && discountController.text.trim().isNotEmpty) {
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
      // Upload any newly picked files; keep existing URLs as-is
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
          imageUrls.add(img.path); // already a URL
        }
      }

      final updatedData = <String, dynamic>{
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'price': price,
        'category': selectedCategory,
        'gender': selectedCategory == 'Thobes' ? selectedGender : null,
        'images': imageUrls,
        'colors': selectedColors.map((c) => c).toList(),
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

      // Return updated map so ProductDetailScreen can refresh
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
                      /// CATEGORY
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
                                // Reset dependent fields
                                if (selectedCategory != 'Thobes') {
                                  selectedGender = null;
                                }
                                selectedAccessories.clear();
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      /// GENDER (Thobes only)
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

                      /// TITLE
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Product Title',
                        ),
                      ),
                      const SizedBox(height: 12),

                      /// DESCRIPTION
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                      ),
                      const SizedBox(height: 12),

                      /// PRICE
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Price (\$)',
                        ),
                      ),
                      const SizedBox(height: 12),

                      /// ACCESSORIES (Independent field below price)
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

                      /// IMAGES
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

                      /// COLORS
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
                              child: Icon(Icons.add, color: themeColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      /// SIZES
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

                      /// FLAGS
                      SwitchListTile(
                        title: const Text(
                          'Flash Sale',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        value: isFlashSale,
                        activeColor: themeColor,
                        onChanged: (v) {
                          setState(() {
                            isFlashSale = v;
                            if (!v) discountController.clear();
                          });
                        },
                      ),
                      if (isFlashSale)
                        TextField(
                          controller: discountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Discount % (0-100)',
                          ),
                          onChanged: (value) {
                            if (value.isEmpty) return;
                            final n = int.tryParse(value) ?? -1;
                            String corrected = value;
                            if (n < 0) corrected = '0';
                            if (n > 100) corrected = '100';
                            if (corrected != value) {
                              discountController.text = corrected;
                              discountController
                                  .selection = TextSelection.fromPosition(
                                TextPosition(
                                  offset: discountController.text.length,
                                ),
                              );
                            }
                          },
                        ),
                      SwitchListTile(
                        title: const Text(
                          'New Collection',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        value: isNewCollection,
                        activeColor: themeColor,
                        onChanged: (v) => setState(() => isNewCollection = v),
                      ),
                      SwitchListTile(
                        title: const Text(
                          'Best Seller',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        value: isBestSeller,
                        activeColor: themeColor,
                        onChanged: (v) => setState(() => isBestSeller = v),
                      ),
                      const SizedBox(height: 20),

                      /// UPDATE BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: updateProduct,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Update Product',
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

  // small helper for dropdown containers
  Widget _boxed(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}
