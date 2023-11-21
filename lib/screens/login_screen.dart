import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communify_beta_final/app_layout.dart';
import 'package:communify_beta_final/bottom_nav.dart';
import 'package:communify_beta_final/bottom_nav_club.dart';
import 'package:communify_beta_final/screens/club_screens/club_sign_up_screen.dart';
import 'package:communify_beta_final/screens/reset_password_screen.dart';
import 'package:communify_beta_final/screens/sign_up_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'email_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {

  late TextEditingController _email;
  late TextEditingController _password;
  bool _switchValue = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
    Firebase.initializeApp();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> showErrorDialog(String errorTitle, String errorMessage) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(errorTitle),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: CupertinoColors.white,
        body: Padding(
          padding: EdgeInsets.only(left: AppLayout.getWidth(20), right: AppLayout.getWidth(20)),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(AppLayout.getHeight(40)),
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    "assets/images/CommUnifyBirdFullTextCropped.jpg",
                    width: AppLayout.getWidth(350),
                    fit: BoxFit.contain,
                  ),
                ),
                Gap(AppLayout.getHeight(15)),
                const Text(
                  'Sign in',
                  style: TextStyle(
                    color: Color(0xFF09152D),
                    fontSize: 28,
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Gap(AppLayout.getHeight(20)),
                CupertinoTextField(
                  controller: _email,
                  prefix: Padding(
                    padding: EdgeInsets.only(left: AppLayout.getWidth(20)),
                    child: const Icon(
                      CupertinoIcons.mail,
                      color: Color(0xFF677489),
                    ),
                  ),
                  placeholder: 'abc@email.com',
                  placeholderStyle: const TextStyle(
                    color: Color(0xFF677489),
                    fontSize: 18,
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w500,
                  ),
                  style: const TextStyle(
                    color: Color(0xFF677489),
                    fontSize: 18,
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: const Color(0xFF677489)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.only(left: AppLayout.getWidth(10), top: AppLayout.getHeight(12), bottom: AppLayout.getHeight(12)),
                ),
                Gap(AppLayout.getHeight(20)),
                CupertinoTextField(
                  controller: _password,
                  obscureText: true,
                  prefix: Padding(
                    padding: EdgeInsets.only(left: AppLayout.getWidth(20)),
                    child: const Icon(
                      CupertinoIcons.lock,
                      color: Color(0xFF677489),
                    ),
                  ),
                  placeholder: 'Your Password',
                  placeholderStyle: const TextStyle(
                    color: Color(0xFF677489),
                    fontSize: 18,
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w500,
                  ),
                  style: const TextStyle(
                    color: Color(0xFF677489),
                    fontSize: 18,
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: const Color(0xFF677489)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.only(left: AppLayout.getWidth(10), top: AppLayout.getHeight(12), bottom: AppLayout.getHeight(12)),
                ),
                Gap(AppLayout.getHeight(20)),
                Row(
                  children: [
                    CupertinoSwitch(
                      value: _switchValue,
                      onChanged: (value) {
                        setState(() {
                          _switchValue = value;
                        });
                      },
                      activeColor: const Color(0xFF09152D),
                    ),
                    const Text(
                      'Remember Me',
                      style: TextStyle(
                        color: Color(0xFF09152D),
                        fontSize: 15,
                        fontFamily: 'Satoshi',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context){
                                return const ResetPasswordScreen();
                              },
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF5668FF),
                            fontSize: 15,
                            fontFamily: 'Satoshi',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Gap(AppLayout.getHeight(30)),
                Center(
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {

                      if (_email.text.isEmpty ||
                      _password.text.isEmpty){
                        showErrorDialog('Missing Fields','Please fill in all required fields.');
                        return;
                      }

                      try {
                        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
                          email: _email.text.trim(),
                          password: _password.text.trim(),
                        );
                        if (userCredential.user != null) {
                          if (false) {}
                          // if (!_auth.currentUser!.emailVerified) {
                          //   if (context.mounted) {
                          //     Navigator.push(context, CupertinoPageRoute(
                          //         builder: (
                          //             context) => const EmailVerifyScreen()));
                          //   }
                          // }

                          else {
                            DocumentSnapshot docSnapshot = await FirebaseFirestore
                                .instance.collection('clubs').doc(
                                userCredential.user!.uid).get();
                            if (_switchValue) {
                              final prefs = await SharedPreferences
                                  .getInstance();
                              prefs.setBool('isLoggedIn', true);
                            }
                            if (docSnapshot.exists) {
                              if (_switchValue) {
                                final prefs = await SharedPreferences
                                    .getInstance();
                                prefs.setBool('isLoggedIn', true);
                                prefs.setBool('isClub', true);
                              }
                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    CupertinoPageRoute(builder: (
                                        context) => const BottomNavClub()),
                                        (Route<dynamic> route) => false
                                );
                              }
                            } else {
                              if (_switchValue) {
                                final prefs = await SharedPreferences
                                    .getInstance();
                                prefs.setBool('isLoggedIn', true);
                                prefs.setBool('isClub', false);
                              }
                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    CupertinoPageRoute(builder: (
                                        context) => const BottomNav()),
                                        (Route<dynamic> route) => false
                                );
                              }
                            }
                          }
                        }
                        else {
                          CupertinoAlertDialog(
                            title: const Text('Error'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        }
                      } catch (e) {
                        if (e is FirebaseAuthException) {
                          if (e.code == 'wrong-password') {
                            showErrorDialog('Wrong password', 'You have entered an incorrect password. Please try again.');
                            _password.clear();
                          } else if (e.code == 'user-not-found') {
                            showErrorDialog('Invalid email', 'No user found for the provided email.');
                          } else if (e.code == 'invalid-email'){
                          showErrorDialog('Invalid Email', 'The email address is not valid.');
                          }
                          else {
                            showErrorDialog('Error', e.toString()); // handles any other FirebaseAuthException
                          }
                        } else {
                          showErrorDialog('Error', e.toString()); // handles any non-FirebaseAuthException
                        }
                      }


                    },
                    child: Container(
                      width: AppLayout.getWidth(275), // Adjust the width as desired
                      height: AppLayout.getHeight(52), // Adjust the height as desired
                      decoration: BoxDecoration(
                        color: const Color(0xFF09152D),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Stack(
                        children: [
                          Center(
                            child: Text(
                              'SIGN IN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Gap(AppLayout.getHeight(30)),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, CupertinoPageRoute(builder: (context) => const SignUpScreen()));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.school, color: Color(0xFF5668FF)),
                      Gap(AppLayout.getWidth(10)),
                      const Text(
                        'Student Sign Up',
                        style: TextStyle(
                          color: Color(0xFF5668FF),
                          fontSize: 17,
                          fontFamily: 'Satoshi',
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                ),
                Gap(AppLayout.getHeight(20)),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, CupertinoPageRoute(builder: (context) => const ClubSignUpScreen()));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(CupertinoIcons.building_2_fill, color: Color(0xFF5668FF)),
                      Gap(AppLayout.getWidth(10)),
                      const Text(
                        'Club Sign Up',
                        style: TextStyle(
                          color: Color(0xFF5668FF),
                          fontSize: 17,
                          fontFamily: 'Satoshi',
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}