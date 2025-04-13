import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:senior_project/style/my_text_style.dart';

class DebtTransactionDetailsDialog extends StatefulWidget {
  final BuildContext context;
  final Map<String, dynamic> ledgerDocument;
  final bool isGroup;

  const DebtTransactionDetailsDialog({
    Key? key,
    required this.context,
    required this.ledgerDocument,
    required this.isGroup,
  }) : super(key: key);

  @override
  _DebtTransactionDetailsDialogState createState() =>
      _DebtTransactionDetailsDialogState();
}

class _DebtTransactionDetailsDialogState
    extends State<DebtTransactionDetailsDialog> {
  List<String> usernames = [];
  List<Map<String, dynamic>> debtData = [];
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await _fetchBillsUsernames(widget.ledgerDocument);
    await _fetchDebtData(widget.ledgerDocument);
  }

  Future<void> _fetchDebtData(Map<String, dynamic> ledgerData) async {
    if (ledgerData.containsKey('transactions')) {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final transactions = ledgerData['transactions'] as List;
      List<Map<String, dynamic>> fetchedDebt = [];

      for (var transaction in transactions) {
        String payerId = transaction['payer'];
        String payeeId = transaction['payee'];
        double amount = transaction['amount'] as double;

        String payerUsername = payerId == currentUser.uid
            ? 'Me'
            : await _getUsername(payerId) ?? 'Unknown Payer';
        String payeeUsername = payeeId == currentUser.uid
            ? 'Me'
            : await _getUsername(payeeId) ?? 'Unknown Payee';

        fetchedDebt.add({
          'payerUsername': payerUsername,
          'payeeUsername': payeeUsername,
          'amount': amount,
        });
      }
      setState(() {
        debtData = fetchedDebt;
      });
    }
  }

  Future<void> _fetchBillsUsernames(Map<String, dynamic> ledgerData) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (ledgerData.containsKey('bill')) {
      final bills = ledgerData['bill'] as List;
      List<String> fetchedUsernames = [];

      for (var bill in bills) {
        String userId = bill['name'];
        String username = userId == currentUser!.uid
            ? 'Me'
            : await _getUsername(userId) ?? 'Unknown';
        fetchedUsernames.add(username);
      }
      setState(() {
        usernames = fetchedUsernames;
      });
    }
  }

  Future<String?> _getUsername(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        return userSnapshot.get('username') as String?;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching username: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Row(
                  children: [
                    SizedBox(width: MediaQuery.of(context).size.height * 0.02),
                    const Text(
                      'Settle debt',
                      style: MyTextStyles.mediumBlackText,
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: debtData.map((debt) {
                    return Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      margin: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.005),
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 0.01),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 3,
                            child: Text(
                              debt['payerUsername'],
                              overflow: TextOverflow.ellipsis,
                              style: MyTextStyles.size16BlackText,
                            ),
                          ),
                          Flexible(
                            flex: 4,
                            child: Text(
                              '──────>',
                              overflow: TextOverflow.clip,
                              textAlign: TextAlign.center,
                              style: MyTextStyles.size16BlackText,
                            ),
                          ),
                          Flexible(
                            flex: 3,
                            child: Text(
                              debt['payeeUsername'],
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                              style: MyTextStyles.size16BlackText,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
