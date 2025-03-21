import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:senior_project/pages/auth_page.dart';
import 'package:senior_project/pages/forgot_password_page.dart';
import 'package:senior_project/style/my_text_style.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String _errorMessage = ''; // General error message
  String _verificationErrorMessage = ''; // Verification error message

  void signUserIn(BuildContext context) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      User? user = userCredential.user;

      if (user != null) {
        if (!user.emailVerified) {
          await user.sendEmailVerification();
          setState(() {
            _errorMessage = ''; // Clear general error message
            _verificationErrorMessage =
                "Please verify your email before logging in.";
          });
          await FirebaseAuth.instance.signOut();
          return;
        }

        print("log in success");
        print("Current user: ${FirebaseAuth.instance.currentUser}");

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const AuthPage()));
        print("Navigation to AuthPage called.");
      }
    } on FirebaseAuthException catch (e) {
      print("Firebase Authentication Error: ${e.code} - ${e.message}");
      String errorMessage = "An error occurred.";

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

      setState(() {
        _verificationErrorMessage = ''; // Clear verification message
        _errorMessage = errorMessage;
      });
    } catch (e) {
      print("General Error: $e");
      setState(() {
        _verificationErrorMessage = ''; // Clear verification message
        _errorMessage = "An unexpected error occurred.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffefe2),
      body: Stack(
        children: [
          Positioned(
            top: 20.0,
            right: 10.0,
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
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Tom@gmail.com',
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  const Text('Password', style: MyTextStyles.lightText),
                  TextField(
                    controller: passwordController,
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
                          signUserIn(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 100.0),
                          decoration: BoxDecoration(
                            color: const Color(0xff383961),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: const Text(
                            'Log In',
                            style: MyTextStyles.mediumWhiteText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0), // Add some spacing
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPasswordPage()),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: MyTextStyles.lightText,
                        ),
                      ),
                    ],
                  ),
                  // Display verification error message
                  if (_verificationErrorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _verificationErrorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  // Display general error message
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
        ],
      ),
    );
  }
}
