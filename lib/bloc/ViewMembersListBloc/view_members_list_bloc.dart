// FriendsBloc Events
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communify_beta_final/bloc/ViewFriendListBloc/view_friend_list_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


abstract class ViewMembersEvent {}

class LoadMembers extends ViewMembersEvent {}

class SearchMembers extends ViewMembersEvent {
  final String searchText;

  SearchMembers({required this.searchText});
}

// FriendsBloc States
abstract class ViewMembersState {}

class MembersInitial extends ViewMembersState {}

class MembersLoading extends ViewMembersState {}

class MembersLoaded extends ViewMembersState {
  final List<UserFriend> members;

  MembersLoaded({required this.members});
}

class MembersError extends ViewMembersState {
  final String message;

  MembersError({required this.message});
}

class ViewMembersBloc extends Bloc<ViewMembersEvent, ViewMembersState> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String _searchText = "";
  List<UserFriend> _allMembers = [];

  ViewMembersBloc() : super(MembersLoading()) {
    on<LoadMembers>((event, emit) async {
      emit(MembersLoading());
      try {
        _allMembers = await _fetchMembers();
        emit(MembersLoaded(members: _allMembers));
      } catch (e) {
        emit(MembersError(message: e.toString()));
      }
    });

    on<SearchMembers>((event, emit) async {
      _searchText = event.searchText;
      emit(MembersLoaded(members: _filterMembers()));
    });
  }

  Future<List<UserFriend>> _fetchMembers() async {
    List<UserFriend> members = [];

    // Assume the current user's uid is available somehow
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // Fetch the friends from Firestore
    QuerySnapshot clubsSnapshot = await firestore
        .collection('clubs')
        .doc(currentUserId)
        .collection('Members')
        .get();

    for (var doc in clubsSnapshot.docs) {
      DocumentSnapshot userDoc = await firestore.collection('users').doc(doc.id).get();
      UserFriend member = UserFriend.fromFirestore(userDoc);
      members.add(member);
    }

    return members;
  }

  List<UserFriend> _filterMembers() {
    if (_searchText.isEmpty) {
      return _allMembers;
    } else {
      return _allMembers.where((member) =>
          ("${member.firstName} ${member.lastName}").toLowerCase().contains(_searchText.toLowerCase())
      ).toList();
    }
  }
}

