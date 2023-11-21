import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communify_beta_final/app_layout.dart';
import 'package:communify_beta_final/bloc/ViewFriendListBloc/view_friend_list_bloc.dart';
import 'package:communify_beta_final/bloc/ViewFriendProfileBloc/friend_profile_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../full_screen_image.dart';

class FriendProfileScreen extends StatelessWidget {
  final UserFriend friend;

  const FriendProfileScreen({Key? key, required this.friend}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FriendProfileBloc()..add(FetchFriendProfile(friendUid: friend.id)),
      child: Scaffold(
        body: BlocBuilder<FriendProfileBloc, FriendProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProfileLoaded) {
              return SingleChildScrollView(
                child: Padding(
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
                              const Text(
                                "Profile",
                                style: TextStyle(
                                  color: Color(0xFF09152D),
                                  fontSize: 24,
                                  fontFamily: 'Satoshi',
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
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
                                            // Show the report dialog
                                            showCupertinoDialog(
                                              context: context,
                                              builder: (BuildContext context) => CupertinoAlertDialog(
                                                title: const Text('Report Inappropriate'),
                                                content: const Text(
                                                  'Is this user involved in something inappropriate? \n We will review this report within 24 hrs and if deemed inappropriate the post will be removed within that timeframe. We will also take actions against its author.',
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
                                                      // Handle the report functionality here
                                                      // Save report details to your Firestore collection
                                                      final userId = FirebaseAuth.instance.currentUser!.uid;
                                                      final targetId = state.friendProfile.id;
                                                      final targetName = '${state.friendProfile.get('first_name')} ${state.friendProfile.get('last_name')}';
                                                      const reportType = "user";  // or "event" or "club" depending on context

                                                      FirebaseFirestore.instance.collection('reports').add({
                                                        'userId': userId,
                                                        'targetId': targetId,
                                                        'targetName': targetName,
                                                        'reportType': reportType,
                                                        'status': 'pending',
                                                        'sentAt': Timestamp.now().toDate().toIso8601String()
                                                      }).then((_) {
                                                        Navigator.pop(context);
                                                      }).catchError((error) {
                                                        print('error');
                                                        // Optionally show an error message to the user
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
                                                title: const Text('Block User'),
                                                content: const Text('Are you sure you want to block this person?'),
                                                actions: <Widget>[
                                                  CupertinoDialogAction(
                                                    child: const Text('No'),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                  CupertinoDialogAction(
                                                    isDestructiveAction: true, // Makes the text red, typically used for destructive actions
                                                    onPressed: () async {
                                                      await FirebaseFirestore.instance
                                                          .collection('users')
                                                          .doc(FirebaseAuth.instance.currentUser!.uid)
                                                          .update({
                                                        'blocked': FieldValue.arrayUnion([state.friendProfile.id])
                                                      });
                                                      await FirebaseFirestore.instance
                                                          .collection('users')
                                                          .doc(FirebaseAuth.instance.currentUser!.uid)
                                                          .collection('Friends')
                                                          .doc(friend.id)
                                                          .delete();
                                                      if (context.mounted) Navigator.of(context).pop();
                                                      if (context.mounted) Navigator.of(context).pop();
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
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenImage(imageUrl: state.imageUrl),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            radius: 75,
                            backgroundColor: const Color(0xFFA8B2C6),
                            backgroundImage: CachedNetworkImageProvider(state.imageUrl),
                          ),
                        )
                            :
                        CircleAvatar(
                          backgroundColor: const Color(0xFFA8B2C6),
                          radius: 75,
                          child: Text(
                            "${state.friendProfile.get('first_name')[0].toUpperCase()}${state.friendProfile.get('last_name')[0].toUpperCase()}",
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
                          "${state.friendProfile.get('first_name')} ${state.friendProfile.get('last_name')}",
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
                                state.friendsCount.toString(),
                                style: const TextStyle(
                                  color: Color(0xFF09152D),
                                  fontSize: 20,
                                  fontFamily: 'Satoshi',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const Text(
                                'Friends',
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
                                state.clubsCount.toString(),
                                style: const TextStyle(
                                  color: Color(0xFF09152D),
                                  fontSize: 20,
                                  fontFamily: 'Satoshi',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Text(
                                'Clubs',
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
                        state.friendProfile.get('about') ?? 'No information provided',
                        style: const TextStyle(
                          color: Color(0xFF677489),
                          fontSize: 16,
                          fontFamily: 'Satoshi',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is ProfileError) {
              return const Center(child: Text("Error loading profile"));
            } else {
              return const Center(child: Text("Something went wrong"));
            }
          },
        ),
      ),
    );
  }
}
