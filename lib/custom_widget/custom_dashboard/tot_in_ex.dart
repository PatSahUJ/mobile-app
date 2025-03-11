import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:senior_project/pages/dept/debt_page.dart';
import 'package:senior_project/style/my_text_style.dart';

class TotInEx extends StatefulWidget {
  const TotInEx({super.key});

  @override
  State<TotInEx> createState() => _TotInExState();
}

class _TotInExState extends State<TotInEx> {
  int _selectedIndex = 0; // Default to 'Weekly'

  Stream<Map<String, dynamic>> _getLedgerDataStream() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value({});
    }

    String userId = user.uid;

    return _fetchUserLedger(userId).asyncExpand((userLedger) {
      return _fetchGroupLedgers(userId).map((groupLedgers) {
        // Combine user and group ledgers
        List<QueryDocumentSnapshot> combinedLedgers = [];
        combinedLedgers.addAll(userLedger);
        combinedLedgers.addAll(groupLedgers);

        double income = 0;
        double expense = 0;

        for (QueryDocumentSnapshot ledgerDoc in combinedLedgers) {
          Map<String, dynamic> data = ledgerDoc.data() as Map<String, dynamic>;
          String type = data['type'] as String;
          num? amount = data['amount'] as num?;
          List<dynamic>? payers = data['payer'] as List<dynamic>?;

          if (payers != null && payers.isNotEmpty) {
            // Group ledger entry
            for (var payer in payers) {
              if (payer['payer'] == userId) {
                amount = payer['amountPaid'] as num?;
                break;
              }
            }
          }

          if (amount != null) {
            try {
              double amountDouble = amount.toDouble();
              if (type == 'income') {
                income += amountDouble;
              } else if (type == 'expense') {
                expense += amountDouble;
              }
            } catch (e) {
              print('Error processing amount: $e');
              print('Problematic data: $data');
            }
          } else {
            print('Amount is null in data: $data');
          }
        }

        return {
          'income': income,
          'expense': expense,
          'total': income - expense,
        };
      });
    });
  }

  Stream<List<QueryDocumentSnapshot>> _fetchUserLedger(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('ledger')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Stream<List<QueryDocumentSnapshot>> _fetchGroupLedgers(String userId) async* {
    List<String> groupIds = await _getUserGroupIds(userId);

    // Skip if no groups are found
    if (groupIds.isEmpty) {
      print('No groups found, yielding empty list');
      yield []; // Yield an empty list to complete the stream
      return;
    }

    for (String groupId in groupIds) {
      yield* FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('ledger')
          .snapshots()
          .map((snapshot) => snapshot.docs);
    }
  }

  Future<List<String>> _getUserGroupIds(String userId) async {
    try {
      QuerySnapshot groupSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('groups')
          .get();

      // If the groups collection is empty, return an empty list
      if (groupSnapshot.docs.isEmpty) {
        return []; // No groups found, skip fetching group ledgers
      }

      // Return the group IDs if groups exist
      return groupSnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error fetching user groups: $e');
      return []; // If there’s an error, return an empty list
    }
  }

  @override
  Widget build(BuildContext context) {
    // (Your existing build method remains the same)
    return StreamBuilder<Map<String, dynamic>>(
      stream: _getLedgerDataStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          return const Text('No data available');
        }

        final data = snapshot.data!;
        final totIncome = data['income'] as double;
        final totExpense = data['expense'] as double;
        final tot = data['total'] as double;

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '฿${tot.toStringAsFixed(2)}',
                        style: MyTextStyles.mediumBoldBlackText,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Total',
                        style: MyTextStyles.size16GreyText,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '฿${totIncome.toStringAsFixed(2)}',
                        style: MyTextStyles.mediumBoldGreenText,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Income',
                        style: MyTextStyles.size16GreyText,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  // Use Expanded for flexible spacing
                  child: Column(
                    children: [
                      Text(
                        '฿${totExpense.toStringAsFixed(2)}',
                        style: MyTextStyles.mediumBoldRedText,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Expense',
                        style: MyTextStyles.size16GreyText,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(
              height: 20,
              thickness: 1,
              color: Color.fromARGB(255, 109, 109, 109),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildButton(0, 'Weekly'),
                    const SizedBox(width: 5),
                    _buildButton(1, 'Monthly'),
                    const SizedBox(width: 5),
                    _buildButton(2, 'Yearly'),
                  ],
                ),
                Container(
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 192, 206, 255),
                        borderRadius: BorderRadius.circular(10)),
                    child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DebtPage()),
                          );
                        },
                        child: const Text(
                          'Debt',
                          style: MyTextStyles.size16lightText,
                        ))),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildButton(int index, String text) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 5),
        backgroundColor: _selectedIndex == index
            ? const Color.fromARGB(131, 255, 193, 69)
            : const Color.fromARGB(196, 243, 243, 243),
        foregroundColor: _selectedIndex == index ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      onPressed: () {
        setState(() {
          _selectedIndex = index;
          // Add logic to filter data based on selected period (Weekly, Monthly, Yearly)
          // For example, you can call a function to update the _getLedgerDataStream()
          // based on the selected period.
        });
      },
      child: Text(
        text,
        style: MyTextStyles.priColorLightText.copyWith(
          color: _selectedIndex == index ? Colors.white : null,
        ),
      ),
    );
  }
}
