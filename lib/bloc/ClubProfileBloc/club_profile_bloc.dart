import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communify_beta_final/bloc/ClubProfileBloc/club_profile_event.dart';
import 'package:communify_beta_final/bloc/ClubProfileBloc/club_profile_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClubProfileBloc extends Bloc<ClubProfileEvent, ClubProfileState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DocumentSnapshot<Object?>? _loadedProfile;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _membersSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _eventsSubscription;

  ClubProfileBloc() : super(ProfileLoading()) {
    on<LoadProfile>(_mapLoadProfileToState);
    on<UpdateMembersCount>(_mapUpdateMembersCountToState);
    on<UpdateEventsCount>(_mapUpdateEventsCountToState);
    on<UnloadProfile>(_mapUnloadProfileToState);
  }

  void _startListeningToCounts() {
    _membersSubscription = _firestore
        .collection('clubs')
        .doc(_auth.currentUser!.uid)
        .collection('Members')
        .snapshots()
        .listen((snapshot) {
      if(!isClosed){
        add(UpdateMembersCount(snapshot.size));
      }
    });

    _eventsSubscription = _firestore
        .collection('events')
        .where('organizerId', isEqualTo: _auth.currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
      if(!isClosed){
        add(UpdateEventsCount(snapshot.size));
      }
    });
  }



  Future<void> _mapUnloadProfileToState(UnloadProfile event, Emitter<ClubProfileState> emit) async {
    await _membersSubscription?.cancel();
    await _eventsSubscription?.cancel();
    _loadedProfile = null;
    _membersSubscription = null;
    _eventsSubscription = null;
  }

  void _mapUpdateMembersCountToState(UpdateMembersCount event, Emitter<ClubProfileState> emit) {
    if (state is ProfileLoaded) {
      final loadedState = state as ProfileLoaded;
      emit(
        loadedState.copyWith(
          membersCount: event.count,
        ),
      );
    }
  }

  void _mapUpdateEventsCountToState(UpdateEventsCount event, Emitter<ClubProfileState> emit) {
    if (state is ProfileLoaded) {
      final loadedState = state as ProfileLoaded;
      emit(
        loadedState.copyWith(
          eventsCount: event.count,
        ),
      );
    }
  }

  void _mapLoadProfileToState(LoadProfile event, Emitter<ClubProfileState> emit) async {
    emit(ProfileLoading());

    try {
      // Fetch the latest profile from Firestore each time.
      _loadedProfile = await _firestore.collection('clubs').doc(_auth.currentUser!.uid).get();

      final imageUrl = (_loadedProfile!.data() as Map<String, dynamic>)['image_url'] ?? '';

      emit(ProfileLoaded(profile: _loadedProfile!, imageUrl: imageUrl));
      _startListeningToCounts();
    } catch (e) {
      emit(ProfileError());
    }
  }
}

