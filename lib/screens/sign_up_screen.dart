import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communify_beta_final/bottom_nav.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_layout.dart';
import '../imageUtil.dart';
import 'email_verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  late TextEditingController _email;
  late TextEditingController _password;
  late TextEditingController _firstName;
  late TextEditingController _lastName;
  late TextEditingController _confirmPassword;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  bool _switchValue = false;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
    _firstName = TextEditingController();
    _lastName = TextEditingController();
    _confirmPassword = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future getImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery, maxHeight: 1000, imageQuality: 100);
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }


  signUp() async {
    if (_email.text.isEmpty ||
        _password.text.isEmpty ||
        _firstName.text.isEmpty ||
        _lastName.text.isEmpty ||
        _confirmPassword.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Missing Fields'),
            content: const Text('Please fill in all required fields.'),
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

    if (_password.text.contains(' ')) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Spaces in Password'),
            content: const Text('Your password cannot contain spaces.'),
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

    _firstName.text = _firstName.text.trim();
    _lastName.text = _lastName.text.trim();
    if ((_firstName.text.length > 100)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('First Name Error'),
            content: const Text('First name has more than 100 characters'),
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
    else if ((_lastName.text.length > 100)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Last Name Error'),
            content: const Text('Last name has more than 100 characters'),
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

    _firstName.text = _firstName.text.toLowerCase();
    _lastName.text = _lastName.text.toLowerCase();
    _firstName.text = _firstName.text[0].toUpperCase() + _firstName.text.substring(1);
    _lastName.text = _lastName.text[0].toUpperCase() + _lastName.text.substring(1);

    // RegExp regex = RegExp(r'^[a-zA-Z\d.]+@uic\.edu$');
    // if (!regex.hasMatch(_email.text.trim())) {
    //   showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return CupertinoAlertDialog(
    //         title: const Text('Invalid email'),
    //         content: const Text('Please provide a valid UIC email.'),
    //         actions: <Widget>[
    //           TextButton(
    //             child: const Text('OK'),
    //             onPressed: () {
    //               Navigator.of(context).pop();
    //             },
    //           ),
    //         ],
    //       );
    //     },
    //   );
    //   return;
    // }

    if (_formKey.currentState!.validate()) {
      if (_password.text != _confirmPassword.text) { // NEW
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text('No match'),
              content: const Text('Password does not match'),
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: SizedBox(
              width: AppLayout.getWidth(100),
              height: AppLayout.getHeight(100),
              child: const Center(child: CupertinoActivityIndicator(color: Color(0xFF09152D))),
            ),
          );
        },
      );
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text.trim(),
        );

        if (userCredential.user != null) {
          User user = userCredential.user!;
          await user.updateDisplayName('${_firstName.text} ${_lastName.text}');

          String imageUrl = '';
          String imageLowUrl = '';

          if (_imageFile != null) {
            final Reference storageReference = FirebaseStorage.instance.ref().child('user_images').child('${user.uid}.jpg');
            final Reference storageReferenceLow = FirebaseStorage.instance.ref().child('user_images_low').child('${user.uid}.jpg');

            // Get temp directory for the app.
            final dir = await getTemporaryDirectory();

            // Create target path for the compressed image.
            final targetPath = path.join(dir.absolute.path, "${user.uid}_compressed.jpg");

            // Compress image.
            File compressedImage = await resizeAndCompressImage(_imageFile!, targetPath);

            await storageReference.putFile(_imageFile!);
            await storageReferenceLow.putFile(compressedImage);

            imageUrl = await storageReference.getDownloadURL();
            imageLowUrl = await storageReferenceLow.getDownloadURL();
          }

          String? token;
          try {
            token = await FirebaseMessaging.instance.getToken();
          } catch (e) {
            throw('Error occurred while getting Firebase token: $e');
          }

          await _firestore.collection('users').doc(user.uid).set({
            'email': _email.text.trim(),
            'first_name': _firstName.text,
            'last_name': _lastName.text,
            'about' : 'Edit Profile to add your About Me!',
            'image_url': imageUrl, // Save the image URL to Firestore
            'image_low_url': imageLowUrl, // Save the low resolution image URL to Firestore
            'token' : token,
          });

          if (_switchValue) {
            final prefs = await SharedPreferences.getInstance();
            prefs.setBool('isLoggedIn', true);
          }

          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              CupertinoPageRoute(builder: (context) => const BottomNav()),
                  (route) => false,
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        String errorMessage, special;
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'email-already-in-use':
              errorMessage = 'The email address is already i use by another account.';
              special = 'Duplicate Account';
              break;
            case 'invalid-email':
              errorMessage = 'The email address is not valid.';
              special = 'Invalid Email';
              break;
            case 'operation-not-allowed':
              errorMessage = 'Email/password accounts are not enabled.';
              special = 'Inactive Account';
              break;
            case 'weak-password':
              errorMessage = 'The password is too weak.';
              special = 'Weak Password';
              break;
            default:
              errorMessage = e.message ?? 'An undefined error occurred.';
              special = 'Error';
          }
        } else {
          errorMessage = 'An undefined error occurred.';
          special = 'Error';
        }

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text(special),
              content: Text(errorMessage), // Show the error message to the user
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
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Error!'),
            content: const Text('Please fill in all required fields.'),
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
  }



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(left: AppLayout.getWidth(20), right: AppLayout.getWidth(20)),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.only(left: AppLayout.getWidth(10), top: AppLayout.getHeight(10)),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Color(0xFF09152D),
                              fontSize: 24,
                              fontFamily: 'Satoshi',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //const Gap(20),
                  Center(
                    child: CupertinoButton(
                      onPressed: getImage,
                      child: CircleAvatar(
                        radius: 75,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : null, // if image is picked then show this image else show the placeholder
                        child: _imageFile == null ? const Icon(CupertinoIcons.camera, size: 65, color: Color(0xFF677489)) : null,
                      ),
                    ),
                  ),
                  Center(
                    child: CupertinoButton(
                      onPressed: getImage,
                      child: const Text(
                        'Add Profile Picture',
                        style: TextStyle(
                          color: Color(0xFF09152D),
                          fontSize: 18,
                          fontFamily: 'Satoshi',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  CupertinoTextField(
                    controller: _firstName,
                    prefix: Padding(
                      padding: EdgeInsets.only(left: AppLayout.getWidth(20)),
                      child: const Icon(
                        CupertinoIcons.person_fill,
                        color: Color(0xFF677489),
                      ),
                    ),
                    placeholder: 'First Name',
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
                  const Gap(20),
                  CupertinoTextField(
                    controller: _lastName,
                    prefix: Padding(
                      padding: EdgeInsets.only(left: AppLayout.getWidth(20)),
                      child: const Icon(
                        CupertinoIcons.person_fill,
                        color: Color(0xFF677489),
                      ),
                    ),
                    placeholder: 'Last Name',
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
                  const Gap(20),
                  CupertinoTextField(
                    controller: _email,
                    prefix: Padding(
                      padding: EdgeInsets.only(left: AppLayout.getWidth(20)),
                      child: const Icon(
                        CupertinoIcons.mail_solid,
                        color: Color(0xFF677489),
                      ),
                    ),
                    placeholder: 'abc@uic.edu',
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
                  const Gap(20),
                  CupertinoTextField(
                    controller: _password,
                    obscureText: true,
                    prefix: Padding(
                      padding: EdgeInsets.only(left: AppLayout.getWidth(20)),
                      child: const Icon(
                        CupertinoIcons.lock_fill,
                        color: Color(0xFF677489),
                      ),
                    ),
                    placeholder: 'New Password',
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
                  const Gap(20),
                  CupertinoTextField(
                    controller: _confirmPassword,
                    obscureText: true,
                    prefix: Padding(
                      padding: EdgeInsets.only(left: AppLayout.getWidth(20)),
                      child: const Icon(
                        CupertinoIcons.check_mark,
                        color: Color(0xFF677489),
                      ),
                    ),
                    placeholder: 'Confirm Password',
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
                  const Gap(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
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
                    ],
                  ),
                  //const Gap(20),
                  CupertinoButton(
                    onPressed: () => signUp(),
                    child: Center(
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
                                'Sign Up',
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
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: "By Signing Up you agree to our ",
                        style: const TextStyle(
                          color: Color(0xFF09152D),
                          fontSize: 15,
                          fontFamily: 'Satoshi',
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(
                            text: "Privacy Policy",
                            style: const TextStyle(
                              color: Color(0xFF5668FF),
                              fontSize: 17,
                              fontFamily: 'Satoshi',
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                final Uri url = Uri.parse('https://www.communifyy.com/privacy-policy');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                } else {
                                  throw 'Could not launch $url';
                                }
                              },
                          ),
                          const TextSpan(
                            text: " and our",
                            style: TextStyle(
                              color: Color(0xFF09152D),
                              fontSize: 15,
                              fontFamily: 'Satoshi',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text: " Terms and Conditions",
                            style: const TextStyle(
                              color: Color(0xFF5668FF),
                              fontSize: 17,
                              fontFamily: 'Satoshi',
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                final Uri url = Uri.parse('https://www.communifyy.com/terms-and-conditions');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                } else {
                                  throw 'Could not launch $url';
                                }
                              },
                          ),

                        ],
                      ),
                    ),
                  ),
                  const Gap(10),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: "Already have an account? ",
                        style: const TextStyle(
                          color: Color(0xFF09152D),
                          fontSize: 15,
                          fontFamily: 'Satoshi',
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(
                            text: "Sign In",
                            style: const TextStyle(
                              color: Color(0xFF5668FF),
                              fontSize: 17,
                              fontFamily: 'Satoshi',
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.of(context).pushReplacementNamed('/');
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gap(AppLayout.getHeight(100))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
