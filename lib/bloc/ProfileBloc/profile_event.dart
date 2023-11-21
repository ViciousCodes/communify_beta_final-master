abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class LoadImage extends ProfileEvent {}

class UpdateFriendsCount extends ProfileEvent {
  final int count;

  UpdateFriendsCount(this.count);
}

class UpdateClubsCount extends ProfileEvent {
  final int count;

  UpdateClubsCount(this.count);
}

class UnloadProfile extends ProfileEvent {}
