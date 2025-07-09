import 'package:flutter/material.dart' hide Badge;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:badges/badges.dart';
import 'package:mawqif/screens/user/user_home/user_home.dart';
import 'brands/brands_screen.dart';
import 'notifications/user_notification.dart';
import 'profile/user_profile.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    BrandsScreen(),
    NotificationsScreen(),
    Center(child: Text('Cart')),
    ProfileScreen(),
  ];

  Stream<int> unreadNotificationsCount() {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey.shade100,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.brown.shade800,
        unselectedItemColor: Colors.brown.shade400,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            label: 'Brands',
          ),
          BottomNavigationBarItem(
            icon: StreamBuilder<int>(
              stream: unreadNotificationsCount(),
              builder: (context, snapshot) {
                int count = snapshot.data ?? 0;
                return Badge(
                  showBadge: count > 0,
                  badgeContent: Text(
                    '$count',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  child: Icon(Icons.notifications_none),
                );
              },
            ),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Cart',
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
