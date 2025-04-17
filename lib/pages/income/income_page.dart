import 'package:flutter/material.dart';
import 'package:senior_project/custom_widget/silver_app_bar_default.dart';
import 'package:senior_project/pages/income/income_bar.dart';
import 'package:senior_project/pages/income/silver_income_detail.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _incomePageState();
  }
}

class _incomePageState extends State<IncomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        body: CustomScrollView(slivers: [
          SilverAppBarDefault(),
          IncomeBar(),
          SilverIncomeDetail()
        ]));
  }
}
