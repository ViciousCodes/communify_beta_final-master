import '../../screens/discover_tabs/friends_list_algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class FriendProfileState {}

class FriendProfileLoading extends FriendProfileState {}

class FriendProfileLoaded extends FriendProfileState {
  final UserFriend friendData; // you can specify a type for this
  final DocumentSnapshot friendProfile;
  final String imageUrl;
  final int friendsCount;
  final int clubsCount;

  FriendProfileLoaded({
    required this.friendData,
    required this.friendProfile,
    this.imageUrl = '',
    this.friendsCount = 0,
    this.clubsCount = 0,
  });

  FriendProfileLoaded copyWith({
    DocumentSnapshot? friendProfile,
    UserFriend? friendData,
    String? imageUrl,
    int? friendsCount,
    int? clubsCount,
  }) {
    return FriendProfileLoaded(
      friendProfile: friendProfile ?? this.friendProfile,
      friendData: friendData ?? this.friendData,
      imageUrl: imageUrl ?? this.imageUrl,
      friendsCount: friendsCount ?? this.friendsCount,
      clubsCount: clubsCount ?? this.clubsCount,
    );
  }


}
class FriendProfileError extends FriendProfileState {}