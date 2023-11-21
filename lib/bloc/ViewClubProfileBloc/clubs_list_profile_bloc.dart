import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ClubListProfileEvent {}

class FetchClubProfile extends ClubListProfileEvent {
  final String clubUid;

  FetchClubProfile({required this.clubUid});
}

abstract class ClubListProfileState {}

class ProfileInitial extends ClubListProfileState {}

class ProfileLoading extends ClubListProfileState {}

class ProfileLoaded extends ClubListProfileState {
  final DocumentSnapshot clubProfile;
  final String imageUrl;
  final int membersCount;
  final int eventsCount;

  ProfileLoaded({required this.clubProfile, required this.imageUrl, required this.membersCount, required this.eventsCount});
}

class ProfileError extends ClubListProfileState {
  final String error;

  ProfileError({required this.error});
}

class ClubsListProfileBloc extends Bloc<ClubListProfileEvent, ClubListProfileState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ClubsListProfileBloc() : super(ProfileInitial()) {
    on<FetchClubProfile>(_onFetchClubProfile);
  }

  Future<void> _onFetchClubProfile(FetchClubProfile event, Emitter<ClubListProfileState> emit) async {
    emit(ProfileLoading());

    try {
      DocumentSnapshot profileDoc = await _firestore.collection('clubs').doc(event.clubUid).get();
      String imageUrl = (profileDoc.data() as Map<String, dynamic>)['image_url'] ?? '';

      QuerySnapshot membersSnap = await _firestore.collection('clubs').doc(event.clubUid).collection('Members').get();
      QuerySnapshot eventsSnap = await _firestore.collection('events').where('organizerId', isEqualTo: event.clubUid).get();
      emit(ProfileLoaded(
          clubProfile: profileDoc,
          imageUrl: imageUrl,
          membersCount: membersSnap.size,
          eventsCount: eventsSnap.size
      ));
    } catch (e) {
      emit(ProfileError(error: e.toString()));
    }
  }
}


