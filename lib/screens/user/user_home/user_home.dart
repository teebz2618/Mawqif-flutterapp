import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mawqif/screens/user/user_home/accessories.dart';
import 'package:mawqif/screens/user/user_home/product_categories.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _country = "Detecting...";
  int _selectedTab = -1; // 0 = Newest, 1 = Sale, 2 = Best Sellers

  Stream<QuerySnapshot> getProductsStream() {
    // Start with the products collection
    Query query = FirebaseFirestore.instance.collection('products');

    // Filter by selected tab
    if (_selectedTab == 0) {
      query = query.where('isNewCollection', isEqualTo: true);
    } else if (_selectedTab == 1) {
      query = query.where('isFlashSale', isEqualTo: true);
    } else if (_selectedTab == 2) {
      query = query.where('isBestSeller', isEqualTo: true);
    }

    // Order by createdAt descending
    return query.orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot> getAccessoriesStream() {
    return FirebaseFirestore.instance
        .collection('products')
        .where('category', isEqualTo: 'Accessories')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        setState(() {
          _country = placemarks.first.country ?? "Unknown";
        });
      }
    } catch (e) {
      setState(() {
        _country = "Unavailable";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String category =
        _selectedTab == 0
            ? "Newest"
            : _selectedTab == 1
            ? "Sale"
            : "Best Sellers";

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// --- Top bar (Location + Wishlist) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.grey),
                        const SizedBox(width: 5),
                        Text(
                          _country,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.favorite_border,
                        color: Colors.black,
                        size: 26,
                      ),
                      onPressed: () {
                        // Navigate to Wishlist
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                /// --- Carousel (New Collection) ---
                CarouselSlider(
                  items: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: const LinearGradient(
                          colors: [Colors.purple, Colors.pink],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          "New Collection\nDiscover our latest arrivals",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                  options: CarouselOptions(
                    height: 150,
                    autoPlay: true,
                    enlargeCenterPage: true,
                  ),
                ),

                const SizedBox(height: 20),

                /// --- Category Section ---
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

                /// --- Accessories Section ---
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
                    _buildAccessoryCard("Hijab/Scarfs", Icons.checkroom),
                    _buildAccessoryCard(
                      "Keffiyeh/Shemagh",
                      Icons.accessibility,
                    ),
                    _buildAccessoryCard("Scarf Pins", Icons.push_pin),
                    _buildAccessoryCard("Niqab", Icons.face_retouching_natural),
                  ],
                ),

                const SizedBox(height: 25),

                /// --- Product Tabs ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTab("Newest", 0),
                    _buildTab("Sale", 1),
                    _buildTab("Best Sellers", 2),
                  ],
                ),

                const SizedBox(height: 15),
                _selectedTab == -1
                    ? const SizedBox.shrink()
                    : StreamBuilder<QuerySnapshot>(
                      stream: getProductsStream(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
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
                                childAspectRatio: 0.65,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                              ),
                          itemBuilder: (context, index) {
                            final product =
                                products.docs[index].data()
                                    as Map<String, dynamic>;
                            return _buildProductCard(
                              product["title"],
                              "\$${product["price"]}",
                              product["images"] != null &&
                                      product["images"].isNotEmpty
                                  ? product["images"][0]
                                  : null,
                            );
                          },
                        );
                      },
                    ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, IconData icon) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryProductsScreen(category: title),
            ),
          );
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
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
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
          MaterialPageRoute(builder: (_) => Accessories(accessory: title)),
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

  /// Fixed Tab Widget
  Widget _buildTab(String title, int index) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
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

  Widget _buildProductCard(String title, String price, String? imageUrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
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
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => const Icon(
                                Icons.broken_image,
                                size: 35,
                                color: Colors.grey,
                              ),
                        ),
                      )
                      : const Icon(
                        Icons.image_outlined,
                        size: 35,
                        color: Colors.grey,
                      ),
            ),
          ),

          /// Product Details
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
