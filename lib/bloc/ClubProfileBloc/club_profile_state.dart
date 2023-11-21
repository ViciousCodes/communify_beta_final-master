import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ClubProfileState {
  int get membersCount => 0;
  int get eventsCount => 0;
}

class ProfileLoading extends ClubProfileState {}

class ProfileLoaded extends ClubProfileState {
  final DocumentSnapshot profile;
  final String imageUrl;
  @override
  final int membersCount;
  @override
  final int eventsCount;

  ProfileLoaded({
    required this.profile,
    this.imageUrl = '',
    this.membersCount = 0,
    this.eventsCount = 0,
  });

  ProfileLoaded copyWith({
    DocumentSnapshot? profile,
    String? imageUrl,
    int? membersCount,
    int? eventsCount,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      imageUrl: imageUrl ?? this.imageUrl,
      membersCount: membersCount ?? this.membersCount,
      eventsCount: eventsCount ?? this.eventsCount,
    );
  }
}

class ImageLoaded extends ClubProfileState {
  final String imageUrl;

  ImageLoaded({required this.imageUrl});
}

class ProfileError extends ClubProfileState {}

