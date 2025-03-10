import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:senior_project/pages/login.dart';
import 'package:senior_project/style/my_text_style.dart';

class Setting extends StatelessWidget {
  const Setting({super.key});

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
    // TODO: implement build
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
              TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/friends');
                  },
                  child: const Text('Friends',
                      style: MyTextStyles.size20BlackText)),
              SizedBox(
                height: 20,
              ),
              TextButton(
                  onPressed: () {
                    signUserOut(context);
                  },
                  child: const Text('Sign out',
                      style: MyTextStyles.size20BlackText))
            ],
          ),
        )
      ]),
    );
  }
}
