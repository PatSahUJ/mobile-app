import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:senior_project/pages/auth_page.dart';
import 'package:senior_project/style/my_text_style.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController =
      TextEditingController(); // Controller for email input
  final TextEditingController passwordController =
      TextEditingController(); // Controller for password input

  void signUserIn(BuildContext context) async {
    // Pass context for showing UI feedback
    print("try to log in");
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      print("log in success");
      print("Current user: ${FirebaseAuth.instance.currentUser}");

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const AuthPage()));
      print("Navigation to AuthPage called."); // Add this line
      // Optionally navigate to the next screen or show a success message.
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Authentication specific errors
      print("Firebase Authentication Error: ${e.code} - ${e.message}");
      String errorMessage = "An error occurred."; // Default error message

      if (e.code == 'user-not-found') {
        errorMessage = "No user found for that email.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Wrong password provided for that user.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "The email address is badly formatted.";
      } else if (e.code == 'user-disabled') {
        errorMessage = "This user account has been disabled.";
      } else if (e.code == 'too-many-requests') {
        errorMessage = "Too many requests. Try again later.";
      }
      // ... Handle other Firebase Auth error codes as needed ...

      // Show the error message to the user (e.g., using a SnackBar or Dialog)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      // Handle other types of errors (e.g., network issues)
      print("General Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An unexpected error occurred.")),
      );
    }
  }

  // Firebase login method
  // Future<void> loginUser() async {
  //   // Function to handle user login with Firebase
  //   try {
  //     String email = emailController.text;
  //     String password = passwordController.text;

  //     if (email.isEmpty || password.isEmpty) {
  //       print("Please enter both email and password.");
  //       return;
  //     }

  //     // Firebase authentication login
  //     UserCredential userCredential =
  //         await FirebaseAuth.instance.signInWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );

  //     print("User logged in: ${userCredential.user?.uid}");
  //     // Navigate to the dashboard or home screen after successful login
  //     Navigator.pushNamed(context, '/dashboard');
  //   } on FirebaseAuthException catch (e) {
  //     // Catch Firebase-specific exceptions
  //     if (e.code == 'user-not-found') {
  //       print('No user found for that email.');
  //     } else if (e.code == 'wrong-password') {
  //       print('Wrong password provided.');
  //     } else {
  //       print('Error: ${e.code}');
  //     }
  //   } catch (e) {
  //     // Catch any other unexpected exceptions
  //     print('Unexpected error: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffefe2),
      body: Stack(
        children: [
          Positioned(
            top: 20.0, // Top edge of the Stack
            right: 10.0, // Right edge of the Stack
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: const Center(
                child: Text('Sign Up', style: MyTextStyles.heading2),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Login', style: MyTextStyles.heading1),
                  const SizedBox(height: 60.0),
                  const Text('Your Email', style: MyTextStyles.lightText),
                  TextField(
                    controller:
                        emailController, // Use the controller for email input
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Tom@gmail.com',
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  const Text('Password', style: MyTextStyles.lightText),
                  TextField(
                    controller:
                        passwordController, // Use the controller for password input
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: '12345',
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          signUserIn(context); // Pass the context here
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 100.0),
                          decoration: BoxDecoration(
                            color: const Color(0xff383961), // Background color
                            borderRadius:
                                BorderRadius.circular(25.0), // Rounded corners
                          ),
                          child: const Text(
                            'Log In',
                            style: MyTextStyles.mediumWhiteText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
