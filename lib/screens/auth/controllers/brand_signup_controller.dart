import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BrandSignUpController extends GetxController {
  // Controllers for text fields
  final brandNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final descriptionController = TextEditingController();
  final contactController = TextEditingController();
  final countryController = TextEditingController();

  // Shipping logic
  RxBool isWorldwide = false.obs;
  RxList<String> selectedCountries = <String>[].obs;

  // Dial code
  String? selectedDialCode;

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
    final country = countryController.text.trim();

    String contact = contactController.text.trim();
    if (selectedDialCode != null && contact.isNotEmpty) {
      contact = '+$selectedDialCode$contact';
    } else {
      contact = '';
    }

    dynamic shippingInfo =
        isWorldwide.value
            ? 'Worldwide'
            : selectedCountries.isNotEmpty
            ? selectedCountries.toList()
            : null;

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      await _firestore.collection('brands').doc(uid).set({
        'uid': uid,
        'name': brandName,
        'email': email,
        'status': 'pending',
        'password': password,
        if (description.isNotEmpty) 'description': description,
        if (shippingInfo != null) 'shippingInfo': shippingInfo,
        if (contact.isNotEmpty) 'contact': contact,
        if (country.isNotEmpty) 'country': country,
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
