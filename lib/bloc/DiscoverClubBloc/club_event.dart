abstract class ClubEvent {}

class LoadClubs extends ClubEvent {}

class SearchClubs extends ClubEvent {
  final String searchTerm;
  SearchClubs(this.searchTerm);
}

class AddMemberToClub extends ClubEvent {
  final String clubId;

  AddMemberToClub(this.clubId);

  @override
  List<Object> get props => [clubId];
}

