import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_colors.dart';
import 'edit_product_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required Map<String, dynamic> product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late String productId;
  late Map<String, dynamic> productData;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments ?? {};
    productId = args['productId'] ?? '';
    productData = Map<String, dynamic>.from(args['productData'] ?? {});
  }

  @override
  Widget build(BuildContext context) {
    final List images = productData['images'] ?? [];
    final List colors = productData['colors'] ?? [];
    final List sizes = productData['sizes'] ?? [];
    final List accessories = productData['accessories'] ?? [];

    final bool isFlashSale = productData['isFlashSale'] ?? false;
    final bool isNewCollection = productData['isNewCollection'] ?? false;
    final bool isBestSeller = productData['isBestSeller'] ?? false;
    final double? price =
        (productData['price'] != null)
            ? double.tryParse(productData['price'].toString())
            : null;
    final double? discount =
        (productData['discount'] != null)
            ? double.tryParse(productData['discount'].toString())
            : null;

    double? calculatedNewPrice;
    if (price != null && discount != null && discount > 0) {
      calculatedNewPrice = price - (price * discount / 100);
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      productData['title'] ?? 'Product Detail',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Images
                    if (images.isNotEmpty)
                      SizedBox(
                        height: 280,
                        child: PageView.builder(
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            return Image.network(
                              images[index],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholderImage(),
                            );
                          },
                        ),
                      )
                    else
                      _placeholderImage(),

                    const SizedBox(height: 20),

                    // Price
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          if (price != null)
                            Row(
                              children: [
                                if (calculatedNewPrice != null)
                                  Text(
                                    "\$${price.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  )
                                else
                                  Text(
                                    "\$${price.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                if (calculatedNewPrice != null) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    "\$${calculatedNewPrice.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          const Spacer(),
                          if (discount != null && discount > 0)
                            Text(
                              "${discount.toStringAsFixed(0)}% OFF",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        (productData['description'] == null ||
                                productData['description']
                                    .toString()
                                    .trim()
                                    .isEmpty)
                            ? 'No description available'
                            : productData['description'],
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.4,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Chips
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (productData['category'] == 'Thobes' &&
                              productData['gender'] != null)
                            _chip("${productData['gender']} Thobe")
                          else if (productData['category'] != null)
                            _chip(productData['category']),
                          if (isNewCollection) _chip("New Collection"),
                          if (isBestSeller) _chip("Best Seller"),
                          if (isFlashSale) _chip("Flash Sale"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Colors
                    if (colors.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.color_lens,
                              size: 20,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Wrap(
                                spacing: 8,
                                children:
                                    colors.map<Widget>((colorValue) {
                                      return Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: Color(colorValue),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Sizes
                    if (sizes.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.straighten,
                              size: 20,
                              color: Colors.deepOrange,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                sizes.join(', '),
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Accessories
                    if (accessories.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.extension,
                              size: 20,
                              color: Colors.purple,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                accessories.join(', '),
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Bottom Edit Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  final updatedData = await Get.to(
                    () => const EditProductScreen(),
                    arguments: {
                      'productId': productId,
                      'productData': productData,
                    },
                  );

                  if (updatedData != null) {
                    setState(() {
                      productData = Map<String, dynamic>.from(updatedData);
                    });
                  }
                },
                child: const Text(
                  "Edit Product",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      height: 280,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
      ),
    );
  }

  Widget _chip(String text) {
    return Chip(
      label: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: themeColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }
}
