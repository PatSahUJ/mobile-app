import 'package:flutter/material.dart';
import 'package:senior_project/custom_widget/silver_app_bar_default.dart';
import 'package:senior_project/pages/expense/expense_bar.dart';
import 'package:senior_project/style/my_text_style.dart';

class GroupExpenseDetail extends StatefulWidget {
  final List<String> memberNames; // This will hold the member names
  const GroupExpenseDetail({super.key, required this.memberNames});
  @override
  State<StatefulWidget> createState() {
    return _groupExpenseDetailState();
  }
} // Constructor

class _groupExpenseDetailState extends State<GroupExpenseDetail> {
  late Color whoPaidButtonColor;
  late Color forWhoButtonColor;
  String state = 'who';
  late List<bool> _whoPaidCheckedValues;
  late List<bool> _forWhoCheckedValues;
  late List<double> _whoPaidPriceList =
      List<double>.filled(widget.memberNames.length, 0);
  late List<double> _forWhoPriceList;
  bool editPrice = false;
  int personButton = 0;
  @override
  void initState() {
    super.initState();
    whoPaidButtonColor = const Color.fromARGB(255, 225, 156, 139);
    forWhoButtonColor = const Color.fromARGB(255, 213, 213, 213);
    _whoPaidCheckedValues = List<bool>.filled(widget.memberNames.length, false);
    _forWhoCheckedValues = List<bool>.filled(widget.memberNames.length, false);
    _whoPaidPriceList = List<double>.filled(widget.memberNames.length, 0);
    _forWhoPriceList = List<double>.filled(widget.memberNames.length, 0);
  }

  List<bool> getValueCheckBox() {
    return state == 'who' ? _whoPaidCheckedValues : _forWhoCheckedValues;
  }

  List<double> getPriceList() {
    return state == 'who' ? _whoPaidPriceList : _forWhoPriceList;
  }

  void change_button_color() {
    setState(() {});
    if (state == 'who') {
      forWhoButtonColor = const Color.fromARGB(255, 213, 213, 213);
      whoPaidButtonColor = const Color.fromARGB(255, 225, 156, 139);
    } else {
      whoPaidButtonColor = const Color.fromARGB(255, 213, 213, 213);
      forWhoButtonColor = const Color.fromARGB(255, 225, 156, 139);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SilverAppBarDefault(),
              const ExpenseBar(),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.only(top: 10),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: () {
                            state = 'who';
                            change_button_color();
                          },
                          child: Container(
                            width: 165,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            decoration: BoxDecoration(
                                color: whoPaidButtonColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromARGB(80, 0, 0, 0),
                                    blurRadius: 4,
                                    spreadRadius: 2,
                                    offset: Offset(0, 4),
                                  )
                                ]),
                            child: const Text(
                              "Who Paid?",
                              style: MyTextStyles.size18BlackText,
                            ),
                          )),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        width: 165,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                            color: forWhoButtonColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromARGB(80, 0, 0, 0),
                                blurRadius: 4,
                                spreadRadius: 2,
                                offset: Offset(0, 4),
                              )
                            ]),
                        child: const Text(
                          "For Who?",
                          style: MyTextStyles.size18BlackText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                  child: Column(
                children: [
                  if (editPrice)
                    Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          //box of price input
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(left: 20, top: 20),
                              width: 120,
                              child: TextField(
                                onSubmitted: (text) {
                                  setState(() {
                                    editPrice = false;
                                    double? parsedValue = double.tryParse(text);
                                    getPriceList()[personButton] =
                                        parsedValue!; // Change the boolean value when text is submitted
                                  });
                                },
                                keyboardType: TextInputType
                                    .number, // Restrict input to numbers
                                decoration: const InputDecoration(
                                  border:
                                      OutlineInputBorder(), // Box with border
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color.fromARGB(255, 171, 54, 21),
                                        width: 2.0), // Border when focused
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color.fromARGB(255, 53, 53, 53),
                                        width: 2.0), // Border when not focused
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 12.0), // Padding inside the box
                                  hintText: '0.00 ฿',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  SizedBox(
                      height: widget.memberNames.length * 65,
                      child: ListView.builder(
                          itemCount: widget.memberNames.length,
                          itemBuilder: (context, index) {
                            if (widget.memberNames[index].isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Transform.scale(
                                          scale: 1.5,
                                          child: Checkbox(
                                            fillColor: WidgetStateProperty
                                                .resolveWith<Color>(
                                                    (Set<WidgetState> states) {
                                              if (states.contains(
                                                  WidgetState.selected)) {
                                                return Colors
                                                    .white; // The inside of the checkbox when selected
                                              }
                                              return Colors
                                                  .white; // The inside of the checkbox when not selected
                                            }),
                                            side: const BorderSide(
                                              color: Color(
                                                  0xffCD5334), // The border color
                                              width: 2.0, // Border thickness
                                            ),
                                            checkColor: const Color(0xffCD5334),
                                            value: getValueCheckBox()[index],
                                            onChanged: (bool? newValue) {
                                              setState(() {
                                                getValueCheckBox()[index] =
                                                    newValue ?? false;
                                              });
                                            },
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors
                                                      .grey, // Grey color for the line
                                                  width:
                                                      1.0, // Thickness of the line
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  widget.memberNames[index],
                                                  style: MyTextStyles
                                                      .size18BlackText,
                                                ),
                                                if (getPriceList()[index] != 0)
                                                  Text(
                                                      '${getPriceList()[index]}'),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (getValueCheckBox()[index] == true)
                                          TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  editPrice = true;
                                                  personButton = index;
                                                });
                                              },
                                              child: const Text(
                                                '🖊️',
                                                style: TextStyle(fontSize: 18),
                                              ))
                                        else
                                          const SizedBox(
                                            width: 65,
                                          ),
                                      ],
                                    ),
                                  ],
                                ));
                          })),
                ],
              ))
            ],
          ),
          if (state == 'who')
            Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 200,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                      color: const Color(0xffCD5334),
                      borderRadius: BorderRadius.circular(15)),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        state = 'for';
                        change_button_color();
                      });
                    },
                    child: const Text(
                      'Next',
                      style: MyTextStyles.mediumWhiteText,
                    ),
                  ),
                ))
          else
            Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 200,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(15)),
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Save',
                      style: MyTextStyles.mediumBlackText,
                    ),
                  ),
                ))
        ],
      ),
    );
  }
}
