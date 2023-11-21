import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:communify_beta_final/app_layout.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class TicketCard extends StatelessWidget {
  final Map<String, dynamic> eventData;
  final String userName;

  final FirebaseStorage storage = FirebaseStorage.instance;


  TicketCard({Key? key, required this.eventData, required this.userName}) : super(key: key);

  String _getEventData(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    // Format the DateTime as a date string in "15 - July 2013" format
    String formattedDate = DateFormat("dd MMMM, yyyy").format(dateTime);
    return formattedDate;
  }

  String _getEventTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    // Format the DateTime as a time string with AM/PM
    String formattedTime = DateFormat("h:mm a").format(dateTime);
    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double ticketWidth = width * 0.85;
    double ticketHeight = height * 0.6;
    return SizedBox(
      width: ticketWidth,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.black, width: 1),  // Adjust the color and width as per your requirement.
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: AppLayout.getHeight(325),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Material(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Ink.image(
                    image: CachedNetworkImageProvider(eventData['image_url']),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            Gap(AppLayout.getHeight(15)),
            Padding(
              padding: EdgeInsets.only(left: AppLayout.getWidth(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${eventData['eventName']}",
                          style: const TextStyle(
                            color: Color(0xFF09152D),
                            fontSize: 26,
                            fontFamily: 'Satoshi',
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "By: ${eventData['organizer']}",
                    style: const TextStyle(
                      color: Color(0xFF09152D),
                      fontSize: 16,
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Gap(AppLayout.getHeight(20)),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        SizedBox(
                          width: AppLayout.getWidth(170),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Name',
                                style: TextStyle(
                                  color: Color(0xFF677489),
                                  fontSize: 17,
                                  fontFamily: 'Satoshi',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Gap(AppLayout.getHeight(10)),
                              Text(
                                userName,
                                style: const TextStyle(
                                  color: Color(0xFF09152D),
                                  fontSize: 15,
                                  fontFamily: 'Satoshi',
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.clip,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                        Gap(AppLayout.getWidth(30)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quantity',
                              style: TextStyle(
                                color: Color(0xFF677489),
                                fontSize: 17,
                                fontFamily: 'Satoshi',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Gap(AppLayout.getHeight(10)),
                            Text(
                              eventData['quantity'].toString(),
                              style: const TextStyle(
                                color: Color(0xFF09152D),
                                fontSize: 15,
                                fontFamily: 'Satoshi',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Gap(AppLayout.getHeight(15)),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        SizedBox(
                          width: AppLayout.getWidth(170),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Date',
                                style: TextStyle(
                                  color: Color(0xFF677489),
                                  fontSize: 17,
                                  fontFamily: 'Satoshi',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Gap(AppLayout.getHeight(10)),
                              Text(
                                _getEventData(eventData['eventDate']),
                                style: const TextStyle(
                                  color: Color(0xFF09152D),
                                  fontSize: 15,
                                  fontFamily: 'Satoshi',
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.clip,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                        Gap(AppLayout.getWidth(30)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Time',
                              style: TextStyle(
                                color: Color(0xFF677489),
                                fontSize: 17,
                                fontFamily: 'Satoshi',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Gap(AppLayout.getHeight(10)),
                            Text(
                              _getEventTime(eventData['eventDate']),
                              style: const TextStyle(
                                color: Color(0xFF09152D),
                                fontSize: 15,
                                fontFamily: 'Satoshi',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Gap(AppLayout.getHeight(15)),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        SizedBox(
                          width: AppLayout.getWidth(170),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Location',
                                style: TextStyle(
                                  color: Color(0xFF677489),
                                  fontSize: 17,
                                  fontFamily: 'Satoshi',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Gap(AppLayout.getHeight(10)),
                              Text(
                                eventData['eventLocation'],
                                style: const TextStyle(
                                  color: Color(0xFF09152D),
                                  fontSize: 15,
                                  fontFamily: 'Satoshi',
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.clip,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                        Gap(AppLayout.getWidth(30)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Price',
                              style: TextStyle(
                                color: Color(0xFF677489),
                                fontSize: 17,
                                fontFamily: 'Satoshi',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Gap(AppLayout.getHeight(10)),
                            Row(
                              children: [
                                Text(
                                  eventData['eventPrice'] == 0 ? 'FREE' : '\$${eventData['eventPrice']}',
                                  style: const TextStyle(
                                    color: Color(0xFF09152D),
                                    fontSize: 15,
                                    fontFamily: 'Satoshi',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Gap(AppLayout.getWidth(10)),
                                if (eventData['eventStatus'] == 'pending')
                                  Container(
                                    width: 50,
                                    height: 27,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFCD56),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Pending',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontFamily: 'Satoshi',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (eventData['eventStatus'] == 'paid')
                                  Container(
                                    width: 50,
                                    height: 27,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00FF56),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Paid',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontFamily: 'Satoshi',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (eventData['eventStatus'] == 'unpaid')
                                  Container(
                                    width: 50,
                                    height: 27,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF0000),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Unpaid',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontFamily: 'Satoshi',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}