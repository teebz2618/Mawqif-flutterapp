import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mawqif/constants/app_colors.dart';
import 'package:mawqif/screens/brand/brand_homeScreen/home.dart';
import 'brand_profile/profile.dart';

class BrandDashboard extends StatefulWidget {
  const BrandDashboard({super.key});

  @override
  State<BrandDashboard> createState() => _BrandDashboardState();
}

class _BrandDashboardState extends State<BrandDashboard> {
  bool _isApproved = false;
  bool _isLoading = true;
  String _brandName = '';

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    checkApprovalStatus();
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

  final List<Widget> _screens = [
    BrandHomeScreen(),
    const Center(child: Text('Orders Screen Placeholder')),
    BrandProfileScreen(),
  ];

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
            children: [
              const Text(
                'Your account is not approved yet.\nPlease wait for admin approval.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBrown,
        title: Center(
          child: Text(
            _currentIndex == 0
                ? _brandName
                : _currentIndex == 1
                ? 'Orders'
                : 'Profile',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.brown.shade600,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.brown.shade200,
        unselectedItemColor: Colors.brown.shade300,
        onTap: (index) => setState(() => _currentIndex = index),
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
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
