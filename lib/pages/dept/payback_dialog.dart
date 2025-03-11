import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:senior_project/style/my_text_style.dart';
import 'package:intl/intl.dart';

class PaybackDialog extends StatefulWidget {
  final String payerId;
  final String payeeId;
  final String payerUsername;
  final String payeeUsername;
  final double amount;
  final String category;
  final String date;
  final String comment;
  final String groupId;
  final String ledgerId;

  PaybackDialog({
    required this.payerId,
    required this.payeeId,
    required this.payerUsername,
    required this.payeeUsername,
    required this.amount,
    required this.category,
    required this.date,
    required this.comment,
    required this.groupId,
    required this.ledgerId,
  });

  @override
  _PaybackDialogState createState() => _PaybackDialogState();
}

class _PaybackDialogState extends State<PaybackDialog> {
  bool _isLoading = false;

  Future<void> _handlePayback() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      String payerUsername = widget.payerUsername;
      String payeeUsername = widget.payeeUsername;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.payeeId)
          .collection('ledger')
          .add({
        'date': widget.date,
        'paybackDate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'category': 'Repayment',
        'type': 'income',
        'comment': 'Paid by $payerUsername',
        'relatedGroupId': widget.groupId,
        'relatedUserId': widget.payerId,
        'amount': widget.amount,
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.payerId)
          .collection('ledger')
          .add({
        'date': widget.date,
        'paybackDate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'category': 'Repayment',
        'type': 'expense',
        'comment': 'Pay to $payeeUsername',
        'relatedGroupId': widget.groupId,
        'relatedUserId': widget.payeeId,
        'amount': widget.amount,
      });

      await _deleteTransaction();

      Navigator.of(context).pop(true);
    } catch (e) {
      print('Error during payback: $e');
      Navigator.of(context).pop(false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteTransaction() async {
    try {
      final ledgerRef = FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('ledger')
          .doc(widget.ledgerId);

      final ledgerDoc = await ledgerRef.get();
      if (ledgerDoc.exists) {
        final transactions = List<Map<String, dynamic>>.from(
            ledgerDoc.data()?['transactions'] ?? []);
        transactions.removeWhere((transaction) =>
            transaction['payer'] == widget.payerId &&
            transaction['payee'] == widget.payeeId &&
            transaction['amount'] == widget.amount);

        await ledgerRef.update({'transactions': transactions});
      }
    } catch (e) {
      print('Error deleting transaction: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isPayer =
        currentUserId == widget.payerId; // Check if current user is the payer

    return AlertDialog(
      title: const Text(
        'Debt info:',
        style: MyTextStyles.heading1,
      ),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Amount: \$${widget.amount.toStringAsFixed(2)}',
                    style: MyTextStyles.mediumBlackText,
                  ),
                  Text(
                    'Category: ${widget.category}',
                    style: MyTextStyles.mediumBlackText,
                  ),
                  Text(
                    'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(widget.date))}',
                    style: MyTextStyles.mediumBlackText,
                  ),
                  Text(
                    'Comment: ${widget.comment}',
                    style: MyTextStyles.mediumBlackText,
                  ),
                  Text(
                    'Payer: ${widget.payerUsername}',
                    style: MyTextStyles.mediumBlackText,
                  ),
                  Text(
                    'Payee: ${widget.payeeUsername}',
                    style: MyTextStyles.mediumBlackText,
                  ),
                ],
              ),
            ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        if (isPayer) // Conditionally show the "Pay Back" button
          ElevatedButton(
            child: const Text('Pay Back'),
            onPressed: _handlePayback,
          ),
      ],
    );
  }
}
