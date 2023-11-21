import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communify_beta_final/app_layout.dart';
import 'package:communify_beta_final/screens/block_club_list_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class BlockedClubsScreen extends StatefulWidget {
  const BlockedClubsScreen({super.key});

  @override
  BlockedClubsScreenState createState() => BlockedClubsScreenState();
}

class BlockedClubsScreenState extends State<BlockedClubsScreen> {
  @override
  void initState() {
    super.initState();
  }

  Stream<List<String>> getBlockedClubsStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((snapshot) => List<String>.from(snapshot.data()?['blockedClubs'] ?? []));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.white,
      body: Padding(
        padding: EdgeInsets.only(left: AppLayout.getWidth(20), right: AppLayout.getWidth(20)),
        child: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(top: AppLayout.getHeight(20)),
                child: const Row(
                  children: [
                    BackButton(color: Color(0xFF09152D)),
                    Text(
                      'Blocked Clubs',
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
              child: StreamBuilder<List<String>>(
                stream: getBlockedClubsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CupertinoActivityIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: AppLayout.getHeight(100.0), left: AppLayout.getWidth(20.0), right: AppLayout.getWidth(20.0)),
                        child: Column(
                          children: <Widget>[
                            Gap(AppLayout.getHeight(50)),
                            const Icon(
                              Icons.block,
                              color: Color(0xFF09152D),
                              size: 100.0,
                            ),
                            const Text(
                              'No Blocked Clubs',
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
                    );
                  } else {
                    final blockedClubs = snapshot.data!;
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: blockedClubs.length,
                      itemBuilder: (context, index) {
                        return BlockedClubItem(uid: blockedClubs[index]); // Make sure you have a BlockedClubItem widget or replace it with the appropriate widget to represent each blocked club
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
