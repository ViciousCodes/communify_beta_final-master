import 'package:communify_beta_final/screens/discover_tabs/friends_list_algolia.dart';

abstract class FriendProfileEvent {}

class LoadFriendProfileData extends FriendProfileEvent {
  final UserFriend friend;

  LoadFriendProfileData({required this.friend});
}

class AddFriend extends FriendProfileEvent {
  final String friendId;

  AddFriend({required this.friendId});
}

class GetFriendsCount extends FriendProfileEvent {
  final int count;

  GetFriendsCount(this.count);
}

class GetClubsCount extends FriendProfileEvent {
  final int count;

  GetClubsCount(this.count);
}