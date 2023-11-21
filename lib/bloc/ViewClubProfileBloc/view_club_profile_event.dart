import 'package:communify_beta_final/screens/discover_tabs/clubs_list_algolia.dart';

abstract class ViewClubProfileEvent {}

class LoadClubProfileData extends ViewClubProfileEvent {
  final Club club;

  LoadClubProfileData({required this.club});
}

class GetMembersCount extends ViewClubProfileEvent {
  final int count;

  GetMembersCount(this.count);
}

class GetEventsCount extends ViewClubProfileEvent {
  final int count;

  GetEventsCount(this.count);
}