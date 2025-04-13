import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:senior_project/style/my_text_style.dart'; // Import your styles

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  String _resetMessage = '';

  Future<void> _resetPassword(BuildContext context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      setState(() {
        _resetMessage = "Password reset email sent. Please check your inbox.";
      });
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Failed to send reset email.";
      if (e.code == 'user-not-found') {
        errorMessage = "No user found with that email.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email address.";
      }
      setState(() {
        _resetMessage = errorMessage;
      });
    } catch (e) {
      setState(() {
        _resetMessage = "An unexpected error occurred.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffefe2),
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Enter your email address and we'll send you a link to reset your password.",
              style: MyTextStyles.lightText,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _resetPassword(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(
                    vertical: 15.0, horizontal: 40.0),
              ),
              child: const Text('Send Reset Email',
                  style: MyTextStyles.mediumWhiteText),
            ),
            const SizedBox(height: 10.0),
            Text(
              _resetMessage,
              style: const TextStyle(color: Colors.green),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
