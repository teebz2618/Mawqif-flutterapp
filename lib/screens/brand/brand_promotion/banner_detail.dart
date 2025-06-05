import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BannerDetailScreen extends StatelessWidget {
  const BannerDetailScreen({super.key});

  Future<void> _deleteBanner(
    BuildContext context,
    String bannerId,
    String? imageUrl,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      EasyLoading.showError("Not logged in");
      return;
    }

    // Confirm deletion
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Delete Banner"),
            content: const Text("Are you sure you want to delete this banner?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    EasyLoading.show(status: "Deleting...");
    try {
      // Delete Firestore document
      await FirebaseFirestore.instance
          .collection("promotional_banners")
          .doc(bannerId)
          .delete();

      // Delete image from Storage if exists
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final ref = FirebaseStorage.instance.refFromURL(imageUrl);
        await ref.delete();
      }

      EasyLoading.showSuccess("Banner deleted successfully");
      Navigator.pop(context); // Go back to previous screen
    } catch (e) {
      EasyLoading.showError("Failed to delete: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;

    if (args == null || !args.containsKey('bannerData')) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Banner Details",
            style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: const Center(child: Text("No banner data available.")),
      );
    }

    final bannerData = args['bannerData'] as Map<String, dynamic>;
    final bannerId = args['bannerId'] ?? ""; // pass id if needed
    final createdAt = bannerData['createdAt'];
    final formattedTime =
        createdAt != null
            ? "${createdAt.toDate().day}/${createdAt.toDate().month}/${createdAt.toDate().year} ${createdAt.toDate().hour}:${createdAt.toDate().minute}"
            : "N/A";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          bannerData['title'] ?? "Banner Details",
          style: const TextStyle(
            color: Colors.brown,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed:
                () => _deleteBanner(context, bannerId, bannerData['imageUrl']),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (bannerData['imageUrl'] != null)
              Center(
                child: Image.network(
                  bannerData['imageUrl'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              bannerData['title'] ?? "No Title",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              bannerData['subtitle'] ?? "",
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Text(
              "Uploaded on: $formattedTime",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
