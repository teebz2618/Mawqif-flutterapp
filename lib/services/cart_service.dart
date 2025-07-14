import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class CartService extends GetxController {
  static CartService get to => Get.find();

  final RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;
  final _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _loadCart();

    ever(cartItems, (_) => _saveCart());
  }

  void _loadCart() {
    final storedCart = _storage.read('cart');
    if (storedCart is List) {
      cartItems.assignAll(
        storedCart.map((e) => Map<String, dynamic>.from(e)).toList(),
      );
    }
  }

  void _saveCart() {
    _storage.write('cart', cartItems);
  }

  void addToCart(Map<String, dynamic> item) {
    // Prevent adding without required options
    if (item.containsKey('requiresSize') &&
        item['requiresSize'] == true &&
        item['selectedSize'] == null) {
      Get.snackbar(
        "Missing Size",
        "Please select a size before adding to cart",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
      return;
    }
    if (item.containsKey('requiresColor') &&
        item['requiresColor'] == true &&
        item['selectedColor'] == null) {
      Get.snackbar(
        "Missing Color",
        "Please select a color before adding to cart",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
      return;
    }

    int index = cartItems.indexWhere(
      (element) =>
          element['id'] == item['id'] &&
          element['selectedColor'] == item['selectedColor'] &&
          element['selectedSize'] == item['selectedSize'],
    );

    if (index >= 0) {
      final existing = cartItems[index];
      cartItems[index] = {
        ...existing,
        'quantity': (existing['quantity'] ?? 1) + (item['quantity'] ?? 1),
      };
    } else {
      cartItems.add({
        ...item,
        'quantity': item['quantity'] ?? 1,
        'price': (item['price'] ?? 0).toDouble(),
        'discount': (item['discount'] ?? 0).toDouble(),
      });
    }
  }

  void removeFromCart(int index) {
    if (index >= 0 && index < cartItems.length) {
      cartItems.removeAt(index);
    }
  }

  void updateQuantity(int index, int quantity) {
    if (index < 0 || index >= cartItems.length) return;

    if (quantity <= 0) {
      removeFromCart(index);
    } else {
      final item = cartItems[index];
      cartItems[index] = {...item, 'quantity': quantity};
    }
  }

  void clearCart() {
    cartItems.clear();
  }

  double getSubtotal() {
    double total = 0;
    for (var item in cartItems) {
      final price = (item['price'] ?? 0).toDouble();
      final discount = (item['discount'] ?? 0).toDouble();
      final quantity = (item['quantity'] ?? 1) as int;

      final discountedPrice =
          discount > 0 ? price - (price * discount / 100) : price;

      total += discountedPrice * quantity;
    }
    return total;
  }

  int getTotalItems() {
    return cartItems.fold<int>(
      0,
      (sum, item) => sum + ((item['quantity'] as int?) ?? 0),
    );
  }

  bool get isEmpty => cartItems.isEmpty;
}
