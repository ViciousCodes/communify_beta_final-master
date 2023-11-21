import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communify_beta_final/app_layout.dart';
import 'package:communify_beta_final/screens/view_club_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:communify_beta_final/bloc/ViewClubListBloc/view_club_list_bloc.dart';
import 'package:communify_beta_final/bloc/ViewClubProfileBloc/clubs_list_profile_bloc.dart';

class ClubList extends StatefulWidget {
  final ClubsBloc clubsBloc;

  const ClubList({required this.clubsBloc, Key? key}) : super(key: key);

  @override
  ClubListState createState() => ClubListState();
}


class ClubListState extends State<ClubList> with AutomaticKeepAliveClientMixin<ClubList> {
  final TextEditingController _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.clubsBloc.add(LoadClubs());
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: CupertinoColors.white,
      body: Padding(
        padding: EdgeInsets.only(left: AppLayout.getWidth(20), right: AppLayout.getWidth(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(top: AppLayout.getHeight(20)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    BackButton(color: Color(0xFF09152D)),
                    Text(
                      'Your Clubs',
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
            Expanded(
              child: BlocBuilder(
                bloc: widget.clubsBloc,
                builder: (BuildContext context, ClubsState state) {
                  if (state is ClubsLoading) {
                    return const Center(child: CupertinoActivityIndicator(color: Color(0xFF09152D)));
                  } else if (state is ClubsLoaded) {
                    return GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                      },
                      child: Column(
                        children: [
                          CupertinoTextField(
                            controller: _searchController,
                            onChanged: (value) => widget.clubsBloc.add(SearchClubs(searchText: value)),
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
                            padding: EdgeInsets.only(left: AppLayout.getWidth(5), top: AppLayout.getHeight(7), bottom: AppLayout.getHeight(7)),
                          ),
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: () async {
                                widget.clubsBloc.add(LoadClubs());
                              },
                              color: const Color(0xFF09152D),
                              child: state.clubs.isEmpty ?
                              Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.person_add_disabled_rounded,
                                        color: Color(0xFF09152D),
                                        size: 100.0,
                                      ),
                                      const Text(
                                        'No Clubs',
                                        style: TextStyle(
                                          color: Color(0xFF09152D),
                                          fontSize: 22,
                                          fontFamily: 'Satoshi',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      IconButton(
                                          iconSize: 40,
                                          onPressed: () {
                                            context.read<ClubsBloc>().add(LoadClubs());
                                          },
                                          icon: const FittedBox(
                                            fit: BoxFit.contain,
                                            child: Icon(CupertinoIcons.refresh_circled_solid, color: Color(0xFF09152D)),
                                          )
                                      )
                                    ],
                                  )
                              ) :
                              ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: state.clubs.length,
                                itemBuilder: (context, index) {
                                  final club = state.clubs[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: ListTile(
                                      leading: club.imageUrl.isEmpty
                                          ? CircleAvatar(
                                        backgroundColor: const Color(0xFFA8B2C6),
                                        radius: 30.0,
                                        child: Text(
                                          club.clubName[0].toUpperCase(),
                                          style: const TextStyle(
                                            color: Color(0xFF09152D),
                                            fontSize: 25,
                                            fontFamily: 'Satoshi',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ) : CircleAvatar(
                                        radius: 30.0,
                                        backgroundImage: CachedNetworkImageProvider(club.imageUrl),
                                      ),
                                      title: Text(
                                        club.clubName,
                                        style: const TextStyle(
                                          color: Color(0xFF09152D),
                                          fontSize: 18,
                                          fontFamily: 'Satoshi',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      trailing: SizedBox(
                                        width: 75,
                                        height: 40,
                                        child: CupertinoButton(
                                          color: const Color(0xFF09152D),
                                          padding: EdgeInsets.zero,
                                          child: const Text(
                                            'Edit',
                                            style: TextStyle(
                                              color: CupertinoColors.white,
                                              fontSize: 16,
                                              fontFamily: 'Satoshi',
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          onPressed: () {
                                            showCupertinoModalPopup(
                                              context: context,
                                              builder: (BuildContext context) => CupertinoActionSheet(
                                                title: const Text(
                                                  'Choose an option',
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
                                                      "Leave",
                                                      style: TextStyle(
                                                        color: Color(0xFF09152D),
                                                        fontSize: 20,
                                                        fontFamily: 'Satoshi',
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                    onPressed: () async {
                                                      Navigator.pop(context);
                                                      // Logic to remove friend from the user's Friends subcollection.
                                                      await FirebaseFirestore.instance
                                                          .collection('users')
                                                          .doc(FirebaseAuth.instance.currentUser!.uid)
                                                          .collection('Clubs')
                                                          .doc(club.id)
                                                          .delete();

                                                      await FirebaseFirestore.instance
                                                          .collection('clubs')
                                                          .doc(club.id)
                                                          .collection('Members')
                                                          .doc(FirebaseAuth.instance.currentUser!.uid)
                                                          .delete();
                                                      // Refresh or rebuild your widget after removing the friend.
                                                      widget.clubsBloc.add(LoadClubs());
                                                    },
                                                  ),
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
                                                            'Is this club involved in something inappropriate ? \n We will review this report within 24 hrs and if deemed inappropriate the post will be removed within that timeframe. We will also take actions against its author.',
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
                                                    onPressed: () {
                                                      // Present a confirmation dialog to the user
                                                      showCupertinoDialog(
                                                        context: context,
                                                        builder: (BuildContext context) => CupertinoAlertDialog(
                                                          title: const Text('Confirmation'),
                                                          content: const Text('Are you sure you wish to block this club? Doing so will remove them from your clubs list.'),
                                                          actions: <Widget>[
                                                            CupertinoDialogAction(
                                                              child: const Text('Cancel'),
                                                              onPressed: () {
                                                                Navigator.of(context).pop(); // Close the confirmation dialog
                                                              },
                                                            ),
                                                            CupertinoDialogAction(
                                                              isDestructiveAction: true,
                                                              child: const Text('Block'),
                                                              onPressed: () async {
                                                                Navigator.of(context).pop(); // Close the confirmation dialog
                                                                Navigator.pop(context); // Close the action sheet

                                                                // Logic to add friend's UID to the Blocked array for the current user.
                                                                await FirebaseFirestore.instance
                                                                    .collection('users')
                                                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                                                    .update({
                                                                  'blockedClubs': FieldValue.arrayUnion([club.id])
                                                                });

                                                                await FirebaseFirestore.instance
                                                                    .collection('users')
                                                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                                                    .collection('Clubs')
                                                                    .doc(club.id)
                                                                    .delete();

                                                                await FirebaseFirestore.instance
                                                                    .collection('clubs')
                                                                    .doc(club.id)
                                                                    .collection('Members')
                                                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                                                    .delete();

                                                                // Refresh or rebuild your widget after blocking the friend.
                                                                widget.clubsBloc.add(LoadClubs());
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                    child: const Text(
                                                      "Block",
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontFamily: 'Satoshi',
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                cancelButton: CupertinoActionSheetAction(
                                                  child: const Text('Cancel'),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BlocProvider(
                                              create: (_) => ClubsListProfileBloc()..add(FetchClubProfile(clubUid: club.id)),
                                              child: ViewClubProfileScreen(club: club),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (state is ClubsError) {
                    return Text('Error: ${state.message}');
                  }
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
