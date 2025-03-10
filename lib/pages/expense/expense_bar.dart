import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:senior_project/style/my_text_style.dart';
import 'package:senior_project/pages/expense/expense_data_provider.dart'; // Import your provider

class ExpenseBar extends StatelessWidget {
  const ExpenseBar({super.key});
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      toolbarHeight: MediaQuery.of(context).size.height * 0.01,
      flexibleSpace: Stack(
        children: [
          TextButton(
            onPressed: () {
              // Clear the data in the ExpenseDataProvider
              Provider.of<ExpenseDataProvider>(context, listen: false)
                  .clearData();

              Navigator.pushNamed(context, '/dashboard');
            },
            child: Container(
                padding: const EdgeInsets.only(left: 12),
                child: Icon(
                  Icons.close,
                  color: Theme.of(context).primaryColor,
                  size: 30,
                )),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                    color: const Color(0xffCD5334),
                    borderRadius: BorderRadius.circular(20)),
                child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      '💸Expense ',
                      style: MyTextStyles.size18WhiteText,
                    )),
              ),
              Container(
                child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/income');
                    },
                    child: const Text(
                      '💰',
                      style: TextStyle(fontSize: 30),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
