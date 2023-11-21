// FriendsBloc Events
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Club {
  final String id;
  final String imageUrl;
  final String clubName;

  Club({
    required this.id,
    required this.imageUrl,
    required this.clubName,
  });

  // Create an instance from Firestore document
  factory Club.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Club(
      id: doc.id,
      clubName: data['club_name'] ?? '',
      imageUrl: data['image_low_url'] ?? '',
    );
  }
}

abstract class ClubsEvent {}

class LoadClubs extends ClubsEvent {}

class SearchClubs extends ClubsEvent {
  final String searchText;

  SearchClubs({required this.searchText});
}

// FriendsBloc States
abstract class ClubsState {}

class ClubsInitial extends ClubsState {}

class ClubsLoading extends ClubsState {}

class ClubsLoaded extends ClubsState {
  final List<Club> clubs;

  ClubsLoaded({required this.clubs});
}

class ClubsError extends ClubsState {
  final String message;

  ClubsError({required this.message});
}

class ClubsBloc extends Bloc<ClubsEvent, ClubsState> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String _searchText = "";
  List<Club> _allClubs = [];

  ClubsBloc() : super(ClubsLoading()) {
    on<LoadClubs>((event, emit) async {
      emit(ClubsLoading());
      try {
        _allClubs = await _fetchClubs();
        emit(ClubsLoaded(clubs: _allClubs));
      } catch (e) {
        emit(ClubsError(message: e.toString()));
      }
    });

    on<SearchClubs>((event, emit) async {
      _searchText = event.searchText;
      emit(ClubsLoaded(clubs: _filterClubs()));
    });
  }

  Future<List<Club>> _fetchClubs() async {
    List<Club> clubs = [];

    // Assume the current user's uid is available somehow
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // Fetch the friends from Firestore
    QuerySnapshot friendsSnapshot = await firestore
        .collection('users')
        .doc(currentUserId)
        .collection('Clubs')
        .get();

    for (var doc in friendsSnapshot.docs) {
      DocumentSnapshot userDoc = await firestore.collection('clubs').doc(doc.id).get();
      Club club = Club.fromFirestore(userDoc);
      clubs.add(club);
    }

    return clubs;
  }

  List<Club> _filterClubs() {
    if (_searchText.isEmpty) {
      return _allClubs;
    } else {
      return _allClubs.where((club) =>
          ("${club.clubName} ").toLowerCase().contains(_searchText.toLowerCase())
      ).toList();
    }
  }
}

