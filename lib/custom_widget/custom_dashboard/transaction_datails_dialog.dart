// transaction_details_dialog.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:senior_project/style/my_text_style.dart';

class TransactionDetailsDialog extends StatelessWidget {
  final String emoji;
  final String itemName;
  final String amount;
  final String date;
  final String member;
  final String comment;
  final BuildContext context;
  final String ledgerId;
  const TransactionDetailsDialog({
    Key? key,
    required this.emoji,
    required this.itemName,
    required this.amount,
    required this.date,
    required this.member,
    required this.comment,
    required this.context,
    required this.ledgerId,
  }) : super(key: key);

  Future<void> deleteTransaction(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('ledger')
          .doc(ledgerId)
          .delete();

      Navigator.pop(context); // Close the dialog after deletion
    } catch (e) {
      print('Error deleting transaction: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete transaction.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    size: 30,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Spacer(), // This will take up all the available space in between
              Container(
                alignment: Alignment.topRight,
                child: TextButton(
                    onPressed: () => deleteTransaction(context),
                    child: Text(
                      '🗑️',
                      style: TextStyle(fontSize: 20),
                    )),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Color.fromRGBO(
                Theme.of(context).primaryColor.red,
                (Theme.of(context).primaryColor.green + 31).clamp(0, 255),
                (Theme.of(context).primaryColor.blue + 95).clamp(0, 255),
                1.0,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$emoji  ',
                          style: const TextStyle(fontSize: 45),
                        ),
                        Text(
                          itemName,
                          style: MyTextStyles.heading2,
                        ),
                      ],
                    ),
                    Text(
                      amount,
                      style: amount.startsWith('-')
                          ? MyTextStyles.size20RedText
                          : MyTextStyles
                              .size20GreenText, // Use green for income
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      'Date : ',
                      style: MyTextStyles.size16GreyText,
                    ),
                    Text(
                      date,
                      style: MyTextStyles.size16BlackText,
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      'Member : ',
                      style: MyTextStyles.size16GreyText,
                    ),
                    Text(
                      member,
                      style: MyTextStyles.size16BlackText,
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      'Comment : ',
                      style: MyTextStyles.size16GreyText,
                    ),
                    Text(
                      comment,
                      style: MyTextStyles.size16BlackText,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
