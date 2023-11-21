import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../../imageUtil.dart';
import 'editProfile_event.dart';
import 'editProfile_state.dart';
import 'package:path/path.dart' as path;

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  EditProfileBloc() : super(EditProfileInitial()) {
    on<StartEditProfile>(_mapStartEditProfileToState);
  }

  void _mapStartEditProfileToState(StartEditProfile event, Emitter<EditProfileState> emit) async {
    emit(EditProfileLoading());

    try {
      if (event.imageFile != null) {
        TaskSnapshot taskSnapshot = await FirebaseStorage.instance
            .ref('user_images/${_auth.currentUser!.uid}.jpg')
            .putFile(event.imageFile!);

        final dir = await getTemporaryDirectory();

        final targetPath = path.join(dir.absolute.path, "${_auth.currentUser!.uid}_compressed.jpg");

        File compressedImage = await resizeAndCompressImage(event.imageFile!, targetPath);

        TaskSnapshot taskSnapshotLow = await FirebaseStorage.instance
            .ref('user_images_low/${_auth.currentUser!.uid}.jpg')
            .putFile(compressedImage);

        await FirebaseFirestore.instance.collection('users').doc(_auth.currentUser!.uid).update({
          'image_url': await taskSnapshot.ref.getDownloadURL(),
          'image_low_url': await taskSnapshotLow.ref.getDownloadURL(),
        });
      }

      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'email': event.email,
        'first_name': event.firstName,
        'last_name': event.lastName,
        'about': event.about,
      });

      emit(EditProfileCompleted());
    } catch (e) {
      emit(EditProfileError());
    }
  }
}
