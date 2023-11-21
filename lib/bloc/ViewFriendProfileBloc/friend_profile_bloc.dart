import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FriendProfileEvent {}

class FetchFriendProfile extends FriendProfileEvent {
  final String friendUid;

  FetchFriendProfile({required this.friendUid});
}

abstract class FriendProfileState {}

class ProfileInitial extends FriendProfileState {}

class ProfileLoading extends FriendProfileState {}

class ProfileLoaded extends FriendProfileState {
  final DocumentSnapshot friendProfile;
  final String imageUrl;
  final int friendsCount;
  final int clubsCount;

  ProfileLoaded({required this.friendProfile, required this.imageUrl, required this.friendsCount, required this.clubsCount});
}

class ProfileError extends FriendProfileState {
  final String error;

  ProfileError({required this.error});
}

class FriendProfileBloc extends Bloc<FriendProfileEvent, FriendProfileState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FriendProfileBloc() : super(ProfileInitial()) {
    on<FetchFriendProfile>(_onFetchFriendProfile);
  }

  Future<void> _onFetchFriendProfile(FetchFriendProfile event, Emitter<FriendProfileState> emit) async {
    emit(ProfileLoading());

    try {
      DocumentSnapshot profileDoc = await _firestore.collection('users').doc(event.friendUid).get();
      String imageUrl = (profileDoc.data() as Map<String, dynamic>)['image_url'] ?? '';

      QuerySnapshot friendsSnap = await _firestore.collection('users').doc(event.friendUid).collection('Friends').get();
      QuerySnapshot clubsSnap = await _firestore.collection('users').doc(event.friendUid).collection('Clubs').get();

      emit(ProfileLoaded(
          friendProfile: profileDoc,
          imageUrl: imageUrl,
          friendsCount: friendsSnap.size,
          clubsCount: clubsSnap.size
      ));
    } catch (e) {
      emit(ProfileError(error: e.toString()));
    }
  }
}


