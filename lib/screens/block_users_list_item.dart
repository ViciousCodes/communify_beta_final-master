import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communify_beta_final/app_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BlockedUserItem extends StatelessWidget {
  final String uid;

  const BlockedUserItem({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CupertinoActivityIndicator();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const SizedBox.shrink();
        } else {
          final user = snapshot.data!;
          return Padding(
            padding: EdgeInsets.only(top: AppLayout.getHeight(15)),
            child: ListTile(
              leading: user['image_low_url'] == ''?
              CircleAvatar(
                backgroundColor: const Color(0xFFA8B2C6),
                radius: 30.0,
                child: Text(
                  "${user['first_name'][0].toUpperCase()}${user['last_name'][0].toUpperCase()}",
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
                backgroundImage: CachedNetworkImageProvider(user['image_low_url']),
              ),
              title: Text(
                '${user['first_name']} ${user['last_name']}',
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
                      'blocked': FieldValue.arrayRemove([uid])
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
