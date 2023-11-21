import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communify_beta_final/app_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:communify_beta_final/screens/block_users_list_item.dart';
import 'package:gap/gap.dart';

class BlockedProfilesScreen extends StatefulWidget {
  const BlockedProfilesScreen({super.key});

  @override
  BlockedProfilesScreenState createState() => BlockedProfilesScreenState();
}

class BlockedProfilesScreenState extends State<BlockedProfilesScreen> {
  @override
  void initState() {
    super.initState();
  }

  Stream<List<String>> getBlockedUsersStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((snapshot) => List<String>.from(snapshot.data()?['blocked'] ?? []));
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
                      'Blocked Users',
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
                stream: getBlockedUsersStream(), // This should fetch a Stream<List<String>> of blocked user UIDs
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
                              'No Blocked Users',
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
                    final blockedUsers = snapshot.data!;
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: blockedUsers.length,
                      itemBuilder: (context, index) {
                        return BlockedUserItem(uid: blockedUsers[index]);
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
