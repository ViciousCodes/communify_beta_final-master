// friend_event.dart
abstract class FriendsEvent {}

class LoadFriends extends FriendsEvent {}

class SearchFriends extends FriendsEvent {
  final String searchText;
  SearchFriends(this.searchText);
}

class SendFriendRequest extends FriendsEvent {
  final String friendId;

  SendFriendRequest(this.friendId);
}


