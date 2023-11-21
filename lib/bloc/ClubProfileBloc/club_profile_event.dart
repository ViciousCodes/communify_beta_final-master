abstract class ClubProfileEvent {}

class LoadProfile extends ClubProfileEvent {}

class LoadImage extends ClubProfileEvent {}

class UpdateMembersCount extends ClubProfileEvent {
  final int count;

  UpdateMembersCount(this.count);
}

class UpdateEventsCount extends ClubProfileEvent {
  final int count;

  UpdateEventsCount(this.count);
}

class UnloadProfile extends ClubProfileEvent {}
