import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawqif/constants/app_colors.dart';
import 'package:mawqif/screens/user/user_home/wishlist/wishlist_provider.dart';
import 'package:provider/provider.dart';

class WishlistScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My Wishlist',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.brown,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Consumer<WishlistProvider>(
            builder: (context, wishlistProvider, child) {
              if (wishlistProvider.wishlistProducts.isEmpty) {
                return const SizedBox.shrink();
              }
              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'clear_all') {
                    _showClearAllDialog(context, wishlistProvider);
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'clear_all',
                        child: Row(
                          children: [
                            Icon(Icons.clear_all, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Clear All'),
                          ],
                        ),
                      ),
                    ],
              );
            },
          ),
        ],
      ),
      body: Consumer<WishlistProvider>(
        builder: (context, wishlistProvider, child) {
          if (wishlistProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.brown),
            );
          }

          if (wishlistProvider.wishlistProducts.isEmpty) {
            return _buildEmptyWishlist();
          }

          return RefreshIndicator(
            onRefresh: () => wishlistProvider.refreshWishlist(),
            color: Colors.brown,
            child: Column(
              children: [
                // Wishlist count header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Text(
                    '${wishlistProvider.wishlistCount} item${wishlistProvider.wishlistCount == 1 ? '' : 's'} in your wishlist',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: wishlistProvider.wishlistProducts.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final product = wishlistProvider.wishlistProducts[index];
                      return _buildWishlistItem(
                        context,
                        product,
                        wishlistProvider,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyWishlist() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border,
                size: 60,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Wishlist is Empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start adding items you love to your wishlist.\nTap the heart icon on any product to save it here.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistItem(
    BuildContext context,
    Map<String, dynamic> product,
    WishlistProvider wishlistProvider,
  ) {
    final String productId = product['id'] ?? '';
    final List images = product['images'] ?? [];
    final String imageUrl = images.isNotEmpty ? images[0] : '';

    final double? price = double.tryParse(product['price']?.toString() ?? '');
    final double? discount = double.tryParse(
      product['discount']?.toString() ?? '',
    );
    final double? calculatedNewPrice =
        (price != null && discount != null && discount > 0)
            ? price - (price * discount / 100)
            : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Navigate to product detail page
          print('Navigating to product: $productId');
          Get.toNamed(
            '/userProductDetail',
            arguments: {'productId': productId, 'productData': product},
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      imageUrl.isNotEmpty
                          ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                ),
                          )
                          : const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                ),
              ),

              const SizedBox(width: 12),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['title'] ?? 'Product Name',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    if (product['category'] != null)
                      Text(
                        product['category'],
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),

                    const SizedBox(height: 8),

                    // Price
                    Row(
                      children: [
                        if (price != null) ...[
                          if (calculatedNewPrice != null) ...[
                            // Show discounted price scenario
                            Text(
                              "\$${calculatedNewPrice.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "\$${price.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ] else ...[
                            // Show regular price
                            Text(
                              "\$${price.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ],
                        const Spacer(),
                        if (discount != null && discount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "${discount.toStringAsFixed(0)}% OFF",
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 32,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: softBeige,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () {
                                // Add to cart functionality
                                // You can implement this later
                                Get.snackbar(
                                  "Cart",
                                  "Added to cart", // You'll implement this
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                              },
                              child: const Text(
                                "Add to Cart",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Remove from wishlist button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () {
                              _showRemoveDialog(
                                context,
                                productId,
                                product['title'] ?? 'this item',
                                wishlistProvider,
                              );
                            },
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
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

  void _showRemoveDialog(
    BuildContext context,
    String productId,
    String productTitle,
    WishlistProvider wishlistProvider,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Remove from Wishlist'),
        content: Text(
          'Are you sure you want to remove "$productTitle" from your wishlist?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              wishlistProvider.removeFromWishlist(productId);
              Get.back();
            },
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(
    BuildContext context,
    WishlistProvider wishlistProvider,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear Wishlist'),
        content: const Text(
          'Are you sure you want to remove all items from your wishlist?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              wishlistProvider.clearWishlist();
              Get.back();
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
