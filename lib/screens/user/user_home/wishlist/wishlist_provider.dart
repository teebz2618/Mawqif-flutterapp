import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class WishlistProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Set<String> _wishlistItems = <String>{};
  List<Map<String, dynamic>> _wishlistProducts = [];
  bool _isLoading = false;

  Set<String> get wishlistItems => _wishlistItems;
  List<Map<String, dynamic>> get wishlistProducts => _wishlistProducts;
  bool get isLoading => _isLoading;

  User? get _user => _auth.currentUser;

  WishlistProvider() {
    _loadWishlist();
  }

  // Check if product is in wishlist
  bool isInWishlist(String productId) {
    return _wishlistItems.contains(productId);
  }

  // Load wishlist from Firestore
  Future<void> _loadWishlist() async {
    if (_user == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final querySnapshot =
          await _firestore
              .collection('wishlists')
              .doc(_user!.uid)
              .collection('items')
              .get();

      _wishlistItems.clear();
      _wishlistProducts.clear();

      for (var doc in querySnapshot.docs) {
        _wishlistItems.add(doc.id);
        _wishlistProducts.add({'id': doc.id, ...doc.data()});
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error loading wishlist: $e');
    }
  }

  // Toggle wishlist status
  Future<void> toggleWishlist(
    String productId,
    Map<String, dynamic> productData,
  ) async {
    if (_user == null) {
      Get.snackbar(
        "Authentication Required",
        "Please login to add items to wishlist",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final wishlistRef = _firestore
          .collection('wishlists')
          .doc(_user!.uid)
          .collection('items')
          .doc(productId);

      if (_wishlistItems.contains(productId)) {
        // Remove from wishlist
        await wishlistRef.delete();
        _wishlistItems.remove(productId);
        _wishlistProducts.removeWhere((item) => item['id'] == productId);

        Get.snackbar(
          "Wishlist",
          "Removed from wishlist",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.heart_broken, color: Colors.white),
        );
      } else {
        // Add to wishlist
        final productToSave = {
          ...productData,
          'id': productId,
          'addedAt': FieldValue.serverTimestamp(),
        };

        await wishlistRef.set(productToSave);
        _wishlistItems.add(productId);
        _wishlistProducts.add(productToSave);

        Get.snackbar(
          "Wishlist",
          "Added to wishlist",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.favorite, color: Colors.white),
        );
      }

      notifyListeners();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update wishlist. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Error toggling wishlist: $e');
    }
  }

  // Remove item from wishlist
  Future<void> removeFromWishlist(String productId) async {
    if (_user == null) return;

    try {
      await _firestore
          .collection('wishlists')
          .doc(_user!.uid)
          .collection('items')
          .doc(productId)
          .delete();

      _wishlistItems.remove(productId);
      _wishlistProducts.removeWhere((item) => item['id'] == productId);
      notifyListeners();

      Get.snackbar(
        "Wishlist",
        "Item removed from wishlist",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error removing from wishlist: $e');
    }
  }

  // Clear entire wishlist
  Future<void> clearWishlist() async {
    if (_user == null) return;

    try {
      final batch = _firestore.batch();
      final wishlistRef = _firestore
          .collection('wishlists')
          .doc(_user!.uid)
          .collection('items');

      final querySnapshot = await wishlistRef.get();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      _wishlistItems.clear();
      _wishlistProducts.clear();
      notifyListeners();

      Get.snackbar(
        "Wishlist",
        "Wishlist cleared",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error clearing wishlist: $e');
    }
  }

  // Get wishlist count
  int get wishlistCount => _wishlistItems.length;

  // Refresh wishlist
  Future<void> refreshWishlist() async {
    await _loadWishlist();
  }
}
