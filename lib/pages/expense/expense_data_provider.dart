import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ExpenseDataProvider with ChangeNotifier {
  double _amount = 0.0;
  String _category = '';
  String _comment = '';
  DateTime? _date;
  String _type = 'expense';
  List<String> _members = [];

  final List<TextEditingController> _memberControllers = [
    TextEditingController()
  ];

  List<Map<String, dynamic>> _payersData = [];
  List<Map<String, dynamic>> _billsAmounts = [];

  List<TextEditingController> get memberControllers => _memberControllers;

  List<Map<String, dynamic>> get payersData => _payersData;
  List<Map<String, dynamic>> get billsAmounts => _billsAmounts;

  double get amount {
    print('Getting amount: $_amount');
    return _amount;
  }

  String get category {
    print('Getting category: $_category');
    return _category;
  }

  String get comment {
    print('Getting comment: $_comment');
    return _comment;
  }

  DateTime? get date {
    print('Getting date: $_date');
    return _date;
  }

  String get type {
    print('Getting type: $_type');
    return _type;
  }

  List<String> get members {
    print("Provider instance hashCode: ${hashCode}");

    print('Getting members: $_members');
    return List.unmodifiable(_members);
  }

  void updatePayersData(List<Map<String, dynamic>> payersData) {
    _payersData = payersData;
    notifyListeners();
    print('payer amountssssss: $payersData');
  }

  void updateBillsAmounts(List<Map<String, dynamic>> billsAmounts) {
    print('try to update owee');
    _billsAmounts = billsAmounts;
    notifyListeners();
    print('owees anounttttttttt:  $billsAmounts');
  }

  void updateAmount(double amount) {
    _amount = amount;
    print('Amount updated to: $_amount');
    notifyListeners();
  }

  void updateCategory(String category) {
    _category = category;
    print('Category updated to: $_category');
    notifyListeners();
  }

  void updateComment(String comment) {
    _comment = comment;
    _commentController.text = comment;
    print('Comment updated to: $_comment');
    notifyListeners();
  }

  void updateDate(DateTime date) {
    _date = date;
    print('Date updated to: $_date');
    notifyListeners();
  }

  void updateType(String type) {
    _type = type;
    print('Type updated to: $_type');
    notifyListeners();
  }

  void updateMembers(List<String> members) {
    _members = members;
    notifyListeners();
    print("Provider instance hashCode: ${hashCode}");

    print('Members updated to: $_members');
  }

  void addMemberController() {
    _memberControllers.add(TextEditingController());
    _members.add(''); // Add an empty string to keep both lists in sync
    notifyListeners();
    print('Added member controller. Total: $_memberControllers');
  }

  void clearMemberControllers() {
    _memberControllers.clear();
    _memberControllers.add(TextEditingController()); // Keep at least one
    notifyListeners();
  }

  void clearMemberControllersText() {
    for (var controller in _memberControllers) {
      controller.clear();
    }
    notifyListeners();
  }

  Future<void> saveExpense(bool mounted) async {
    // Add mounted parameter
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not logged in.');
      return;
    }

    if (_category == '' || _date == null || _amount == 0) {
      print('Please select category, date, and amount...');
      return;
    }

    try {
      String? formattedDate;
      if (_date != null) {
        formattedDate = DateFormat('yyyy-MM-dd').format(_date!);
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('ledger')
          .add({
        'amount': _amount,
        'category': _category,
        'comment': _comment,
        'date': formattedDate,
        'type': _type,
        'member': _members.length,
      });

      if (mounted) {
        print('Expense saved to Firestore');
      } else {
        print('Expense saved to Firestore, but widget unmounted');
      }
    } catch (e) {
      if (mounted) {
        print('Error saving expense: $e');
      } else {
        print('Error saving expense: $e, but widget unmounted');
      }
    }
  }

  final TextEditingController _commentController = TextEditingController();

  TextEditingController get commentController => _commentController;

  void clearData() {
    _amount = 0.0;
    _category = '';
    _comment = '';
    _date = null;
    _type = 'expense';
    _members.clear();
    _payersData.clear();
    _billsAmounts.clear();
    clearMemberControllers();
    _commentController.clear();
    notifyListeners();
  }
}
