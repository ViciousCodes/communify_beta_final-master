import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communify_beta_final/app_layout.dart';
import 'package:communify_beta_final/bloc/ClubHomeBloc/event_bloc.dart';
import 'package:communify_beta_final/screens/club_screens/event_list_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'club_create_event.dart';

class ClubEventsScreen extends StatefulWidget {
  const ClubEventsScreen({Key? key}) : super(key: key);

  @override
  ClubEventsScreenState createState() => ClubEventsScreenState();
}

class ClubEventsScreenState extends State<ClubEventsScreen> with AutomaticKeepAliveClientMixin<ClubEventsScreen>{

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: CupertinoColors.white,
      body: Padding(
        padding: EdgeInsets.only(left: AppLayout.getWidth(20), right: AppLayout.getWidth(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(top: AppLayout.getHeight(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Events',
                      style: TextStyle(
                        color: Color(0xFF09152D),
                        fontSize: 30,
                        fontFamily: 'Satoshi',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.add_circled_solid, color: Color(0xFF09152D), size: 30),
                      onPressed: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const AddEventScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            EventListScreen(bloc: EventBloc(FirebaseFirestore.instance, FirebaseStorage.instance))
          ],
        ),
      ),
    );
  }
}
