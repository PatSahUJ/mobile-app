// // group_ex.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:senior_project/pages/expense/expense_data_provider.dart';
// import 'package:senior_project/pages/expense/payer_page.dart';
// import 'package:senior_project/style/my_text_style.dart';

// class GroupEx extends StatefulWidget {
//   const GroupEx({super.key});
//   @override
//   State<StatefulWidget> createState() {
//     return _groupExState();
//   }
// }

// class _groupExState extends State<GroupEx> {
//   bool _isExpanded = false;

//   @override
//   void dispose() {
//     Provider.of<ExpenseDataProvider>(context, listen: false)
//         .clearMemberControllersText();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final expenseProvider =
//         Provider.of<ExpenseDataProvider>(context, listen: false);

//     print('Build method called. _isExpanded: $_isExpanded');
//     return SliverToBoxAdapter(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 7),
//         child: Column(children: [
//           const SizedBox(
//             height: 10,
//           ),
//           Container(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
//             margin: const EdgeInsets.symmetric(vertical: 4.0),
//             decoration: BoxDecoration(
//               color: const Color.fromARGB(255, 239, 239, 239),
//               border:
//                   Border.all(color: const Color.fromARGB(255, 192, 192, 192)),
//               borderRadius: BorderRadius.circular(30),
//               boxShadow: const [
//                 BoxShadow(
//                   color: Color.fromARGB(20, 0, 0, 0),
//                   blurRadius: 4,
//                   spreadRadius: 2,
//                   offset: Offset(0, 4),
//                 )
//               ],
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               mainAxisSize: MainAxisSize.max,
//               children: [
//                 const Text(' Group Expense',
//                     style: MyTextStyles.size18BlackText),
//                 Switch(
//                   inactiveTrackColor: const Color.fromARGB(146, 133, 133, 133),
//                   activeColor: const Color(0xffCD5334),
//                   value: _isExpanded,
//                   onChanged: (value) {
//                     setState(() {
//                       _isExpanded = value;
//                       if (!_isExpanded) {
//                         expenseProvider.clearMemberControllers();
//                       }
//                     });
//                   },
//                 ),
//               ],
//             ),
//           ),
//           if (_isExpanded)
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//               child: Column(
//                 children: [
//                   ...expenseProvider.memberControllers.map((controller) {
//                     return Padding(
//                       padding: const EdgeInsets.only(bottom: 10.0),
//                       child: Column(
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: TextField(
//                                   controller: controller,
//                                   key: ValueKey(controller),
//                                   keyboardType: TextInputType.text,
//                                   style: MyTextStyles.size16BlackText,
//                                   decoration: const InputDecoration(
//                                     hintText: 'Enter Name',
//                                     hintStyle: MyTextStyles.size16GreyText,
//                                     border: UnderlineInputBorder(
//                                         borderSide:
//                                             BorderSide(color: Colors.grey)),
//                                     enabledBorder: UnderlineInputBorder(
//                                         borderSide:
//                                             BorderSide(color: Colors.grey)),
//                                     focusedBorder: UnderlineInputBorder(
//                                         borderSide:
//                                             BorderSide(color: Colors.grey)),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     );
//                   }),
//                   GestureDetector(
//                     onTap: () {
//                       expenseProvider.addMemberController();
//                       setState(() {});
//                     },
//                     child: const Row(
//                       children: [
//                         Text('+ Add member', style: MyTextStyles.size16RedText),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           const SizedBox(height: 15),
//           if (!_isExpanded)
//             Container(
//               width: 200,
//               decoration: BoxDecoration(
//                   color: Theme.of(context).primaryColor,
//                   borderRadius: BorderRadius.circular(15)),
//               child: TextButton(
//                 onPressed: () {
//                   Provider.of<ExpenseDataProvider>(context, listen: false)
//                       .saveExpense(mounted);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Expense saved!')));
//                   Navigator.pushNamed(context, '/dashboard');
//                 },
//                 child: const Text('Save', style: MyTextStyles.size20BlackText),
//               ),
//             ),
//           if (_isExpanded)
//             Container(
//               width: 200,
//               decoration: BoxDecoration(
//                   color: const Color(0xffCD5334),
//                   borderRadius: BorderRadius.circular(15)),
//               child: TextButton(
//                 onPressed: () {
//                   List<String> memberNames = expenseProvider.memberControllers
//                       .map((controller) => controller.text.trim())
//                       .where((name) => name.isNotEmpty)
//                       .toList();

//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => PayerPage(memberNames: memberNames),
//                     ),
//                   );
//                 },
//                 child: const Text('Next', style: MyTextStyles.mediumWhiteText),
//               ),
//             )
//         ]),
//       ),
//     );
//   }
// }
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
  Map<String, String> _userIdToUsername = {};

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
    // Update the UI with fetched usernames
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
        Provider.of<ExpenseDataProvider>(context, listen: false);
    final friendsProvider = Provider.of<FriendsProvider>(context);

    print('Build method called. _isExpanded: $_isExpanded');

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
                  }).toList(),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          const SizedBox(height: 15),
          if (!_isExpanded)
            Container(
              width: 200,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(15)),
              child: TextButton(
                onPressed: () {
                  Provider.of<ExpenseDataProvider>(context, listen: false)
                      .saveExpense(mounted);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Expense saved!')));
                  Navigator.pushNamed(context, '/dashboard');
                },
                child: const Text('Save', style: MyTextStyles.size20BlackText),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PayerPage(memberIds: _selectedFriendIds),
                    ),
                  );
                },
                child: const Text('Next', style: MyTextStyles.mediumWhiteText),
              ),
            )
        ]),
      ),
    );
  }
}
