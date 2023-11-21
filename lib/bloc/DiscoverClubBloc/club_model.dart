import 'package:cloud_firestore/cloud_firestore.dart';

class Club {
  final String id;
  final String clubName;
  final String email;
  final String imageUrl;
  final String imageUrlHigh;
  int memberCount = 0;
  bool isMembershipPending = false;

  Club({
    required this.id,
    required this.clubName,
    required this.email,
    required this.imageUrl,
    required this.imageUrlHigh,
  });

  factory Club.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Club(
      id: doc.id,
      clubName: data['club_name'] ?? '',
      email: data['email'] ?? '',
      imageUrl: data['image_low_url'] ?? '',
      imageUrlHigh: data['image_url'] ?? '',
    );
  }
}

