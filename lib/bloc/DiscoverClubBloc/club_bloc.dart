import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'club_event.dart';
import 'club_model.dart';
import 'club_state.dart';

class ClubBloc extends Bloc<ClubEvent, ClubState> {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  Set<String> sentMembershipRequests = <String>{};
  List<Club> _allClubs = [];

  ClubBloc(this.firestore, this.storage) : super(ClubsInitial()) {
    on<LoadClubs>(_onLoadClubs);
    on<SearchClubs>(_onSearchClubs);
    on<AddMemberToClub>(_onAddMemberToClub);
  }

  Future<void> _onLoadClubs(LoadClubs event, Emitter<ClubState> emit) async {
    try {
      emit(ClubsLoading());
      _allClubs = await _fetchClubs();
      emit(ClubsLoaded(clubs: _allClubs));
    } catch (e) {
      emit(ClubsError(message: e.toString()));
    }
  }

  Future<void> _onSearchClubs(SearchClubs event, Emitter<ClubState> emit) async {
    final searchTerm = event.searchTerm;
    final searchResults = _allClubs.where((club) => club.clubName.toLowerCase().startsWith(searchTerm.toLowerCase())).toList();
    emit(ClubsSearchResults(clubs: searchResults));
  }

  Future<void> _onAddMemberToClub(AddMemberToClub event, Emitter<ClubState> emit) async {
    try {
      sentMembershipRequests.add(event.clubId);

      if (state is ClubsLoaded) {
        var loadedState = state as ClubsLoaded;
        var clubs = loadedState.clubs;
        clubs.firstWhere((club) => club.id == event.clubId).isMembershipPending = true;
        emit(ClubsLoaded(clubs: clubs));
      }
      else if (state is ClubsSearchResults) {
        var searchState = state as ClubsSearchResults;
        var clubs = searchState.clubs;
        clubs.firstWhere((club) => club.id == event.clubId).isMembershipPending = true;
        emit(ClubsSearchResults(clubs: clubs));
      }

      await _addMemberToClub(event.clubId);
    } catch (e) {
      emit(ClubsError(message: e.toString()));
    }
  }


  Future<List<Club>> _fetchClubs() async {
    QuerySnapshot snapshot = await firestore.collection('clubs').get();
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      // Fetch all clubs
      List<Club> clubs = snapshot.docs
          .where((doc) => doc.id != firebaseUser.uid)
          .map((doc) => Club.fromFirestore(doc))
          .toList();

      // Fetch club images and member counts from Firebase Storage and Firestore respectively
      for (var club in clubs) {
        // Fetch members count
        try {
          QuerySnapshot memberSnapshot = await firestore.collection('clubs').doc(club.id).collection('Members').get();
          club.memberCount = memberSnapshot.docs.length;
        } catch(e) {
          // Handle any errors during member count fetch
          print('Failed to fetch member count for club ${club.id}: $e');
        }
      }

      // Get the current user's clubs
      QuerySnapshot userClubsSnapshot = await firestore.collection('users').doc(firebaseUser.uid).collection('Clubs').get();
      // Collect the IDs of all the clubs that the current user is a member of
      List<String> userClubIds = userClubsSnapshot.docs.map((doc) => doc.id).toList();

      // Get the current user's blocked clubs
      DocumentSnapshot userDoc = await firestore.collection('users').doc(firebaseUser.uid).get();
      List<String> blockedClubs = List<String>.from((userDoc.data() as Map<String, dynamic>)['blockedClubs'] ?? []);

      // Filter out clubs that the current user is already a member of and clubs that are blocked by the user
      clubs.removeWhere((club) => userClubIds.contains(club.id) || blockedClubs.contains(club.id));

      return clubs;
    } else {
      throw Exception("No current user found.");
    }
  }


  Future<void> _addMemberToClub(String clubId) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      DocumentSnapshot userDocument;
      DocumentSnapshot clubDocument;

      try {
        userDocument = await firestore.collection('users').doc(firebaseUser.uid).get();
        clubDocument = await firestore.collection('clubs').doc(clubId).get();
      } catch (e) {
        print('Failed to fetch user or club document: $e');
        throw Exception('Failed to fetch user or club document');
      }

      if (!userDocument.exists) {
        throw Exception('User document does not exist');
      }

      if (!clubDocument.exists) {
        throw Exception('Club document does not exist');
      }

      String memberFirstName = (userDocument.data() as Map<String, dynamic>)['first_name'] ?? "N/A";
      String memberLastName = (userDocument.data() as Map<String, dynamic>)['last_name'] ?? "N/A";

      String clubName = (clubDocument.data() as Map<String, dynamic>)['club_name'] ?? "N/A";

      try {
        await firestore.collection('clubs').doc(clubId).collection('Members').doc(firebaseUser.uid).set({
          'memberFirstName' : memberFirstName,
          'memberLastName' : memberLastName,
          'memberId' : firebaseUser.uid,
          'memberSince' : Timestamp.now(),
        });

        await firestore.collection('users').doc(firebaseUser.uid).collection('Clubs').doc(clubId).set({
          'clubName' : clubName,
          'clubId' : clubId,
          'memberSince' : Timestamp.now(),
        });
      } catch (e) {
        print('Failed to add member to club or add club to user: $e');
        throw Exception('Failed to add member to club or add club to user');
      }
    } else {
      throw Exception("No current user found.");
    }
  }


}
