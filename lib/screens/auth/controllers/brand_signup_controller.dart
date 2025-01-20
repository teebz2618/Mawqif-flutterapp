import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BrandSignUpController extends GetxController {
  final brandNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final descriptionController = TextEditingController();
  final contactController = TextEditingController();
  final shippingInfoController = TextEditingController();
  final countryController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    brandNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    descriptionController.dispose();
    contactController.dispose();
    shippingInfoController.dispose();
    countryController.dispose();
    super.dispose();
  }

  Future<void> signUpWithEmail({
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final brandName = brandNameController.text.trim();
    final description = descriptionController.text.trim();
    final contact = contactController.text.trim();
    final shipping = shippingInfoController.text.trim();
    final country = countryController.text.trim();

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'brandName': brandName,
        'description': description,
        'contact': contact,
        'shippingInfo': shipping,
        'country': country,
        'role': 'brand',
        'createdAt': FieldValue.serverTimestamp(),
      });

      onSuccess();
    } on FirebaseAuthException catch (e) {
      onError(e.message ?? 'Something went wrong');
    } catch (e) {
      onError('Unexpected error occurred');
    }
  }
}
