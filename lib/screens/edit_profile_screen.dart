import 'dart:async';

import 'package:communify_beta_final/bloc/ProfileBloc/profile_bloc.dart';
import 'package:communify_beta_final/bloc/ProfileBloc/profile_state.dart';
import 'package:communify_beta_final/bloc/ProfileBloc/profile_event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../app_layout.dart';
import '../bloc/EditProfileBloc/editProfile_bloc.dart';
import '../bloc/EditProfileBloc/editProfile_event.dart';
import '../bloc/EditProfileBloc/editProfile_state.dart';


class EditProfileScreen extends StatefulWidget {
  final ProfileBloc profileBloc;

  const EditProfileScreen({Key? key, required this.profileBloc}) : super(key: key);

  @override
  EditProfileScreenState createState() => EditProfileScreenState(profileBloc: profileBloc);
}

class EditProfileScreenState extends State<EditProfileScreen> {
  late EditProfileBloc _editProfileBloc;
  late final ProfileBloc profileBloc;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  File? _imageFile;

  EditProfileScreenState({required this.profileBloc});


  @override
  void initState() {
    super.initState();
    _editProfileBloc = EditProfileBloc();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _aboutController.dispose();
    _editProfileBloc.close();
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
      _editProfileBloc.add(
        StartEditProfile(
          email: _emailController.text,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          about: _aboutController.text,
          imageFile: _imageFile,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EditProfileBloc>.value(
      value: _editProfileBloc,  // Using already created instance
      child: BlocBuilder<ProfileBloc, ProfileState>(
        bloc: profileBloc,
        builder: (context, state) {
          if (state is ProfileLoaded) {
            _emailController.text = state.profile.get('email');
            _firstNameController.text = state.profile.get('first_name');
            _lastNameController.text = state.profile.get('last_name');
            _aboutController.text = state.profile.get('about');

            return EditProfileView(
              formKey: _formKey,
              emailController: _emailController,
              firstNameController: _firstNameController,
              lastNameController: _lastNameController,
              aboutController: _aboutController,
              imageFile: _imageFile,
              saveProfile: saveProfile,
              pickImage: pickImage,
              profileBloc: profileBloc,
            );
          }
          if (state is ProfileLoading) {
            return const Center(child: CupertinoActivityIndicator(color: Color(0xFF09152D)));  // Show a loading indicator
          }
          return const Text("An unexpected state occurred");
        },
      ),
    );
  }
}

// The rest of your code remains the same...


class EditProfileView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController aboutController;
  final File? imageFile;
  final Function saveProfile;
  final Function pickImage;
  final ProfileBloc profileBloc;

  const EditProfileView({super.key,
    required this.formKey,
    required this.emailController,
    required this.firstNameController,
    required this.lastNameController,
    required this.aboutController,
    required this.imageFile,
    required this.saveProfile,
    required this.pickImage,
    required this.profileBloc,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<EditProfileBloc, EditProfileState>(
        listener: (context, state) {
          if (state is EditProfileCompleted) {
            Navigator.of(context).pop();
            profileBloc.add(LoadProfile());
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
              firstNameController: firstNameController,
              lastNameController: lastNameController,
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
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController aboutController;
  final File? imageFile;
  final Function saveProfile;
  final Function pickImage;

  const ProfileForm({super.key,
    required this.formKey,
    required this.emailController,
    required this.firstNameController,
    required this.lastNameController,
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
                            'Edit Profile',
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
                    controller: firstNameController,
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
                    controller: lastNameController,
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