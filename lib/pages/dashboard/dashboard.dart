import 'package:flutter/material.dart';
import 'package:senior_project/custom_widget/silver_app_bar_dashboard.dart';
import 'package:senior_project/pages/dashboard/silver_box_dash.dart';
import 'package:senior_project/pages/dashboard/silver_date_list.dart';
//import 'package:senior_project/style/my_text_style.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: const CustomScrollView(
        slivers: [
          SilverAppBarDashboard(),
          SilverBoxDash(),
          SilverDateList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/income');
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          tooltip: 'Increment',
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.add)),
    );
  }
}
