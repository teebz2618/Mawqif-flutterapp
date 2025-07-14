import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/cart_service.dart';
import '../user_home/user_product_detail.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool selectionMode = false;
  final Set<int> selectedIndexes = {};

  void _toggleSelection(int index) {
    setState(() {
      if (selectedIndexes.contains(index)) {
        selectedIndexes.remove(index);
      } else {
        selectedIndexes.add(index);
      }
    });
  }

  void _deleteSelectedItems() {
    if (selectedIndexes.isEmpty) return;

    Get.defaultDialog(
      title: "Delete Items",
      middleText:
          "Are you sure you want to remove ${selectedIndexes.length} item(s) from the cart?",
      textCancel: "Cancel",
      textConfirm: "Delete",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        final sortedIndexes =
            selectedIndexes.toList()..sort((a, b) => b.compareTo(a));
        for (var index in sortedIndexes) {
          CartService.to.removeFromCart(index);
        }
        setState(() {
          selectedIndexes.clear();
          selectionMode = false;
        });
        Get.back();
        Get.snackbar("Deleted", "Selected items removed from cart");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (selectionMode) {
          setState(() {
            selectionMode = false;
            selectedIndexes.clear();
          });
          return false; // just exit selection mode
        }

        // Go back with arguments
        if (Get.arguments != null) {
          Get.back(result: Get.arguments);
        } else {
          Get.back();
        }

        return false; // prevent default pop because we already handled it
      },

      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectionMode
                    ? "Selected (${selectedIndexes.length})"
                    : "My Cart",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Obx(() {
                final totalItems = CartService.to.cartItems.length;
                return Text(
                  "$totalItems item(s) in cart",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                );
              }),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.brown,
          elevation: 0,
          actions: [
            if (selectionMode)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed:
                    selectedIndexes.isEmpty ? null : _deleteSelectedItems,
              )
            else
              IconButton(
                icon: const Icon(Icons.select_all),
                onPressed: () {
                  setState(() {
                    selectionMode = true;
                  });
                },
              ),
          ],
        ),
        body: Obx(() {
          final cartItems = CartService.to.cartItems;

          if (cartItems.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(10),
                  itemCount: cartItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    final double price = item['price'] as double;
                    final double discount = item['discount'] as double;
                    final int quantity = item['quantity'] as int;

                    final discountedPrice =
                        discount > 0 ? price - (price * discount / 100) : price;

                    final isSelected = selectedIndexes.contains(index);

                    return GestureDetector(
                      onTap: () {
                        if (selectionMode) {
                          _toggleSelection(index);
                        } else {
                          Get.to(
                            () => const UserProductDetail(),
                            arguments: {
                              'productId': item['id'],
                              'productData': item,
                            },
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? Colors.brown.shade50 : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            if (selectionMode)
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Checkbox(
                                    value: isSelected,
                                    onChanged: (_) => _toggleSelection(index),
                                    activeColor: Colors.brown,
                                  ),
                                  if (isSelected)
                                    Text(
                                      (selectedIndexes.toList().indexOf(index) +
                                              1)
                                          .toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item['image'],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      if (discount > 0) ...[
                                        Text(
                                          "Rs ${(price * quantity).toStringAsFixed(0)}",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          "Rs ${(discountedPrice * quantity).toStringAsFixed(0)}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ] else ...[
                                        Text(
                                          "Rs ${(price * quantity).toStringAsFixed(0)}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      if (item['selectedColor'] != null) ...[
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color:
                                                item['selectedColor'] is int
                                                    ? Color(
                                                      item['selectedColor'],
                                                    )
                                                    : Color(
                                                      int.parse(
                                                        item['selectedColor']
                                                            .toString(),
                                                      ),
                                                    ),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.grey.shade400,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],

                                      if (item['selectedSize'] != null)
                                        Text(
                                          "Size: ${item['selectedSize']}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  if (!selectionMode)
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.remove,
                                            size: 18,
                                          ),
                                          onPressed:
                                              quantity > 1
                                                  ? () => CartService.to
                                                      .updateQuantity(
                                                        index,
                                                        quantity - 1,
                                                      )
                                                  : null,
                                          color:
                                              quantity > 1
                                                  ? Colors.black
                                                  : Colors.grey,
                                        ),
                                        Text(
                                          quantity.toString(),
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add, size: 18),
                                          onPressed:
                                              () =>
                                                  CartService.to.updateQuantity(
                                                    index,
                                                    quantity + 1,
                                                  ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            if (!selectionMode)
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  Get.defaultDialog(
                                    title: "Delete Item",
                                    middleText: "Remove this item from cart?",
                                    textCancel: "Cancel",
                                    textConfirm: "Delete",
                                    confirmTextColor: Colors.white,
                                    buttonColor: Colors.red,
                                    onConfirm: () {
                                      CartService.to.removeFromCart(index);
                                      Get.back();
                                    },
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              if (!selectionMode)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Subtotal",
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            "Rs ${CartService.to.getSubtotal().toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              cartItems.isEmpty
                                  ? null
                                  : () {
                                    Get.snackbar(
                                      "Checkout",
                                      "Proceeding to checkout...",
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Proceed to Checkout →",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}
