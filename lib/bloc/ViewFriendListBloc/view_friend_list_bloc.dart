// FriendsBloc Events
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserFriend {
  final String id;
  final String imageUrl;
  final String firstName;
  final String lastName;

  UserFriend({
    required this.id,
    required this.imageUrl,
    required this.firstName,
    required this.lastName,
  });

  // Create an instance from Firestore document
  factory UserFriend.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserFriend(
      id: doc.id,
      firstName: data['first_name'] ?? '',
      lastName: data['last_name'] ?? '',
      imageUrl: data['image_low_url'] ?? '',
    );
  }
}


abstract class FriendsEvent {}

class LoadFriends extends FriendsEvent {}

class SearchFriends extends FriendsEvent {
  final String searchText;

  SearchFriends({required this.searchText});
}

// FriendsBloc States
abstract class FriendsState {}

class FriendsInitial extends FriendsState {}

class FriendsLoading extends FriendsState {}

class FriendsLoaded extends FriendsState {
  final List<UserFriend> friends;

  FriendsLoaded({required this.friends});
}

class FriendsError extends FriendsState {
  final String message;

  FriendsError({required this.message});
}

class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String _searchText = "";
  List<UserFriend> _allFriends = [];

  FriendsBloc() : super(FriendsLoading()) {
    on<LoadFriends>((event, emit) async {
      emit(FriendsLoading());
      try {
        _allFriends = await _fetchFriends();
        emit(FriendsLoaded(friends: _allFriends));
      } catch (e) {
        emit(FriendsError(message: e.toString()));
      }
    });

    on<SearchFriends>((event, emit) async {
      _searchText = event.searchText;
      emit(FriendsLoaded(friends: _filterFriends()));
    });
  }

  Future<List<UserFriend>> _fetchFriends() async {
    List<UserFriend> friends = [];

    // Assume the current user's uid is available somehow
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // Fetch the friends from Firestore
    QuerySnapshot friendsSnapshot = await firestore
        .collection('users')
        .doc(currentUserId)
        .collection('Friends')
        .get();

    for (var doc in friendsSnapshot.docs) {
      DocumentSnapshot userDoc = await firestore.collection('users').doc(doc.id).get();
      UserFriend friend = UserFriend.fromFirestore(userDoc);
      friends.add(friend);
    }

    return friends;
  }

  List<UserFriend> _filterFriends() {
    if (_searchText.isEmpty) {
      return _allFriends;
    } else {
      return _allFriends.where((friend) =>
          ("${friend.firstName} ${friend.lastName}").toLowerCase().contains(_searchText.toLowerCase())
      ).toList();
    }
  }
}

