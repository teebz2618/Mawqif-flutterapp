import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawqif/constants/app_colors.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

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
  bool _isUserInteracting = false;

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
        if (!_isUserInteracting && _pageController!.hasClients) {
          _currentPage = (_currentPage + 1) % images.length;
          _pageController!.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 400),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          productData['title'] ?? 'Product Detail',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.brown,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Carousel with Zoom
                  if (images.isNotEmpty)
                    SizedBox(
                      height: 430,
                      width: double.infinity,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (notification is ScrollStartNotification) {
                                _isUserInteracting =
                                    true; // user touched/scroll started
                              } else if (notification
                                  is ScrollEndNotification) {
                                _isUserInteracting = false; // user released
                              }
                              return false;
                            },
                            child: Listener(
                              onPointerDown: (_) => _isUserInteracting = true,
                              onPointerUp: (_) => _isUserInteracting = false,
                              child: PhotoViewGallery.builder(
                                itemCount: images.length,
                                pageController: _pageController,
                                onPageChanged:
                                    (index) =>
                                        setState(() => _currentPage = index),
                                builder:
                                    (context, index) =>
                                        PhotoViewGalleryPageOptions(
                                          imageProvider: NetworkImage(
                                            images[index],
                                          ),
                                          minScale:
                                              PhotoViewComputedScale.contained,
                                          maxScale:
                                              PhotoViewComputedScale.covered *
                                              2,
                                        ),
                                scrollPhysics: const BouncingScrollPhysics(),
                                backgroundDecoration: const BoxDecoration(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          // Dots Indicator
                          Positioned(
                            bottom: 8,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                images.length,
                                (index) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  width: _currentPage == index ? 10 : 6,
                                  height: _currentPage == index ? 10 : 6,
                                  decoration: BoxDecoration(
                                    color:
                                        _currentPage == index
                                            ? Colors.brown
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
                    _placeholderImage(height: 430),

                  const SizedBox(height: 12),

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
                                    decoration: TextDecoration.lineThrough,
                                    fontWeight: FontWeight.w500,
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

                  const SizedBox(height: 10),

                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      (productData['description']?.toString().trim().isEmpty ??
                              true)
                          ? 'No description available'
                          : productData['description'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Tags / Chips
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (productData['category'] != null &&
                            productData['category'].toString().isNotEmpty)
                          _chip(productData['category'].toString()),
                        if (productData['isNewCollection'] == true)
                          _chip("New Collection"),
                        if (productData['isBestSeller'] == true)
                          _chip("Best Seller"),
                        if (productData['isFlashSale'] == true)
                          _chip("Flash Sale"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Colors
                  if (colors.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Colors Available",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.brown.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: List.generate(
                              colors.length,
                              (index) => GestureDetector(
                                onTap:
                                    () => setState(
                                      () => _selectedColorIndex = index,
                                    ),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Color(colors[index]),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          _selectedColorIndex == index
                                              ? Colors.black
                                              : Colors.grey.shade300,
                                      width:
                                          _selectedColorIndex == index ? 2 : 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 10),

                  // Sizes
                  if (sizes.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Sizes Available",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.brown.shade600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
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
                                    fontSize: 13,
                                  ),
                                ),
                                selected: _selectedSizeIndex == index,
                                selectedColor: Colors.brown,
                                onSelected:
                                    (_) => setState(
                                      () => _selectedSizeIndex = index,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 10),

                  // Accessories
                  if (accessories.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Accessories: ${accessories.join(', ')}",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: softBeige,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Add to Cart",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Buy Now",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImage({double? height}) => Container(
    height: height ?? 280,
    width: double.infinity,
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
    backgroundColor: primaryBrown,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
  );
}
