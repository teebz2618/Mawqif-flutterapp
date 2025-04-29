import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

class Accessories extends StatelessWidget {
  final String? category;
  final String? accessory;

  const Accessories({Key? key, this.category, this.accessory})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance.collection("products");

    // Apply filters
    if (category != null) {
      query = query.where("category", isEqualTo: category);
    }
    if (accessory != null) {
      query = query.where("accessories", arrayContains: accessory);
    }

    query = query.orderBy("createdAt", descending: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          category ?? accessory ?? "Products",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
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
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.7,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final doc = products[index];
              final product = doc.data() as Map<String, dynamic>;
              final productId = doc.id;

              return GestureDetector(
                onTap: () {
                  Get.toNamed(
                    AppRoutes.userProductDetail,
                    arguments: {'productId': productId, 'productData': product},
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image.network(
                            product['images'][0],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Title + Price
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  "\$${product['price']}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                if (product['discount'] != null &&
                                    product['discount'] > 0) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    "-${product['discount']}%",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ],
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
    );
  }
}
