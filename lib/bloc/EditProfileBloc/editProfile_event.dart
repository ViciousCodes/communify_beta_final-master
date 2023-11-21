import 'dart:io';

abstract class EditProfileEvent {}

class StartEditProfile extends EditProfileEvent {
  final String email;
  final String firstName;
  final String lastName;
  final String about;
  final File? imageFile;

  StartEditProfile({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.about,
    this.imageFile,
  });
}
