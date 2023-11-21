import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String about;
  final String address;
  final Timestamp date;
  final String location;
  final String name;
  final String organizer;
  final String organizerId;
  final String paymentMethod;
  final String time;
  final int price;
  final String imageUrl;
  final String imageUrlHigh;
  final String organizerImageUrl;


  EventModel({
    required this.id,
    required this.about,
    required this.address,
    required this.date,
    required this.location,
    required this.name,
    required this.organizer,
    required this.organizerId,
    required this.paymentMethod,
    required this.time,
    required this.price,
    required this.imageUrl,
    required this.imageUrlHigh,
    required this.organizerImageUrl,
  });
}