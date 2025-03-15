import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:senior_project/custom_widget/custom_dashboard/filter/category_selection_dialog.dart';
import 'package:senior_project/custom_widget/custom_dashboard/filter/filter_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SilverAppBarDashboard extends StatefulWidget {
  const SilverAppBarDashboard({super.key});

  @override
  State<SilverAppBarDashboard> createState() => _SilverAppBarDashboardState();
}

class _SilverAppBarDashboardState extends State<SilverAppBarDashboard> {
  String? _categoryEmoji;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchCategoryEmoji();
  }

  Future<void> _fetchCategoryEmoji() async {
    final filterProvider = Provider.of<FilterProvider>(context);
    String? selectedCategory = filterProvider.selectedCategory;

    if (selectedCategory != null) {
      if (selectedCategory == 'Group Transaction') {
        setState(() {
          _categoryEmoji = '👥';
        });
        return;
      }
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          DocumentSnapshot categorySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('category')
              .doc(selectedCategory)
              .get();

          if (categorySnapshot.exists) {
            Map<String, dynamic>? data =
                categorySnapshot.data() as Map<String, dynamic>?;
            if (data != null && data.containsKey('emoji')) {
              setState(() {
                _categoryEmoji = data['emoji'] as String;
              });
              return;
            }
          }
        } catch (e) {
          print('Error fetching category emoji: $e');
        }
      }
    }
    setState(() {
      _categoryEmoji = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filterProvider = Provider.of<FilterProvider>(context);

    return SliverAppBar(
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 0,
      pinned: true,
      floating: true,
      centerTitle: false,
      stretch: false,
      automaticallyImplyLeading: false,
      expandedHeight: MediaQuery.of(context).size.width * 0.18,
      flexibleSpace: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).size.height * 0.025,
            right: 10,
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                ),
                IconButton(
                  icon: Builder(
                    builder: (BuildContext context) {
                      if (_categoryEmoji != null) {
                        return Text(
                          _categoryEmoji!,
                          style: const TextStyle(fontSize: 30),
                        );
                      } else {
                        return const Icon(
                          Icons.search,
                          size: 50,
                        );
                      }
                    },
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const CategorySelectionDialog();
                      },
                    ).then((value) {
                      _fetchCategoryEmoji();
                    });
                  },
                ),
                IconButton(
                  alignment: Alignment.center,
                  icon: Image.asset('asset/icons/setting.png', width: 50),
                  onPressed: () {
                    Navigator.pushNamed(context, '/setting');
                  },
                ),
              ],
            ),
          ),
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.1,
            child: Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(79, 66, 66, 66),
                    blurRadius: 9,
                    spreadRadius: -2,
                    offset: Offset(0.0, -12.0),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
