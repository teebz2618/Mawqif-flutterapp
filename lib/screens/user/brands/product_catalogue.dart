import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../user_home/user_product_detail.dart';

class ProductCatalogueScreen extends StatefulWidget {
  const ProductCatalogueScreen({super.key});

  @override
  State<ProductCatalogueScreen> createState() => _ProductCatalogueScreenState();
}

class _ProductCatalogueScreenState extends State<ProductCatalogueScreen> {
  late Map<String, dynamic> brandData;
  String searchQuery = "";
  bool _loadingBrandInfo = true;
  Map<String, dynamic> _brandInfo = {};

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      brandData = args;
      if (brandData['id'] != null) {
        _loadBrandInfo();
      } else {
        _loadingBrandInfo = false;
      }
    } else {
      brandData = {};
      _loadingBrandInfo = false;
    }
  }

  Future<void> _loadBrandInfo() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('brands')
              .doc(brandData['id'])
              .get();

      if (doc.exists) {
        setState(() {
          _brandInfo = doc.data() ?? {};
          _loadingBrandInfo = false;
        });
      } else {
        setState(() => _loadingBrandInfo = false);
      }
    } catch (e) {
      setState(() => _loadingBrandInfo = false);
      debugPrint("Error loading brand info: $e");
    }
  }

  Stream<QuerySnapshot> getProductsStream() {
    final brandId = brandData['id'];
    return FirebaseFirestore.instance
        .collection('products')
        .where('brandId', isEqualTo: brandId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          brandData['name'] ?? "Brand Products",
          style: const TextStyle(
            color: Colors.brown,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body:
          _loadingBrandInfo
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Brand Info Header
                  if (_brandInfo.isNotEmpty)
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_brandInfo['country'] != null)
                            Text(
                              "Location: ${_brandInfo['country']}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          if (_brandInfo['returnDays'] != null)
                            Text(
                              "Return within ${_brandInfo['returnDays']} days",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          if (_brandInfo['shippingInfo'] != null)
                            Text(
                              "Ships to: ${(_brandInfo['shippingInfo'] as List).join(', ')}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() => searchQuery = value.toLowerCase());
                      },
                      decoration: InputDecoration(
                        hintText: "Search products...",
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.brown,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.brown.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.brown.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.brown.shade800,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Product Grid
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: getProductsStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Error: ${snapshot.error}"),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("No products found"));
                        }

                        final products = snapshot.data!.docs;

                        // Apply search
                        final filteredProducts =
                            products.where((doc) {
                              final product =
                                  doc.data() as Map<String, dynamic>;
                              final title =
                                  (product['title'] ?? '')
                                      .toString()
                                      .toLowerCase();
                              final category =
                                  (product['category'] ?? '')
                                      .toString()
                                      .toLowerCase();
                              final accessories =
                                  ((product['accessories'] ?? []) as List)
                                      .map((e) => e.toString().toLowerCase())
                                      .toList();
                              final query = searchQuery.toLowerCase();
                              return title.contains(query) ||
                                  category.contains(query) ||
                                  accessories.any((acc) => acc.contains(query));
                            }).toList();

                        if (filteredProducts.isEmpty) {
                          return const Center(
                            child: Text("No products match your search"),
                          );
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    MediaQuery.of(context).size.width > 600
                                        ? 3
                                        : 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                mainAxisExtent: 280,
                              ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product =
                                filteredProducts[index].data()
                                    as Map<String, dynamic>;
                            final id = filteredProducts[index].id;

                            final title = product['title'] ?? 'No Title';
                            final basePrice =
                                (product['price'] as num?)?.toDouble() ?? 0.0;
                            final discount =
                                (product['discount'] as num?)?.toDouble() ??
                                0.0;
                            final imageUrl =
                                (product['images'] != null &&
                                        (product['images'] as List).isNotEmpty)
                                    ? product['images'][0]
                                    : null;

                            final discountedPrice =
                                discount > 0
                                    ? basePrice - (basePrice * discount / 100)
                                    : null;

                            return GestureDetector(
                              onTap:
                                  () => Get.to(
                                    () => const UserProductDetail(),
                                    arguments: {
                                      'productId': id,
                                      'productData': product,
                                    },
                                  ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 0.5,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Image
                                    Expanded(
                                      child:
                                          imageUrl != null
                                              ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  imageUrl,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                              : const Icon(
                                                Icons.image_outlined,
                                                size: 50,
                                                color: Colors.grey,
                                              ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                          const SizedBox(height: 4),
                                          discountedPrice != null
                                              ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Rs ${basePrice.toStringAsFixed(0)}",
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                      decoration:
                                                          TextDecoration
                                                              .lineThrough,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Rs ${discountedPrice.toStringAsFixed(0)}",
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              )
                                              : Text(
                                                "Rs ${basePrice.toStringAsFixed(0)}",
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
