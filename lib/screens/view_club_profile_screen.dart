import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:communify_beta_final/app_layout.dart';
import 'package:communify_beta_final/bloc/ViewClubListBloc/view_club_list_bloc.dart';
import 'package:communify_beta_final/bloc/ViewClubProfileBloc/clubs_list_profile_bloc.dart';

class ViewClubProfileScreen extends StatelessWidget {
  final Club club;

  const ViewClubProfileScreen({Key? key, required this.club}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ClubsListProfileBloc()..add(FetchClubProfile(clubUid: club.id)),
      child: Scaffold(
        backgroundColor: CupertinoColors.white,
        body: BlocBuilder<ClubsListProfileBloc, ClubListProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CupertinoActivityIndicator(color: Color(0xFF09152D)));
            } else if (state is ProfileLoaded) {
              String clubName = state.clubProfile.get('club_name');
              List<String> words = clubName.split(' '); // split club name into words
              String initials = words.map((word) => word.isNotEmpty ? word[0] : '').join().toUpperCase();
              return Padding(
                padding: EdgeInsets.only(left: AppLayout.getWidth(20), right: AppLayout.getWidth(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.only(top: AppLayout.getHeight(20)),
                        child: Row(
                          children: [
                            const BackButton(color: Color(0xFF09152D)),
                            Text(
                              "$initials's Profile",
                              style: const TextStyle(
                                color: Color(0xFF09152D),
                                fontSize: 30,
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
                                                'Is this club involved in something inappropriate? \n We will review this report within 24 hrs and if deemed inappropriate the post will be removed within that timeframe. We will also take actions against its author.',
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
                                                    final targetId = club.id;
                                                    final targetName = club.clubName;
                                                    const reportType = "club";
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
                                      CupertinoActionSheetAction(
                                        isDestructiveAction: true,
                                        child: const Text(
                                          "Block",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontFamily: 'Satoshi',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        onPressed: () {
                                          // Close the actionsheet first
                                          Navigator.pop(context);

                                          // Show confirmation dialog
                                          showCupertinoDialog(
                                            context: context,
                                            builder: (BuildContext context) => CupertinoAlertDialog(
                                              title: const Text('Block Club'),
                                              content: const Text('Are you sure you want to block this club?'),
                                              actions: <Widget>[
                                                CupertinoDialogAction(
                                                  child: const Text('No'),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                CupertinoDialogAction(
                                                  isDestructiveAction: true, // Makes the text red, typically used for destructive actions
                                                  onPressed: () {
                                                    // Handle the block functionality here
                                                    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;  // assuming you have access to the auth instance
                                                    final blockedUserUid = state.clubProfile.id; // assuming the friendProfile DocumentSnapshot has the id property

                                                    FirebaseFirestore.instance
                                                        .collection('users')
                                                        .doc(currentUserUid)
                                                        .update({
                                                      'blockedClubs': FieldValue.arrayUnion([blockedUserUid])
                                                    }).then((_) {
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                    }).catchError((error) {
                                                      print("Error blocking user: $error");
                                                      // Optionally show an error message to the user
                                                    });
                                                  },
                                                  child: const Text('Yes'),
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
                    Gap(AppLayout.getHeight(25)),
                    Center(
                      child: state.imageUrl.isNotEmpty ?
                      CircleAvatar(
                        radius: 75,
                        backgroundColor: const Color(0xFFA8B2C6),
                        backgroundImage: CachedNetworkImageProvider(state.imageUrl),
                      )
                          :
                      CircleAvatar(
                        backgroundColor: const Color(0xFFA8B2C6),
                        radius: 75,
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Color(0xFF09152D),
                            fontSize: 60,
                            fontFamily: 'Satoshi',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Gap(AppLayout.getHeight(20)),
                    Center(
                      child: Text(
                        "${state.clubProfile.get('club_name')}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF09152D),
                          fontSize: 28,
                          fontFamily: 'Satoshi',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Gap(AppLayout.getHeight(20)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              state.membersCount.toString(),
                              style: const TextStyle(
                                color: Color(0xFF09152D),
                                fontSize: 20,
                                fontFamily: 'Satoshi',
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const Text(
                              'Members',
                              style: TextStyle(
                                color: Color(0xFF747688),
                                fontSize: 16,
                                fontFamily: 'Satoshi',
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ],
                        ),
                        Gap(AppLayout.getWidth(30)),
                        Container(
                          width: 1,
                          height: 32,
                          color: const Color(0xFF747688),
                        ),
                        Gap(AppLayout.getWidth(30)),
                        Column(
                          children: [
                            Text(
                              state.eventsCount.toString(),
                              style: const TextStyle(
                                color: Color(0xFF09152D),
                                fontSize: 20,
                                fontFamily: 'Satoshi',
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const Text(
                              'Events',
                              style: TextStyle(
                                color: Color(0xFF747688),
                                fontSize: 16,
                                fontFamily: 'Satoshi',
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                    Gap(AppLayout.getHeight(40)),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'About Me',
                        style: TextStyle(
                          color: Color(0xFF09152D),
                          fontSize: 24,
                          fontFamily: 'Satoshi',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Gap(AppLayout.getHeight(20)),
                    Text(
                      state.clubProfile.get('about') ?? 'No information provided',
                      style: const TextStyle(
                        color: Color(0xFF677489),
                        fontSize: 16,
                        fontFamily: 'Satoshi',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is ProfileError) {
              return const Center(child: Text("Error loading profile"));
            }

            // If none of the above conditions are met, return a fallback widget.
            return const Center(child: Text("Something went wrong"));
          },
        ),
      ),
    );
  }
}