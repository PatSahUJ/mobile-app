import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:senior_project/style/my_text_style.dart';

class LedgerService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<Map<String, List<Map<String, dynamic>>>> getLedgerEntries() {
    User? user = _auth.currentUser;
    if (user == null) return Stream.value({});

    String userId = user.uid;

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('ledger')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      Map<String, List<Map<String, dynamic>>> groupedLedgers = {};
      for (QueryDocumentSnapshot ledgerDoc in snapshot.docs) {
        Map<String, dynamic> ledgerData =
            ledgerDoc.data() as Map<String, dynamic>;

        if (ledgerData.containsKey('date')) {
          String dateString = ledgerData['date'];

          if (!groupedLedgers.containsKey(dateString)) {
            groupedLedgers[dateString] = [];
          }
          groupedLedgers[dateString]!.add(ledgerData);
        } else {
          print('Ledger document missing "date" field: ${ledgerDoc.id}');
        }
      }
      var sortedKeys = groupedLedgers.keys.toList()
        ..sort((a, b) => b.compareTo(a)); //Sort by latest date first.
      Map<String, List<Map<String, dynamic>>> sortedGroupedLedgers = {};
      for (var key in sortedKeys) {
        sortedGroupedLedgers[key] = groupedLedgers[key]!;
      }

      return sortedGroupedLedgers;
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
    return StreamBuilder<Map<String, List<Map<String, dynamic>>>>(
      stream: LedgerService().getLedgerEntries(),
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

        return Column(
          children: groupedLedgerEntries.entries.map((dateGroup) {
            final date = dateGroup.key;
            final ledgerDocuments = dateGroup.value;

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
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(date,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: Color.fromARGB(255, 166, 20, 20),
                    ),
                  ],
                ),
              ),
              children: ledgerDocuments.map((ledgerDocument) {
                return ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(categoryEmojis[ledgerDocument['category']] ?? '',
                              style: const TextStyle(fontSize: 40)),
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
                              Text(
                                ledgerDocument['category'],
                                style: MyTextStyles.mediumBlackText,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                  ledgerDocument['member'] == null ||
                                          ledgerDocument['member']
                                              .toString()
                                              .isEmpty
                                      ? 'Me'
                                      : ledgerDocument['member'],
                                  style: MyTextStyles.size14lightText),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              '${ledgerDocument['type'] == 'expense' ? '-฿' : '฿'}${ledgerDocument['amount'].toStringAsFixed(2)}',
                              style: ledgerDocument['type'] == 'expense'
                                  ? MyTextStyles.size20RedText
                                  : MyTextStyles.size20BlackText),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }).toList(),
        );
      },
    );
  }
}
