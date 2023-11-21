import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app_layout.dart';
import '../../bottom_nav.dart';
import '../../bottom_nav_club.dart';
import '../../imageUtil.dart';
import '../email_verification_screen.dart';
import '../login_screen.dart';

class ClubSignUpScreen extends StatefulWidget {
  const ClubSignUpScreen({Key? key}) : super(key: key);

  @override
  ClubSignUpScreenState createState() => ClubSignUpScreenState();
}

class ClubSignUpScreenState extends State<ClubSignUpScreen> {
  late TextEditingController _email;
  late TextEditingController _password;
  late TextEditingController _clubName;
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
    _confirmPassword = TextEditingController();
    _clubName = TextEditingController();

  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _clubName.dispose();
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

  Future<bool> showCodeDialog(BuildContext context) async {
    final TextEditingController codeController = TextEditingController();
    bool authenticated = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Code Authentication'),
          content: CupertinoTextField(
            keyboardType: TextInputType.number,
            controller: codeController,
            placeholder: "Enter 4 Digit Code",
            maxLength: 4,
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Authenticate'),
              onPressed: () {
                if (codeController.text == "0831") {
                  authenticated = true;
                  Navigator.of(context).pop();
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: const Text('Authentication Error'),
                        content: const Text('Authentication failed. Incorrect code.'),
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
              },
            ),
          ],
        );
      },
    );
    return authenticated;
  }

  signUp() async {
    if (_email.text.isEmpty ||
        _password.text.isEmpty ||
        _clubName.text.isEmpty || _confirmPassword.text.isEmpty) {
      if (context.mounted) {
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
      }
      return;
    }

    if (_password.text.contains(' ')) {
      if (context.mounted) {
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
      }
      return;
    }

    _clubName.text = _clubName.text.trim();
    if ((_clubName.text.length > 100)) {
      if (context.mounted) {
        showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Club Name Error'),
            content: const Text('Club name has more than 100 characters'),
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
      return;
    }
    _clubName.text = _clubName.text[0].toUpperCase() + _clubName.text.substring(1);


    if (_formKey.currentState!.validate()) {
      if (_password.text != _confirmPassword.text) { // NEW
        if (context.mounted) {
          showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text('Error'),
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
        }
        return;
      }

      bool isCodeValid = await showCodeDialog(context);
      // Check if the code is valid before proceeding
      if (!isCodeValid) {
        return;
      }

      if (context.mounted) {
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
      }
      try {
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text.trim(),
        );

        if (userCredential.user != null) {
          User user = userCredential.user!;
          await user.updateDisplayName(_clubName.text);

          String imageUrl = '';
          String imageLowUrl = '';

          if (_imageFile != null) {
            final Reference storageReference = FirebaseStorage.instance.ref().child('club_images').child('${user.uid}.jpg');
            final Reference storageReferenceLow = FirebaseStorage.instance.ref().child('club_images_low').child('${user.uid}.jpg');

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

          await _firestore.collection('clubs').doc(user.uid).set({
            'email': _email.text.trim(),
            'club_name': _clubName.text,
            'about' : 'Edit Profile to add your About Me!',
            'image_url': imageUrl, // Save the image URL to Firestore
            'image_low_url': imageLowUrl, // Save the low resolution image URL to Firestore
          });

          if (_switchValue) {
            final prefs = await SharedPreferences.getInstance();
            prefs.setBool('isLoggedIn', true);
            prefs.setBool('isClub', true);
          }

          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              CupertinoPageRoute(builder: (context) => const BottomNavClub()),
                  (route) => false,
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
        if (context.mounted) {
          showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text('Error'),
              content: Text(e.toString()), // Show the error message to the user
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
    } else {
      if (context.mounted) {
        showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Error'),
            content: const Text('Please fill in all required fields'),
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
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.only(left: AppLayout.getWidth(20), right: AppLayout.getWidth(20)),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.only(left: AppLayout.getWidth(10), top: AppLayout.getHeight(20)),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Club Sign Up',
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
                  const Gap(20),
                  Center(
                    child: CircleAvatar(
                      radius: 75,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : null, // if image is picked then show this image else show the placeholder
                      child: _imageFile == null ? const Icon(CupertinoIcons.camera, size: 65, color: Color(0xFF677489)) : null,
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
                    controller: _clubName,
                    prefix: Padding(
                      padding: EdgeInsets.only(left: AppLayout.getWidth(20)),
                      child: const Icon(
                        CupertinoIcons.building_2_fill,
                        color: Color(0xFF677489),
                      ),
                    ),
                    placeholder: 'Club Name',
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
                    placeholder: 'clubMail@email.com',
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
                  const Gap(20),
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
                                Navigator.of(context).pushAndRemoveUntil(
                                    CupertinoPageRoute(builder: (context) => const LoginScreen()),
                                        (route) => false
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
