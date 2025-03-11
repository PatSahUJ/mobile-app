// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:senior_project/pages/expense/calculation_utils.dart';
// import 'package:senior_project/pages/expense/expense_data_provider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import 'package:uuid/uuid.dart';

// class BillPage extends StatefulWidget {
//   final List<String> memberNames;
//   BillPage({required this.memberNames});

//   @override
//   _BillPageState createState() => _BillPageState();
// }

// class _BillPageState extends State<BillPage> {
//   Map<String, TextEditingController> amountControllers = {};
//   Map<String, String> userIdToUsername = {};
//   bool _isLoading = true; // Add loading state
//   @override
//   void initState() {
//     super.initState();
//     _fetchUsernames();
//   }

//   Future<void> _fetchUsernames() async {
//     List<String> members = List.from(widget.memberNames);
//     String myUserId = FirebaseAuth.instance.currentUser?.uid ?? "Me";

//     for (String member in members) {
//       if (member != myUserId) {
//         try {
//           DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
//               .collection('users')
//               .doc(member)
//               .get();
//           if (userSnapshot.exists) {
//             String username = userSnapshot['username'] ?? 'Unknown User';
//             userIdToUsername[member] = username;
//           }
//         } catch (e) {
//           print("Error fetching username for $member: $e");
//         }
//       }
//       amountControllers[member] = TextEditingController();
//     }
//     setState(() {
//       _isLoading = false; // Set loading to false after data is fetched
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<String> members = List.from(widget.memberNames);
//     String myUserId = FirebaseAuth.instance.currentUser?.uid ?? "Me";
//     if (_isLoading) {
//       return Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }
//     return Scaffold(
//       appBar: AppBar(title: Text('For Who?')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Text('Enter bill amount for each person:'),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: members.length,
//                 itemBuilder: (context, index) {
//                   String member = members[index];
//                   String displayName = member == myUserId
//                       ? "Me"
//                       : userIdToUsername[member] ?? member;
//                   return ListTile(
//                     title: Text(displayName),
//                     trailing: SizedBox(
//                       width: 80,
//                       child: TextField(
//                         controller: amountControllers[member],
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(),
//                           contentPadding:
//                               EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                           hintText: 'Amount',
//                           hintStyle: TextStyle(fontSize: 12),
//                         ),
//                         keyboardType:
//                             TextInputType.numberWithOptions(decimal: true),
//                         onChanged: (value) {},
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 final expenseProvider =
//                     Provider.of<ExpenseDataProvider>(context, listen: false);

//                 List<Map<String, dynamic>> billsData = [];
//                 bool allAmountsFilled = true;

//                 for (String member in members) {
//                   if (amountControllers[member]!.text.isNotEmpty) {
//                     billsData.add({
//                       'name': member,
//                       'amount':
//                           double.tryParse(amountControllers[member]!.text) ??
//                               0.0,
//                     });
//                   } else {
//                     allAmountsFilled = false;
//                     break;
//                   }
//                 }

//                 if (allAmountsFilled) {
//                   expenseProvider.updateBillsAmounts(billsData);

//                   List<Map<String, dynamic>> paymentTransactions =
//                       CalculationUtils.getPaymentTransactions(context);

//                   print("Payment Transactions:");
//                   for (var transaction in paymentTransactions) {
//                     print(transaction);
//                   }

//                   String type = expenseProvider.type;
//                   DateTime? date = expenseProvider.date;
//                   String comment = expenseProvider.comment;
//                   String category = expenseProvider.category;
//                   double myAmount = 0.0;
//                   for (var bill in billsData) {
//                     if (bill['name'] ==
//                         FirebaseAuth.instance.currentUser?.uid) {
//                       myAmount = bill['amount'];
//                       break;
//                     }
//                   }

//                   User? user = FirebaseAuth.instance.currentUser;
//                   if (user != null) {
//                     final groupId = Uuid().v4();

//                     // await FirebaseFirestore.instance
//                     //     .collection('groupLedger')
//                     //     .doc(groupId)
//                     //     .set({
//                     //       'transactions': paymentTransactions,
//                     //       'timestamp': FieldValue.serverTimestamp(),
//                     //       'memberCount': billsData.length,
//                     //       'type': type,
//                     //       'amount': myAmount,
//                     //       'date': date != null
//                     //           ? DateFormat('yyyy-MM-dd').format(date)
//                     //           : null,
//                     //       'comment': comment,
//                     //       'category': category,
//                     //       'payer': expenseProvider.payersData,
//                     //       'bill': expenseProvider.billsAmounts,
//                     //       'createdBy': user.uid,
//                     //       'groupId': groupId,
//                     //     })
//                     //     .then((value) =>
//                     //         print("Transactions added to group ledger"))
//                     //     .catchError((error) =>
//                     //         print("Failed to add transactions: $error"));

//                     for (String memberId in members) {
//                       String userIdToUpdate =
//                           memberId == "Me" ? user.uid : memberId;
//                       // DocumentReference userRef = FirebaseFirestore.instance
//                       //     .collection('users')
//                       //     .doc(userIdToUpdate);

//                       // await userRef.update({
//                       //   'groupIds': FieldValue.arrayUnion([groupId])
//                       // });

//                       double memberAmount = 0.0; // Initialize to 0

//                       // Find the member's paid amount in payersData
//                       for (var payer in expenseProvider.payersData) {
//                         if (payer['payer'] == userIdToUpdate) {
//                           memberAmount = payer['amountPaid'];
//                           break;
//                         }
//                       }

//                       await FirebaseFirestore.instance
//                           .collection('users')
//                           .doc(userIdToUpdate)
//                           .collection('ledger')
//                           .add({
//                         'transactions': paymentTransactions,
//                         'timestamp': FieldValue.serverTimestamp(),
//                         'member': billsData.length,
//                         'type': type,
//                         'amount': memberAmount, // Use memberAmount here
//                         'date': date != null
//                             ? DateFormat('yyyy-MM-dd').format(date)
//                             : null,
//                         'comment': comment,
//                         'category': category,
//                         'payer': expenseProvider.payersData,
//                         'bill': expenseProvider.billsAmounts,
//                         'groupId': groupId,
//                       });
//                     }
//                   } else {
//                     print("User not logged in");
//                   }

//                   Navigator.pushNamed(context, '/dashboard');
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content:
//                           Text("Please fill in the amount for every member."),
//                     ),
//                   );
//                 }
//               },
//               child: Text('Complete'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senior_project/pages/expense/calculation_utils.dart';
import 'package:senior_project/pages/expense/expense_data_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:senior_project/style/my_text_style.dart';
import 'package:uuid/uuid.dart';

class BillPage extends StatefulWidget {
  final List<String> memberNames;
  BillPage({required this.memberNames});

  @override
  _BillPageState createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  Map<String, TextEditingController> amountControllers = {};
  Map<String, String> userIdToUsername = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsernames();
  }

  Future<void> _fetchUsernames() async {
    List<String> members = List.from(widget.memberNames);
    String myUserId = FirebaseAuth.instance.currentUser?.uid ?? "Me";

    for (String member in members) {
      if (member != myUserId) {
        try {
          DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(member)
              .get();
          if (userSnapshot.exists) {
            String username = userSnapshot['username'] ?? 'Unknown User';
            userIdToUsername[member] = username;
          }
        } catch (e) {
          print("Error fetching username for $member: $e");
        }
      }
      amountControllers[member] = TextEditingController();
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> members = List.from(widget.memberNames);
    String myUserId = FirebaseAuth.instance.currentUser?.uid ?? "Me";
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('For Who?')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Enter bill amount for each person:'),
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
                  String displayName = member == myUserId
                      ? "Me"
                      : userIdToUsername[member] ?? member;
                  return ListTile(
                    title: Text(displayName),
                    trailing: SizedBox(
                      width: 80,
                      child: TextField(
                        controller: amountControllers[member],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          hintText: 'Amount',
                          hintStyle: TextStyle(fontSize: 12),
                        ),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        onChanged: (value) {},
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final expenseProvider =
                    Provider.of<ExpenseDataProvider>(context, listen: false);

                List<Map<String, dynamic>> billsData = [];
                bool allAmountsFilled = true;

                for (String member in members) {
                  if (amountControllers[member]!.text.isNotEmpty) {
                    billsData.add({
                      'name': member,
                      'amount':
                          double.tryParse(amountControllers[member]!.text) ??
                              0.0,
                    });
                  } else {
                    allAmountsFilled = false;
                    break;
                  }
                }

                if (allAmountsFilled) {
                  expenseProvider.updateBillsAmounts(billsData);

                  List<Map<String, dynamic>> paymentTransactions =
                      CalculationUtils.getPaymentTransactions(context);

                  print("Payment Transactions:");
                  for (var transaction in paymentTransactions) {
                    print(transaction);
                  }

                  String type = expenseProvider.type;
                  DateTime? date = expenseProvider.date;
                  String comment = expenseProvider.comment;
                  String category = expenseProvider.category;
                  // Get the amount from the provider
                  double providerAmount = expenseProvider.amount;

                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    final groupId = Uuid().v4();

                    await FirebaseFirestore.instance
                        .collection('groups')
                        .doc(groupId)
                        .set({
                      'name': 'Group Expense',
                      'members': members,
                      'created_at': FieldValue.serverTimestamp(),
                    });

                    await FirebaseFirestore.instance
                        .collection('groups')
                        .doc(groupId)
                        .collection('ledger')
                        .add({
                      'transactions': paymentTransactions,
                      'timestamp': FieldValue.serverTimestamp(),
                      'member': billsData.length,
                      'type': type,
                      // Use the amount from the provider
                      'amount': providerAmount,
                      'date': date != null
                          ? DateFormat('yyyy-MM-dd').format(date)
                          : null,
                      'comment': comment,
                      'category': category,
                      'payer': expenseProvider.payersData,
                      'bill': expenseProvider.billsAmounts,
                      'creator': user.uid,
                    });

                    for (String memberId in members) {
                      String userIdToUpdate =
                          memberId == FirebaseAuth.instance.currentUser?.uid
                              ? user.uid
                              : memberId;
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userIdToUpdate)
                          .collection('groups')
                          .doc(groupId)
                          .set({});
                    }
                  } else {
                    print("User not logged in");
                  }

                  Navigator.pushNamed(context, '/dashboard');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text("Please fill in the amount for every member."),
                    ),
                  );
                }
              },
              child: Text('Complete'),
            ),
          ],
        ),
      ),
    );
  }
}
