import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mawqif/screens/user/user_home/user_product_detail.dart';
import 'package:mawqif/screens/user/user_home/wishlist/wishlist.dart';

import '../../../services/cart_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0; // 0 = Newest, 1 = Sale, 2 = Best Sellers
  String _selectedCountry = "Pakistan"; // Default country
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _autoDetectCountry();
  }

  void _autoDetectCountry() {
    // In real app, you can use Geolocator or Localizations.localeOf(context)
    setState(() {
      _selectedCountry = "Pakistan";
    });
  }

  // --- WISHLIST FUNCTIONS ---
  Future<void> _toggleWishlist(
    String productId,
    Map<String, dynamic> product,
  ) async {
    if (_user == null) return;
    final wishlistRef = FirebaseFirestore.instance
        .collection('wishlists')
        .doc(_user!.uid)
        .collection('items')
        .doc(productId);

    final doc = await wishlistRef.get();
    if (doc.exists) {
      await wishlistRef.delete();
      Get.snackbar("Wishlist", "Removed from wishlist");
    } else {
      await wishlistRef.set(product);
      Get.snackbar("Wishlist", "Added to wishlist");
    }
  }

  Stream<bool> _isInWishlist(String productId) {
    if (_user == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('wishlists')
        .doc(_user!.uid)
        .collection('items')
        .doc(productId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  Stream<QuerySnapshot> getProductsStream() {
    Query query = FirebaseFirestore.instance.collection('products');
    if (_selectedTab == 0) {
      query = query.where('isNewCollection', isEqualTo: true);
    } else if (_selectedTab == 1) {
      query = query.where('isFlashSale', isEqualTo: true);
    } else if (_selectedTab == 2) {
      query = query.where('isBestSeller', isEqualTo: true);
    }
    return query.orderBy('createdAt', descending: true).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Location, Title & Wishlist ---
                Row(
                  children: [
                    // Location
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.brown.shade800,
                            size: 22,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            _selectedCountry,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Title
                    Text(
                      "Mawqif",
                      style: const TextStyle(
                        color: Colors.brown,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    // Wishlist
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.favorite_border, size: 26),
                          onPressed: () => Get.to(() => WishlistScreen()),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),

                // --- Banner Carousel ---
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection("promotional_banners")
                          .orderBy("createdAt", descending: true)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const SizedBox(
                        height: 150,
                        child: Center(child: Text("No banners available.")),
                      );
                    }
                    final banners = snapshot.data!.docs;
                    return CarouselSlider.builder(
                      itemCount: banners.length,
                      options: CarouselOptions(
                        height: 150,
                        autoPlay: true,
                        enlargeCenterPage: true,
                        viewportFraction: 0.9,
                      ),
                      itemBuilder: (context, index, realIndex) {
                        final data =
                            banners[index].data() as Map<String, dynamic>;
                        final imageUrl = data['imageUrl'] ?? "";
                        final title = data['title'] ?? "";
                        final subtitle = data['subtitle'] ?? "";
                        final link = data['link'] as Map<String, dynamic>?;

                        return GestureDetector(
                          onTap: () async {
                            if (link != null && link['type'] == 'product') {
                              final doc =
                                  await FirebaseFirestore.instance
                                      .collection('products')
                                      .doc(link['targetId'])
                                      .get();
                              if (doc.exists) {
                                Get.to(
                                  () => const UserProductDetail(),
                                  arguments: {
                                    'productId': doc.id,
                                    'productData': doc.data()!,
                                  },
                                );
                              }
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image:
                                  imageUrl.isNotEmpty
                                      ? DecorationImage(
                                        image: NetworkImage(imageUrl),
                                        fit: BoxFit.cover,
                                      )
                                      : null,
                              gradient:
                                  imageUrl.isEmpty
                                      ? const LinearGradient(
                                        colors: [Colors.purple, Colors.pink],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                      : null,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    subtitle,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),

                // --- Categories & Accessories ---
                const Text(
                  "Category",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildCategoryCard(context, "Thobes", Icons.male),
                    const SizedBox(width: 12),
                    _buildCategoryCard(context, "Abayas", Icons.female),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "Accessories",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _buildAccessoryCard("Scarfs", Icons.checkroom),
                    _buildAccessoryCard(
                      "Keffiyeh/Shemagh",
                      Icons.accessibility,
                    ),
                    _buildAccessoryCard("Scarf Pins", Icons.push_pin),
                    _buildAccessoryCard("Niqab", Icons.face_retouching_natural),
                  ],
                ),
                const SizedBox(height: 25),

                // --- Product Tabs ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTab("Newest", 0),
                    _buildTab("Sale", 1),
                    _buildTab("Best Sellers", 2),
                  ],
                ),
                const SizedBox(height: 15),

                // --- Products Grid ---
                StreamBuilder<QuerySnapshot>(
                  stream: getProductsStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final products = snapshot.data!;
                    if (products.docs.isEmpty) {
                      return const Center(child: Text("No products found"));
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.docs.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.47,
                          ),
                      itemBuilder: (context, index) {
                        final product =
                            products.docs[index].data() as Map<String, dynamic>;
                        final id = products.docs[index].id;
                        return _buildProductCard(product, id);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- CATEGORY & ACCESSORY CARDS ---
  Widget _buildCategoryCard(BuildContext context, String title, IconData icon) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (title == "Thobes") {
            Get.toNamed('/thobeScreen');
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => Scaffold(
                      appBar: AppBar(title: Text(title)),
                      body: _buildProductListByFilter(
                        field: title == "Abayas" ? 'category' : 'accessory',
                        value: title,
                      ),
                    ),
              ),
            );
          }
        },
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.brown.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccessoryCard(String title, IconData icon) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => Scaffold(
                  appBar: AppBar(title: Text(title)),
                  body: _buildProductListByFilter(
                    field: 'accessories',
                    value: title,
                  ),
                ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: Theme.of(context).primaryColor),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB ---
  Widget _buildTab(String title, int index) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  // --- PRODUCT LIST BY FILTER ---
  Widget _buildProductListByFilter({
    required String field,
    required String value,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          (field == 'accessories')
              ? FirebaseFirestore.instance
                  .collection('products')
                  .where('accessories', arrayContains: value)
                  .snapshots()
              : FirebaseFirestore.instance
                  .collection('products')
                  .where(field, isEqualTo: value)
                  .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final products = snapshot.data!.docs;
        if (products.isEmpty)
          return const Center(child: Text("No products found"));
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.56,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index].data() as Map<String, dynamic>;
            final id = products[index].id;
            return _buildProductCard(product, id, showButtons: false);
          },
        );
      },
    );
  }

  // --- PRODUCT CARD WITH WISHLIST ---
  Widget _buildProductCard(
    Map<String, dynamic> product,
    String id, {
    bool showButtons = true,
  }) {
    final title = product['title'] ?? 'No Title';
    final description =
        (product['description'] as String?)?.isNotEmpty == true
            ? product['description']
            : 'No description available';
    final basePrice = (product['price'] as num?)?.toDouble() ?? 0.0;
    final discount = (product['discount'] as num?)?.toDouble() ?? 0.0;
    final imageUrl =
        (product['images'] != null && (product['images'] as List).isNotEmpty)
            ? product['images'][0]
            : null;
    final brandName = product['brandName'] ?? 'Unknown Brand';
    double? discountedPrice =
        discount > 0 ? basePrice - (basePrice * discount / 100) : null;

    Widget priceSection =
        discountedPrice != null
            ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Rs.${basePrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      "Rs.${discountedPrice.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${discount.toStringAsFixed(0)}% OFF",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            )
            : Text(
              "Rs.${basePrice.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            );

    return GestureDetector(
      onTap:
          () => Get.to(
            () => const UserProductDetail(),
            arguments: {'productId': id, 'productData': product},
          ),
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 160,
              width: double.infinity,
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade300, width: 0.5),
                ),
                child:
                    imageUrl != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(imageUrl, fit: BoxFit.cover),
                        )
                        : const Icon(
                          Icons.image_outlined,
                          size: 35,
                          color: Colors.grey,
                        ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                brandName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  priceSection,
                ],
              ),
            ),
            if (showButtons) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        side: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () {
                        if (product.isEmpty) return;

                        // If colors exist, select the first one by default
                        String? selectedColor;
                        if ((product['colors']?.isNotEmpty ?? false)) {
                          selectedColor = product['colors'][0].toString();
                        }

                        // If sizes exist, select the first one by default
                        String? selectedSize;
                        if ((product['sizes']?.isNotEmpty ?? false)) {
                          selectedSize = product['sizes'][0].toString();
                        }

                        final cartItem = {
                          'id': id,
                          'title': product['title'],
                          'price': product['price'] ?? 0.0,
                          'discount': product['discount'] ?? 0.0,
                          'image':
                              (product['images'] != null &&
                                      product['images'].isNotEmpty)
                                  ? product['images'][0]
                                  : '',
                          'quantity': 1,
                          'selectedColor': selectedColor,
                          'selectedSize': selectedSize,
                        };

                        CartService.to.addToCart(cartItem);

                        Get.snackbar(
                          "Success",
                          "Product added to cart successfully!",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green.shade600,
                          colorText: Colors.white,
                          margin: const EdgeInsets.only(
                            bottom: 70,
                            left: 12,
                            right: 12,
                          ),
                          duration: const Duration(seconds: 2),
                          mainButton: TextButton(
                            onPressed: () => Get.toNamed('/cart'),
                            child: const Text(
                              "View Cart",
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
                        style: TextStyle(fontSize: 12),
                      ),
                    ),

                    StreamBuilder<bool>(
                      stream: _isInWishlist(id),
                      builder: (context, snapshot) {
                        bool isFav = snapshot.data ?? false;
                        return IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          onPressed: () => _toggleWishlist(id, product),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
