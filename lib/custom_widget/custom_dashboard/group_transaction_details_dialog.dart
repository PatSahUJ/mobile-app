// group_transaction_details_dialog.dart

import 'package:flutter/material.dart';
import 'package:senior_project/style/my_text_style.dart';

class GroupTransactionDetailsDialog extends StatelessWidget {
  final String emoji;
  final String itemName;
  final String amount;
  final String date;
  final String member;
  final String comment;
  final BuildContext context;

  const GroupTransactionDetailsDialog({
    Key? key,
    required this.emoji,
    required this.itemName,
    required this.amount,
    required this.date,
    required this.member,
    required this.comment,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Transaction Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
              Spacer(),
              Container(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    '🗑️',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
          Text(
            emoji,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 8),
          Text('Item: $itemName', style: MyTextStyles.mediumBlackText),
          const SizedBox(height: 8),
          Text('Amount: $amount', style: MyTextStyles.mediumBlackText),
          const SizedBox(height: 8),
          Text('Date: $date', style: MyTextStyles.mediumBlackText),
          const SizedBox(height: 8),
          Text('Member: $member', style: MyTextStyles.mediumBlackText),
          const SizedBox(height: 8),
          Text('Comment: $comment', style: MyTextStyles.mediumBlackText),
        ],
      ),
    );
  }
}
