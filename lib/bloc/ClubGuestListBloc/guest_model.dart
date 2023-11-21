import 'package:cloud_firestore/cloud_firestore.dart';

class Guest {
  final String id;
  final String firstName;
  final String lastName;
  final String imageUrl;
  int price = 0;
  String status = '';
  String receivedTime = '';

  Guest({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.imageUrl,
  });

  factory Guest.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Guest(
      id: doc.id,
      firstName: data['first_name'] ?? '',
      lastName: data['last_name'] ?? '',
      imageUrl: data['image_low_url'] ?? '',
    );
  }
}