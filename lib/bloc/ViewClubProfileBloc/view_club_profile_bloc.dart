import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communify_beta_final/bloc/ViewClubProfileBloc/view_club_profile_event.dart';
import 'package:communify_beta_final/bloc/ViewClubProfileBloc/view_club_profile_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewClubProfileBloc extends Bloc<ViewClubProfileEvent, ViewClubProfileState> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DocumentSnapshot<Object?>? _loadedClubProfile;

  ViewClubProfileBloc() : super(ViewClubProfileLoading()) {
    on<LoadClubProfileData>(_mapLoadFriendProfileToState);
  }

  Future<int> getMembersCount(LoadClubProfileData event) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('clubs')
        .doc(event.club.uid) // Assuming `uid` is a unique identifier for a friend
        .collection('Members')
        .get();
    return snapshot.size;
  }

  Future<int> getEventsCount(LoadClubProfileData event) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('organizerId', isEqualTo: event.club.uid)
        .get();
    return snapshot.size;
  }

  void _mapLoadFriendProfileToState(LoadClubProfileData event, Emitter<ViewClubProfileState> emit) async {
    emit(ViewClubProfileLoading());

    try {
      // Fetch the latest profile from Firestore each time.
      _loadedClubProfile = await _firestore.collection('clubs').doc(event.club.uid).get();
      String imageUrl = (_loadedClubProfile?.data() as Map<String, dynamic>)['image_url'] ?? '';
      final membersCount = await getMembersCount(event);
      final eventsCount = await getEventsCount(event);
      emit(ViewClubProfileLoaded(clubProfile: _loadedClubProfile!, imageUrl: imageUrl,
          clubData: event.club, membersCount: membersCount, eventsCount: eventsCount));
      // _startListeningToCounts();
    } catch (e) {
      emit(ViewClubProfileError());
    }
  }
}