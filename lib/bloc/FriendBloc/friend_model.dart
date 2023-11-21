import 'package:cloud_firestore/cloud_firestore.dart';

class Friend {
  final String id;
  final String firstName;
  final String lastName;
  final String imageUrl;
  final String imageUrlHigh;
  int friendCount = 0;
  bool requestSent = false;
  bool isRequestPending = false;

  Friend({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.imageUrl,
    required this.imageUrlHigh,
    required this.requestSent,
  });

  factory Friend.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Friend(
      id: doc.id,
      firstName: data['first_name'] ?? '',
      lastName: data['last_name'] ?? '',
      imageUrl: data['image_low_url'] ?? '',  // Now you directly get the URL from Firestore
      imageUrlHigh: data['image_url'] ?? '',
      requestSent: false,
    );
  }
}




