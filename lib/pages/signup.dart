// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:senior_project/style/my_text_style.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class Signup extends StatefulWidget {
//   const Signup({super.key});

//   @override
//   _SignupState createState() => _SignupState();
// }

// class _SignupState extends State<Signup> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _displayNameController = TextEditingController();

//   // Error handling variables
//   String _errorMessage = '';

//   Future<void> signUpWithEmailAndPassword(
//       String email, String password, String displayName) async {
//     try {
//       UserCredential userCredential =
//           await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       print('signed up successfulllllllll');
//       print('User signed up: ${userCredential.user!.uid}');

//       // Add user data to Firestore (optional)
//       await addUserToFirestore(userCredential.user!.uid, {
//         'email': email,
//         'username': displayName.isNotEmpty
//             ? displayName
//             : email, // Use displayName or fallback to email
//         'creationDate': DateTime.now(),
//         'total': 0,
//         'totalExpense': 0, // Add totalExpense with initial value 0
//         'totalIncome': 0, // Add totalIncome with initial value 0
//       });

//       print('User signed up and data added to Firestore');
//       // Navigate to login page after successful signup
//       Navigator.pushReplacementNamed(context, '/login');
//     } on FirebaseAuthException catch (e) {
//       print('FirebaseAuthException: ${e.code}, ${e.message}');
//       setState(() {
//         if (e.code == 'weak-password') {
//           _errorMessage = 'The password provided is too weak.';
//         } else if (e.code == 'email-already-in-use') {
//           _errorMessage = 'The account already exists for that email.';
//         } else {
//           _errorMessage = 'Error during signup: ${e.code} - ${e.message}';
//         }
//       });
//     } catch (e) {
//       print('Unexpected error during signup: $e');
//       setState(() {
//         _errorMessage = 'Unexpected error during signup: $e';
//       });
//     }
//   }

//   Future<void> addUserToFirestore(
//       String uid, Map<String, dynamic> userData) async {
//     try {
//       print('Attempting to add user data to Firestore...');
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(uid)
//           .set(userData);
//       print('User data added to Firestore');
//     } catch (e) {
//       print('Error adding user data to Firestore: $e');
//       setState(() {
//         _errorMessage = 'Error adding user data to Firestore: $e';
//       });
//     }
//   }

//   void _signUp() {
//     String email = _emailController.text;
//     String password = _passwordController.text;
//     String confirmPassword = _confirmPasswordController.text;
//     String displayName = _displayNameController.text;

//     if (password != confirmPassword) {
//       setState(() {
//         _errorMessage = "Passwords do not match!";
//       });
//     } else {
//       signUpWithEmailAndPassword(email, password, displayName);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xffffefe2),
//       body: CustomScrollView(
//         slivers: [
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   TextButton(
//                     onPressed: () {
//                       Navigator.pushNamed(context, '/login');
//                     },
//                     child: const Text('Log In', style: MyTextStyles.heading2),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SliverFillRemaining(
//             child: Padding(
//               padding: const EdgeInsets.all(40.0),
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('Sign Up', style: MyTextStyles.heading1),
//                     const SizedBox(height: 60.0),
//                     const Text('Your Email', style: MyTextStyles.lightText),
//                     TextField(
//                       controller: _emailController,
//                       keyboardType: TextInputType.emailAddress,
//                       decoration:
//                           const InputDecoration(hintText: 'Tom@gmail.com'),
//                     ),
//                     const SizedBox(height: 20.0),
//                     const Text('Password', style: MyTextStyles.lightText),
//                     TextField(
//                       controller: _passwordController,
//                       obscureText: true,
//                       decoration: const InputDecoration(
//                           hintText: 'Enter your password'),
//                     ),
//                     const SizedBox(height: 20.0),
//                     const Text('Confirm Password',
//                         style: MyTextStyles.lightText),
//                     TextField(
//                       controller: _confirmPasswordController,
//                       obscureText: true,
//                       decoration: const InputDecoration(
//                           hintText: 'Confirm your password'),
//                     ),
//                     const SizedBox(height: 20.0),
//                     const Text('Display Name', style: MyTextStyles.lightText),
//                     TextField(
//                       controller: _displayNameController,
//                       decoration:
//                           const InputDecoration(hintText: 'Enter your name'),
//                     ),
//                     const SizedBox(height: 50.0),
//                     Center(
//                       child: TextButton(
//                         onPressed: _signUp,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 10.0, horizontal: 100.0),
//                           decoration: BoxDecoration(
//                             color: const Color(0xff383961), // Background color
//                             borderRadius:
//                                 BorderRadius.circular(25.0), // Rounded corners
//                           ),
//                           child: const Text(
//                             'Sign Up',
//                             style: MyTextStyles.mediumWhiteText,
//                           ),
//                         ),
//                       ),
//                     ),
//                     // Display error message if any
//                     if (_errorMessage.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           _errorMessage,
//                           style: const TextStyle(color: Colors.red),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:senior_project/style/my_text_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();

  // Error handling variables
  String _errorMessage = '';
  String _verificationMessage = ''; // To display verification message

  Future<void> signUpWithEmailAndPassword(
      String email, String password, String displayName) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Send verification email
        await user.sendEmailVerification();
        print('Verification email sent to: ${user.email}');

        // Add user data to Firestore, including isVerified
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': email,
          'username': displayName.isNotEmpty ? displayName : email,
          'creationDate': DateTime.now(),
          // 'total': 0,
          // 'totalExpense': 0,
          // 'totalIncome': 0,
          'isVerified': false, // Add isVerified field, set to false
        });

        print(
            'User signed up, verification email sent, and data added to Firestore');

        // Display verification message
        setState(() {
          _errorMessage = ''; // Clear other errors
          _verificationMessage =
              "Verification email sent. Please check your inbox and verify your email.";
        });

        // Navigate to login after showing the message
        // You might want to delay this slightly to ensure the user sees the message
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(
                context, '/login'); // Or a verify-email screen
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code}, ${e.message}');
      setState(() {
        _verificationMessage = ''; // Clear verification message
        if (e.code == 'weak-password') {
          _errorMessage = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          _errorMessage = 'The account already exists for that email.';
        } else {
          _errorMessage = 'Error during signup: ${e.code} - ${e.message}';
        }
      });
    } catch (e) {
      print('Unexpected error during signup: $e');
      setState(() {
        _verificationMessage = ''; // Clear verification message
        _errorMessage = 'Unexpected error during signup: $e';
      });
    }
  }

  Future<void> addUserToFirestore(
      String uid, Map<String, dynamic> userData) async {
    try {
      print('Attempting to add user data to Firestore...');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(userData);
      print('User data added to Firestore');
    } catch (e) {
      print('Error adding user data to Firestore: $e');
      setState(() {
        _errorMessage = 'Error adding user data to Firestore: $e';
      });
    }
  }

  void _signUp() {
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;
    String displayName = _displayNameController.text;

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = "Passwords do not match!";
      });
    } else {
      signUpWithEmailAndPassword(email, password, displayName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffefe2),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text('Log In', style: MyTextStyles.heading2),
                  ),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sign Up', style: MyTextStyles.heading1),
                    const SizedBox(height: 60.0),
                    const Text('Your Email', style: MyTextStyles.lightText),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration:
                          const InputDecoration(hintText: 'Tom@gmail.com'),
                    ),
                    const SizedBox(height: 20.0),
                    const Text('Password', style: MyTextStyles.lightText),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          hintText: 'Enter your password'),
                    ),
                    const SizedBox(height: 20.0),
                    const Text('Confirm Password',
                        style: MyTextStyles.lightText),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          hintText: 'Confirm your password'),
                    ),
                    const SizedBox(height: 20.0),
                    const Text('Display Name', style: MyTextStyles.lightText),
                    TextField(
                      controller: _displayNameController,
                      decoration:
                          const InputDecoration(hintText: 'Enter your name'),
                    ),
                    const SizedBox(height: 50.0),
                    Center(
                      child: TextButton(
                        onPressed: _signUp,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 100.0),
                          decoration: BoxDecoration(
                            color: const Color(0xff383961),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: const Text(
                            'Sign Up',
                            style: MyTextStyles.mediumWhiteText,
                          ),
                        ),
                      ),
                    ),
                    // Display verification message
                    if (_verificationMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _verificationMessage,
                          style: const TextStyle(
                              color: Colors.green), // Or any style you prefer
                        ),
                      ),
                    // Display error message if any
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
