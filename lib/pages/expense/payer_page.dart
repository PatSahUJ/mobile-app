import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senior_project/pages/expense/expense_data_provider.dart';
import 'package:senior_project/pages/expense/bill_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:senior_project/style/my_text_style.dart';

class PayerPage extends StatefulWidget {
  final List<String> memberIds;
  PayerPage({required this.memberIds});

  @override
  _PayerPageState createState() => _PayerPageState();
}

class _PayerPageState extends State<PayerPage> {
  String? selectedPayer;
  double amountPaid = 0.0;
  TextEditingController amountController = TextEditingController();
  String myUserId = FirebaseAuth.instance.currentUser?.uid ?? "Me";
  Map<String, bool> memberSelected = {};
  Map<String, TextEditingController> amountControllers = {};
  Map<String, String> userIdToUsername = {};
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true; // Add loading state

  @override
  void initState() {
    super.initState();
    _fetchUsernames();
  }

  Future<void> _fetchUsernames() async {
    List<String> members = [];
    members.add(myUserId);

    for (String userId in widget.memberIds) {
      try {
        DocumentSnapshot userSnapshot =
            await _firestore.collection('users').doc(userId).get();
        if (userSnapshot.exists) {
          String username = userSnapshot['username'] ?? 'Unknown User';
          userIdToUsername[userId] = username;
          members.add(userId);
        } else {
          print('User document not found for userId: $userId');
          members.add(userId);
        }
      } catch (e) {
        print('Error fetching user data: $e');
        members.add(userId);
      }
    }

    setState(() {
      for (String member in members) {
        memberSelected[member] = false;
        amountControllers[member] = TextEditingController();
      }
      _isLoading = false; // Set loading to false after data is fetched
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> members = [myUserId, ...widget.memberIds];

    if (_isLoading) {
      // Show loading indicator while data is being fetched
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Who Paid?',
          style: MyTextStyles.heading1,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        toolbarHeight: MediaQuery.of(context).size.height * 0.07,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Select the person who paid:',
              style: MyTextStyles.size18BlackText,
            ),
            Consumer<ExpenseDataProvider>(
              builder: (context, expenseProvider, child) {
                return Text(
                  'Total Amount: ${expenseProvider.amount}',
                  style: MyTextStyles.size16lightText,
                );
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: members.length,
                itemBuilder: (context, index) {
                  String member = members[index];
                  return ListTile(
                    leading: Checkbox(
                      value: memberSelected[member],
                      onChanged: (bool? value) {
                        setState(() {
                          memberSelected[member] = value!;
                        });
                      },
                    ),
                    title: Text(member == myUserId
                        ? "Me"
                        : userIdToUsername[member] ?? member),
                    trailing: memberSelected[member] == true
                        ? SizedBox(
                            width: 80,
                            child: TextField(
                              controller: amountControllers[member],
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                hintText: 'Amount',
                                hintStyle: TextStyle(fontSize: 12),
                              ),
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              onChanged: (value) {},
                            ),
                          )
                        : null,
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.symmetric(horizontal: 60, vertical: 20),
              ),
              onPressed: () {
                final expenseProvider =
                    Provider.of<ExpenseDataProvider>(context, listen: false);

                List<Map<String, dynamic>> payersData = [];
                double totalEnteredAmount = 0.0;

                for (String member in members) {
                  if (memberSelected[member] == true &&
                      amountControllers[member]!.text.isNotEmpty) {
                    double amount =
                        double.tryParse(amountControllers[member]!.text) ?? 0.0;
                    payersData.add({'payer': member, 'amountPaid': amount});
                    totalEnteredAmount += amount;
                  }
                }
                if (totalEnteredAmount != expenseProvider.amount) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          "The sum of entered amounts must equal the total amount."),
                    ),
                  );
                  return;
                }
                if (payersData.isNotEmpty) {
                  expenseProvider.updatePayersData(payersData);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BillPage(memberNames: members),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Please select at least one payer and enter an amount."),
                    ),
                  );
                }
              },
              child: Text(
                'Next',
                style: MyTextStyles.mediumBoldBlackText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
