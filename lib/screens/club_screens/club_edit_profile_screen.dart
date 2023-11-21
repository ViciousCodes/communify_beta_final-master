import 'dart:async';

import 'package:communify_beta_final/app_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:communify_beta_final/bloc/ClubProfileBloc/club_profile_bloc.dart';
import 'package:communify_beta_final/bloc/ClubProfileBloc/club_profile_event.dart';
import 'package:communify_beta_final/bloc/ClubProfileBloc/club_profile_state.dart';

import 'package:communify_beta_final/bloc/EditClubProfileBloc/edit_clubProfile_bloc.dart';
import 'package:communify_beta_final/bloc/EditClubProfileBloc/edit_clubProfile_state.dart';
import 'package:communify_beta_final/bloc/EditClubProfileBloc/edit_clubProfile_event.dart';


class ClubEditProfileScreen extends StatefulWidget {
  final ClubProfileBloc clubProfileBloc;

  const ClubEditProfileScreen({Key? key, required this.clubProfileBloc}) : super(key: key);

  @override
  ClubEditProfileScreenState createState() => ClubEditProfileScreenState(clubProfileBloc: clubProfileBloc);
}

class ClubEditProfileScreenState extends State<ClubEditProfileScreen> {
  late EditClubProfileBloc _clubEditProfileBloc;
  late final ClubProfileBloc clubProfileBloc;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _clubNameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  File? _imageFile;

  ClubEditProfileScreenState({required this.clubProfileBloc});


  @override
  void initState() {
    super.initState();
    _clubEditProfileBloc = EditClubProfileBloc();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _clubNameController.dispose();
    _aboutController.dispose();
    _clubEditProfileBloc.close();
    super.dispose();
  }

  Future<void> pickImage() async {
    final XFile? selectedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      setState(() {
        _imageFile = File(selectedImage.path);
      });
    }
  }

  void saveProfile() {
    if (_formKey.currentState!.validate()) {
      _clubEditProfileBloc.add(
        StartEditProfile(
          email: _emailController.text,
          clubName: _clubNameController.text,
          about: _aboutController.text,
          imageFile: _imageFile,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EditClubProfileBloc>.value(
      value: _clubEditProfileBloc,  // Using already created instance
      child: BlocBuilder<ClubProfileBloc, ClubProfileState>(
        bloc: clubProfileBloc,
        builder: (context, state) {
          if (state is ProfileLoaded) {
            _emailController.text = state.profile.get('email');
            _clubNameController.text = state.profile.get('club_name');
            _aboutController.text = state.profile.get('about');

            return ClubEditProfileView(
              formKey: _formKey,
              emailController: _emailController,
              clubNameController: _clubNameController,
              aboutController: _aboutController,
              imageFile: _imageFile,
              saveProfile: saveProfile,
              pickImage: pickImage,
              clubProfileBloc: clubProfileBloc,
            );
          }
          if (state is ProfileLoading) {
            return const Center(child: CupertinoActivityIndicator(color: Color(0xFF09152D)));// Show a loading indicator
          }
          return const Text("An unexpected state occurred");
        },
      ),
    );
  }
}

// The rest of your code remains the same...


class ClubEditProfileView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController clubNameController;
  final TextEditingController aboutController;
  final File? imageFile;
  final Function saveProfile;
  final Function pickImage;
  final ClubProfileBloc clubProfileBloc;

  const ClubEditProfileView({super.key,
    required this.formKey,
    required this.emailController,
    required this.clubNameController,
    required this.aboutController,
    required this.imageFile,
    required this.saveProfile,
    required this.pickImage,
    required this.clubProfileBloc,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<EditClubProfileBloc, EditClubProfileState>(
        listener: (context, state) {
          if (state is EditProfileCompleted) {
            Navigator.of(context).pop();
            clubProfileBloc.add(LoadProfile());
          } else if (state is EditProfileError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Error updating profile.')));
          }
        },
        builder: (context, state) {
          if (state is EditProfileLoading) {
            return const Center(child: CupertinoActivityIndicator(color: Color(0xFF09152D)));
          } else {
            return ProfileForm(
              formKey: formKey,
              emailController: emailController,
              clubNameController: clubNameController,
              aboutController: aboutController,
              imageFile: imageFile,
              saveProfile: saveProfile,
              pickImage: pickImage,
            );
          }
        },
      ),
    );
  }
}

class ProfileForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController clubNameController;
  final TextEditingController aboutController;
  final File? imageFile;
  final Function saveProfile;
  final Function pickImage;

  const ProfileForm({super.key,
    required this.formKey,
    required this.emailController,
    required this.clubNameController,
    required this.aboutController,
    this.imageFile,
    required this.saveProfile,
    required this.pickImage,
  });

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
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.only(top: AppLayout.getHeight(10)),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          BackButton(color: Color(0xFF09152D)),
                          Text(
                            'Edit Club Profile',
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
                    child: CupertinoButton(
                      onPressed: () {
                        pickImage();
                      },
                    child: CircleAvatar(
                      radius: 75,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: imageFile != null
                          ? FileImage(imageFile!)
                          : null, // if image is picked then show this image else show the placeholder
                      child: imageFile == null ? const Icon(CupertinoIcons.camera, size: 60, color: Color(0xFF677489)) : null,
                    ),
                  ),
                  ),
                  Center(
                    child: CupertinoButton(
                      onPressed: () {
                        pickImage();
                      },
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
                    controller: clubNameController,
                    readOnly: true,
                    prefix: Padding(
                      padding: EdgeInsets.only(left: AppLayout.getWidth(20)),
                      child: const Icon(
                        CupertinoIcons.person_fill,
                        color: Color(0xFF677489),
                      ),
                    ),
                    style: const TextStyle(
                      color: Color(0xFF677489),
                      fontSize: 18,
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      border: Border.all(width: 1, color: const Color(0xFF677489)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.only(left: AppLayout.getWidth(10), top: AppLayout.getHeight(12), bottom: AppLayout.getHeight(12)),
                  ),
                  const Gap(20),
                  CupertinoTextField(
                    controller: emailController,
                    readOnly: true,
                    prefix: Padding(
                      padding: EdgeInsets.only(left: AppLayout.getWidth(20)),
                      child: const Icon(
                        CupertinoIcons.mail_solid,
                        color: Color(0xFF677489),
                      ),
                    ),
                    style: const TextStyle(
                      color: Color(0xFF677489),
                      fontSize: 18,
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      border: Border.all(width: 1, color: const Color(0xFF677489)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.only(left: AppLayout.getWidth(10), top: AppLayout.getHeight(12), bottom: AppLayout.getHeight(12)),
                  ),
                  const Gap(20),
                  CupertinoTextField(
                    controller: aboutController,
                    maxLines: 3,
                    prefix: Padding(
                      padding: EdgeInsets.only(left: AppLayout.getWidth(20)),
                      child: const Icon(
                        Icons.abc_outlined,
                        color: Color(0xFF677489),
                      ),
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
                  CupertinoButton(
                    onPressed: () {
                      saveProfile();
                    },
                    child: Center(
                      child: Container(
                        width: AppLayout.getWidth(150), // Adjust the width as desired
                        height: AppLayout.getHeight(50), // Adjust the height as desired
                        decoration: BoxDecoration(
                          color: const Color(0xFF09152D),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Stack(
                          children: [
                            Center(
                              child: Text(
                                'Save',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}