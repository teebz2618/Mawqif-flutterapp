import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class InviteFriendsScreen extends StatelessWidget {
  const InviteFriendsScreen({super.key});

  void _shareApp() {
    final message =
        'Hey! I’m using the Mawqif app to explore thobes and abayas from trusted brands. You should try it too!\nDownload here: https://mawqif.com/download';
    Share.share(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Invite Friends"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.group_add, size: 80, color: Colors.brown),
            const SizedBox(height: 20),
            Text(
              "Share Mawqif with your friends!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.brown.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "Help your friends discover elegant fashion. Send them a link to our app!",
              style: TextStyle(fontSize: 14, color: Colors.brown.shade400),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton.icon(
                onPressed: _shareApp,
                icon: Icon(Icons.share, color: Colors.brown.shade200),
                label: Text(
                  "Invite via Share",
                  style: TextStyle(color: Colors.brown.shade200),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
