import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communify_beta_final/app_layout.dart';
import 'package:communify_beta_final/bloc/EventHomeBloc/event_event.dart';
import 'package:communify_beta_final/bloc/EventHomeBloc/event_model.dart';
import 'package:communify_beta_final/bloc/EventHomeBloc/event_state.dart';
import 'package:communify_beta_final/bloc/EventHomeBloc/event_bloc.dart';
import 'package:communify_beta_final/full_screen_image.dart';
import 'package:communify_beta_final/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'buy_ticket_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final EventModel event;
  final EventBloc bloc;

  const EventDetailsScreen({Key? key, required this.event, required this.bloc})
      : super(key: key);

  @override
  EventDetailsScreenState createState() => EventDetailsScreenState();
}


class EventDetailsScreenState extends State<EventDetailsScreen>  {

  @override
  void initState() {
    super.initState();
    widget.bloc.add(EventFriendsCount(widget.event.id));
  }

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
                Column(
                  children: [
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.only(top: AppLayout.getWidth(10), left: AppLayout.getWidth(5), right: AppLayout.getWidth(25)),
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
                            const Spacer(),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                showCupertinoModalPopup(
                                  context: context,
                                  builder: (context) => CupertinoActionSheet(
                                    title: const Text(
                                      "Options",
                                      style: TextStyle(
                                        color: Color(0xFF677489),
                                        fontSize: 14,
                                        fontFamily: 'Satoshi',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    actions: <Widget>[
                                      CupertinoActionSheetAction(
                                        child: const Text(
                                          "Report Inappropriate",
                                          style: TextStyle(
                                            color: Color(0xFF09152D),
                                            fontSize: 20,
                                            fontFamily: 'Satoshi',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          showCupertinoDialog(
                                            context: context,
                                            builder: (BuildContext context) => CupertinoAlertDialog(
                                              title: const Text('Report Inappropriate'),
                                              content: const Text(
                                                'Is this event inappropriate? \n We will review this report within 24 hrs and if deemed inappropriate the post will be removed within that timeframe. We will also take actions against its author.',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: 'Satoshi',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              actions: <Widget>[
                                                CupertinoDialogAction(
                                                  child: const Text('Cancel'),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                CupertinoDialogAction(
                                                  isDestructiveAction: true,
                                                  onPressed: () {
                                                    final userId = FirebaseAuth.instance.currentUser!.uid;
                                                    final targetId = widget.event.id;
                                                    final targetName = widget.event.name;
                                                    const reportType = "event";
                                                    FirebaseFirestore.instance.collection('reports').add({
                                                      'userId': userId,
                                                      'targetId': targetId,
                                                      'targetName': targetName,
                                                      'reportType': reportType,
                                                      'status': 'pending',
                                                      'sentAt': Timestamp.now().toDate().toIso8601String()
                                                    });
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Report'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                    cancelButton: CupertinoActionSheetAction(
                                      isDefaultAction: true,
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        "Cancel",
                                        style: TextStyle(
                                          color: Color(0xFF09152D),
                                          fontSize: 20,
                                          fontFamily: 'Satoshi',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: const Icon(Icons.more_vert_outlined, color: Color(0xFF09152D), size: 30,),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Gap(AppLayout.getHeight(5)),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        if (widget.event.imageUrlHigh != "")
                          Padding(
                            padding: EdgeInsets.only(bottom: AppLayout.getHeight(20)),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FullScreenImage(imageUrl: widget.event.imageUrlHigh),
                                  ),
                                );
                              },
                              child: Container(
                                width: AppLayout.getWidth(350),
                                height: AppLayout.getHeight(200),
                                decoration: ShapeDecoration(
                                  image: DecorationImage(
                                    image: CachedNetworkImageProvider(widget.event.imageUrlHigh),
                                    fit: BoxFit.cover,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(CupertinoIcons.person_2_fill, color: Color(0xFF09152D)),
                                Gap(AppLayout.getWidth(10)),
                                BlocBuilder<EventBloc, EventState>(
                                  bloc: widget.bloc,
                                  builder: (context, state) {
                                    String friendsText = "Loading...";  // Default text when loading

                                    // Check if the state is EventFriendsCountLoaded
                                    if (state is EventFriendsCountLoaded) {
                                      friendsText = "${state.count} Friends Attending";
                                    }
                                    return Text(
                                      friendsText,
                                      style: const TextStyle(
                                        color: Color(0xFF09152D),
                                        fontSize: 17,
                                        fontFamily: 'Satoshi',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    );
                                  }
                                ),
                                // const Gap(10),
                                // InkWell(
                                //   onTap: () {
                                //     print("Invite button clicked");
                                //   },
                                //   child: Container(
                                //     width: AppLayout.getWidth(70), // Adjust the width as desired
                                //     height: AppLayout.getHeight(30), // Adjust the height as desired
                                //     decoration: BoxDecoration(
                                //       color: const Color(0xFF09152D),
                                //       borderRadius: BorderRadius.circular(12),
                                //     ),
                                //     child: const Center(
                                //       child: Text(
                                //         'Invite',
                                //         style: TextStyle(
                                //           color: Colors.white,
                                //           fontSize: 12,
                                //           fontWeight: FontWeight.w700,
                                //         ),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ],
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
                        widget.event.name,
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
                                      DateFormat('MMM d, y').format(widget.event.date.toDate()),
                                      style: const TextStyle(
                                        color: Color(0xFF09152D),
                                        fontSize: 16,
                                        fontFamily: 'Satoshi',
                                        fontWeight: FontWeight.w500,
                                      )
                                  ),
                                  Text(
                                    widget.event.time,
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
                                      widget.event.location,
                                      style: const TextStyle(
                                        color: Color(0xFF09152D),
                                        fontSize: 16,
                                        fontFamily: 'Satoshi',
                                        fontWeight: FontWeight.w500,
                                      )
                                  ),
                                  Text(
                                    widget.event.address,
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
                                  image: (widget.event.organizerImageUrl != null && widget.event.organizerImageUrl.isNotEmpty)
                                      ? DecorationImage(
                                    image: CachedNetworkImageProvider(widget.event.organizerImageUrl),
                                    fit: BoxFit.fill,
                                  )
                                      : null,
                                  color: (widget.event.organizerImageUrl == null || widget.event.organizerImageUrl.isEmpty)
                                      ? Colors.grey
                                      : null, // A default background color for initials, change as needed.
                                    ),
                                      child: (widget.event.organizerImageUrl == null || widget.event.organizerImageUrl.isEmpty)
                                          ? Center(
                                            child: Text(widget.event.organizer[0],
                                    style: const TextStyle(color: Colors.white, fontSize: 16), // Adjust styling as needed
                                  ),
                                ) : null,
                              ),
                              const Gap(8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      widget.event.organizer,
                                      style: const TextStyle(
                                        color: Color(0xFF09152D),
                                        fontSize: 16,
                                        fontFamily: 'Satoshi',
                                        fontWeight: FontWeight.w500,
                                      )
                                  ),
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
                                widget.event.about,
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
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => BuyTicketScreen(
                      eventId: widget.event.id,
                      eventName: widget.event.name,
                      eventLocation: widget.event.location,
                      eventPrice: widget.event.price,
                      eventDate: widget.event.date,
                      paymentMethod: widget.event.paymentMethod,
                      organizerId: widget.event.organizerId,
                      organizer: widget.event.organizer,
                      eventImage: widget.event.imageUrlHigh
                    ),
                  ),
                );
              },
              child: Container(
                width: AppLayout.getWidth(275), // Adjust the width as desired
                height: AppLayout.getHeight(52), // Adjust the height as desired
                decoration: BoxDecoration(
                  color: const Color(0xFF09152D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        widget.event.price == 0 ? 'Register' : 'Buy Tickets \$${widget.event.price}',
                        style: const TextStyle(
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