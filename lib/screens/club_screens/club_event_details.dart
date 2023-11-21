import 'package:cached_network_image/cached_network_image.dart';
import 'package:communify_beta_final/app_layout.dart';
import 'package:communify_beta_final/screens/club_screens/guest_list_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../bloc/ClubHomeBloc/event_model.dart';
import 'edit_event_screen.dart';

class EventDetailsScreen extends StatelessWidget {
  final EventModel event;

  const EventDetailsScreen({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(top: AppLayout.getHeight(20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Gap(AppLayout.getWidth(20)),
                        const BackButton(color: Color(0xFF09152D)),
                        const Text(
                          'Event Details',
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
                Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        if (event.imageUrlHigh != "")
                          Padding(
                            padding: EdgeInsets.only(bottom: AppLayout.getHeight(20)),
                            child: Container(
                              width: AppLayout.getWidth(350),
                              height: AppLayout.getHeight(200),
                              decoration: ShapeDecoration(
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(event.imageUrlHigh),
                                  fit: BoxFit.cover,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          top: AppLayout.getHeight(175),
                          left: AppLayout.getWidth(25),
                          child: Container(
                            width: AppLayout.getWidth(300),
                            height: AppLayout.getHeight(60),
                            decoration: ShapeDecoration(
                              color: const Color(0xFFFEFEFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              shadows: const [
                                BoxShadow(
                                  color: Color(0x19595959),
                                  blurRadius: 20,
                                  offset: Offset(0, 20),
                                  spreadRadius: 0,
                                )
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(left: AppLayout.getWidth(30), right: AppLayout.getWidth(30)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(CupertinoPageRoute(builder: (context) => GuestListScreen(eventId: event.id,)));
                                    },
                                    child: Container(
                                      width: AppLayout.getWidth(120), // Adjust the width as desired
                                      height: AppLayout.getHeight(35), // Adjust the height as desired
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF09152D),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.list, color: Colors.white),
                                            Gap(AppLayout.getWidth(5)),
                                            const Text(
                                              'Guest Lists',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // const Spacer(),
                                  // InkWell(
                                  //   onTap: () {
                                  //     print("Invite button clicked");
                                  //   },
                                  //   child: Container(
                                  //     width: AppLayout.getWidth(110), // Adjust the width as desired
                                  //     height: AppLayout.getHeight(30), // Adjust the height as desired
                                  //     decoration: BoxDecoration(
                                  //       color: const Color(0xFF09152D),
                                  //       borderRadius: BorderRadius.circular(8),
                                  //     ),
                                  //     child: Center(
                                  //       child: Row(
                                  //         mainAxisAlignment: MainAxisAlignment.center,
                                  //         children: [
                                  //           const Icon(Icons.send_rounded, color: Colors.white),
                                  //           Gap(AppLayout.getWidth(5)),
                                  //           const Text(
                                  //             'Send Invites',
                                  //             style: TextStyle(
                                  //               color: Colors.white,
                                  //               fontSize: 12,
                                  //               fontWeight: FontWeight.w700,
                                  //             ),
                                  //           ),
                                  //         ],
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Gap(AppLayout.getHeight(25)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppLayout.getWidth(35)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(20),
                      Text(
                        event.name,
                        style: const TextStyle(
                          color: Color(0xFF09152D),
                          fontSize: 35,
                          fontFamily: 'Satoshi',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Gap(25),
                          Row(
                            children: [
                              Stack(
                                children: [
                                  Opacity(
                                    opacity: 0.10,
                                    child: Container(
                                      width: AppLayout.getWidth(48),
                                      height: AppLayout.getHeight(48),
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFF09152D),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Positioned.fill(
                                    child: Icon(
                                      CupertinoIcons.calendar,
                                      color: Color(0xFF09152D),
                                      size: 30,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      DateFormat('MMM d, y').format(event.date.toDate()),
                                      style: const TextStyle(
                                        color: Color(0xFF09152D),
                                        fontSize: 16,
                                        fontFamily: 'Satoshi',
                                        fontWeight: FontWeight.w500,
                                      )
                                  ),
                                  Text(
                                    event.time,
                                    style: const TextStyle(
                                      color: Color(0xFF677489),
                                      fontSize: 14,
                                      fontFamily: 'Satoshi',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          const Gap(20),
                          Row(
                            children: [
                              Stack(
                                children: [
                                  Opacity(
                                    opacity: 0.10,
                                    child: Container(
                                      width: AppLayout.getWidth(48),
                                      height: AppLayout.getHeight(48),
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFF09152D),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Positioned.fill(
                                    child: Icon(
                                      CupertinoIcons.map_pin,
                                      color: Color(0xFF09152D),
                                      size: 30,
                                    ),
                                  ),
                                ],
                              ),

                              const Gap(8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      event.location,
                                      style: const TextStyle(
                                        color: Color(0xFF09152D),
                                        fontSize: 16,
                                        fontFamily: 'Satoshi',
                                        fontWeight: FontWeight.w500,
                                      )
                                  ),
                                  Text(
                                    event.address,
                                    style: const TextStyle(
                                      color: Color(0xFF677489),
                                      fontSize: 14,
                                      fontFamily: 'Satoshi',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          const Gap(20),
                          Row(
                            children: [
                              Container(
                                width: AppLayout.getWidth(48),
                                height: AppLayout.getHeight(48),
                                decoration: ShapeDecoration(
                                  shape: const OvalBorder(),
                                  image: (event.organizerImageUrl.isNotEmpty)
                                      ? DecorationImage(
                                    image: CachedNetworkImageProvider(event.organizerImageUrl),
                                    fit: BoxFit.fill,
                                  )
                                      : null,
                                  color: (event.organizerImageUrl.isEmpty)
                                      ? Colors.grey
                                      : null, // A default background color for initials, change as needed.
                                ),
                                child: (event.organizerImageUrl.isEmpty)
                                    ? Center(
                                  child: Text(
                                    event.organizer[0],
                                    style: const TextStyle(color: Colors.white, fontSize: 16), // Adjust styling as needed
                                  ),
                                )
                                    : null,
                              ),
                              const Gap(8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(event.organizer,
                                      style: const TextStyle(
                                        color: Color(0xFF09152D),
                                        fontSize: 16,
                                        fontFamily: 'Satoshi',
                                        fontWeight: FontWeight.w500,
                                      )),
                                  const Text(
                                    'Organizer',
                                    style: TextStyle(
                                      color: Color(0xFF677489),
                                      fontSize: 14,
                                      fontFamily: 'Satoshi',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),

                          const Gap(20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                'About Event',
                                style: TextStyle(
                                  color: Color(0xFF09152D),
                                  fontSize: 20,
                                  fontFamily: 'Satoshi',
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              const Gap(8),
                              Text(
                                event.about,
                                style: const TextStyle(
                                  color: Color(0xFF677489),
                                  fontSize: 16,
                                  fontFamily: 'Satoshi',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Gap(90),
                            ],
                          ),
                          const Gap(20),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 25,
            left: 50,
            right: 50,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(CupertinoPageRoute(builder: (context) =>
                    EditEventScreen(
                      oldName: event.name,
                      oldDate: event.date,
                      oldTime: event.time,
                      oldLocation: event.location,
                      oldAddress: event.address,
                      oldAbout: event.about,
                      eventId: event.id,
                      dateTime: event.date,)));
              },
              child: Container(
                width: AppLayout.getWidth(275), // Adjust the width as desired
                height: AppLayout.getHeight(52), // Adjust the height as desired
                decoration: BoxDecoration(
                  color: const Color(0xFF09152D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Stack(
                  children: [
                    Center(
                      child: Text(
                        'Edit Event',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}