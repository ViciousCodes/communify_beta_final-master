import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ProfileState {
  int get friendsCount => 0;
  int get clubsCount => 0;
}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final DocumentSnapshot profile;
  final String imageUrl;
  @override
  final int friendsCount;
  @override
  final int clubsCount;

  ProfileLoaded({
    required this.profile,
    this.imageUrl = '',
    this.friendsCount = 0,
    this.clubsCount = 0,
  });

  ProfileLoaded copyWith({
    DocumentSnapshot? profile,
    String? imageUrl,
    int? friendsCount,
    int? clubsCount,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      imageUrl: imageUrl ?? this.imageUrl,
      friendsCount: friendsCount ?? this.friendsCount,
      clubsCount: clubsCount ?? this.clubsCount,
    );
  }
}

class ImageLoaded extends ProfileState {
  final String imageUrl;

  ImageLoaded({required this.imageUrl});
}

class ProfileError extends ProfileState {}

