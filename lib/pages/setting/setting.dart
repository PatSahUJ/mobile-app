import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:senior_project/pages/login.dart';
import 'package:senior_project/style/my_text_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class Setting extends StatefulWidget {
  // Change to StatefulWidget
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState(); // Create State
}

class _SettingState extends State<Setting> {
  // Create State class
  String? _username;
  String? _email;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic>? userData =
              userDoc.data() as Map<String, dynamic>?;

          if (userData != null) {
            setState(() {
              _username = userData['username'] as String?;
              _email = user.email;
            });
          }
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  void signUserOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Login()));
      print('sign out success');
    } on FirebaseAuthException catch (e) {
      // Handle sign-out errors (e.g., display an error message)
      print("Sign out error: ${e.message}");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sign out failed: ${e.message}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: CustomScrollView(slivers: [
        SliverAppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          pinned: true,
          floating: true,
          centerTitle: false,
          stretch: false,
          automaticallyImplyLeading: false,
          expandedHeight: 50,
          flexibleSpace: Stack(
            children: [
              Positioned(
                  top: 32,
                  right: 10,
                  child: Row(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.home,
                          size: 40,
                          color: Color.fromARGB(255, 29, 0, 45),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/dashboard');
                        },
                      ),
                    ],
                  )),
              Positioned.fill(
                  top: 80,
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(40)),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(79, 66, 66, 66),
                            blurRadius: 9,
                            spreadRadius: -2,
                            offset: Offset(0.0, -12.0),
                          )
                        ]),
                  ))
            ],
          ),
          //actions: <Widget>[],
        ),
        SliverToBoxAdapter(
          child: Column(
            //alignment: Alignment.center,
            children: [
              SizedBox(height: 50),
              if (_username != null) // Display username and email
                Text('Username: $_username',
                    style: MyTextStyles.size18BlackText),
              if (_email != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('Email: $_email',
                      style: MyTextStyles.size18BlackText),
                ),
              SizedBox(height: 50), // Add spacing
              TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 174, 211, 241),
                      padding: EdgeInsets.symmetric(horizontal: 20)),
                  onPressed: () {
                    Navigator.pushNamed(context, '/friends');
                  },
                  child: const Text('Friends',
                      style: MyTextStyles.size20BlackText)),
              SizedBox(
                height: 50,
              ),
              TextButton(
                  style: TextButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      backgroundColor: Theme.of(context).primaryColor),
                  onPressed: () {
                    signUserOut(context);
                  },
                  child: const Text('Sign out',
                      style: MyTextStyles.size20BlackText)),
            ],
          ),
        )
      ]),
    );
  }
}
