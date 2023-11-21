import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communify_beta_final/app_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gap/gap.dart';
import 'package:timeago/timeago.dart' as timeago;


class NotificationCardType1 extends StatelessWidget {
  final String requestId;
  final String senderUid;
  final String text1;
  final String text2;
  final Timestamp sentAt;
  final String imageUrl;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  NotificationCardType1({super.key,
    required this.requestId,
    required this.senderUid,
    required this.text1,
    required this.text2,
    required this.sentAt,
    required this.imageUrl,
  });

  void acceptRequest(BuildContext context) async {
    // Add current user as a friend
    final currentUserUid = auth.currentUser!.uid;
    DocumentSnapshot userDocument = await _firestore.collection('users').doc(currentUserUid).get();
    DocumentSnapshot senderDocument = await _firestore.collection('users').doc(senderUid).get();
    // Get current user's name and profile picture URL
    String userFirstName = (userDocument.data() as Map<String, dynamic>)['first_name'] ?? "N/A";
    String userLastName = (userDocument.data() as Map<String, dynamic>)['last_name'] ?? "N/A";
    String senderFirstName = (senderDocument.data() as Map<String, dynamic>)['first_name'] ?? "N/A";
    String senderLastName = (senderDocument.data() as Map<String, dynamic>)['last_name'] ?? "N/A";

    await _firestore.collection('users').doc(senderUid).collection('Friends').doc(currentUserUid).set({
      'FriendId' : currentUserUid,
      'friendFirstName' : userFirstName,
      'friendLastName' : userLastName,
      'friendProfilePictureUrl' : 'current user profile picture url', // ??
    });

    await _firestore.collection('users').doc(currentUserUid).collection('Friends').doc(senderUid).set({
      'FriendId' : senderUid,
      'friendFirstName' : senderFirstName,
      'friendLastName' : senderLastName,
      'friendProfilePictureUrl' : 'sender profile picture url', // ??
    });

    // Remove friend request from sub collection
    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .collection('Friend Requests')
        .doc(senderUid)
        .delete();

    FirebaseFirestore.instance
        .collection('users')
        .doc(senderUid)
        .collection('Friend Requests')
        .doc(currentUserUid)
        .delete();

    // Redirect to sender's profile or appropriate screen
    //Navigator.push(
    //  context,
    //  MaterialPageRoute(
    //    builder: (context) => UserProfileScreen(uid: senderUid),
    // ),
    //);
  }

  void rejectRequest() {
    // Remove friend request from sub collection
    final currentUserUid = auth.currentUser!.uid; // Replace with your actual current user UID
    // Remove friend request from sub collection
    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .collection('Friend Requests')
        .doc(senderUid)
        .delete();

    FirebaseFirestore.instance
        .collection('users')
        .doc(senderUid)
        .collection('Friend Requests')
        .doc(currentUserUid)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: imageUrl == '' ?
          CircleAvatar(
            backgroundColor: const Color(0xFFA8B2C6),
            radius: 30,
            child: Text(
              "${text1[0].toUpperCase()}${text2[0].toUpperCase()}",
              style: const TextStyle(
                color: Color(0xFF09152D),
                fontSize: 25,
                fontFamily: 'Satoshi',
                fontWeight: FontWeight.w700,
              ),
            ),
          ) :
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFA8B2C6),
            backgroundImage: CachedNetworkImageProvider(imageUrl),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$text1 $text2",
                style: const TextStyle(
                  color: Color(0xFF09152D),
                  fontSize: 16,
                  fontFamily: 'Satoshi',
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                timeago.format(sentAt.toDate()),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF677489),
                  fontSize: 14,
                  fontFamily: 'Satoshi',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          subtitle: const Text(
            'sent you a friend request!',
            style: TextStyle(
              color: Color(0xFF677489),
              fontSize: 14,
              fontFamily: 'Satoshi',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Gap(AppLayout.getHeight(10)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: AppLayout.getWidth(100), // Adjust the width as desired
              height: AppLayout.getHeight(35), // Adjust the height as desired
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CupertinoButton(
                onPressed: () => rejectRequest(),
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: const Center(
                  child: Text(
                    'Reject',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
            Gap(AppLayout.getWidth(5)),
            Container(
              width: AppLayout.getWidth(100), // Adjust the width as desired
              height: AppLayout.getHeight(35), // Adjust the height as desired
              decoration: BoxDecoration(
                color: const Color(0xFF09152D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CupertinoButton(
                onPressed: () => acceptRequest(context),
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: const Center(
                  child: Text(
                    'Accept',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}