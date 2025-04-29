import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mawqif/screens/user/profile/privacy_policy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import 'edit_profile.dart';
import 'help_center.dart';
import 'invite_friends.dart';
import 'settings.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Log out"),
            backgroundColor: Colors.white,
            content: const Text("Are you sure you want to log out?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Log out"),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed(AppRoutes.login);
    }
  }

  static Widget _buildProfileOption(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.brown.shade700),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.brown.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(Icons.chevron_right, color: Colors.brown.shade400),
          onTap: onTap,
        ),
        const Divider(
          height: 1,
          thickness: 0.8,
          color: Color(0xFFD7CCC8),
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? "User";
    final photoUrl = user?.photoURL;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown.shade800,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      photoUrl != null
                          ? NetworkImage(photoUrl)
                          : const AssetImage("assets/images/default_user.png")
                              as ImageProvider,
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.brown.shade800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView(
              children: [
                _buildProfileOption(context, "Your profile", Icons.person, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  );
                }),
                _buildProfileOption(
                  context,
                  "Payment Methods",
                  Icons.credit_card,
                  () {},
                ),
                _buildProfileOption(
                  context,
                  "My Orders",
                  Icons.shopping_bag,
                  () {},
                ),
                _buildProfileOption(context, "Settings", Icons.settings, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                }),
                _buildProfileOption(
                  context,
                  "Help Center",
                  Icons.help_outline,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HelpCenterScreen(),
                      ),
                    );
                  },
                ),
                _buildProfileOption(
                  context,
                  "Privacy Policy",
                  Icons.privacy_tip,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),
                _buildProfileOption(
                  context,
                  "Invite Friends",
                  Icons.group_add,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InviteFriendsScreen(),
                      ),
                    );
                  },
                ),
                _buildProfileOption(
                  context,
                  "Log out",
                  Icons.logout,
                  () => logout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
