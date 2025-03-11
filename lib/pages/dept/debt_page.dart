import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:senior_project/pages/dept/payback_dialog.dart';
import 'package:senior_project/style/my_text_style.dart';

class DebtPage extends StatefulWidget {
  const DebtPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DebtPageState();
  }
}

class _DebtPageState extends State<DebtPage> {
  Map<String, List<Map<String, dynamic>>> groupedDebts = {};
  bool isLoading = true;
  Map<String, String> categoryEmojis = {};
  double netBalance = 0.0;
  String currentUserUsername = ''; // Add this line
  String groupId = ''; // Add this line
  String ledgerId = ''; // Add this line

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await _fetchCategoryEmojis();
    await _fetchAndGroupDebts();
  }

  Future<void> _fetchCategoryEmojis() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      QuerySnapshot categorySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('category')
          .get();

      Map<String, String> emojis = {};
      for (QueryDocumentSnapshot doc in categorySnapshot.docs) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('emoji')) {
          emojis[doc.id] = data['emoji'] as String;
        }
      }

      setState(() {
        categoryEmojis = emojis;
      });
    } catch (e) {
      print('Error fetching category emojis: $e');
    }
  }

  Future<void> _fetchAndGroupDebts() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      List<String> groupIds = await _getUserGroupIds(currentUser.uid);
      Map<String, List<Map<String, dynamic>>> grouped = {};
      double balance = 0.0;
      for (String groupId in groupIds) {
        QuerySnapshot ledgerSnapshots = await FirebaseFirestore.instance
            .collection('groups')
            .doc(groupId)
            .collection('ledger')
            .get();

        for (var doc in ledgerSnapshots.docs) {
          Map<String, dynamic> ledgerData = doc.data() as Map<String, dynamic>;
          if (ledgerData.containsKey('transactions')) {
            List transactions = ledgerData['transactions'];
            String date = ledgerData['date'];
            String category = ledgerData['category'];
            String comment = ledgerData['comment'];
            for (var transaction in transactions) {
              if (transaction['payer'] == currentUser.uid ||
                  transaction['payee'] == currentUser.uid) {
                String username = '';
                double amount = 0;
                bool isPayer = false;

                if (transaction['payer'] == currentUser.uid) {
                  String payeeId = transaction['payee'];
                  username = await _getUsername(payeeId) ?? 'Unknown';
                  amount = transaction['amount'];
                  isPayer = true;
                  balance -= amount;
                } else {
                  String payerId = transaction['payer'];
                  username = await _getUsername(payerId) ?? 'Unknown';
                  amount = transaction['amount'];
                  isPayer = false;
                  balance += amount;
                }

                if (!grouped.containsKey(date)) {
                  grouped[date] = [];
                }

                grouped[date]!.add({
                  'category': category,
                  'username': username,
                  'amount': amount,
                  'isPayer': isPayer, // Add this line
                  'transaction': transaction, // Store the transaction
                  'ledgerId': doc.id, // Store ledger ID
                  'groupId': groupId, // Store Group ID
                  'comment': comment, // Store Group ID
                });
              }
            }
          }
        }
      }

      var sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
      Map<String, List<Map<String, dynamic>>> sortedGrouped = {};
      for (var key in sortedKeys) {
        sortedGrouped[key] = grouped[key]!;
      }

      String? username =
          await _getUsername(currentUser.uid); // Get current username.

      setState(() {
        groupedDebts = sortedGrouped;
        isLoading = false;
        netBalance = balance;
        currentUserUsername = username ?? 'Unknown'; // Set current username.
      });
    } catch (e) {
      print('Error fetching debts: $e');
      setState(() {
        isLoading = false;
      });
    }
    print('debt data $groupedDebts');
  }

  Future<List<String>> _getUserGroupIds(String userId) async {
    QuerySnapshot groupSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('groups')
        .get();

    return groupSnapshot.docs.map((doc) => doc.id).toList();
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
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration:
                        BoxDecoration(color: Theme.of(context).primaryColor),
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.05,
                          bottom: MediaQuery.of(context).size.height * 0.015),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.arrow_back_ios_new_outlined,
                                  size: 30,
                                  color: Colors.black,
                                ),
                                Text(' Debt', style: MyTextStyles.heading1),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.1,
                              ),
                              const Text(
                                'Net Balance: ',
                                style: MyTextStyles.size20BlackText,
                              ),
                              Text(
                                netBalance.toStringAsFixed(2),
                                style: netBalance >= 0
                                    ? MyTextStyles.size20GreenText
                                    : MyTextStyles.size20RedText,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.1,
                              ),
                              Text(
                                netBalance >= 0 ? 'You are owed' : 'You owe',
                                style: MyTextStyles.size14lightText,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  ...groupedDebts.entries.map((entry) {
                    final date = entry.key;
                    final debts = entry.value;

                    return ExpansionTile(
                      title: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(
                            Theme.of(context).primaryColor.red,
                            (Theme.of(context).primaryColor.green + 31)
                                .clamp(0, 255),
                            (Theme.of(context).primaryColor.blue + 95)
                                .clamp(0, 255),
                            1.0,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(
                                color: Color.fromARGB(20, 0, 0, 0),
                                blurRadius: 4,
                                spreadRadius: 2,
                                offset: Offset(0, 4))
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(date,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      children: debts.map((debt) {
                        return ListTile(
                          onTap: () async {
                            final String? payeeUsername = await _getUsername(
                              debt['transaction']['payee'],
                            );
                            final String? payerUsername = await _getUsername(
                              debt['transaction']['payer'],
                            ); // Fetch payer's username
                            final result = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return PaybackDialog(
                                  payerId: debt['transaction']
                                      ['payer'], // Correct payerId
                                  payeeId: debt['transaction']
                                      ['payee'], // Correct payeeId
                                  payerUsername: payerUsername ??
                                      'Unknown', // Use fetched payerUsername
                                  payeeUsername: payeeUsername ??
                                      'Unknown', // Use the resolved username or 'Unknown'
                                  amount: debt['amount'],
                                  category: debt['category'],
                                  date: date,
                                  comment: debt['comment'] ??
                                      '', // Add your comment logic
                                  groupId: debt['groupId'],
                                  ledgerId: debt['ledgerId'],
                                );
                              },
                            );
                            if (result != null && result) {
                              _fetchAndGroupDebts(); // Refresh the debt page
                            }
                          },
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(categoryEmojis[debt['category']] ?? '❔',
                                      style: const TextStyle(fontSize: 40)),
                                  const SizedBox(width: 10),
                                  Container(
                                    width: 1,
                                    height: 50,
                                    color: const Color.fromARGB(
                                        255, 174, 174, 174),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(debt['category'],
                                          style: MyTextStyles.mediumBlackText),
                                      Text(debt['username'],
                                          style: MyTextStyles.size14lightText),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    debt['isPayer'] ? 'You Owe' : 'Owed to you',
                                  ),
                                  SizedBox(
                                      width:
                                          MediaQuery.of(context).size.height *
                                              0.02),
                                  Text(
                                    '${debt['amount'].toStringAsFixed(2)}',
                                    style: debt['isPayer']
                                        ? MyTextStyles.size20RedText
                                        : MyTextStyles.size20GreenText,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }
}
