import 'package:flutter/material.dart';

class DateListPanel extends StatefulWidget {
  const DateListPanel({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DateListPanelState();
  }
}

class _DateListPanelState extends State<DateListPanel> {
  final List<Item> _list = List<Item>.generate(10, (int index) {
    return Item(headerText: 'Date $index', expandedText: 'Item number $index');
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        child: ExpansionPanelList(
      expandedHeaderPadding: const EdgeInsets.all(2),
      elevation: 4,
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _list[index].isExpanded = !_list[index].isExpanded;
        });
      },
      children: _list.map<ExpansionPanel>((Item item) {
        return ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return Container(
                decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(50)),
                child: ListTile(
                  tileColor: const Color.fromARGB(30, 0, 0, 0),
                  title: Text(item.headerText),
                ),
              );
            },
            body: ListTile(
              title: Text(item.expandedText),
            ),
            isExpanded: item.isExpanded); // Set isExpanded property here
      }).toList(),
    ));
  }
}

class Item {
  Item(
      {required this.headerText,
      required this.expandedText,
      this.isExpanded = false});
  String headerText, expandedText;
  bool isExpanded;
}
