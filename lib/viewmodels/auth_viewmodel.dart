import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _brandName;
  String? get brandName => _brandName;

  Future<void> fetchBrandName() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final doc = await _firestore.collection('brands').doc(uid).get();
      if (doc.exists) {
        _brandName = doc['brandName'];
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching brand name: $e");
    }
  }

  /// Logout
  Future<void> signOut() async {
    await _auth.signOut();
    _brandName = null;
    notifyListeners();
  }
}
