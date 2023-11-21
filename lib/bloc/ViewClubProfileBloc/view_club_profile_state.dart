import 'package:communify_beta_final/screens/discover_tabs/clubs_list_algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ViewClubProfileState {}

class ViewClubProfileLoading extends ViewClubProfileState {}

class ViewClubProfileLoaded extends ViewClubProfileState {
  final Club clubData; // you can specify a type for this
  final DocumentSnapshot clubProfile;
  final String imageUrl;
  final int membersCount;
  final int eventsCount;

  ViewClubProfileLoaded({
    required this.clubData,
    required this.clubProfile,
    this.imageUrl = '',
    this.membersCount = 0,
    this.eventsCount = 0,
  });

  ViewClubProfileLoaded copyWith({
    DocumentSnapshot? clubProfile,
    Club? clubData,
    String? imageUrl,
    int? membersCount,
    int? eventsCount,
  }) {
    return ViewClubProfileLoaded(
      clubProfile: clubProfile ?? this.clubProfile,
      clubData: clubData ?? this.clubData,
      imageUrl: imageUrl ?? this.imageUrl,
      membersCount: membersCount ?? this.membersCount,
      eventsCount: eventsCount ?? this.eventsCount,
    );
  }
}
class ViewClubProfileError extends ViewClubProfileState {}