import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:senior_project/style/my_text_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoryEx extends StatefulWidget {
  final double? amount;
  const CategoryEx({super.key, required this.amount});

  @override
  State<StatefulWidget> createState() {
    return _CategoryExState();
  }
}

class _CategoryExState extends State<CategoryEx> {
  Map<String, String> categoryEmojis = {};
  bool _isExpanded = false;
  DateTime? _selectedDate; // Declare _selectedDate as a state variable
  final TextEditingController _commentController = TextEditingController();
  String? _selectedCategoryId; // Store the selected category ID
  final Map<String, Color> _categoryColors =
      {}; // Store colors for each category

  @override
  void initState() {
    super.initState();
    _fetchCategoryEmojis();
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
      for (var doc in categorySnapshot.docs) {
        emojis[doc.id] = doc['emoji'];
        _categoryColors[doc.id] = Colors.transparent;
      }

      setState(() {
        categoryEmojis = emojis;
      });
    } catch (e) {
      print('Error fetching category emojis: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> categoryIds = categoryEmojis.keys.toList();
    String displayDate = _selectedDate == null
        ? 'Select Date'
        : DateFormat('yyyy-MM-dd').format(_selectedDate!);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Column(
        children: [
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 239, 239, 239),
                border:
                    Border.all(color: const Color.fromARGB(255, 192, 192, 192)),
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
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    _isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: const Color(0xffCD5334),
                  ),
                  const Text('Category', style: MyTextStyles.size18BlackText),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                padding: const EdgeInsets.only(top: 15),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categoryIds.length + 1,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4),
                itemBuilder: (context, index) {
                  if (index == categoryIds.length) {
                    return Container(
                      margin: const EdgeInsets.only(
                          bottom: 25, left: 12, right: 12),
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 219, 178, 178),
                          borderRadius: BorderRadius.circular(15)),
                      child: TextButton(
                        onPressed: () {
                          _showAddCategoryDialog(context);
                        },
                        child: const Text('+',
                            style:
                                TextStyle(fontSize: 30, color: Colors.black)),
                      ),
                    );
                  }
                  String categoryId = categoryIds[index];
                  String emoji = categoryEmojis[categoryId] ?? '';

                  return GestureDetector(
                    // Wrap with GestureDetector
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = categoryId;
                        _categoryColors.forEach((key, value) {
                          _categoryColors[key] = Colors.transparent;
                        });
                        _categoryColors[categoryId] =
                            Theme.of(context).primaryColor;
                      });
                    },
                    child: Container(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 3),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                            // Use decoration here
                            color: _categoryColors[categoryId],
                            borderRadius: BorderRadius.circular(
                                10) // Set color inside decoration
                            ),
                        child: Column(
                          children: [
                            Text(emoji, style: const TextStyle(fontSize: 30)),
                            Text(categoryId,
                                style: MyTextStyles.size14lightText),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 5),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 239, 239, 239),
              border:
                  Border.all(color: const Color.fromARGB(255, 192, 192, 192)),
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
            child: const Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text('Information', style: MyTextStyles.size18BlackText),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Text('📆', style: TextStyle(fontSize: 30)),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != _selectedDate) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        displayDate,
                        style: MyTextStyles.size16GreyText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Text('📝', style: TextStyle(fontSize: 30)),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _commentController,
                    keyboardType: TextInputType.multiline,
                    style: MyTextStyles.size16GreyText,
                    decoration: const InputDecoration(
                      hintText: 'Comment',
                      hintStyle: MyTextStyles.size16GreyText,
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    String categoryId = '';
    String emoji = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: const InputDecoration(labelText: 'Category ID'),
                onChanged: (value) {
                  categoryId = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Emoji'),
                onChanged: (value) {
                  emoji = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () async {
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('category')
                      .doc(categoryId)
                      .set({'emoji': emoji});

                  _fetchCategoryEmojis(); // Refresh the category list
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
