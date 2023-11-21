import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../app_layout.dart';
import '../bloc/ViewFriendListBloc/view_friend_list_bloc.dart';
import '../bloc/ViewFriendProfileBloc/friend_profile_bloc.dart';
import 'friend_profile_screen.dart';
import 'notification_card/notification_card1.dart';
import 'notification_card/notification_card2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsScreen extends StatefulWidget {

  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  NotificationScreenState createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationsScreen> with AutomaticKeepAliveClientMixin<NotificationsScreen> {

  final FirebaseAuth auth = FirebaseAuth.instance;
  late final FriendsBloc _friendsBloc;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _friendsBloc = FriendsBloc(); // Initialize the bloc
    _friendsBloc.add(LoadFriends());
  }

  @override
  void dispose() {
    _friendsBloc.close(); // or any cleanup operation
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: CupertinoColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: AppLayout.getHeight(65), bottom: AppLayout.getHeight(10)),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                BackButton(color: Color(0xFF09152D)),
                Text(
                  'Notifications',
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
          Expanded(
            child: BlocBuilder<FriendsBloc, FriendsState>(
              bloc: _friendsBloc,  // Updated to use the local variable
              builder: (context, friendsState) {
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(auth.currentUser!.uid)
                      .collection('Friend Requests')
                      .orderBy('SentAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final requests = snapshot.data?.docs ?? [];

                    if (requests.isEmpty) {
                      return const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            CupertinoIcons.bell_slash_fill,
                            color: Color(0xFF09152D),
                            size: 100.0,
                          ),
                          Text(
                            'No Notifications',
                            style: TextStyle(
                              color: Color(0xFF09152D),
                              fontSize: 24,
                              fontFamily: 'Satoshi',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final request = requests[index];
                        if (request['Status'] == 'Pending') {
                          final requestId = request.id;
                          final senderUid = request['SenderUserId'] ?? 'Default Value';
                          final text1 = request['SenderFirstName'] ?? 'Default Value';
                          final text2 = request['SenderLastName'] ?? 'Default Value';
                          final sentAt = request['SentAt'] ?? 'Default Value';
                          final imageUrl = request['SenderImageUrl'] ?? 'Default Value';
                          Widget notificationCard = Container();
                          notificationCard = NotificationCardType1(
                              requestId: requestId,
                              senderUid: senderUid,
                              text1: text1,
                              text2: text2,
                              sentAt: sentAt,
                              imageUrl: imageUrl,
                          );

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider(
                                    create: (_) => FriendProfileBloc()..add(FetchFriendProfile(friendUid: senderUid)),
                                    child: FriendProfileScreen(
                                      friend: UserFriend(
                                          id: senderUid,
                                          firstName: text1,
                                          lastName: text2,
                                          imageUrl: imageUrl // assuming Friend has an imageUrl attribute
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: notificationCard,
                          );
                        }
                        return Container();
                      },
                    );

                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
