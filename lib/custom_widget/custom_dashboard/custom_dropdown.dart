import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:senior_project/custom_widget/custom_dashboard/filter/filter_provider.dart';
import 'package:senior_project/custom_widget/custom_dashboard/group_transaction_details_dialog.dart';
import 'package:senior_project/custom_widget/custom_dashboard/transaction_datails_dialog.dart';
import 'package:senior_project/style/my_text_style.dart';
import 'dart:async';

class LedgerService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _ledgerStreamController =
      StreamController<Map<String, List<QueryDocumentSnapshot>>>();

  Stream<Map<String, List<QueryDocumentSnapshot>>> getLedgerEntries(
      FilterProvider filterProvider) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value({});

    String userId = user.uid;

    return _fetchUserLedger(userId, filterProvider).asyncExpand((userLedger) {
      return _fetchGroupLedgers(userId, filterProvider).map((groupLedgers) {
        // Merge user and group ledgers
        Map<String, List<QueryDocumentSnapshot>> mergedLedgers = {};
        _mergeLedgers(mergedLedgers, userLedger);
        _mergeLedgers(mergedLedgers, groupLedgers);

        // Sort by date
        var sortedKeys = mergedLedgers.keys.toList()
          ..sort((a, b) => b.compareTo(a));
        Map<String, List<QueryDocumentSnapshot>> sortedGroupedLedgers = {};
        for (var key in sortedKeys) {
          sortedGroupedLedgers[key] = mergedLedgers[key]!;
        }
        return sortedGroupedLedgers;
      });
    });
  }

  Stream<Map<String, List<QueryDocumentSnapshot>>> _fetchUserLedger(
      String userId, FilterProvider filterProvider) {
    // Add FilterProvider parameter
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('ledger')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => _groupLedgerByDate(
            snapshot, filterProvider)); // Pass filterProvider
  }

  Stream<Map<String, List<QueryDocumentSnapshot>>> _fetchGroupLedgers(
      String userId, FilterProvider filterProvider) async* {
    // Add FilterProvider parameter
    List<String> groupIds = await _getUserGroupIds(userId);
    Map<String, List<QueryDocumentSnapshot>> allGroupLedgers = {};

    for (String groupId in groupIds) {
      QuerySnapshot snapshot = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('ledger')
          .orderBy('date', descending: true)
          .get();

      Map<String, List<QueryDocumentSnapshot>> groupedLedgers =
          _groupLedgerByDate(snapshot, filterProvider); // Pass filterProvider

      // Merge the groupedLedgers into allGroupLedgers
      groupedLedgers.forEach((date, ledgerList) {
        if (!allGroupLedgers.containsKey(date)) {
          allGroupLedgers[date] = [];
        }
        allGroupLedgers[date]!.addAll(ledgerList);
      });
    }

    // Yield the merged group ledgers as a single stream event
    yield allGroupLedgers;
  }

  Future<List<String>> _getUserGroupIds(String userId) async {
    QuerySnapshot groupSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('groups')
        .get();

    return groupSnapshot.docs.map((doc) => doc.id).toList();
  }

  Map<String, List<QueryDocumentSnapshot>> _groupLedgerByDate(
      QuerySnapshot snapshot, FilterProvider filterProvider) {
    // Add FilterProvider parameter
    Map<String, List<QueryDocumentSnapshot>> groupedLedgers = {};
    for (QueryDocumentSnapshot ledgerDoc in snapshot.docs) {
      Map<String, dynamic> ledgerData =
          ledgerDoc.data() as Map<String, dynamic>;
      if (ledgerData.containsKey('date')) {
        String dateString = ledgerData['date'];
        if (_shouldIncludeData(dateString, filterProvider, ledgerData)) {
          // Filter data
          if (!groupedLedgers.containsKey(dateString)) {
            groupedLedgers[dateString] = [];
          }
          groupedLedgers[dateString]!.add(ledgerDoc);
        }
      } else {
        print('Ledger document missing "date" field: ${ledgerDoc.id}');
      }
    }
    return groupedLedgers;
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
        // If selectedCategory is "Group Transaction", check for 'groupId'
        if (ledgerData['groupId'] == null) {
          return false; // Exclude if 'groupId' is missing
        }
      } else {
        // If selectedCategory is not "Group Transaction", check for category match
        if (ledgerData['category'] != selectedCategory) {
          return false;
        }
      }
    }

    if (currentFilterType == FilterType.all) {
      return true;
    }

    DateTime date = DateFormat('yyyy-MM-dd').parse(dateString);
    print(
        'selected Category: $selectedCategory and Items: ${ledgerData['category']}');

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

  void _mergeLedgers(Map<String, List<QueryDocumentSnapshot>> mergedLedgers,
      Map<String, List<QueryDocumentSnapshot>> newLedgers) {
    newLedgers.forEach((date, ledgerList) {
      if (!mergedLedgers.containsKey(date)) {
        mergedLedgers[date] = [];
      }
      mergedLedgers[date]!.addAll(ledgerList);
    });
  }

  Future<Map<String, String>> getCategoryEmojis(String userId) async {
    try {
      print('try to get emojis');
      QuerySnapshot categorySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('category')
          .get();

      Map<String, String> categoryEmojis = {};

      for (QueryDocumentSnapshot doc in categorySnapshot.docs) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('emoji')) {
          categoryEmojis[doc.id] = data['emoji'] as String;
        }
      }

      return categoryEmojis;
    } catch (e) {
      print('Error fetching category emojis: $e');
      return {};
    }
  }
}

class Category {
  final String categoryName;
  final String emoji;

  Category({required this.categoryName, required this.emoji});

  factory Category.fromMap(Map<String, dynamic> data) {
    return Category(
      categoryName: data['categoryName'] ?? '',
      emoji: data['emoji'] ?? '',
    );
  }
}

class CustomDropdown extends StatefulWidget {
  const CustomDropdown({super.key});

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  Map<String, String> categoryEmojis = {};

  @override
  void initState() {
    super.initState();
    _fetchCategoryEmojis();
  }

  Future<void> _fetchCategoryEmojis() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    Map<String, String> emojis =
        await LedgerService().getCategoryEmojis(user.uid);
    setState(() {
      categoryEmojis = emojis;
    });
  }

  @override
  Widget build(BuildContext context) {
    String getAmountText(Map<String, dynamic> ledgerDocument, String? userId) {
      if (ledgerDocument['payer'] != null && userId != null) {
        List<dynamic> payers = ledgerDocument['payer'];
        for (var payer in payers) {
          if (payer['payer'] == userId) {
            return '${ledgerDocument['type'] == 'expense' ? '-฿' : '฿'}${payer['amountPaid'].toStringAsFixed(2)}';
          }
        }
        return '${ledgerDocument['type'] == 'expense' ? '-฿' : '฿'}0.00';
      } else {
        return '${ledgerDocument['type'] == 'expense' ? '-฿' : '฿'}${ledgerDocument['amount'].toStringAsFixed(2)}';
      }
    }

    final filterProvider = Provider.of<FilterProvider>(context);

    return StreamBuilder<Map<String, List<QueryDocumentSnapshot>>>(
      stream: LedgerService().getLedgerEntries(filterProvider),
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

        final groupedLedgerEntries = snapshot.data!;
        User? currentUser = FirebaseAuth.instance.currentUser;

        return Column(
          children: [
            Column(
              children: groupedLedgerEntries.entries.map((dateGroup) {
                final date = dateGroup.key;
                final ledgerSnapshots = dateGroup.value;

                return ExpansionTile(
                  trailing: const SizedBox.shrink(),
                  title: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 239, 239, 239),
                      border: Border.all(
                          color: const Color.fromARGB(255, 192, 192, 192)),
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
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const Icon(Icons.arrow_drop_down,
                            color: Color.fromARGB(255, 166, 20, 20)),
                      ],
                    ),
                  ),
                  children: ledgerSnapshots.map((ledgerSnapshot) {
                    final ledgerDocument =
                        ledgerSnapshot.data() as Map<String, dynamic>;

                    return ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                ledgerDocument['category'] == 'Repayment'
                                    ? '💸'
                                    : categoryEmojis[
                                            ledgerDocument['category']] ??
                                        '❔',
                                style: const TextStyle(fontSize: 40),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 1,
                                height: 50,
                                color: const Color.fromARGB(255, 174, 174, 174),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ledgerDocument['category'],
                                      style: MyTextStyles.mediumBlackText),
                                  const SizedBox(height: 5),
                                  Text(
                                    ledgerDocument['member'] != null &&
                                            ledgerDocument['member'] > 0
                                        ? '👤 ${ledgerDocument['member']}'
                                        : 'Me',
                                    style: MyTextStyles.size14lightText,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                getAmountText(ledgerDocument, currentUser?.uid),
                                style: ledgerDocument['type'] == 'expense'
                                    ? MyTextStyles.size20RedText
                                    : MyTextStyles.size20GreenText,
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        bool isGroup = ledgerDocument['groupId'] != null;
                        print('isgroup: $isGroup');
                        if (ledgerDocument['member'] != null &&
                            ledgerDocument['member'] > 1) {
                          // Show GroupTransactionDetailsDialog
                          showDialog(
                            context: context,
                            builder: (context) => GroupTransactionDetailsDialog(
                              emoji:
                                  categoryEmojis[ledgerDocument['category']] ??
                                      '',
                              amount: getAmountText(
                                  ledgerDocument, currentUser?.uid),
                              context: context,
                              ledgerDocument:
                                  ledgerDocument, // Pass the entire document
                              isGroup: isGroup, //pass the boolean
                              deleteable: true,
                            ),
                          );
                        } else {
                          // Show TransactionDetailsDialog
                          showDialog(
                            context: context,
                            builder: (context) => TransactionDetailsDialog(
                              emoji:
                                  categoryEmojis[ledgerDocument['category']] ??
                                      '',
                              itemName: ledgerDocument['category'],
                              ledgerId: ledgerSnapshot.id,
                              amount: getAmountText(
                                  ledgerDocument, currentUser?.uid),
                              date: ledgerDocument['date'],
                              member: 'Me',
                              comment: ledgerDocument['comment'] ?? '',
                              context: context,
                            ),
                          );
                        }
                      },
                    );
                  }).toList(),
                );
              }).toList(),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
            ),
          ],
        );
      },
    );
  }
}
