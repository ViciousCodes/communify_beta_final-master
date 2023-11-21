import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communify_beta_final/app_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:communify_beta_final/screens/discover_tabs/clubs_list_algolia.dart';
import 'package:flutter/material.dart';

class ClubListItem extends StatefulWidget {
  final Club item;

  const ClubListItem({super.key, required this.item});

  @override
  ClubListItemState createState() => ClubListItemState();
}

class ClubListItemState extends State<ClubListItem> {
  bool _isAdded = false; // This state variable checks if the friend has been added or not.

  Future<bool> addMemberToClub(String clubId) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;
    if (firebaseUser != null) {
      DocumentSnapshot userDocument = await firestore.collection('users').doc(firebaseUser.uid).get();
      DocumentSnapshot clubDocument= await firestore.collection('clubs').doc(clubId).get();

      String memberFirstName = (userDocument.data() as Map<String, dynamic>)['first_name'] ?? "N/A";
      String memberLastName = (userDocument.data() as Map<String, dynamic>)['last_name'] ?? "N/A";

      String clubName = (clubDocument.data() as Map<String, dynamic>)['club_name'] ?? "N/A";

      try {
        await firestore.collection('clubs').doc(clubId).collection('Members').doc(firebaseUser.uid).set({
          'memberFirstName' : memberFirstName,
          'memberLastName' : memberLastName,
          'memberId' : firebaseUser.uid,
          'memberSince' : Timestamp.now(),
        });

        await firestore.collection('users').doc(firebaseUser.uid).collection('Clubs').doc(clubId).set({
          'clubName' : clubName,
          'clubId' : clubId,
          'memberSince' : Timestamp.now(),
        });

        return true;
      } catch (e) {
        print('Failed to add member to club or add club to user: $e');
        return false;
      }
    } else {
      return false;
    }
  }

  void addFriend() {
    // First, we update the UI
    setState(() {
      _isAdded = true; // Set the state to true when the friend is added.
    });

    // Then, we perform the Firestore operations in the background
    addMemberToClub(widget.item.uid).then((isRequestSent) {
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
            widget.item.clubName[0].toUpperCase(),
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
          widget.item.clubName,
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