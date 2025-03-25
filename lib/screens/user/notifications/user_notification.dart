import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return DateFormat('MMM d, yyyy • hh:mm a').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('notifications')
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No notifications yet",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final title = doc['title'] ?? 'No Title';
              final body = doc['body'] ?? '';
              final imageUrl = doc['imageUrl'];
              final timestamp = doc['timestamp'] as Timestamp?;

              return NotificationCard(
                title: title,
                body: body,
                date: formatTimestamp(timestamp),
                imageUrl: imageUrl,
              );
            },
          );
        },
      ),
    );
  }
}

class NotificationCard extends StatefulWidget {
  final String title;
  final String body;
  final String date;
  final String? imageUrl;

  const NotificationCard({
    super.key,
    required this.title,
    required this.body,
    required this.date,
    this.imageUrl,
  });

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard>
    with TickerProviderStateMixin {
  bool _showImage = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showImage = !_showImage;
        });
      },
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title & Body
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(widget.body),
              const SizedBox(height: 8),
              Text(
                widget.date,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),

              // Animated Image Section
              AnimatedSize(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _showImage ? 1.0 : 0.0,
                  child:
                      _showImage && widget.imageUrl != null
                          ? Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                widget.imageUrl!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                          : const SizedBox.shrink(),
                ),
              ),

              const SizedBox(height: 8),

              // Toggle text
              Text(
                _showImage ? "Tap to hide" : "Tap to view detail",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
