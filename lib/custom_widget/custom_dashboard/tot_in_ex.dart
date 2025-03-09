import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('ledger')
        .snapshots()
        .map((snapshot) {
      double income = 0;
      double expense = 0;

      for (QueryDocumentSnapshot ledgerDoc in snapshot.docs) {
        Map<String, dynamic> data = ledgerDoc.data() as Map<String, dynamic>;
        String type = data['type'] as String;
        num? amount = data['amount'] as num?;

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
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _getLedgerDataStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Text('No data');
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
                Column(
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
                Column(
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
                Column(
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
              ],
            ),
            const Divider(
              height: 20,
              thickness: 1,
              color: Color.fromARGB(255, 109, 109, 109),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildButton(0, 'Weekly'),
                SizedBox(
                  width: 5,
                ),
                _buildButton(1, 'Monthly'),
                SizedBox(
                  width: 5,
                ),
                _buildButton(2, 'Yearly'),
              ],
            )
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
