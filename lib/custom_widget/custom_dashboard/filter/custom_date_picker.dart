// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:senior_project/custom_widget/custom_dashboard/filter/filter_provider.dart';
// import 'package:senior_project/style/my_text_style.dart';
// import 'package:intl/intl.dart';

// class CustomDatePicker extends StatelessWidget {
//   const CustomDatePicker({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final filterProvider = Provider.of<FilterProvider>(context);
//     final selectedYear = filterProvider.selectedYear!;
//     final selectedMonth = filterProvider.selectedMonth!;
//     final currentFilterType = filterProvider.selectedFilter;
//     final weeklyStartDate = filterProvider.weeklyStartDate;
//     final weeklyEndDate = filterProvider.weeklyEndDate;

//     void _previous() {
//       if (currentFilterType == FilterType.monthly) {
//         if (selectedMonth == 1) {
//           filterProvider.setMonthYear(selectedYear - 1, 12);
//         } else {
//           filterProvider.setMonthYear(selectedYear, selectedMonth - 1);
//         }
//       } else if (currentFilterType == FilterType.yearly) {
//         filterProvider.setYear(selectedYear - 1);
//       } else if (currentFilterType == FilterType.weekly) {
//         filterProvider.previousWeek();
//       }
//     }

//     void _next() {
//       if (currentFilterType == FilterType.monthly) {
//         if (selectedMonth == 12) {
//           filterProvider.setMonthYear(selectedYear + 1, 1);
//         } else {
//           filterProvider.setMonthYear(selectedYear, selectedMonth + 1);
//         }
//       } else if (currentFilterType == FilterType.yearly) {
//         filterProvider.setYear(selectedYear + 1);
//       } else if (currentFilterType == FilterType.weekly) {
//         filterProvider.nextWeek();
//       }
//     }

//     String _formatWeeklyRange() {
//       if (weeklyStartDate != null && weeklyEndDate != null) {
//         String startDate = DateFormat('dd/MM/yy').format(weeklyStartDate);
//         String endDate = DateFormat('dd/MM/yy').format(weeklyEndDate);
//         return '$startDate - $endDate';
//       }
//       return '';
//     }

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         IconButton(
//           icon: const Icon(Icons.chevron_left),
//           onPressed: _previous,
//         ),
//         Text(
//           currentFilterType == FilterType.monthly
//               ? '$selectedMonth/$selectedYear'
//               : currentFilterType == FilterType.yearly
//                   ? '$selectedYear'
//                   : currentFilterType == FilterType.weekly
//                       ? _formatWeeklyRange()
//                       : currentFilterType == FilterType.all
//                           ? 'All' // Add this line
//                           : '',
//           style: MyTextStyles.size16BlackText,
//         ),
//         IconButton(
//           icon: const Icon(Icons.chevron_right),
//           onPressed: _next,
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senior_project/custom_widget/custom_dashboard/filter/filter_provider.dart';
import 'package:senior_project/custom_widget/custom_dashboard/filter/statistic_page.dart';
import 'package:senior_project/style/my_text_style.dart';
import 'package:intl/intl.dart';

class CustomDatePicker extends StatelessWidget {
  const CustomDatePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final filterProvider = Provider.of<FilterProvider>(context);
    final selectedYear = filterProvider.selectedYear!;
    final selectedMonth = filterProvider.selectedMonth!;
    final currentFilterType = filterProvider.selectedFilter;
    final weeklyStartDate = filterProvider.weeklyStartDate;
    final weeklyEndDate = filterProvider.weeklyEndDate;

    void _previous() {
      if (currentFilterType == FilterType.monthly) {
        if (selectedMonth == 1) {
          filterProvider.setMonthYear(selectedYear - 1, 12);
        } else {
          filterProvider.setMonthYear(selectedYear, selectedMonth - 1);
        }
      } else if (currentFilterType == FilterType.yearly) {
        filterProvider.setYear(selectedYear - 1);
      } else if (currentFilterType == FilterType.weekly) {
        filterProvider.previousWeek();
      }
    }

    void _next() {
      if (currentFilterType == FilterType.monthly) {
        if (selectedMonth == 12) {
          filterProvider.setMonthYear(selectedYear + 1, 1);
        } else {
          filterProvider.setMonthYear(selectedYear, selectedMonth + 1);
        }
      } else if (currentFilterType == FilterType.yearly) {
        filterProvider.setYear(selectedYear + 1);
      } else if (currentFilterType == FilterType.weekly) {
        filterProvider.nextWeek();
      }
    }

    String _formatWeeklyRange() {
      if (weeklyStartDate != null && weeklyEndDate != null) {
        String startDate = DateFormat('dd/MM/yy').format(weeklyStartDate);
        String endDate = DateFormat('dd/MM/yy').format(weeklyEndDate);
        return '$startDate - $endDate';
      }
      return '';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _previous,
            ),
            Text(
              currentFilterType == FilterType.monthly
                  ? '$selectedMonth/$selectedYear'
                  : currentFilterType == FilterType.yearly
                      ? '$selectedYear'
                      : currentFilterType == FilterType.weekly
                          ? _formatWeeklyRange()
                          : currentFilterType == FilterType.all
                              ? 'All'
                              : '',
              style: MyTextStyles.size16BlackText,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _next,
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StatisticsPage()),
                  );
                },
                icon: Icon(Icons.stacked_bar_chart))
          ],
        )
      ],
    );
  }
}
