import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senior_project/pages/expense/expense_data_provider.dart';
import 'package:senior_project/pages/expense/payer_page.dart';
import 'package:senior_project/style/my_text_style.dart';
import 'package:senior_project/pages/setting/friends_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupEx extends StatefulWidget {
  const GroupEx({super.key});

  @override
  State<StatefulWidget> createState() {
    return _groupExState();
  }
}

class _groupExState extends State<GroupEx> {
  bool _isExpanded = false;
  List<String> _selectedFriendIds = [];
  final Map<String, String> _userIdToUsername = {};

  Future<void> _fetchUsernames(List<String> friendIds) async {
    _userIdToUsername.clear();
    for (String friendId in friendIds) {
      try {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(friendId)
            .get();
        if (userSnapshot.exists) {
          _userIdToUsername[friendId] =
              userSnapshot['username'] ?? 'Unknown User';
        } else {
          _userIdToUsername[friendId] = 'Unknown User';
        }
      } catch (e) {
        print("Error fetching username for $friendId: $e");
        _userIdToUsername[friendId] = 'Error User';
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    Provider.of<ExpenseDataProvider>(context, listen: false)
        .clearMemberControllersText();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider =
        Provider.of<ExpenseDataProvider>(context); // Listen to changes
    final friendsProvider = Provider.of<FriendsProvider>(context);

    print('Build method called. _isExpanded: $_isExpanded');

    bool isNextButtonEnabled = expenseProvider.amount > 0 &&
        expenseProvider.category.isNotEmpty &&
        expenseProvider.date != null;

    bool isSaveButtonEnabled = expenseProvider.amount > 0 &&
        expenseProvider.category.isNotEmpty &&
        expenseProvider.date != null;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7),
        child: Column(children: [
          const SizedBox(height: 10),
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
                  inactiveTrackColor: const Color.fromARGB(146, 133, 133, 133),
                  activeColor: const Color(0xffCD5334),
                  value: _isExpanded,
                  onChanged: (value) async {
                    setState(() {
                      _isExpanded = value;
                      if (!_isExpanded) {
                        print(
                            "FriendsProvider friends length: ${friendsProvider.friends.length}");
                        expenseProvider.clearMemberControllers();
                        _selectedFriendIds.clear();
                        _userIdToUsername.clear();
                      }
                    });
                    if (_isExpanded) {
                      _selectedFriendIds =
                          friendsProvider.friends.map((doc) => doc.id).toList();
                      await _fetchUsernames(_selectedFriendIds);
                    }
                  },
                ),
              ],
            ),
          ),
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  ..._selectedFriendIds.map((friendId) {
                    final friendName =
                        _userIdToUsername[friendId] ?? 'Loading...';
                    final isSelected = _selectedFriendIds.contains(friendId);

                    return CheckboxListTile(
                      title: Text(friendName),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value != null) {
                            if (value) {
                              _selectedFriendIds.add(friendId);
                            } else {
                              _selectedFriendIds.remove(friendId);
                            }
                          }
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          const SizedBox(height: 15),
          if (!_isExpanded)
            Container(
              width: 200,
              decoration: BoxDecoration(
                  color: isSaveButtonEnabled
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(15)),
              child: TextButton(
                onPressed: isSaveButtonEnabled
                    ? () {
                        Provider.of<ExpenseDataProvider>(context, listen: false)
                            .saveExpense(mounted);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Expense saved!')));

                        Provider.of<ExpenseDataProvider>(context, listen: false)
                            .clearData();

                        Navigator.pushNamed(context, '/dashboard');
                      }
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Please select category, amount, and date.'),
                          ),
                        );
                      },
                child: const Text('Save', style: MyTextStyles.size20BlackText),
              ),
            ),
          if (_isExpanded)
            Container(
              width: 200,
              decoration: BoxDecoration(
                  color: isNextButtonEnabled
                      ? const Color(0xffCD5334)
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(15)),
              child: TextButton(
                onPressed: isNextButtonEnabled
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PayerPage(memberIds: _selectedFriendIds),
                          ),
                        );
                      }
                    : null,
                child: const Text('Next', style: MyTextStyles.mediumWhiteText),
              ),
            )
        ]),
      ),
    );
  }
}
