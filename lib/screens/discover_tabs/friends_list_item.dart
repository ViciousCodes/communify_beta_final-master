import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communify_beta_final/app_layout.dart';
import 'package:communify_beta_final/screens/discover_tabs/friends_list_algolia.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FriendListItem extends StatefulWidget {
  final UserFriend item;

  const FriendListItem({super.key, required this.item});

  @override
  FriendListItemState createState() => FriendListItemState();
}

class FriendListItemState extends State<FriendListItem> {
  bool _isAdded = false; // This state variable checks if the friend has been added or not.

  Future<bool> sendFriendRequest(UserFriend friend) async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      final firestore = FirebaseFirestore.instance;
      if (firebaseUser != null) {
        // Get current user's document
        DocumentSnapshot userDocument = await firestore.collection('users').doc(firebaseUser.uid).get();
        DocumentSnapshot receiverDocument = await firestore.collection('users').doc(friend.uid).get();

        // Get current user's name
        String senderFirstName = (userDocument.data() as Map<String, dynamic>)['first_name'] ?? "N/A";
        String senderLastName = (userDocument.data() as Map<String, dynamic>)['last_name'] ?? "N/A";
        String senderImageUrl = (userDocument.data() as Map<String, dynamic>)['image_low_url'] ?? "N/A";
        String receiverFirstName = (receiverDocument.data() as Map<String, dynamic>)['first_name'] ?? "N/A";
        String receiverLastName = (receiverDocument.data() as Map<String, dynamic>)['last_name'] ?? "N/A";
        String receiverImageUrl = (receiverDocument.data() as Map<String, dynamic>)['image_low_url'] ?? "N/A";

        // Current timestamp
        Timestamp sentAt = Timestamp.now();

        // Current user's ID
        String senderUserId = firebaseUser.uid;

        // Add friend request to sender's 'Friend Requests' subcollection
        await firestore.collection('users').doc(senderUserId).collection('Friend Requests').doc(friend.uid).set({
          'ReceiverFirstName' : receiverFirstName,
          'ReceiverLastName' : receiverLastName,
          'ReceiverUserId' : friend.uid,
          'ReceiverImageUrl' : receiverImageUrl,
          'SentAt' : sentAt,
          'Status' : "Sent",
        });

        // Add friend request to receiver's 'Friend Requests' subcollection
        await firestore.collection('users').doc(friend.uid).collection('Friend Requests').doc(senderUserId).set({
          'SenderFirstName' : senderFirstName,
          'SenderLastName' : senderLastName,
          'SenderUserId' : senderUserId,
          'SenderImageUrl' : senderImageUrl,
          'SentAt' : sentAt,
          'Status' : "Pending"
        });

        return true;
      } else {
        throw Exception("No current user found.");
      }
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  void addFriend() {
    // First, we update the UI
    setState(() {
      _isAdded = true; // Set the state to true when the friend is added.
    });

    // Then, we perform the Firestore operations in the background
    sendFriendRequest(widget.item).then((isRequestSent) {
      // We check the result of the request
      if(!isRequestSent) {
        // If the request wasn't successful, we revert the button state
        setState(() {
          _isAdded = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: AppLayout.getHeight(15)),
      child: ListTile(
        leading: widget.item.imageUrl == ''?
        CircleAvatar(
          backgroundColor: const Color(0xFFA8B2C6),
          radius: 30.0,
          child: Text(
            "${widget.item.firstName[0].toUpperCase()}${widget.item.lastName[0].toUpperCase()}",
            style: const TextStyle(
              color: Color(0xFF09152D),
              fontSize: 25,
              fontFamily: 'Satoshi',
              fontWeight: FontWeight.w700,
            ),
          ),
        ) :
        CircleAvatar(
          radius: 30.0,
          backgroundImage: CachedNetworkImageProvider(widget.item.imageUrl),
        ),
        title: Text(
          "${widget.item.firstName} ${widget.item.lastName}",
          style: const TextStyle(
            color: Color(0xFF09152D),
            fontSize: 17,
            fontFamily: 'Satoshi',
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: IconButton(
          icon: _isAdded ?
            const Icon(CupertinoIcons.checkmark_alt, color: CupertinoColors.activeGreen) :
            const Icon(CupertinoIcons.person_add_solid, color: Color(0xFF09152D)),
          onPressed: () {
            if (!_isAdded) {
              addFriend();
              print("Friend added");
            }
          },
        ),
      ),
    );
  }
}
