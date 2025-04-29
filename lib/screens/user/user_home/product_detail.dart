import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_colors.dart';

class UserProductDetail extends StatefulWidget {
  const UserProductDetail({super.key});

  @override
  State<UserProductDetail> createState() => _UserProductDetailState();
}

class _UserProductDetailState extends State<UserProductDetail> {
  late String productId;
  late Map<String, dynamic> productData;

  int? _selectedColorIndex;
  int? _selectedSizeIndex;

  PageController? _pageController;
  int _currentPage = 0;
  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments ?? {};
    productId = args['productId'] ?? '';
    productData = Map<String, dynamic>.from(args['productData'] ?? {});

    final List images = productData['images'] ?? [];
    if (images.isNotEmpty) {
      _pageController = PageController(initialPage: 0);
      _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (_pageController!.hasClients) {
          _currentPage++;
          if (_currentPage >= images.length) _currentPage = 0;
          _pageController!.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List images = productData['images'] ?? [];
    final List colors = productData['colors'] ?? [];
    final List sizes = productData['sizes'] ?? [];
    final List accessories = productData['accessories'] ?? [];

    final double? price = double.tryParse(
      productData['price']?.toString() ?? '',
    );
    final double? discount = double.tryParse(
      productData['discount']?.toString() ?? '',
    );
    final double? calculatedNewPrice =
        (price != null && discount != null && discount > 0)
            ? price - (price * discount / 100)
            : null;

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

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (images.isNotEmpty)
                      SizedBox(
                        height: 300,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              itemCount: images.length,
                              itemBuilder:
                                  (_, index) => ClipRRect(
                                    child: Image.network(
                                      images[index],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder:
                                          (_, __, ___) => _placeholderImage(),
                                    ),
                                  ),
                            ),
                            // Page Indicator Dots
                            Positioned(
                              bottom: 10,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  images.length,
                                  (index) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    width: _currentPage == index ? 12 : 8,
                                    height: _currentPage == index ? 12 : 8,
                                    decoration: BoxDecoration(
                                      color:
                                          _currentPage == index
                                              ? themeColor
                                              : Colors.grey.shade400,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      _placeholderImage(),

                    const SizedBox(height: 16),

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
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
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
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
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
                        productData['description']?.toString().trim().isEmpty ??
                                true
                            ? 'No description available'
                            : productData['description'],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Chips / Tags
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          // Category as a chip
                          if (productData['category'] != null &&
                              productData['category'].toString().isNotEmpty)
                            _chip(productData['category'].toString()),

                          // New Collection tag
                          if (productData['isNewCollection'] == true)
                            _chip("New Collection"),

                          // Best Seller tag
                          if (productData['isBestSeller'] == true)
                            _chip("Best Seller"),

                          // Flash Sale tag
                          if (productData['isFlashSale'] == true)
                            _chip("Flash Sale"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Colors - Selectable
                    if (colors.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.color_lens,
                                  color: Colors.blueGrey,
                                  size: 20,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "Select Color",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 10,
                              children: List.generate(
                                colors.length,
                                (index) => GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedColorIndex = index;
                                    });
                                  },
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Color(colors[index]),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            _selectedColorIndex == index
                                                ? Colors.black
                                                : Colors.grey.shade300,
                                        width:
                                            _selectedColorIndex == index
                                                ? 2
                                                : 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Sizes - Selectable
                    if (sizes.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.straighten,
                                  color: Colors.deepOrange,
                                  size: 20,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "Select Size",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 10,
                              children: List.generate(
                                sizes.length,
                                (index) => ChoiceChip(
                                  label: Text(
                                    sizes[index].toString(),
                                    style: TextStyle(
                                      color:
                                          _selectedSizeIndex == index
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                  ),
                                  selected: _selectedSizeIndex == index,
                                  selectedColor: themeColor,
                                  onSelected: (_) {
                                    setState(() {
                                      _selectedSizeIndex = index;
                                    });
                                  },
                                ),
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
                              color: Colors.purple,
                              size: 20,
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

            // Add to Cart Button
            Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    // TODO: Use _selectedColorIndex & _selectedSizeIndex here
                  },
                  child: const Text(
                    "Add to Cart",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),

            // Buy Now Button
            Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    // TODO: Use _selectedColorIndex & _selectedSizeIndex here
                  },
                  child: const Text(
                    "Buy Now",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() => Container(
    height: 280,
    color: Colors.grey[300],
    child: const Center(
      child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
    ),
  );

  Widget _chip(String text) => Chip(
    label: Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 12),
    ),
    backgroundColor: themeColor,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
  );
}
