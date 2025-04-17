import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:senior_project/custom_widget/custom_dashboard/group_transaction_details_dialog.dart';
import 'package:senior_project/style/my_text_style.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  Future<Map<String, String>> getCategoryEmojis(String userId) async {
    try {
      QuerySnapshot categorySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('category')
          .get();

      Map<String, String> categoryEmojis = {};

      for (QueryDocumentSnapshot doc in categorySnapshot.docs) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('emoji')) {
          categoryEmojis[doc.id] = data['emoji'] as String;
        }
      }

      return categoryEmojis;
    } catch (e) {
      print('Error fetching category emojis: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    String getAmountText(Map<String, dynamic> ledgerDocument, String? userId) {
      if (ledgerDocument['payer'] != null && userId != null) {
        List<dynamic> payers = ledgerDocument['payer'];
        for (var payer in payers) {
          if (payer['payer'] == userId) {
            return '${ledgerDocument['type'] == 'expense' ? '-฿' : '฿'}${payer['amountPaid'].toStringAsFixed(2)}';
          }
        }
        return '${ledgerDocument['type'] == 'expense' ? '-฿' : '฿'}0.00';
      } else {
        return '${ledgerDocument['type'] == 'expense' ? '-฿' : '฿'}${ledgerDocument['amount'].toStringAsFixed(2)}';
      }
    }

    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: MyTextStyles.heading2,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        toolbarHeight: MediaQuery.of(context).size.height * 0.07,
      ),
      body: Padding(
        // Added padding for the body
        padding: const EdgeInsets.all(15),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .collection('notifications')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No notifications yet.'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final groupId = doc['groupId'] as String;
                final createdAt = doc['createdAt'] as Timestamp;
                final notificationId = doc.id;
                final creatorUsername = doc['creatorUsername'] as String;
                final notificationType = doc['type'] as String?;

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('groups')
                      .doc(groupId)
                      .get(),
                  builder: (context, groupSnapshot) {
                    if (groupSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return ListTile(
                        title: const Text('Loading group details...'),
                        subtitle: Text(
                          DateFormat('yyyy-MM-dd HH:mm')
                              .format(createdAt.toDate()),
                        ),
                      );
                    }

                    if (groupSnapshot.hasError || !groupSnapshot.hasData) {
                      return ListTile(
                        title: const Text('Error loading group details'),
                        subtitle: Text(
                          DateFormat('yyyy-MM-dd HH:mm')
                              .format(createdAt.toDate()),
                        ),
                      );
                    }

                    final groupData =
                        groupSnapshot.data!.data() as Map<String, dynamic>;
                    final groupName = groupData['name'] as String;

                    return Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.all(8.0),
                          tileColor: const Color.fromARGB(255, 255, 255, 255),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                color: Color.fromARGB(255, 18, 5, 5),
                                width: 1.0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: notificationType == 'deletion'
                              ? Row(
                                  children: [
                                    const Text(
                                      '🗑️ ',
                                      style: TextStyle(fontSize: 35),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Group expense deleted by $creatorUsername'),
                                        Text(
                                          DateFormat('yyyy-MM-dd HH:mm')
                                              .format(createdAt.toDate()),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : notificationType == 'deny'
                                  ? Row(
                                      children: [
                                        const Text(
                                          '🚫',
                                          style: TextStyle(fontSize: 35),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                '$creatorUsername denied your payment'),
                                            Text(
                                              DateFormat('yyyy-MM-dd HH:mm')
                                                  .format(createdAt.toDate()),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ) // Display deny message
                                  : notificationType == 'payback'
                                      ? Row(
                                          children: [
                                            const Text(
                                              '✅',
                                              style: TextStyle(fontSize: 35),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    '$creatorUsername Payback to you'),
                                                Text(
                                                  DateFormat('yyyy-MM-dd HH:mm')
                                                      .format(
                                                          createdAt.toDate()),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ) // Display deny message
                                      : Row(
                                          children: [
                                            const Text(
                                              '💸',
                                              style: TextStyle(fontSize: 35),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    'New group expense by $creatorUsername'),
                                                Text(
                                                  DateFormat('yyyy-MM-dd HH:mm')
                                                      .format(
                                                          createdAt.toDate()),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Color.fromARGB(255, 131, 152, 170),
                            ),
                            onPressed: () {
                              _deleteNotification(
                                  context, currentUser.uid, notificationId);
                            },
                          ),
                          onTap: () async {
                            final ledgerSnapshot = await FirebaseFirestore
                                .instance
                                .collection('groups')
                                .doc(groupId)
                                .collection('ledger')
                                .orderBy('timestamp', descending: true)
                                .limit(1)
                                .get();

                            if (ledgerSnapshot.docs.isNotEmpty) {
                              final ledgerDocument =
                                  ledgerSnapshot.docs.first.data();
                              final category =
                                  ledgerDocument['category'] as String;
                              final emojis =
                                  await getCategoryEmojis(currentUser.uid);
                              final emoji = emojis[category] ?? '💸';
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    GroupTransactionDetailsDialog(
                                  emoji: emoji,
                                  amount: getAmountText(
                                      ledgerDocument, currentUser.uid),
                                  context: context,
                                  ledgerDocument: ledgerDocument,
                                  isGroup: true,
                                  deleteable: false,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Ledger entry not found')),
                              );
                            }
                          },
                        ),
                        const SizedBox(
                          height: 5,
                        )
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _deleteNotification(
      BuildContext context, String userId, String notificationId) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .delete()
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification deleted')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete notification: $error')),
      );
    });
  }
}
