import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'friend_event.dart';
import 'friend_model.dart';
import 'friend_state.dart';

class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  Set<String> sentRequests = <String>{};
  List<Friend> _allFriends = [];

  FriendsBloc(this.firestore, this.storage) : super(FriendsInitial()) {
    on<LoadFriends>(_onLoadFriends);
    on<SearchFriends>(_onSearchFriends);
    on<SendFriendRequest>(_onSendFriendRequest);
  }

  Future<void> _onLoadFriends(LoadFriends event, Emitter<FriendsState> emit) async {
    try {
      emit(FriendsLoading());
      _allFriends = await _fetchFriends();
      emit(FriendsLoaded(friends: _allFriends));
    } catch (e) {
      emit(FriendsError(message: e.toString()));
    }
  }

  Future<void> _onSearchFriends(SearchFriends event, Emitter<FriendsState> emit) async {
    try {
      emit(FriendsLoading());
      final results = _allFriends.where((friend) =>
          ("${friend.firstName} ${friend.lastName}").toLowerCase().contains(event.searchText.toLowerCase())
      ).toList();
      emit(FriendsSearchResults(friends: results));
    } catch (e) {
      emit(FriendsError(message: e.toString()));
    }
  }

  Future<void> _onSendFriendRequest(SendFriendRequest event, Emitter<FriendsState> emit) async {
    try {
      // Before sending the friend request, add the friendId to sentRequests and emit a new state.
      sentRequests.add(event.friendId);

      if (state is FriendsLoaded) {
        var loadedState = state as FriendsLoaded;
        var friends = loadedState.friends;
        friends.firstWhere((friend) => friend.id == event.friendId).isRequestPending = true;
        emit(FriendsLoaded(friends: friends));
      }
      else if (state is FriendsSearchResults) {
        var searchState = state as FriendsSearchResults;
        var friends = searchState.friends;
        friends.firstWhere((friend) => friend.id == event.friendId).isRequestPending = true;
        emit(FriendsSearchResults(friends: friends));
      }

      // Then send the friend request in the background.
      await _sendFriendRequest(event.friendId);
    } catch (e) {
      emit(FriendsError(message: e.toString()));
    }
  }

  Future<List<Friend>> _fetchFriends() async {
    QuerySnapshot snapshot = await firestore.collection('users').get();
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      // Filter out the currently logged in user
      List<Friend> friends = snapshot.docs
          .where((doc) => doc.id != firebaseUser.uid)
          .map((doc) => Friend.fromFirestore(doc))
          .toList();

      // Get the current user's friend requests and friends
      QuerySnapshot sentRequestsSnapshot = await firestore.collection('users').doc(firebaseUser.uid).collection('Friend Requests').get();
      QuerySnapshot friendsSnapshot = await firestore.collection('users').doc(firebaseUser.uid).collection('Friends').get();

      // Collect the IDs of all the users that the current user has sent a friend request to or are already friends
      List<String> filterIds = [];
      for (var doc in sentRequestsSnapshot.docs) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data?['Status'] == "Sent" || data?['Status'] == "Pending") {
          filterIds.add(doc.id);
        }
      }
      for (var doc in friendsSnapshot.docs) {
        filterIds.add(doc.id);
      }

      // Filter out users that the current user has sent a friend request to or are already friends
      friends.removeWhere((friend) => filterIds.contains(friend.id));
      await _updateFriends(friends, sentRequests.toList());
      return friends;
    } else {
      throw Exception("No current user found.");
    }
  }

  Future<void> _sendFriendRequest(String friendId) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      // Get current user's document
      DocumentSnapshot userDocument = await firestore.collection('users').doc(firebaseUser.uid).get();
      DocumentSnapshot receiverDocument = await firestore.collection('users').doc(friendId).get();

      // Get current user's name
      String senderFirstName = (userDocument.data() as Map<String, dynamic>)['first_name'] ?? "N/A";
      String senderLastName = (userDocument.data() as Map<String, dynamic>)['last_name'] ?? "N/A";
      String senderImageUrl = (userDocument.data() as Map<String, dynamic>)['image_low_url'] ?? "N/A";
      String receiverFirstName = (receiverDocument.data() as Map<String, dynamic>)['first_name'] ?? "N/A";
      String receiverLastName = (receiverDocument.data() as Map<String, dynamic>)['last_name'] ?? "N/A";
      String receiverImageUrl = (receiverDocument.data() as Map<String, dynamic>)['image_low_url'] ?? "N/A";

      // Current timestamp
      Timestamp sentAt = Timestamp.now();

      // Current user's ID
      String senderUserId = firebaseUser.uid;

      // Add friend request to sender's 'Friend Requests' subcollection
      await firestore.collection('users').doc(senderUserId).collection('Friend Requests').doc(friendId).set({
        'ReceiverFirstName' : receiverFirstName,
        'ReceiverLastName' : receiverLastName,
        'ReceiverUserId' : friendId,
        'ReceiverImageUrl' : receiverImageUrl,
        'SentAt' : sentAt,
        'Status' : "Sent"
      });

      // Add friend request to receiver's 'Friend Requests' subcollection
      await firestore.collection('users').doc(friendId).collection('Friend Requests').doc(senderUserId).set({
        'SenderFirstName' : senderFirstName,
        'SenderLastName' : senderLastName,
        'SenderUserId' : senderUserId,
        'SenderImageUrl' : senderImageUrl,
        'SentAt' : sentAt,
        'Status' : "Pending"
      });

    } else {
      throw Exception("No current user found.");
    }
  }

  Future<void> _updateFriends(List<Friend> friends, List<String> sentRequests) async {
    for (Friend friend in friends) {
      friend.isRequestPending = sentRequests.contains(friend.id);

      try {
        var friendCount = (await firestore.collection('users').doc(friend.id).collection('Friends').get()).size;
        friend.friendCount = friendCount;
      } catch (e) {
        friend.friendCount = 0;
      }
    }
  }

}