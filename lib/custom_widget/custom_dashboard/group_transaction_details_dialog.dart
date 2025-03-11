import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:senior_project/custom_widget/custom_dashboard/debt_transaction_details_dialog.dart';
import 'package:senior_project/style/my_text_style.dart';

class GroupTransactionDetailsDialog extends StatefulWidget {
  final String emoji;
  final String itemName;
  final String amount;
  final String date;
  final String member;
  final String comment;
  final BuildContext context;
  final Map<String, dynamic> ledgerDocument;
  final bool isGroup;

  const GroupTransactionDetailsDialog({
    Key? key,
    required this.emoji,
    required this.itemName,
    required this.amount,
    required this.date,
    required this.member,
    required this.comment,
    required this.context,
    required this.ledgerDocument,
    required this.isGroup,
  }) : super(key: key);

  @override
  _GroupTransactionDetailsDialogState createState() =>
      _GroupTransactionDetailsDialogState();
}

class _GroupTransactionDetailsDialogState
    extends State<GroupTransactionDetailsDialog> {
  List<String> usernames = [];
  List<String> payersUsernames = [];
  List<Map<String, dynamic>> payersData = [];
  List<Map<String, dynamic>> billsData = [];
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await _fetchBillsUsernames(widget.ledgerDocument);
    await _fetchPayersUsernames(widget.ledgerDocument);
    await _fetchBillsData(widget.ledgerDocument);
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

  Future<void> _fetchBillsData(Map<String, dynamic> ledgerData) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (ledgerData.containsKey('bill')) {
      final bills = ledgerData['bill'] as List;
      List<Map<String, dynamic>> fetchedBills = [];

      for (var bill in bills) {
        String userId = bill['name'];
        String username = userId == currentUser!.uid
            ? 'Me'
            : await _getUsername(userId) ?? 'Unknown';
        double amount = bill['amount'] as double;

        fetchedBills.add({'username': username, 'amount': amount});
      }
      setState(() {
        billsData = fetchedBills; // Store all bills data
      });
      print('billsData: $billsData');
    }
  }

  Future<void> _fetchPayersUsernames(Map<String, dynamic> ledgerData) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (ledgerData.containsKey('payer')) {
      final payers = ledgerData['payer'] as List;
      List<Map<String, dynamic>> fetchedPayers =
          []; // Store username and amount

      for (var payer in payers) {
        String userId = payer['payer'];
        String username = userId == currentUser!.uid
            ? 'Me'
            : await _getUsername(userId) ?? 'Unknown';
        double amountPaid = payer['amountPaid'] as double;

        fetchedPayers.add({'username': username, 'amountPaid': amountPaid});
      }
      setState(() {
        payersUsernames =
            fetchedPayers.map((payer) => payer['username'] as String).toList();
        payersData = fetchedPayers; // Store all payer data in widget
      });
      print('payerrr: $payersUsernames');
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

  Future<void> deleteTransaction() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("Error: No current user found.");
      return;
    }
    final currentUserId = user.uid;

    // Get groupId from user's groups collection
    String? groupId;
    final userGroupsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('groups')
        .get();

    if (userGroupsSnapshot.docs.isEmpty) {
      print("Error: No groupId found in user's groups.");
      return;
    }

    // Assuming there is only one group (if multiple groups exist, adjust accordingly)
    groupId = userGroupsSnapshot.docs.first.id;
    print("Found groupId in user's groups: $groupId");

    // Now fetch the ledger document using groupId
    final ledgerDocument = widget.ledgerDocument;
    final billData = ledgerDocument['bill'];
    if (billData == null || billData is! List) {
      print("Error: bill data is null or not a list");
      return;
    }

    final payerData = ledgerDocument['payer'];
    if (payerData == null || payerData is! List) {
      print("Error: payer data is null or not a list");
      return;
    }

    // Loop through each bill and perform deletion
    for (var bill in billData) {
      String? memberId = bill['name'] as String?;
      if (memberId == null) continue;

      // Query to find ledger entries for this payer
      QuerySnapshot ledgerQuery = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('ledger')
          .where('transactions', arrayContains: {'payer': memberId}).get();

      for (QueryDocumentSnapshot ledgerDoc in ledgerQuery.docs) {
        // Delete the ledger transaction document
        await ledgerDoc.reference.delete();
        print('Deleted transaction for: $memberId, ledgerId: ${ledgerDoc.id}');
      }

      // Delete the reference from the user's group collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(memberId)
          .collection('groups')
          .doc(groupId)
          .delete();
      Navigator.pushNamed(context, '/dashboard');
      print('Deleted group $groupId reference from user: $memberId');
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
              Container(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    deleteTransaction();
                  },
                  child: Text(
                    '🗑️',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
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
                          '${widget.emoji} ',
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
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Row(
                    children: [
                      const Text(
                        'Members : ',
                        style: MyTextStyles.size16GreyText,
                      ),
                      Expanded(
                        child: Text(
                          usernames.join(', '),
                          style: MyTextStyles.size14lightText,
                          softWrap: true, // Enable line wrapping
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      'Comment : ',
                      style: MyTextStyles.size16GreyText,
                    ),
                    Text(
                      widget.comment,
                      style: MyTextStyles.size14lightText,
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Row(
                  children: [
                    SizedBox(width: MediaQuery.of(context).size.height * 0.02),
                    Text(
                      'Paid By',
                      style: MyTextStyles.mediumBlackText,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: payersUsernames.asMap().entries.map((entry) {
                    int index = entry.key;
                    String username = entry.value;
                    double amountPaid =
                        payersData[index]['amountPaid'] as double;

                    return Container(
                      width: MediaQuery.of(context).size.width * 0.45,
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
                          Text(username, style: TextStyle(fontSize: 16)),
                          Text('\$${amountPaid.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Row(
                  children: [
                    SizedBox(width: MediaQuery.of(context).size.height * 0.02),
                    Text(
                      'For',
                      style: MyTextStyles.mediumBlackText,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: billsData.asMap().entries.map((entry) {
                    int index = entry.key;
                    String username = entry.value['username'];
                    double amount = entry.value['amount'] as double;

                    return Container(
                      width: MediaQuery.of(context).size.width * 0.45,
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
                          Text(username, style: TextStyle(fontSize: 16)),
                          Text('\$${amount.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.35,
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the current dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            DebtTransactionDetailsDialog(
                          context: context,
                          ledgerDocument: widget.ledgerDocument,
                          isGroup: widget.isGroup, // Pass the ledgerId
                        ),
                      );
                    },
                    child: const Text(
                      'Debt',
                      style: MyTextStyles.mediumBoldBlackText,
                    )),
              ),
            ],
          )
        ],
      ),
    );
  }
}
