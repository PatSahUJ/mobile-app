import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:senior_project/custom_widget/custom_dashboard/filter/filter_provider.dart';
import 'package:senior_project/pages/dept/debt_page.dart';
import 'package:senior_project/style/my_text_style.dart';

class TotInEx extends StatefulWidget {
  const TotInEx({super.key});

  @override
  State<TotInEx> createState() => _TotInExState();
}

class _TotInExState extends State<TotInEx> {
  int? _selectedIndex; // Default to 'Weekly'
  int _rebuildTrigger = 0; // Add this line

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<FilterProvider>(context).addListener(_filterChanged);
  }

  @override
  void dispose() {
    Provider.of<FilterProvider>(context).removeListener(_filterChanged);
    super.dispose();
  }

  void _filterChanged() {
    setState(() {
      _rebuildTrigger++;
    });
  }

  Stream<Map<String, dynamic>> _getLedgerDataStream() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value({});
    }
    String userId = user.uid;
    final filterProvider = Provider.of<FilterProvider>(context, listen: false);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('ledger')
        .snapshots()
        .asyncExpand((userLedgerSnapshot) async* {
      double income = 0;
      double expense = 0;

      for (QueryDocumentSnapshot ledgerDoc in userLedgerSnapshot.docs) {
        Map<String, dynamic> data = ledgerDoc.data() as Map<String, dynamic>;
        String type = data['type'] as String;
        num? amount = data['amount'] as num?;
        String dateString = data['date'] as String;

        if (_shouldIncludeData(dateString, filterProvider, data)) {
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
      }

      QuerySnapshot groupSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('groups')
          .get();

      for (QueryDocumentSnapshot groupDoc in groupSnapshot.docs) {
        String groupId = groupDoc.id;
        QuerySnapshot groupLedgerSnapshot = await FirebaseFirestore.instance
            .collection('groups')
            .doc(groupId)
            .collection('ledger')
            .get();

        if (groupLedgerSnapshot.docs.isNotEmpty) {
          Map<String, dynamic> groupLedgerData =
              groupLedgerSnapshot.docs.first.data() as Map<String, dynamic>;
          List<dynamic>? payers = groupLedgerData['payer'] as List<dynamic>?;
          String dateString = groupLedgerData['date'] as String;

          if (_shouldIncludeData(dateString, filterProvider, groupLedgerData)) {
            if (payers != null) {
              for (var payer in payers) {
                if (payer['payer'] == userId) {
                  num? amountPaid = payer['amountPaid'] as num?;
                  if (amountPaid != null) {
                    expense += amountPaid.toDouble();
                  }
                  break;
                }
              }
            }
          }
        }
      }

      yield {
        'income': income,
        'expense': expense,
        'total': income - expense,
      };
    });
  }

  bool _shouldIncludeData(String dateString, FilterProvider filterProvider,
      Map<String, dynamic> ledgerData) {
    final currentFilterType = filterProvider.selectedFilter;
    final selectedYear = filterProvider.selectedYear;
    final selectedMonth = filterProvider.selectedMonth;
    final weeklyStartDate = filterProvider.weeklyStartDate;
    final weeklyEndDate = filterProvider.weeklyEndDate;
    final selectedCategory = filterProvider.selectedCategory;

    if (selectedCategory != null) {
      if (selectedCategory == 'Group Transaction') {
        if (ledgerData['groupId'] == null) {
          return false;
        }
      } else {
        if (ledgerData['category'] != selectedCategory) {
          return false;
        }
      }
    }

    if (currentFilterType == FilterType.all) {
      return true;
    }

    DateTime date = DateFormat('yyyy-MM-dd').parse(dateString);

    if (currentFilterType == FilterType.yearly && selectedYear != null) {
      return date.year == selectedYear;
    }

    if (currentFilterType == FilterType.monthly &&
        selectedYear != null &&
        selectedMonth != null) {
      return date.year == selectedYear && date.month == selectedMonth;
    }

    if (currentFilterType == FilterType.weekly &&
        weeklyStartDate != null &&
        weeklyEndDate != null) {
      return date.isAfter(weeklyStartDate.subtract(const Duration(days: 1))) &&
          date.isBefore(weeklyEndDate.add(const Duration(days: 1)));
    }

    return false;
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
          if (_selectedIndex == index) {
            _selectedIndex = null;
            Provider.of<FilterProvider>(context, listen: false)
                .setFilter(FilterType.all);
            Provider.of<FilterProvider>(context, listen: false)
                .clearMonthYear();
          } else {
            _selectedIndex = index;
            FilterType filter;
            if (index == 0) {
              filter = FilterType.weekly;
            } else if (index == 1) {
              filter = FilterType.monthly;
              if (Provider.of<FilterProvider>(context, listen: false)
                          .selectedMonth ==
                      null ||
                  Provider.of<FilterProvider>(context, listen: false)
                          .selectedYear ==
                      null) {
                Provider.of<FilterProvider>(context, listen: false)
                    .setMonthYear(DateTime.now().year, DateTime.now().month);
              }
            } else {
              filter = FilterType.yearly;
              if (Provider.of<FilterProvider>(context, listen: false)
                      .selectedYear ==
                  null) {
                Provider.of<FilterProvider>(context, listen: false)
                    .setYear(DateTime.now().year);
              }
            }
            Provider.of<FilterProvider>(context, listen: false)
                .setFilter(filter);
          }
          _rebuildTrigger++; // Add this line
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
