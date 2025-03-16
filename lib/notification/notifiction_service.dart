// import 'package:firebase_messaging/firebase_messaging.dart';

// class NotificationService {
//   final _firebaseMessagnig = FirebaseMessaging.instance;

//   Future<void> initNotifications() async {
//     //request permission from user
//     await _firebaseMessagnig.requestPermission();
//     final FCMToken = await _firebaseMessagnig.getToken();

//     print('Token: $FCMToken');
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            '@mipmap/ic_launcher'); // Replace with your icon

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'group_ledger_channel',
      'Group Ledger Notifications',
      channelDescription: 'Notifications for new group ledger entries',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID (unique)
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> addGroupLedgerNotification(
      String groupId, List<String> members) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final creatorId = currentUser.uid;

    // Fetch the creator's username
    final creatorSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(creatorId)
        .get();
    final creatorUsername = creatorSnapshot.exists
        ? creatorSnapshot['username'] as String? ?? 'Unknown User'
        : 'Unknown User';

    for (String memberId in members) {
      if (memberId != creatorId) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(memberId)
              .collection('notifications')
              .add({
            'groupId': groupId,
            'createdAt': FieldValue.serverTimestamp(),
            'creatorUsername': creatorUsername, // Store username
            'type': 'creation'
          });

          await showNotification(
            'New Group Transaction',
            '$creatorUsername added a new group transaction.',
          );
        } catch (e) {
          print("Error adding notification for $memberId: $e");
        }
      }
    }
  }

  Future<void> addGroupLedgerDeletionNotification(
    String groupId,
    List<String> members,
    String creatorUsername,
  ) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final creatorId = currentUser.uid;

    for (String memberId in members) {
      if (memberId != creatorId) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(memberId)
              .collection('notifications')
              .add({
            'groupId': groupId,
            'createdAt': FieldValue.serverTimestamp(),
            'creatorUsername': creatorUsername, // Store username
            'type': 'deletion', // Add type for deletion notifications
          });

          await showNotification(
            'Group Transaction Deleted',
            '$creatorUsername deleted a group transaction.',
          );
        } catch (e) {
          print("Error adding deletion notification for $memberId: $e");
        }
      }
    }
  }

  Future<void> addDenyPaymentNotification(
    String senderUserId,
    String receiverUserId,
    String groupId,
  ) async {
    // Fetch sender's username
    final senderSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(senderUserId)
        .get();
    final senderUsername = senderSnapshot.exists
        ? senderSnapshot['username'] as String? ?? 'Unknown User'
        : 'Unknown User';

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(receiverUserId)
          .collection('notifications')
          .add({
        'groupId': groupId,
        'createdAt': FieldValue.serverTimestamp(),
        'creatorUsername': senderUsername, // Store sender username
        'type': 'deny', // Add type for deny notifications
      });

      await showNotification(
        'Payment Denied',
        '$senderUsername denied your payment request.',
      );
    } catch (e) {
      print("Error adding deny payment notification for $receiverUserId: $e");
    }
  }
}
