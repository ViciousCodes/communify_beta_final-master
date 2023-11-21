import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communify_beta_final/bloc/ViewFriendProfileBloc/view_friend_profile_event.dart';
import 'package:communify_beta_final/bloc/ViewFriendProfileBloc/view_friend_profile_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FriendProfileBloc extends Bloc<FriendProfileEvent, FriendProfileState> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DocumentSnapshot<Object?>? _loadedFriendProfile;

  FriendProfileBloc() : super(FriendProfileLoading()) {
    on<LoadFriendProfileData>(_mapLoadFriendProfileToState);
  }

  Future<int> getClubCount(LoadFriendProfileData event) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(event.friend.uid) // Assuming `uid` is a unique identifier for a friend
        .collection('Clubs')
        .get();
    return snapshot.size;
  }

  Future<int> getFriendCount(LoadFriendProfileData event) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(event.friend.uid) // Assuming `uid` is a unique identifier for a friend
        .collection('Friends')
        .get();
    return snapshot.size;
  }



  void _mapLoadFriendProfileToState(LoadFriendProfileData event, Emitter<FriendProfileState> emit) async {
    emit(FriendProfileLoading());

    try {
      // Fetch the latest profile from Firestore each time.
      _loadedFriendProfile = await _firestore.collection('users').doc(event.friend.uid).get();
      String imageUrl = (_loadedFriendProfile?.data() as Map<String, dynamic>)['image_url'] ?? '';
      final clubsCount = await getClubCount(event);
      final friendsCount = await getFriendCount(event);
      emit(FriendProfileLoaded(friendProfile: _loadedFriendProfile!, imageUrl: imageUrl,
        friendData: event.friend, clubsCount: clubsCount, friendsCount: friendsCount));
      // _startListeningToCounts();
    } catch (e) {
      emit(FriendProfileError());
    }
  }



  Future<void> addFriend(String friendUserId) async {
    final User currentUser = auth.currentUser!;

    // Get current user's document
    DocumentSnapshot userDocument =
    await _firestore.collection('users').doc(currentUser.uid).get();
    DocumentSnapshot receiverDocument =
    await _firestore.collection('users').doc(friendUserId).get();

    // Get current user's name and profile picture URL
    String senderFirstName = (userDocument.data() as Map<String, dynamic>)['first_name'] ?? "N/A";
    String senderLastName = (userDocument.data() as Map<String, dynamic>)['last_name'] ?? "N/A";
    String receiverFirstName = (receiverDocument.data() as Map<String, dynamic>)['first_name'] ?? "N/A";
    String receiverLastName = (receiverDocument.data() as Map<String, dynamic>)['last_name'] ?? "N/A";

    // Current timestamp
    Timestamp sentAt = Timestamp.now();

    // Current user's ID
    String senderUserId = currentUser.uid;

    await _firestore.collection('users').doc(friendUserId).collection('Friend Requests').doc(senderUserId).set({
      'SenderFirstName' : senderFirstName,
      'SenderLastName' : senderLastName,
      'SenderUserId' : senderUserId,
      'SentAt' : sentAt,
      'Status' : "Pending"
    });

    await _firestore.collection('users').doc(senderUserId).collection('Friend Requests').doc(friendUserId).set({
      'ReceiverFirstName' : receiverFirstName,
      'ReceiverFirstNameLastName' : receiverLastName,
      'ReceiverFirstNameUserId' : friendUserId,
      'SentAt' : sentAt,
      'Status' : "Sent"
    });
  }


}