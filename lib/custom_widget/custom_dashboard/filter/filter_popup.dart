import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senior_project/custom_widget/custom_dashboard/filter/filter_provider.dart';
import 'package:senior_project/style/my_text_style.dart';

class FilterPopup {
  static Future<void> showWeeklyPopup(BuildContext context) async {
    DateTime? startDate;
    DateTime? endDate;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Weekly Range'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  startDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                },
                child: const Text('Select Start Date'),
              ),
              ElevatedButton(
                onPressed: () async {
                  endDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                },
                child: const Text('Select End Date'),
              ),
              // Display selected dates
              // if (Provider.of<FilterProvider>(context, listen: false)
              //             .weeklyStartDate !=
              //         null &&
              //     Provider.of<FilterProvider>(context, listen: false)
              //             .weeklyEndDate !=
              //         null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                // child: Text(
                //   'Selected: ${Provider.of<FilterProvider>(context, listen: false).weeklyStartDate!.toIso8601String().split('T')[0]} - ${Provider.of<FilterProvider>(context, listen: false).weeklyEndDate!.toIso8601String().split('T')[0]}',
                //   style: MyTextStyles.size16BlackText,
                // ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                // if (startDate != null && endDate != null) {
                //   Provider.of<FilterProvider>(context, listen: false)
                //       .setWeeklyRange(startDate!, endDate!);
                //   Navigator.of(context).pop();
                // }
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> showMonthlyPopup(BuildContext context) async {
    int? selectedYear;
    int? selectedMonth;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Month and Year'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  selectedYear = await showDialog<int>(
                    context: context,
                    builder: (BuildContext context) {
                      return SimpleDialog(
                        title: const Text('Select Year'),
                        children: List.generate(
                          DateTime.now().year - 2000 + 1,
                          (index) => SimpleDialogOption(
                            onPressed: () {
                              Navigator.pop(context, 2000 + index);
                            },
                            child: Text((2000 + index).toString()),
                          ),
                        ),
                      );
                    },
                  );
                },
                child: const Text('Select Year'),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.015),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(50, 50), // Width & Height
                ),
                onPressed: () async {
                  selectedMonth = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SimpleDialog(
                        title: const Text(
                          'Select Month',
                          style: MyTextStyles.size16lightText,
                        ),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height *
                                0.045, // Set fixed height
                            child: SingleChildScrollView(
                              child: Column(
                                children: List.generate(
                                  12,
                                  (index) => SimpleDialogOption(
                                    onPressed: () {
                                      Navigator.pop(context, index + 1);
                                    },
                                    child: Text(
                                      (12 - index).toString(),
                                      style: MyTextStyles.size18BlackText,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Select Month'),
              ),
              // Display selected month and year
              if (Provider.of<FilterProvider>(context, listen: false)
                          .selectedYear !=
                      null &&
                  Provider.of<FilterProvider>(context, listen: false)
                          .selectedMonth !=
                      null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Selected:  ${Provider.of<FilterProvider>(context, listen: false).selectedMonth}',
                    style: MyTextStyles.size16BlackText,
                  ),
                ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                if (selectedYear != null && selectedMonth != null) {
                  Provider.of<FilterProvider>(context, listen: false)
                      .setMonthYear(selectedYear!, selectedMonth!);
                  Navigator.of(context).pop();
                }
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> showYearlyPopup(BuildContext context) async {
    int? selectedYear;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Year'),
          contentPadding: const EdgeInsets.only(top: 20),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            ElevatedButton(
              onPressed: () async {
                selectedYear = await showDialog<int>(
                  context: context,
                  builder: (BuildContext context) {
                    return SimpleDialog(
                      title: const Text('Select Year'),
                      children: List.generate(
                        DateTime.now().year - 2000 + 1,
                        (index) => SimpleDialogOption(
                          onPressed: () {
                            Navigator.pop(context, 2000 + index);
                          },
                          child: Text((2000 + index).toString()),
                        ),
                      ),
                    );
                  },
                );
              },
              child: const Text('Select Year'),
            ),
            if (Provider.of<FilterProvider>(context, listen: false)
                    .selectedYear !=
                null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Selected: ${Provider.of<FilterProvider>(context, listen: false).selectedYear}',
                  style: MyTextStyles.size16BlackText,
                ),
              ),
          ]),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                if (selectedYear != null) {
                  Provider.of<FilterProvider>(context, listen: false)
                      .setYear(selectedYear!);
                  Navigator.of(context).pop();
                }
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
