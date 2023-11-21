import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communify_beta_final/app_layout.dart';
import 'package:communify_beta_final/bloc/ViewFriendProfileBloc/friend_profile_bloc.dart';
import 'package:communify_beta_final/screens/friend_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:communify_beta_final/bloc/ViewFriendListBloc/view_friend_list_bloc.dart';

class FriendList extends StatefulWidget {
  final FriendsBloc friendsBloc;

  const FriendList({required this.friendsBloc, Key? key}) : super(key: key);

  @override
  FriendListState createState() => FriendListState();
}


class FriendListState extends State<FriendList> with AutomaticKeepAliveClientMixin<FriendList> {
  final TextEditingController _searchController = TextEditingController();
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.friendsBloc.add(LoadFriends());
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
                      'Your Friends',
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
                bloc: widget.friendsBloc,
                builder: (BuildContext context, FriendsState state) {
                  if (state is FriendsLoading) {
                    return const Center(child: CupertinoActivityIndicator(color: Color(0xFF09152D)));
                  } else if (state is FriendsLoaded) {
                    return GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                      },
                      child: Column(
                        children: [
                          CupertinoTextField(
                            controller: _searchController,
                            onChanged: (value) => widget.friendsBloc.add(SearchFriends(searchText: value)),
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
                                widget.friendsBloc.add(LoadFriends());
                              },
                              color: const Color(0xFF09152D),
                              child: state.friends.isEmpty ?
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
                                        'No Friends',
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
                                            context.read<FriendsBloc>().add(LoadFriends());
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
                                itemCount: state.friends.length,
                                itemBuilder: (context, index) {
                                  final friend = state.friends[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: ListTile(
                                      leading: friend.imageUrl.isEmpty
                                          ? CircleAvatar(
                                            backgroundColor: const Color(0xFFA8B2C6),
                                            radius: 30.0,
                                            child: Text(
                                              "${friend.firstName[0].toUpperCase()}${friend.lastName[0].toUpperCase()}",
                                              style: const TextStyle(
                                                color: Color(0xFF09152D),
                                                fontSize: 25,
                                                fontFamily: 'Satoshi',
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                      ) : CircleAvatar(
                                        radius: 30.0,
                                        backgroundImage: CachedNetworkImageProvider(friend.imageUrl),
                                      ),
                                      title: Text(
                                        "${friend.firstName} ${friend.lastName}",
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
                                                      "Remove",
                                                      style: TextStyle(
                                                        color: Color(0xFF09152D),
                                                        fontSize: 20,
                                                        fontFamily: 'Satoshi',
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                    onPressed: () async {
                                                      Navigator.pop(context);
                                                      await FirebaseFirestore.instance
                                                          .collection('users')
                                                          .doc(FirebaseAuth.instance.currentUser!.uid)
                                                          .collection('Friends')
                                                          .doc(friend.id)
                                                          .delete();

                                                      await FirebaseFirestore.instance
                                                          .collection('users')
                                                          .doc(friend.id)
                                                          .collection('Friends')
                                                          .doc(FirebaseAuth.instance.currentUser!.uid)
                                                          .delete();
                                                      widget.friendsBloc.add(LoadFriends());
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
                                                                final userId = FirebaseAuth.instance.currentUser!.uid;
                                                                final targetId = friend.id;
                                                                final targetName = '${friend.firstName} ${friend.lastName}';
                                                                const reportType = "user";
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
                                                      Navigator.pop(context);
                                                      showCupertinoDialog(
                                                        context: context,
                                                        builder: (BuildContext context) => CupertinoAlertDialog(
                                                          title: const Text('Confirmation'),
                                                          content: const Text('Are you sure you wish to block this user? Doing so will remove them from your friends list.'),
                                                          actions: <Widget>[
                                                            CupertinoDialogAction(
                                                              child: const Text('Cancel'),
                                                              onPressed: () {
                                                                Navigator.of(context).pop();
                                                              },
                                                            ),
                                                            CupertinoDialogAction(
                                                              isDestructiveAction: true,
                                                              child: const Text('Block'),
                                                              onPressed: () async {
                                                                await FirebaseFirestore.instance
                                                                    .collection('users')
                                                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                                                    .update({
                                                                  'blocked': FieldValue.arrayUnion([friend.id])
                                                                });
                                                                await FirebaseFirestore.instance
                                                                    .collection('users')
                                                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                                                    .collection('Friends')
                                                                    .doc(friend.id)
                                                                    .delete();
                                                                widget.friendsBloc.add(LoadFriends());
                                                                if (context.mounted) Navigator.of(context).pop();
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
                                              )
                                            );
                                          },
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BlocProvider(
                                              create: (_) => FriendProfileBloc()..add(FetchFriendProfile(friendUid: friend.id)),
                                              child: FriendProfileScreen(friend: friend),
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
                  } else if (state is FriendsError) {
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
