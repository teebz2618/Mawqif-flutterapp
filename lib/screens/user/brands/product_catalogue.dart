import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';
import '../../../services/currency_helper.dart';
import '../user_home/user_product_detail.dart';

class ProductCatalogueScreen extends StatefulWidget {
  final Map<String, dynamic> brandData;

  const ProductCatalogueScreen({super.key, required this.brandData});

  @override
  State<ProductCatalogueScreen> createState() => _ProductCatalogueScreenState();
}

class _ProductCatalogueScreenState extends State<ProductCatalogueScreen> {
  String searchQuery = "";
  final CurrencyHelper _currencyHelper = CurrencyHelper();
  final Map<String, Map<String, dynamic>> _priceCache = {};

  @override
  void initState() {
    super.initState();
  }

  Stream<QuerySnapshot> getProductsStream() {
    final brandId = widget.brandData['id'];
    return FirebaseFirestore.instance
        .collection('products')
        .where('brandId', isEqualTo: brandId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<Map<String, dynamic>> _getCachedPrice(
    String productId,
    double basePrice,
    double discount,
  ) async {
    if (_priceCache.containsKey(productId)) return _priceCache[productId]!;

    final convertedPrice = await _currencyHelper.convertPrice(basePrice);
    final discountedPrice =
        discount > 0
            ? convertedPrice - (convertedPrice * discount / 100)
            : null;

    final priceData = {
      'convertedPrice': convertedPrice,
      'discountedPrice': discountedPrice,
    };
    _priceCache[productId] = priceData;
    return priceData;
  }

  @override
  Widget build(BuildContext context) {
    final currency = _currencyHelper.currency;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.brandData['name'] ?? "Brand Products"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () {
              showCountryPicker(
                context: context,
                showPhoneCode: false,
                onSelect: (Country country) {
                  _currencyHelper.setCountry(country);
                  setState(() {});
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (value) {
                setState(() => searchQuery = value.toLowerCase());
              },
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search, color: Colors.brown),
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
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final products = snapshot.data!.docs;

                // Apply search
                final filteredProducts =
                    products.where((doc) {
                      final product = doc.data() as Map<String, dynamic>;
                      final title =
                          (product['title'] ?? '').toString().toLowerCase();
                      return title.contains(searchQuery);
                    }).toList();

                if (filteredProducts.isEmpty) {
                  return const Center(
                    child: Text(
                      "No products found.",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 280,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product =
                        filteredProducts[index].data() as Map<String, dynamic>;
                    final id = filteredProducts[index].id;

                    final title = product['title'] ?? 'No Title';
                    final basePrice =
                        (product['price'] as num?)?.toDouble() ?? 0.0;
                    final discount =
                        (product['discount'] as num?)?.toDouble() ?? 0.0;
                    final imageUrl =
                        (product['images'] != null &&
                                (product['images'] as List).isNotEmpty)
                            ? product['images'][0]
                            : null;

                    return FutureBuilder<Map<String, dynamic>>(
                      future: _getCachedPrice(id, basePrice, discount),
                      builder: (context, priceSnapshot) {
                        if (!priceSnapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final convertedPrice =
                            priceSnapshot.data!['convertedPrice'] as double;
                        final discountedPrice =
                            priceSnapshot.data!['discountedPrice'] as double?;

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
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
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
                                                "${currency.symbol}${convertedPrice.toStringAsFixed(2)}",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                  decoration:
                                                      TextDecoration
                                                          .lineThrough,
                                                ),
                                              ),
                                              Text(
                                                "${currency.symbol}${discountedPrice.toStringAsFixed(2)}",
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          )
                                          : Text(
                                            "${currency.symbol}${convertedPrice.toStringAsFixed(2)}",
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
