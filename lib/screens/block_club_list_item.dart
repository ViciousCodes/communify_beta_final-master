import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communify_beta_final/app_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BlockedClubItem extends StatelessWidget {
  final String uid;

  const BlockedClubItem({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('clubs').doc(uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CupertinoActivityIndicator();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const SizedBox.shrink();
        } else {
          final club = snapshot.data!;
          return Padding(
            padding: EdgeInsets.only(top: AppLayout.getHeight(15)),
            child: ListTile(
              leading: club['image_low_url'] == ''?
              CircleAvatar(
                backgroundColor: const Color(0xFFA8B2C6),
                radius: 30.0,
                child: Text(
                  "${club['club_name'][0].toUpperCase()}", // Assuming the club only has a name and not first and last name
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
                backgroundImage: CachedNetworkImageProvider(club['image_low_url']),
              ),
              title: Text(
                '${club['club_name']}',
                style: const TextStyle(
                  color: Color(0xFF09152D),
                  fontSize: 20,
                  fontFamily: 'Satoshi',
                  fontWeight: FontWeight.w700,
                ),
              ),
              trailing: SizedBox(
                width: 100,
                height: 40,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  color: CupertinoColors.destructiveRed,
                  onPressed: () async {
                    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
                      'blockedClubs': FieldValue.arrayRemove([uid])
                    });
                  },
                  child: const Text(
                    'Unblock',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 16,
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
