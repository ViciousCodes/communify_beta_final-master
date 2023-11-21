import 'package:communify_beta_final/app_layout.dart';
import 'package:communify_beta_final/screens/notifications_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:communify_beta_final/bloc/EventHomeBloc/event_event.dart';
import 'package:communify_beta_final/bloc/EventHomeBloc/event_bloc.dart';
import 'event_list.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin<HomeScreen>{
  late TextEditingController _search;
  late EventBloc _eventBloc;
  final firebaseUser = FirebaseAuth.instance.currentUser;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController();
    _eventBloc = EventBloc(FirebaseFirestore.instance, FirebaseStorage.instance);
  }

  @override
  void dispose() {
    _search.dispose();
    _eventBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent, // Set your preferred status bar color
    ));
    return BlocProvider<EventBloc>(
      create: (context) => _eventBloc,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: CupertinoColors.white,
          body: Padding(
            padding: EdgeInsets.only(left: AppLayout.getWidth(20), right: AppLayout.getWidth(20)),
            child: Column(
              children: [
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(top: AppLayout.getHeight(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Events',
                          style: TextStyle(
                            color: Color(0xFF09152D),
                            fontSize: 30,
                            fontFamily: 'Satoshi',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(firebaseUser!.uid) // Replace with your actual current user UID
                              .collection('Friend Requests')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return IconButton(
                                icon: const Icon(CupertinoIcons.bell_fill, color: Color(0xFF09152D)),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => const NotificationsScreen(),
                                    ),
                                  );
                                },
                              );
                            } else {
                              var pendingRequests = snapshot.data!.docs.where((doc) => doc['Status'] == 'Pending').length;
                              return Stack(
                                children: <Widget>[
                                  IconButton(
                                    icon: const Icon(CupertinoIcons.bell_fill, color: Color(0xFF09152D), size: 30,),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) => NotificationsScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  pendingRequests > 0 ? Positioned(
                                    right: AppLayout.getWidth(4),
                                    top: AppLayout.getHeight(4),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 19,
                                        minHeight: 19,
                                      ),
                                      child: Text(
                                        pendingRequests > 9 ? '9+' : '$pendingRequests',
                                        style: const TextStyle(
                                          color: CupertinoColors.white,
                                          fontSize: 13,
                                          fontFamily: 'Satoshi',
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ) : Container(),
                                ],
                              );
                            }
                          },
                        )
                      ],
                    ),
                  ),
                ),
                Gap(AppLayout.getHeight(5)),
                CupertinoTextField(
                  controller: _search,
                  onChanged: (value) {
                    _eventBloc.add(SearchEvents(value));
                  },
                  prefix: Padding(
                    padding: EdgeInsets.only(left: AppLayout.getWidth(5)),
                    child: const Icon(
                      CupertinoIcons.search,
                      color: Color(0xFF677489),
                      size: 22,  // adjust as needed
                    ),
                  ),
                  placeholder: "Search...",
                  placeholderStyle: const TextStyle(
                    color: Color(0xFF677489),
                    fontSize: 15,
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w400,
                  ),
                  style: const TextStyle(
                    color: Color(0xFF677489),
                    fontSize: 15,
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    border: Border.all(width: 1, color: const Color(0xFF677489)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.only(left: AppLayout.getWidth(5), top: AppLayout.getHeight(7), bottom: AppLayout.getHeight(7)), // adjust as needed
                ),
                EventListScreen(bloc: EventBloc(FirebaseFirestore.instance, FirebaseStorage.instance)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}