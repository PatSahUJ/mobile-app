import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:senior_project/style/my_text_style.dart';

class TransactionDetailsDialog extends StatefulWidget {
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

  @override
  _TransactionDetailsDialogState createState() =>
      _TransactionDetailsDialogState();
}

class _TransactionDetailsDialogState extends State<TransactionDetailsDialog> {
  String? relatedGroupId;
  String? type;
  String? relatedUserId;
  double? amount;
  String? currentUserId;
  @override
  void initState() {
    super.initState();
    _fetchLedgerData();
  }

  Future<void> _fetchLedgerData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      DocumentSnapshot ledgerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('ledger')
          .doc(widget.ledgerId)
          .get();

      if (ledgerDoc.exists && ledgerDoc.data() != null) {
        Map<String, dynamic> data = ledgerDoc.data() as Map<String, dynamic>;
        setState(() {
          relatedGroupId = data['relatedGroupId'] as String?;
          type = data['type'] as String?;
          relatedUserId = data['relatedUserId'] as String?;
          amount = data['amount'] as double?;
        });
      }
    } catch (e) {
      print('Error fetching ledger data: $e');
    }
  }

  Future<void> deleteTransaction(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('ledger')
          .doc(widget.ledgerId)
          .delete();

      Navigator.pop(context); // Close the dialog after deletion
    } catch (e) {
      print('Error deleting transaction: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete transaction.')),
      );
    }
  }

  Future<void> denyPayment(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          currentUserId = user.uid;
        });
      }
      if (user == null ||
          relatedGroupId == null ||
          relatedUserId == null ||
          amount == null) return;

      // 1. Add transaction to group ledger (query and update)
      QuerySnapshot groupLedgerQuery = await FirebaseFirestore.instance
          .collection('groups')
          .doc(relatedGroupId)
          .collection('ledger')
          .get();

      if (groupLedgerQuery.docs.isNotEmpty) {
        // Assuming only one ledger document exists
        String groupLedgerId = groupLedgerQuery.docs.first.id;

        await FirebaseFirestore.instance
            .collection('groups')
            .doc(relatedGroupId)
            .collection('ledger')
            .doc(groupLedgerId)
            .update({
          'transactions': FieldValue.arrayUnion([
            {'payer': relatedUserId, 'amount': amount, 'payee': currentUserId}
          ])
        });
      }
      // 2. Delete ledgers for both users
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('ledger')
          .doc(widget.ledgerId)
          .delete();

      // Query and delete related ledger for relatedUserId
      QuerySnapshot relatedUserLedger = await FirebaseFirestore.instance
          .collection('users')
          .doc(relatedUserId)
          .collection('ledger')
          .where('relatedGroupId', isEqualTo: relatedGroupId)
          .get();

      if (relatedUserLedger.docs.isNotEmpty) {
        // Assuming only one ledger should match the relatedGroupId
        await FirebaseFirestore.instance
            .collection('users')
            .doc(relatedUserId)
            .collection('ledger')
            .doc(relatedUserLedger.docs.first.id)
            .delete();
      }

      Navigator.pop(context); // Close the dialog after denying
    } catch (e) {
      print('Error denying payment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to deny payment.')),
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
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Icon(
                  Icons.close,
                  size: 30,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => deleteTransaction(context),
                child: const Text(
                  '🗑️',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.65,
            ),
            width: double.infinity,
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
                          widget.itemName == 'Debt Repayment'
                              ? '${widget.emoji} '
                              : '',
                          style: const TextStyle(fontSize: 45),
                        ),
                        Text(
                          widget.itemName,
                          style: MyTextStyles.heading2,
                        ),
                      ],
                    ),
                    Text(
                      widget.amount,
                      style: widget.amount.startsWith('-')
                          ? MyTextStyles.size20RedText
                          : MyTextStyles.size20GreenText,
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
                      widget.date,
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
                      widget.member,
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
                      widget.comment,
                      style: MyTextStyles.size16BlackText,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (relatedGroupId != null && type != 'expense')
            Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor),
                onPressed: () => denyPayment(context),
                child: const Text('Deny Payment'),
              ),
            ),
        ],
      ),
    );
  }
}
