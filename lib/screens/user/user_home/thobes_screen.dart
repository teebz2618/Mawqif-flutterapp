import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mawqif/screens/user/user_home/user_product_detail.dart';
import 'package:country_picker/country_picker.dart';
import 'package:intl/intl.dart';
import '../../../services/currency_helper.dart';

class ThobesScreen extends StatefulWidget {
  const ThobesScreen({super.key});

  @override
  State<ThobesScreen> createState() => _ThobesScreenState();
}

class _ThobesScreenState extends State<ThobesScreen> {
  int _selectedGenderTab = 0; // 0 = Male, 1 = Female
  final CurrencyHelper _currencyHelper = CurrencyHelper();

  // Cache converted prices to reduce FutureBuilder reload flicker
  final Map<String, Map<String, dynamic>> _priceCache = {};

  @override
  void initState() {
    super.initState();
  }

  Stream<QuerySnapshot> getThobesStream() {
    final gender = _selectedGenderTab == 0 ? "Male" : "Female";
    return FirebaseFirestore.instance
        .collection('products')
        .where('category', isEqualTo: "Thobes")
        .where('gender', isEqualTo: gender)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thobes"),
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
          // --- Gender Tabs ---
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: _buildGenderTab("Male", 0)),
                const SizedBox(width: 12),
                Expanded(child: _buildGenderTab("Female", 1)),
              ],
            ),
          ),

          // --- Products Grid ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getThobesStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final products = snapshot.data!.docs;
                if (products.isEmpty) {
                  return const Center(child: Text("No Thobes found"));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 289,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product =
                        products[index].data() as Map<String, dynamic>;
                    final id = products[index].id;

                    return _buildProductCard(product, id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Gender Tab ---
  Widget _buildGenderTab(String title, int index) {
    final isSelected = _selectedGenderTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedGenderTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.brown : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: isSelected ? Colors.brown : Colors.grey),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  // --- Product Card with Cached Currency Conversion ---
  Widget _buildProductCard(Map<String, dynamic> product, String id) {
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

    return FutureBuilder<Map<String, dynamic>>(
      future: _getCachedPrice(id, basePrice, discount),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final convertedPrice = snapshot.data!['convertedPrice'] as double;
        final discountedPrice = snapshot.data!['discountedPrice'] as double?;
        final currency = _currencyHelper.currency;

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
                // Image
                SizedBox(
                  height: 190,
                  width: double.infinity,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 0.5,
                      ),
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
                      const SizedBox(height: 4),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      discountedPrice != null
                          ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                NumberFormat.currency(
                                  locale: 'en_US',
                                  name: currency.code,
                                  symbol: currency.symbol,
                                ).format(convertedPrice),
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
                                    NumberFormat.currency(
                                      locale: 'en_US',
                                      name: currency.code,
                                      symbol: currency.symbol,
                                    ).format(discountedPrice),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 7),
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
                            NumberFormat.currency(
                              locale: 'en_US',
                              name: currency.code,
                              symbol: currency.symbol,
                            ).format(convertedPrice),
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
  }

  // --- Get Cached Price ---
  Future<Map<String, dynamic>> _getCachedPrice(
    String productId,
    double basePrice,
    double discount,
  ) async {
    if (_priceCache.containsKey(productId)) {
      return _priceCache[productId]!;
    }

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
}
