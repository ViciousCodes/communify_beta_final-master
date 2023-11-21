import 'dart:io';

abstract class EditClubProfileEvent {}

class StartEditProfile extends EditClubProfileEvent {
  final String email;
  final String clubName;
  final String about;
  final File? imageFile;

  StartEditProfile({
    required this.email,
    required this.clubName,
    required this.about,
    this.imageFile,
  });
}
