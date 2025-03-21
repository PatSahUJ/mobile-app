import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:senior_project/pages/login.dart';
import 'package:senior_project/style/my_text_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  String? _username;
  String? _email;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController(); // Password controller
  final TextEditingController _currentPasswordController =
      TextEditingController();
  String? _passwordError;
  bool _isEnteringCurrentPassword = false; // Add this state variable
  bool _isEditingUsername = false;
  // bool _isEditingEmail = false; // Track if the email is being edited
  bool _isEditingPassword = false;

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
              _usernameController.text = _username ?? '';
              _emailController.text = _email ?? '';
            });
          }
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  Future<void> _updateUsername() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'username': _usernameController.text});

        setState(() {
          _username = _usernameController.text;
          _isEditingUsername = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Username updated successfully.")));
      } catch (e) {
        print('Error updating username: $e');
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to update username.")));
      }
    }
  }

  // Future<void> _updateEmail() async {
  //   User? user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     try {
  //       await user.updateEmail(_emailController.text);

  //       setState(() {
  //         _email = _emailController.text;
  //         _isEditingEmail = false;
  //       });

  //       ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text("Email updated successfully.")));
  //     } on FirebaseAuthException catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text("Failed to update email: ${e.message}")));
  //     }
  //   }
  // }

  Future<void> _updatePassword() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Reauthenticate the user with the current password
        AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!, password: _currentPasswordController.text);
        await user.reauthenticateWithCredential(credential);

        // Update the password
        await user.updatePassword(_passwordController.text);

        setState(() {
          _isEditingPassword = false;
          _passwordError = null; // Clear any previous error
        });

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Password updated successfully.")));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password') {
          setState(() {
            _passwordError = "Incorrect password";
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Failed to update password: ${e.message}")));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to update password.")));
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
      print("Sign out error: ${e.message}");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sign out failed: ${e.message}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            padding:
                const EdgeInsets.only(top: 50.0, right: 10.0, bottom: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _isEditingUsername
                          ? Expanded(
                              child: TextField(
                                controller: _usernameController,
                                decoration: const InputDecoration(
                                    labelText: 'Username'),
                              ),
                            )
                          : Text('$_username', style: MyTextStyles.heading1),
                      IconButton(
                        icon:
                            Icon(_isEditingUsername ? Icons.check : Icons.edit),
                        onPressed: () {
                          setState(() {
                            if (_isEditingUsername) {
                              _updateUsername();
                            } else {
                              _isEditingUsername = true;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email Address:',
                        style: MyTextStyles.size18BlackText,
                      ),
                      const SizedBox(height: 3),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: const Color.fromARGB(255, 232, 232, 232)),
                        child: Row(
                          children: [
                            Text('$_email',
                                style: MyTextStyles.size18BlackText),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Password:',
                        style: MyTextStyles.size18BlackText,
                      ),
                      const SizedBox(height: 3),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: const Color.fromARGB(255, 232, 232, 232)),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _isEditingPassword ||
                                          _isEnteringCurrentPassword
                                      ? TextField(
                                          controller: _isEditingPassword
                                              ? _passwordController
                                              : _currentPasswordController,
                                          decoration: InputDecoration(
                                            labelText: _isEditingPassword
                                                ? 'Enter your new password'
                                                : 'Enter your current password',
                                            errorText: _passwordError,
                                          ),
                                          obscureText: true,
                                        )
                                      : const Text(
                                          '••••••••', // Masked password
                                          style: TextStyle(fontSize: 20)),
                                ),
                                IconButton(
                                  icon: Icon(_isEditingPassword ||
                                          _isEnteringCurrentPassword
                                      ? Icons.check
                                      : Icons.edit),
                                  onPressed: () {
                                    setState(() {
                                      if (_isEditingPassword) {
                                        _updatePassword();
                                      } else {
                                        if (!_isEditingPassword &&
                                            !_isEnteringCurrentPassword) {
                                          _isEnteringCurrentPassword = true;
                                        } else if (_isEnteringCurrentPassword) {
                                          User? user =
                                              FirebaseAuth.instance.currentUser;
                                          if (user != null) {
                                            AuthCredential credential =
                                                EmailAuthProvider.credential(
                                                    email: user.email!,
                                                    password:
                                                        _currentPasswordController
                                                            .text);
                                            user
                                                .reauthenticateWithCredential(
                                                    credential)
                                                .then((value) {
                                              setState(() {
                                                _isEditingPassword = true;
                                                _passwordError = null;
                                                _isEnteringCurrentPassword =
                                                    false;
                                              });
                                            }).onError((error, stackTrace) {
                                              setState(() {
                                                _passwordError =
                                                    "Incorrect password";
                                                _isEnteringCurrentPassword =
                                                    true;
                                              });
                                            });
                                          }
                                        }
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 174, 211, 241),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 10)),
                      onPressed: () {
                        Navigator.pushNamed(context, '/friends');
                      },
                      child: const Text('Friends',
                          style: MyTextStyles.size20BlackText)),
                  const SizedBox(height: 50),
                  TextButton(
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 10),
                          backgroundColor: Theme.of(context).primaryColor),
                      onPressed: () {
                        signUserOut(context);
                      },
                      child: const Text('Sign out',
                          style: MyTextStyles.size20BlackText)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
