import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:senior_project/style/my_text_style.dart';

class DateTimePickerPage extends StatefulWidget {
  const DateTimePickerPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DateTimePickerPageState createState() => _DateTimePickerPageState();
}

class _DateTimePickerPageState extends State<DateTimePickerPage> {
  late DateTime pickedDate;
  int pickedYear = DateTime.now().year;
  @override
  void initState() {
    super.initState();
    pickedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        child: CupertinoButton(
            pressedOpacity: 0.5,
            child: Text(
              '<  $pickedYear  >',
              style: MyTextStyles.size16BlackText,
            ),
            onPressed: () {
              showCupertinoModalPopup(
                  barrierColor: const Color.fromARGB(119, 217, 235, 255),
                  context: context,
                  builder: (BuildContext context) => SizedBox(
                      height: 300,
                      child: CupertinoPicker(
                        itemExtent: 30,
                        scrollController: FixedExtentScrollController(
                            initialItem: pickedDate.year),
                        onSelectedItemChanged: (int newYear) {
                          setState(() => pickedYear = 1900 + newYear);
                        },
                        children: List<Widget>.generate(
                          DateTime.now().year - 1900 + 1,
                          (int index) {
                            return Center(
                              child: Text('${1900 + index}'),
                            );
                          },
                        ),
                      )));
            }));
  }
}
