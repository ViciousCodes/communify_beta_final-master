import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communify_beta_final/bloc/ProfileBloc/profile_event.dart';
import 'package:communify_beta_final/bloc/ProfileBloc/profile_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DocumentSnapshot<Object?>? _loadedProfile;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _friendsSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _clubsSubscription;

  ProfileBloc() : super(ProfileLoading()) {
    on<LoadProfile>(_mapLoadProfileToState);
    on<UpdateFriendsCount>(_mapUpdateFriendsCountToState);
    on<UpdateClubsCount>(_mapUpdateClubsCountToState);
    on<UnloadProfile>(_mapUnloadProfileToState);
  }

  void _startListeningToCounts() {
    _friendsSubscription = _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('Friends')
        .snapshots()
        .listen((snapshot) {
      if(!isClosed){
        add(UpdateFriendsCount(snapshot.size));
      }
    });

    _clubsSubscription = _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('Clubs')
        .snapshots()
        .listen((snapshot) {
      if(!isClosed){
        add(UpdateClubsCount(snapshot.size));
      }
    });
  }


  Future<void> _mapUnloadProfileToState(UnloadProfile event, Emitter<ProfileState> emit) async {
    await _friendsSubscription?.cancel();
    await _clubsSubscription?.cancel();
    _loadedProfile = null;
    _friendsSubscription = null;
    _clubsSubscription = null;
  }

  void _mapUpdateClubsCountToState(UpdateClubsCount event, Emitter<ProfileState> emit) {
    if (state is ProfileLoaded) {
      final loadedState = state as ProfileLoaded;
      emit(
        loadedState.copyWith(
          clubsCount: event.count,
        ),
      );
    }
  }

  void _mapUpdateFriendsCountToState(UpdateFriendsCount event, Emitter<ProfileState> emit) {
    if (state is ProfileLoaded) {
      final loadedState = state as ProfileLoaded;
      emit(
        loadedState.copyWith(
          friendsCount: event.count,
        ),
      );
    }
  }

  void _mapLoadProfileToState(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());

    try {
      // Fetch the latest profile from Firestore each time.
      _loadedProfile = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();

      final imageUrl = (_loadedProfile!.data() as Map<String, dynamic>)['image_url'] ?? '';

      emit(ProfileLoaded(profile: _loadedProfile!, imageUrl: imageUrl));
      _startListeningToCounts();
    } catch (e) {
      emit(ProfileError());
    }
  }

}

