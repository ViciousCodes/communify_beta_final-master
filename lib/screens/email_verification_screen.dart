import 'dart:async';

import 'package:communify_beta_final/app_layout.dart';
import 'package:communify_beta_final/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../bottom_nav.dart';

class EmailVerifyScreen extends StatefulWidget{
  const EmailVerifyScreen({super.key});

  @override
  EmailVerifyScreenState createState() => EmailVerifyScreenState();
}

class EmailVerifyScreenState extends State<EmailVerifyScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isEmailVerified = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if(!isEmailVerified){
      sendVerificationEmail();
      timer = Timer.periodic(Duration(seconds: 1), (_) => checkEmailVerified());
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
    }
    catch(e){
      showDialog(context: context, builder: (context){
        return CupertinoAlertDialog(
          title: const Text("Error!"),
          content: Text(e.toString()),
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
      );
    }
}

  Future checkEmailVerified() async{
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if(isEmailVerified){
      timer?.cancel();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute(builder: (context) => const BottomNav()),
                (Route<dynamic> route) => false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: CupertinoColors.white,
        body: Padding(
          padding: EdgeInsets.only(left: AppLayout.getWidth(20), right: AppLayout.getWidth(20)),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(top: AppLayout.getHeight(40)),
                  child: const Center(
                    child: Text(
                      'Email Verification',
                      style: TextStyle(
                        color: Color(0xFF09152D),
                        fontSize: 24,
                        fontFamily: 'Satoshi',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),

              Gap(AppLayout.getWidth(20)),
              const Text(
                'A verification email has been sent to your email. You will be redirected to the login page once your email is verified',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 20,
                  fontFamily: 'Satoshi',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Gap(AppLayout.getHeight(20)),
              CupertinoButton(
                onPressed: sendVerificationEmail,
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
                          'Resend Email',
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
              CupertinoButton(
                onPressed: () {
                  _auth.signOut();
                  if(context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      CupertinoPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                    );
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
                          'Cancel',
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
            ],
          ),
        ),
      ),
    );
  }


}
