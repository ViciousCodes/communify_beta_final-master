import 'friend_model.dart';

abstract class FriendsState {}

class FriendsInitial extends FriendsState {}

class FriendsLoading extends FriendsState {}

class FriendsLoaded extends FriendsState {
  final List<Friend> friends;

  FriendsLoaded({required this.friends});
}

class FriendsSearchResults extends FriendsState {
  final List<Friend> friends;

  FriendsSearchResults({required this.friends});
}

class FriendsError extends FriendsState {
  final String message;

  FriendsError({required this.message});
}

