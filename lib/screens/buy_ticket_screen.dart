import 'package:communify_beta_final/bottom_nav.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../app_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import the cloud_firestore package

class BuyTicketScreen extends StatefulWidget {
  final String eventName;
  final String eventLocation;
  final String paymentMethod;
  final String organizerId;
  final String organizer;
  final String eventId;
  final int eventPrice;
  final Timestamp eventDate;
  final String eventImage;


  const BuyTicketScreen({
    Key? key,
    required this.eventName,
    required this.eventLocation,
    required this.eventPrice,
    required this.eventDate,
    required this.paymentMethod,
    required this.organizerId,
    required this.organizer,
    required this.eventId,
    required this.eventImage,
  }) : super(key: key);

  @override
  BuyTicketScreenState createState() => BuyTicketScreenState();
}

class BuyTicketScreenState extends State<BuyTicketScreen> {
  bool isPaid = false; // Default value for payment status
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.white,
      body: Padding(
        padding: EdgeInsets.only(left: AppLayout.getWidth(20), right: AppLayout.getWidth(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(top: AppLayout.getHeight(20)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    BackButton(color: Color(0xFF09152D)),
                    Text(
                      'Payment',
                      style: TextStyle(
                        color: Color(0xFF09152D),
                        fontSize: 24,
                        fontFamily: 'Satoshi',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Gap(AppLayout.getHeight(30)),
            const Text(
              'Price per Ticket:',
              style: TextStyle(
                color: Color(0xFF677489),
                fontSize: 16,
                fontFamily: 'Satoshi',
                fontWeight: FontWeight.w700,
              ),
            ),
            Gap(AppLayout.getHeight(20)),
            Text(
            widget.eventPrice == 0 ? 'FREE' : "\$${widget.eventPrice.toString()}",
              style: const TextStyle(
                color: Color(0xFF09152D),
                fontSize: 18,
                fontFamily: 'Satoshi',
                fontWeight: FontWeight.w700,
              ),
            ),
            Gap(AppLayout.getHeight(20)),
            const Text(
              'Select Quantity:',
              style: TextStyle(
                color: Color(0xFF677489),
                fontSize: 16,
                fontFamily: 'Satoshi',
                fontWeight: FontWeight.w700,
              ),
            ),
            Gap(AppLayout.getHeight(20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(CupertinoIcons.minus_circle),
                  onPressed: () {
                    if (quantity > 1) {
                      setState(() {
                        quantity--;
                      });
                    }
                  },
                ),
                Text(
                  "$quantity",
                  style: const TextStyle(
                    color: Color(0xFF09152D),
                    fontSize: 18,
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.add_circled),
                  onPressed: () {
                    setState(() {
                      quantity++;
                    });
                  },
                ),
              ],
            ),
            Gap(AppLayout.getHeight(20)),
            const Text(
              'Total Cost:',
              style: TextStyle(
                color: Color(0xFF677489),
                fontSize: 16,
                fontFamily: 'Satoshi',
                fontWeight: FontWeight.w700,
              ),
            ),
            Gap(AppLayout.getHeight(20)),
            Text(
              widget.eventPrice == 0 ? 'FREE' : "\$${(quantity * widget.eventPrice).toStringAsFixed(0)}",
              style: const TextStyle(
                color: Color(0xFF09152D),
                fontSize: 18,
                fontFamily: 'Satoshi',
                fontWeight: FontWeight.w700,
              ),
            ),
            Gap(AppLayout.getHeight(20)),
            if (widget.eventPrice != 0) ... [
              const Text(
                'The organizer has provided the following method for payment:',
                style: TextStyle(
                  color: Color(0xFF677489),
                  fontSize: 16,
                  fontFamily: 'Satoshi',
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              Gap(AppLayout.getHeight(20)),
              Text(
                widget.paymentMethod,
                style: const TextStyle(
                  color: Color(0xFF09152D),
                  fontSize: 18,
                  fontFamily: 'Satoshi',
                  fontWeight: FontWeight.w700,
                ),
              ),
              Gap(AppLayout.getHeight(20)),
              const Text(
                'I have completed the above payment:',
                style: TextStyle(
                  color: Color(0xFF677489),
                  fontSize: 16,
                  fontFamily: 'Satoshi',
                  fontWeight: FontWeight.w700,
                ),
              ),
              Gap(AppLayout.getHeight(20)),
              Container(
                width: AppLayout.getWidth(200), // Adjust the width as desired
                height: AppLayout.getHeight(50), // Adjust the height as desired
                decoration: BoxDecoration(
                  color: const Color(0xFF09152D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CupertinoButton(
                  onPressed: () {
                    setState(() {
                      isPaid = true; // Set the payment status to paid
                    });

                    addRegisteredEventToFirestore('pending', quantity);
                  },
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: const Center(
                    child: Text(
                      'Paid',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Satoshi',
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
              Gap(AppLayout.getHeight(20)),
              const Text(
                'I wish to pay in person at the event:',
                style: TextStyle(
                  color: Color(0xFF677489),
                  fontSize: 16,
                  fontFamily: 'Satoshi',
                  fontWeight: FontWeight.w700,
                ),
              ),
              Gap(AppLayout.getHeight(20)),
              Container(
                width: AppLayout.getWidth(200), // Adjust the width as desired
                height: AppLayout.getHeight(50), // Adjust the height as desired
                decoration: BoxDecoration(
                  color: const Color(0xFF09152D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CupertinoButton(
                  onPressed: () {
                    setState(() {
                      isPaid = false; // Set the payment status to unpaid
                    });

                    addRegisteredEventToFirestore('unpaid', quantity);
                  },
                  padding: EdgeInsets.zero,
                  child: const Center(
                    child: Text(
                      'Unpaid',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Satoshi',
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ] else ... [
              const Text(
                'This is a Free Event:',
                style: TextStyle(
                  color: Color(0xFF677489),
                  fontSize: 16,
                  fontFamily: 'Satoshi',
                  fontWeight: FontWeight.w700,
                ),
              ),
              Gap(AppLayout.getHeight(20)),
              Container(
                width: AppLayout.getWidth(200), // Adjust the width as desired
                height: AppLayout.getHeight(50), // Adjust the height as desired
                decoration: BoxDecoration(
                  color: const Color(0xFF09152D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CupertinoButton(
                  onPressed: () {
                    setState(() {
                      isPaid = true; // Set the payment status to paid
                    });

                    addRegisteredEventToFirestore('paid', quantity);
                  },
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: const Center(
                    child: Text(
                      'Register',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Satoshi',
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> addRegisteredEventToFirestore(String status, int quantity) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;
        final registeredEventsRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('Registered Events');
        final eventAttendeesRef = FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventId)
            .collection('Attendees');

        await registeredEventsRef.doc(widget.eventId).set({
          'name': widget.eventName,
          'organizerId' : widget.organizerId,
          'organizer' : widget.organizer,
          'date': widget.eventDate,
          'location': widget.eventLocation,
          'quantity' : quantity,
          'price': widget.eventPrice,
          'status': status,
          'received_time': DateFormat('MMM d, y \'around\' h:mm a').format(Timestamp.now().toDate()),
          'image_url': widget.eventImage,
        });

        await eventAttendeesRef.doc(userId).set({
          'name': user.displayName,
          'quantity': quantity,
          'status': status,
          'received_time': DateFormat('MMM d, y \'around\' h:mm a').format(Timestamp.now().toDate()),
        });

        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
              context,
              CupertinoPageRoute(builder: (context) => const BottomNav(initialIndex: 2)),
                  (Route<dynamic> route) => false);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding registered event: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}