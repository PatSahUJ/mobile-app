import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senior_project/custom_widget/silver_app_bar_default.dart';
import 'package:senior_project/pages/expense/expense_bar.dart';
import 'package:senior_project/pages/expense/group_ex.dart';
import 'package:senior_project/pages/expense/silver_expense_detail.dart';
import 'package:senior_project/pages/setting/friends_provider.dart'; // Import FriendsProvider

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _expensePageState();
  }
}

class _expensePageState extends State<ExpensePage> {
  @override
  void initState() {
    super.initState();
    Provider.of<FriendsProvider>(context, listen: false)
        .fetchFriends(); // Call fetchFriends() here
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: CustomScrollView(slivers: [
        SilverAppBarDefault(),
        ExpenseBar(),
        SilverExpenseDetail(),
        GroupEx()
      ]),
    );
  }
}
