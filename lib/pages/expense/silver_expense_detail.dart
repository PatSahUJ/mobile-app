import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senior_project/pages/expense/category_ex.dart';
import 'package:senior_project/pages/expense/expense_data_provider.dart';
import 'package:senior_project/style/my_text_style.dart';
// Import your provider

class SilverExpenseDetail extends StatefulWidget {
  const SilverExpenseDetail({super.key});

  @override
  State<SilverExpenseDetail> createState() => _SilverExpenseDetailState();
}

class _SilverExpenseDetailState extends State<SilverExpenseDetail> {
  final TextEditingController _amountController = TextEditingController();
  double? _amount;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _amountController,
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.number,
                    style: MyTextStyles.mediumBoldBlackText,
                    decoration: const InputDecoration(
                      hintText: 'How much?',
                      hintStyle: MyTextStyles.mediumBoldBlackText,
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _amount = double.tryParse(value);
                      });
                      // Update the provider with the new amount
                      if (_amount != null) {
                        Provider.of<ExpenseDataProvider>(context, listen: false)
                            .updateAmount(_amount!);

                        //print('Provider Amount: ${Provider.of<ExpenseDataProvider>(context, listen: false).amount}');
                      }
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Text(
                    '฿',
                    style: MyTextStyles.heading1,
                  ),
                ),
              ],
            ),
          ),
          const CategoryEx(),
        ],
      ),
    );
  }
}
