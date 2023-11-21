import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communify_beta_final/ticket_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../app_layout.dart';

class RegisteredScreen extends StatefulWidget {
  const RegisteredScreen({super.key});

  @override
  RegisteredScreenState createState() => RegisteredScreenState();
}

class RegisteredScreenState extends State<RegisteredScreen> with AutomaticKeepAliveClientMixin<RegisteredScreen>{
  CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
  final FirebaseStorage storage = FirebaseStorage.instance;
  late String currentUserId;
  String? userFullName;
  List<Map<String, dynamic>> eventList = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid;
      _fetchUserName();
      fetchEventData();
    } else {
      debugPrint('User not authenticated');
    }
  }

  Future<void> fetchEventData() async {
    try {
      // Get the document reference for the current user
      DocumentReference userDocRef = usersCollection.doc(currentUserId);

      // Get the registered_events subcollection for the current user
      CollectionReference registeredEventsCollection = userDocRef.collection('Registered Events');

      // Fetch all event documents
      QuerySnapshot eventsSnapshot = await registeredEventsCollection.get();

      // Process the event documents
      List<Map<String, dynamic>> events = eventsSnapshot.docs.map((eventDoc) {
        Map<String, dynamic> eventData = eventDoc.data() as Map<String, dynamic>;

        // Assuming your event document has fields like 'registered_event_name', 'registered_event_date', etc.
        String eventName = eventData['name'];
        Timestamp eventDate = eventData['date'];
        String eventLocation = eventData['location'];
        int eventPrice = eventData['price'];
        String eventStatus = eventData['status'];
        String organizerId = eventData['organizerId'];
        String organizer = eventData['organizer'] ?? '';
        int quantity = eventData['quantity'];
        String imageUrl = eventData['image_url'];

        return {
          'eventName': eventName,
          'eventDate': eventDate,
          'organizerId' : organizerId,
          'organizer' : organizer,
          'eventLocation': eventLocation,
          'eventPrice': eventPrice,
          'eventStatus': eventStatus,
          'quantity': quantity,
          'image_url': imageUrl,
        };
      }).toList();

      // Store the event list in the state
      setState(() {
        eventList = events;
      });
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<String> _fetchUserName() async {
    try {
      // Get the document reference for the current user
      DocumentReference userDocRef = usersCollection.doc(currentUserId);

      // Fetch the user document
      DocumentSnapshot userSnapshot = await userDocRef.get();

      // Get the userName
      if (userSnapshot.exists) {
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        String firstName = userData['first_name'];
        String lastName = userData['last_name'];
        String userName = '$firstName $lastName';
        return userName;
      } else {
        debugPrint('User document does not exist');
        return ''; // Return an empty string or default value in case of an error
      }
    } catch (err) {
      debugPrint('Error: $err');
      return ''; // Return an empty string or default value in case of an error
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double height = MediaQuery.of(context).size.height;
    double ticketHeight = height * 0.0025;
    double topHeight = height * 0.001;
    return Scaffold(
      backgroundColor: CupertinoColors.white,
      body: Padding(
        padding: EdgeInsets.only(left: AppLayout.getWidth(20), right: AppLayout.getWidth(20)),
        child: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(top: AppLayout.getHeight(10)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Registered',
                      style: TextStyle(
                        color: Color(0xFF09152D),
                        fontSize: 30,
                        fontFamily: 'Satoshi',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Gap(ticketHeight),
            _buildEventList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList() {
    return FutureBuilder(
      future: _fetchUserName(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading indicator while fetching userName
          return const Center(child: CupertinoActivityIndicator());
        }

        // Check if userName is available
        if (snapshot.hasData) {
          if (eventList.isEmpty) {
            return Padding(
              padding: EdgeInsets.only(top: AppLayout.getHeight(100.0), left: AppLayout.getWidth(20.0), right: AppLayout.getWidth(20.0)),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.event_available,
                      color: Color(0xFF09152D),
                      size: 100.0,
                    ),
                    Text(
                      'No Registered Events',
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
            );
          }
          String userName = snapshot.data as String;
          eventList.sort((a, b) => a['eventDate'].compareTo(b['eventDate']));

          // Filter the eventList based on the date-time condition
          List<Map<String, dynamic>> validEventList = eventList.where((eventData) {
            Timestamp eventTimestamp = eventData['eventDate'];
            DateTime eventDateTime = eventTimestamp.toDate();
            DateTime expirationTime = eventDateTime.add(const Duration(hours: 24));
            return DateTime.now().isBefore(expirationTime);
          }).toList();

          return SizedBox(
            height: AppLayout.getHeight(650), // Adjust the height as needed
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: validEventList.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> eventData = validEventList[index];

                return Padding(
                  padding: EdgeInsets.only(left: validEventList.length == 1 ? AppLayout.getWidth(15) : AppLayout.getWidth(0)),
                  child: TicketCard(eventData: eventData, userName: userName),
                );
              },
            ),
          );
        } else {
          // Show placeholder or default widget if userName is not available
          return Container();
        }
      },
    );
  }
}
