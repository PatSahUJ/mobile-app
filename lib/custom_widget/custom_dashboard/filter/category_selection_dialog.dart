import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senior_project/custom_widget/custom_dashboard/filter/filter_provider.dart';

class CategorySelectionDialog extends StatefulWidget {
  const CategorySelectionDialog({super.key});

  @override
  _CategorySelectionDialogState createState() =>
      _CategorySelectionDialogState();
}

class _CategorySelectionDialogState extends State<CategorySelectionDialog> {
  String? _selectedCategory;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    List<String> categories = [];

    // Fetch categories from the 'category' collection
    final categorySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('category')
        .get();

    categories.addAll(categorySnapshot.docs.map((doc) => doc.id).toList());

    // Check if the user has a 'groups' collection
    final groupsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('groups')
        .get();

    // If the user has groups, add "Group Transaction" to the list
    if (groupsSnapshot.docs.isNotEmpty) {
      categories.add('Group Transaction');
    }

    setState(() {
      _categories = categories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Category'),
      content: SingleChildScrollView(
        child: Column(
          children: _categories.map((category) {
            return RadioListTile<String>(
              title: Text(category),
              value: category,
              groupValue: _selectedCategory,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Clear'),
          onPressed: () {
            Provider.of<FilterProvider>(context, listen: false)
                .clearSelectedCategory();
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Provider.of<FilterProvider>(context, listen: false)
                .setSelectedCategory(_selectedCategory);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
