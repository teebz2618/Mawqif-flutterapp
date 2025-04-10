import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mawqif/screens/brand/brand_home/brand_home.dart';
import 'package:mawqif/screens/brand/notification/brand_notification.dart';
import 'brand_profile/brand_profile.dart';

class BrandDashboard extends StatefulWidget {
  const BrandDashboard({super.key});

  @override
  State<BrandDashboard> createState() => _BrandDashboardState();
}

class _BrandDashboardState extends State<BrandDashboard> {
  String brandId = '';
  bool _isApproved = false;
  bool _isLoading = true;
  String _brandName = '';

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    checkApprovalStatus();
    _loadBrandInfo();
  }

  Future<void> checkApprovalStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user logged in, redirecting to login');
      Get.offAllNamed('/login');
      return;
    }
    final doc =
        await FirebaseFirestore.instance
            .collection('brands')
            .doc(user.uid)
            .get();

    if (!doc.exists || doc.data()?['status'] != 'approved') {
      setState(() {
        _isApproved = false;
        _isLoading = false;
      });
    } else {
      final data = doc.data();
      print('Brand document data: $data');
      setState(() {
        _isApproved = true;
        _brandName = data?['name'] ?? 'Brand';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadBrandInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('brands')
            .doc(user.uid)
            .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _brandName = data['name'] ?? 'Brand';
        brandId = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isApproved) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Your account is not approved yet.\nPlease wait for admin approval.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      );
    }

    final List<Widget> _screens = [
      BrandHomeScreen(brandName: _brandName),
      const Center(child: Text('Orders Screen Placeholder')),
      BrandNotificationScreen(brandId: brandId),
      BrandProfileScreen(),
    ];

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed, // For more than 3 items
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
