import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../../imageUtil.dart';
import 'edit_clubProfile_event.dart';
import 'edit_clubProfile_state.dart';
import 'package:path/path.dart' as path;

class EditClubProfileBloc extends Bloc<EditClubProfileEvent, EditClubProfileState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  EditClubProfileBloc() : super(EditProfileInitial()) {
    on<StartEditProfile>(_mapStartEditProfileToState);
  }

  void _mapStartEditProfileToState(StartEditProfile event, Emitter<EditClubProfileState> emit) async {
    emit(EditProfileLoading());

    String imageUrl = '';
    String imageLowUrl = '';

    try {
      if (event.imageFile != null) {
        TaskSnapshot taskSnapshot = await FirebaseStorage.instance
            .ref('club_images/${_auth.currentUser!.uid}.jpg')
            .putFile(event.imageFile!);

        final dir = await getTemporaryDirectory();

        final targetPath = path.join(dir.absolute.path, "${_auth.currentUser!.uid}_compressed.jpg");

        File compressedImage = await resizeAndCompressImage(event.imageFile!, targetPath);

        TaskSnapshot taskSnapshotLow = await FirebaseStorage.instance
            .ref('club_images_low/${_auth.currentUser!.uid}.jpg')
            .putFile(compressedImage);
        await FirebaseFirestore.instance.collection('clubs').doc(_auth.currentUser!.uid).update({
          'image_url': await taskSnapshot.ref.getDownloadURL(),
          'image_low_url': await taskSnapshotLow.ref.getDownloadURL(),
        });

      }

      await _firestore.collection('clubs').doc(_auth.currentUser!.uid).update({
        'about': event.about,
      });

      emit(EditProfileCompleted());
    } catch (e) {
      emit(EditProfileError());
    }
  }
}
