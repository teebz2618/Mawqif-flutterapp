import 'package:flutter/material.dart';
import 'password_manager.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown.shade800,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildItem(
            "Notification Settings",
            Icons.notifications_outlined,
            () {},
          ),
          _buildItem("Password Manager", Icons.lock_outline, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PasswordManagerScreen()),
            );
          }),
          _buildItem("Delete Account", Icons.delete_outline, () {
            // Add your delete logic here
          }),
        ],
      ),
    );
  }

  Widget _buildItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
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
    );
  }
}
