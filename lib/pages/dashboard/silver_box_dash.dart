// import 'package:flutter/material.dart';
// import 'package:senior_project/custom_widget/custom_dashboard/date_time_picker.dart';
// import 'package:senior_project/custom_widget/custom_dashboard/tot_in_ex.dart';

// class SilverBoxDash extends StatelessWidget {
//   const SilverBoxDash({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//         padding: const EdgeInsets.all(15),
//         child: Container(
//           height: 200,
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(30),
//               border:
//                   Border.all(color: Theme.of(context).primaryColor, width: 5),
//               boxShadow: const [
//                 BoxShadow(
//                   color: Color.fromARGB(208, 211, 211, 211),
//                   blurRadius: 8,
//                   spreadRadius: 6,
//                   offset: Offset(0, 0),
//                 )
//               ]),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(27),
//             child: Container(
//               color: Color.fromARGB(255, 255, 255, 255),
//               child: Padding(
//                 padding: EdgeInsetsDirectional.all(15),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [DateTimePickerPage(), TotInEx()],
//                 ),
//               ),
//             ),
//           ),
//         ));
//   }
//}
import 'package:flutter/material.dart';
import 'package:senior_project/custom_widget/custom_dashboard/date_time_picker.dart';
import 'package:senior_project/custom_widget/custom_dashboard/filter/custom_date_picker.dart';
import 'package:senior_project/custom_widget/custom_dashboard/tot_in_ex.dart';

class SilverBoxDash extends StatelessWidget {
  const SilverBoxDash({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        expandedHeight: 210,
        flexibleSpace: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              //top: 00,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(208, 211, 211, 211),
                          blurRadius: 8,
                          spreadRadius: 6,
                          offset: Offset(0, 0),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(27),
                      child: Container(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        child: const Padding(
                          padding: EdgeInsetsDirectional.all(15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomDatePicker(),
                              Expanded(child: TotInEx()),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ));
  }
}
