import 'club_model.dart';

abstract class ClubState {}

class ClubsInitial extends ClubState {}

class ClubsLoading extends ClubState {}

class ClubsLoaded extends ClubState {
  final List<Club> clubs;
  ClubsLoaded({required this.clubs});
}

class ClubsSearchResults extends ClubState {
  final List<Club> clubs;
  ClubsSearchResults({required this.clubs});
}

class ClubsError extends ClubState {
  final String message;
  ClubsError({required this.message});
}

class ClubsUpdated extends ClubState {
  final List<Club> clubs;

  ClubsUpdated(this.clubs);
}
