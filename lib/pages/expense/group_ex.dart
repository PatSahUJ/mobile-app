import 'package:flutter/material.dart';
import 'package:senior_project/pages/expense/group_expense_detail.dart';
import 'package:senior_project/style/my_text_style.dart';

class GroupEx extends StatefulWidget {
  const GroupEx({super.key});
  @override
  State<StatefulWidget> createState() {
    return _groupExState();
  }
}

class _groupExState extends State<GroupEx> {
  bool _isExpanded = false;
  final List<TextEditingController> _memberControllers = [
    TextEditingController()
  ];

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: Column(children: [
            const SizedBox(
              height: 10,
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 239, 239, 239),
                border:
                    Border.all(color: const Color.fromARGB(255, 192, 192, 192)),
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(20, 0, 0, 0),
                    blurRadius: 4,
                    spreadRadius: 2,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Text(' Group Expense',
                      style: MyTextStyles.size18BlackText),
                  Switch(
                    inactiveTrackColor:
                        const Color.fromARGB(146, 133, 133, 133),
                    activeColor: const Color(0xffCD5334),
                    value: _isExpanded,
                    onChanged: (value) {
                      setState(() {
                        _isExpanded = value; // Toggle the expanded state
                      });
                    },
                  ),
                ],
              ),
            ),
            if (_isExpanded)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    ..._memberControllers.map((controller) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: 10.0), // Space between text fields
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller, // Bind the controller
                                keyboardType: TextInputType.text,
                                style: MyTextStyles.size16BlackText,
                                decoration: const InputDecoration(
                                  hintText: 'Enter Name',
                                  hintStyle: MyTextStyles.size16GreyText,
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          Colors.grey, // Color of the underline
                                    ),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors
                                          .grey, // Color of the underline when not focused
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors
                                          .grey, // Color of the underline when focused
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _memberControllers.add(
                              TextEditingController()); // Add a new text field controller
                        });
                      },
                      child: const Row(
                        children: [
                          Text(
                            '+ Add member',
                            style: MyTextStyles
                                .size16RedText, // Style for the add member text
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(
              height: 15,
            ),
            if (!_isExpanded)
              Container(
                width: 200,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(15)),
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Save',
                    style: MyTextStyles.size20BlackText,
                  ),
                ),
              ),
            if (_isExpanded)
              Container(
                width: 200,
                decoration: BoxDecoration(
                    color: const Color(0xffCD5334),
                    borderRadius: BorderRadius.circular(15)),
                child: TextButton(
                  onPressed: () {
                    // Prepare to navigate and pass the member names
                    List<String> memberNames = _memberControllers
                        .map((controller) => controller.text)
                        .toList();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              GroupExpenseDetail(memberNames: memberNames)),
                    );
                  },
                  child: const Text(
                    'Next',
                    style: MyTextStyles.mediumWhiteText,
                  ),
                ),
              )
          ])),
    );
  }
}
