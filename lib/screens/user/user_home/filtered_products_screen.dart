import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mawqif/screens/user/user_home/user_product_detail.dart';
import 'package:mawqif/services/currency_service.dart';
import 'package:country_picker/country_picker.dart';

class FilteredProductsScreen extends StatefulWidget {
  final String field; // e.g. "category", "accessories"
  final dynamic value; // e.g. "Abayas", "Niqab", true

  const FilteredProductsScreen({
    super.key,
    required this.field,
    required this.value,
  });

  @override
  State<FilteredProductsScreen> createState() => _FilteredProductsScreenState();
}

class _FilteredProductsScreenState extends State<FilteredProductsScreen> {
  Country? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = Country.parse("US"); // default
  }

  Stream<QuerySnapshot> getFilteredProducts() {
    if (widget.field == 'accessories') {
      return FirebaseFirestore.instance
          .collection('products')
          .where('accessories', arrayContains: widget.value)
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('products')
          .where(widget.field, isEqualTo: widget.value)
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.value.toString())),
      body: StreamBuilder<QuerySnapshot>(
        stream: getFilteredProducts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final products = snapshot.data!.docs;
          if (products.isEmpty) {
            return const Center(child: Text("No products found"));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 390,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index].data() as Map<String, dynamic>;
              final id = products[index].id;
              return _buildProductCard(product, id);
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, String id) {
    final brandName = product['brandName'] ?? 'Unknown Brand';
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

    if (_selectedCountry == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final currency = CurrencyService.getCurrencyFromCountryCode(
      _selectedCountry!.countryCode,
    );

    return FutureBuilder<double>(
      future: CurrencyService.convertPrice(
        basePrice,
        fromCurrency: "USD",
        toCurrency: currency.code,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final convertedPrice = snapshot.data ?? basePrice;
        final discountedPrice =
            (discount > 0)
                ? convertedPrice - (convertedPrice * discount / 100)
                : null;

        Widget priceSection =
            discountedPrice != null
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      NumberFormat.currency(
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
                : SizedBox(
                  height: 38,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      NumberFormat.currency(
                        name: currency.code,
                        symbol: currency.symbol,
                      ).format(convertedPrice),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      priceSection,
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
}
