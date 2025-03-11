import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:senior_project/custom_widget/custom_dashboard/custom_dropdown.dart';

class SilverDateList extends StatefulWidget {
  const SilverDateList({super.key});

  @override
  State<StatefulWidget> createState() {
    return _silverDateListState();
  }
}

class _silverDateListState extends State<SilverDateList> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
          padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.height * 0.015,
          ),
          child: CustomDropdown()),
    );
  }
}
