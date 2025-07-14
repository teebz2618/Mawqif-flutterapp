import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initFCM() async {
    final fcmToken = await _firebaseMessaging.getToken();
    print('FCM Token : $fcmToken');

    // Handle message when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showPopupNotification(message);
    });

    // Optional: handle message when user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('User tapped notification: ${message.notification?.title}');
    });
  }

  void _showPopupNotification(RemoteMessage message) {
    showSimpleNotification(
      Text(
        message.data['title'] ??
            message.notification?.title ??
            "New Notification",
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(message.data['body'] ?? message.notification?.body ?? ""),
      leading: Icon(Icons.notifications, color: Colors.white),
      background: Colors.blueGrey.shade800,
      autoDismiss: true,
      slideDismissDirection: DismissDirection.up,
    );
  }
}
