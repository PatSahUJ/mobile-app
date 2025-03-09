// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:senior_project/pages/dashboard/dashboard.dart';
// import 'package:senior_project/pages/login.dart';

// class AuthPage extends StatelessWidget {
//   const AuthPage({super.key});
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return Scaffold(
//       body: StreamBuilder<User?>(
//           stream: FirebaseAuth.instance.authStateChanges(),
//           builder: (context, snapshot) {
//             //user logged in
//             if (snapshot.hasData) {
//               print('going to dashboard');
//               return const Dashboard();
//             } else {
//               print('not going to dashboard');
//               return Login();
//             }
//           }),
//     );
//   }
// }
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:senior_project/pages/dashboard/dashboard.dart';
import 'package:senior_project/pages/login.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  void initState() {
    super.initState();
    print("AuthPage initState called.");
  }

  @override
  void dispose() {
    print("AuthPage dispose called.");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //user logged in
          if (snapshot.hasData) {
            print('going to dashboard');
            return const Dashboard();
          } else {
            print('going to dashboard log in');
            return const Login();
          }
        },
      ),
    );
  }
}
