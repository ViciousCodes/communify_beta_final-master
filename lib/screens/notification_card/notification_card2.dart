import 'package:flutter/material.dart';

class NotificationCardType2 extends StatelessWidget {
  final String text1;
  final String text2;

  const NotificationCardType2({super.key, required this.text1, required this.text2});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundImage: NetworkImage('https://placehold.co/70x80/09152D/FFFFFF/png'), // Replace with your actual circle photo
        ),
        title: Text(
          text1,
          style: const TextStyle(
            color: Color(0xFF09152D),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          text2,
          style: const TextStyle(
            color: Color(0xFF09152D),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}