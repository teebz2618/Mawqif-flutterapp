import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawqif/constants/app_colors.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:mawqif/screens/user/user_home/wishlist/wishlist_provider.dart';
import 'package:provider/provider.dart';
import '../../../services/cart_service.dart';

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
      body: ChangeNotifierProvider(
        create: (_) => WishlistProvider(),
        child: Consumer<WishlistProvider>(
          builder:
              (context, wishlistProvider, child) => Column(
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
                                      if (notification
                                          is ScrollStartNotification) {
                                        _isUserInteracting = true;
                                      } else if (notification
                                          is ScrollEndNotification) {
                                        _isUserInteracting = false;
                                      }
                                      return false;
                                    },
                                    child: Listener(
                                      onPointerDown:
                                          (_) => _isUserInteracting = true,
                                      onPointerUp:
                                          (_) => _isUserInteracting = false,
                                      child: PhotoViewGallery.builder(
                                        itemCount: images.length,
                                        pageController: _pageController,
                                        onPageChanged:
                                            (index) => setState(
                                              () => _currentPage = index,
                                            ),
                                        builder:
                                            (context, index) =>
                                                PhotoViewGalleryPageOptions(
                                                  imageProvider: NetworkImage(
                                                    images[index],
                                                  ),
                                                  minScale:
                                                      PhotoViewComputedScale
                                                          .contained,
                                                  maxScale:
                                                      PhotoViewComputedScale
                                                          .covered *
                                                      2,
                                                ),
                                        scrollPhysics:
                                            const BouncingScrollPhysics(),
                                        backgroundDecoration:
                                            const BoxDecoration(
                                              color: Colors.white,
                                            ),
                                      ),
                                    ),
                                  ),
                                  // Wishlist button on image
                                  Positioned(
                                    top: 16,
                                    right: 16,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        icon: AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          child: Icon(
                                            wishlistProvider.isInWishlist(
                                                  productId,
                                                )
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            key: ValueKey(
                                              wishlistProvider.isInWishlist(
                                                productId,
                                              ),
                                            ),
                                            color:
                                                wishlistProvider.isInWishlist(
                                                      productId,
                                                    )
                                                    ? Colors.red
                                                    : Colors.grey,
                                            size: 28,
                                          ),
                                        ),
                                        onPressed: () {
                                          wishlistProvider.toggleWishlist(
                                            productId,
                                            productData,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  // Page indicators
                                  if (images.length > 1)
                                    Positioned(
                                      bottom: 16,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: List.generate(
                                            images.length,
                                            (index) => Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 2,
                                                  ),
                                              width: 6,
                                              height: 6,
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
                                          "Rs.${price.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                            decoration:
                                                TextDecoration.lineThrough,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        )
                                      else
                                        Text(
                                          "Rs.${price.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      if (calculatedNewPrice != null) ...[
                                        const SizedBox(width: 6),
                                        Text(
                                          "Rs.${calculatedNewPrice.toStringAsFixed(2)}",
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
                              (productData['description']
                                          ?.toString()
                                          .trim()
                                          .isEmpty ??
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

                          // Colors
                          if (colors.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
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

                          const SizedBox(height: 10),

                          // Sizes
                          if (sizes.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
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
                              onPressed: () {
                                if (productData.isEmpty) return;

                                // ✅ Validation
                                if ((productData['colors']?.isNotEmpty ??
                                        false) &&
                                    _selectedColorIndex == null) {
                                  Get.snackbar(
                                    "Select Color",
                                    "Please choose a color before adding to cart",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                  return;
                                }
                                if ((productData['sizes']?.isNotEmpty ??
                                        false) &&
                                    _selectedSizeIndex == null) {
                                  Get.snackbar(
                                    "Select Size",
                                    "Please choose a size before adding to cart",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                  return;
                                }

                                final cartItem = {
                                  'id': productId,
                                  'title': productData['title'],
                                  'price': productData['price'] ?? 0.0,
                                  'discount': productData['discount'] ?? 0.0,
                                  'image':
                                      (productData['images'] != null &&
                                              productData['images'].isNotEmpty)
                                          ? productData['images'][0]
                                          : '',
                                  'quantity': 1,
                                  'selectedColor':
                                      _selectedColorIndex != null
                                          ? productData['colors'][_selectedColorIndex!]
                                              .toString()
                                          : null,
                                  'selectedSize':
                                      _selectedSizeIndex != null
                                          ? productData['sizes'][_selectedSizeIndex!]
                                              .toString()
                                          : null,
                                };

                                CartService.to.addToCart(cartItem);

                                Get.snackbar(
                                  "Success",
                                  "Product added to cart successfully!",
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green.shade600,
                                  colorText: Colors.white,
                                  duration: const Duration(seconds: 3),
                                  mainButton: TextButton(
                                    onPressed: () => Get.toNamed('/wishlist'),
                                    child: const Text(
                                      "View Wishlist",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
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
        ),
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
}
