import 'package:communify_beta_final/app_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ResetPasswordScreen extends StatefulWidget{
  const ResetPasswordScreen({super.key});

  @override
  ResetPasswordScreenState createState() => ResetPasswordScreenState();
}

class ResetPasswordScreenState extends State<ResetPasswordScreen> {

  late TextEditingController _email;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future passwordReset() async {

    if (_email.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Error!'),
            content: const Text('Please enter an email.'),
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
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: _email.text.trim());
      if (!mounted) return;
      Navigator.pop(context); // No warnings now
      showDialog(context: context, builder: (context){
        return CupertinoAlertDialog(
          title: const Text("Success!"),
          content: const Text("Password reset link sent! Check email"),
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
    } on FirebaseAuthException catch(e){
      showDialog(context: context, builder: (context){
        return CupertinoAlertDialog(
          title: const Text("Error!"),
          content: Text(e.message.toString()),
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
                  padding: EdgeInsets.only(top: AppLayout.getHeight(20)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      BackButton(color: Color(0xFF09152D)),
                    ],
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'Forgot Password',
                  style: TextStyle(
                    color: Color(0xFF09152D),
                    fontSize: 24,
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Gap(AppLayout.getWidth(20)),
              const Text(
                'Enter your email to receive a password reset link',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 20,
                  fontFamily: 'Satoshi',
                  fontWeight: FontWeight.w500,
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
              CupertinoButton(
                onPressed: passwordReset,
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
                          'RESET',
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
