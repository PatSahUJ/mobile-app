import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // ✅ Register the channel (required for Android 8+)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'group_ledger_channel',
      'Group Ledger Notifications',
      description: 'Notifications for new group ledger entries',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            'group_ledger_channel', 'Group Ledger Notifications',
            channelDescription: 'Notifications for new group ledger entries',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
            icon: 'ic_notification');

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
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

  Future<void> addPaybackNotification(
    String payerUserId,
    String receiverUserId,
    String groupId,
    double amount,
  ) async {
    // Fetch payer's username
    final payerSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(payerUserId)
        .get();
    final payerUsername = payerSnapshot.exists
        ? payerSnapshot['username'] as String? ?? 'Unknown User'
        : 'Unknown User';

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(receiverUserId)
          .collection('notifications')
          .add({
        'groupId': groupId,
        'createdAt': FieldValue.serverTimestamp(),
        'creatorUsername': payerUsername, // Store payer username
        'type': 'payback', // Add type for payback notifications
        'amount': amount, // Optionally include the amount
      });

      await showNotification(
        'Debt Paid Back',
        '$payerUsername paid you back ${amount.toStringAsFixed(2)}.',
      );
    } catch (e) {
      print("Error adding payback notification for $receiverUserId: $e");
    }
  }
}
