import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  Map<String, double> categoryTotals = {};
  List<PieChartSectionData> pieChartSections = [];
  String _selectedType = 'expense'; // Default to expense
  Map<String, String> categoryEmojis = {};

  @override
  void initState() {
    super.initState();
    _loadCategoryStatistics();
    _fetchCategoryEmojis();
  }

  Future<void> _loadCategoryStatistics() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userId = user.uid;
    Map<String, double> totals = {};

    // Fetch personal ledger data
    final ledgerSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('ledger')
        .get();

    for (var doc in ledgerSnapshot.docs) {
      final data = doc.data();
      _processLedgerData(data, totals);
    }

    // Fetch group ledger data
    final groupSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('groups')
        .get();

    for (var groupDoc in groupSnapshot.docs) {
      final groupId = groupDoc.id;
      final groupLedgerSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('ledger')
          .get();

      if (groupLedgerSnapshot.docs.isNotEmpty) {
        final groupLedgerData = groupLedgerSnapshot.docs.first.data();
        _processGroupLedgerData(groupLedgerData, totals, userId);
      }
    }

    setState(() {
      categoryTotals = totals;
      pieChartSections = _generatePieChartSections(totals);
    });
  }

  Future<void> _fetchCategoryEmojis() async {
    // Add this function
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userId = user.uid;
    final categorySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('category')
        .get();

    Map<String, String> emojis = {};
    for (var doc in categorySnapshot.docs) {
      final data = doc.data();
      if (data != null && data.containsKey('emoji')) {
        emojis[doc.id] = data['emoji'] as String;
      }
    }

    setState(() {
      categoryEmojis = emojis;
    });
  }

  void _processLedgerData(
      Map<String, dynamic> data, Map<String, double> totals) {
    final category = data['category'] as String?;
    final amount = data['amount'] as num?;
    final type = data['type'] as String?;
    final dateString = data['date'] as String?;

    if (category != null &&
        amount != null &&
        type != null &&
        dateString != null) {
      DateTime date = DateFormat('yyyy-MM-dd').parse(dateString);
      if (type == _selectedType) {
        // Use selected type
        if (totals.containsKey(category)) {
          totals[category] = totals[category]! + amount.toDouble();
        } else {
          totals[category] = amount.toDouble();
        }
      }
    }
  }

  void _processGroupLedgerData(
      Map<String, dynamic> data, Map<String, double> totals, String userId) {
    List<dynamic>? payers = data['payer'] as List<dynamic>?;
    String dateString = data['date'] as String;
    String category = data['category'] as String? ?? 'Group Transaction';

    if (payers != null && dateString != null) {
      DateTime date = DateFormat('yyyy-MM-dd').parse(dateString);
      for (var payer in payers) {
        if (payer['payer'] == userId) {
          num? amountPaid = payer['amountPaid'] as num?;
          if (amountPaid != null) {
            if (_selectedType == 'expense') {
              // Only for expense in groups
              if (totals.containsKey(category)) {
                totals[category] = totals[category]! + amountPaid.toDouble();
              } else {
                totals[category] = amountPaid.toDouble();
              }
            }
          }
          break;
        }
      }
    }
  }

  List<PieChartSectionData> _generatePieChartSections(
      Map<String, double> totals) {
    List<PieChartSectionData> sections = [];
    if (totals.isNotEmpty) {
      double totalSum = totals.values.reduce((a, b) => a + b);
      List<Color> colors = [
        const Color.fromARGB(255, 167, 206, 237),
        const Color.fromARGB(255, 184, 209, 173),
        const Color.fromARGB(255, 255, 170, 165),
        const Color.fromARGB(255, 254, 245, 169),
        const Color.fromARGB(255, 196, 161, 202),
        const Color.fromARGB(255, 234, 184, 132),
        const Color.fromARGB(255, 159, 221, 214),
        const Color.fromARGB(255, 204, 186, 150),
        const Color.fromARGB(255, 90, 107, 109)
      ];
      int colorIndex = 0;

      totals.forEach((category, total) {
        String emoji = categoryEmojis[category] ?? '';
        if (category == 'Repayment') {
          emoji = '💸';
        }
        sections.add(
          PieChartSectionData(
            value: total,
            title: '${emoji}\n${(total / totalSum * 100).toStringAsFixed(1)}%',

            radius: 80,
            titleStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            color: colors[colorIndex % colors.length], // Cycle through colors
          ),
        );
        colorIndex++;
      });
    }
    return sections;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Statistics'),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedType = 'expense';
                          _loadCategoryStatistics();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedType == 'expense'
                            ? const Color.fromARGB(255, 255, 210, 158)
                            : Colors.grey,
                      ),
                      child: const Text('Expense'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedType = 'income';
                          _loadCategoryStatistics();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedType == 'income'
                            ? const Color.fromARGB(255, 191, 234, 156)
                            : Colors.grey,
                      ),
                      child: const Text('Income'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 300,
                  child: PieChart(
                    swapAnimationCurve: Curves.decelerate,
                    swapAnimationDuration: Duration(milliseconds: 700),
                    PieChartData(
                      sections: pieChartSections,
                      sectionsSpace: 5,
                      centerSpaceRadius: 60,
                      pieTouchData: PieTouchData(
                          enabled: true), // optional: enable touch data
                      startDegreeOffset: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ..._getSortedCategoryListTiles()
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _getSortedCategoryListTiles() {
    if (categoryTotals.isEmpty) {
      return [];
    }

    double totalSum = categoryTotals.values.reduce((a, b) => a + b);

    List<MapEntry<String, double>> sortedEntries = categoryTotals.entries
        .toList()
      ..sort((a, b) {
        double percentageA = (a.value / totalSum) * 100;
        double percentageB = (b.value / totalSum) * 100;
        return percentageB.compareTo(percentageA); // Sort in descending order
      });

    return sortedEntries.map((entry) {
      String emoji = categoryEmojis[entry.key] ?? '';
      if (entry.key == 'Repayment') {
        emoji = '💸';
      }
      return ListTile(
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$emoji  ${entry.key}: '),
                Text('\$${entry.value.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 1,
              decoration:
                  const BoxDecoration(color: Color.fromARGB(150, 0, 0, 0)),
            ),
          ],
        ),
      );
    }).toList();
  }
}
