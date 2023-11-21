import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communify_beta_final/app_layout.dart';
import 'package:communify_beta_final/full_screen_image.dart';
import 'package:communify_beta_final/screens/block_clubs_list_screen.dart';
import 'package:communify_beta_final/screens/block_users_list_screen.dart';
import 'package:communify_beta_final/screens/edit_profile_screen.dart';
import 'package:communify_beta_final/screens/login_screen.dart';
import 'package:communify_beta_final/screens/view_club_list_screen.dart';
import 'package:communify_beta_final/screens/view_friend_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:communify_beta_final/bloc/ProfileBloc/profile_bloc.dart';
import 'package:communify_beta_final/bloc/ProfileBloc/profile_event.dart';
import 'package:communify_beta_final/bloc/ProfileBloc/profile_state.dart';
import 'package:communify_beta_final/bloc/ViewFriendListBloc/view_friend_list_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/ViewClubListBloc/view_club_list_bloc.dart';
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => FriendsBloc()),
        BlocProvider(create: (context) => ClubsBloc()),
        BlocProvider(create: (context) => ProfileBloc()..add(LoadProfile())),
      ],
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  ProfileViewState createState() => ProfileViewState();
}

class ProfileViewState extends State<ProfileView> with AutomaticKeepAliveClientMixin<ProfileView> {
  late final ProfileBloc _profileBloc;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _profileBloc = BlocProvider.of<ProfileBloc>(context, listen: false)..add(LoadProfile());
  }

    @override
  void dispose() {
    _profileBloc.close();
    super.dispose();
  }

  Future<void> _deleteUserFromFirebase() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String userUID = user.uid;

    // Get the reference to Firestore
    var firestore = FirebaseFirestore.instance;

    // Fetch all clubs the user is a part of
    var userClubs = await firestore.collection('users').doc(userUID).collection('Clubs').get();

    // For each club, delete the user entry from the 'Members' subcollection
    for (var clubDoc in userClubs.docs) {
      var clubId = clubDoc.data()['clubId'];
      if (clubId != null) {
        await firestore.collection('clubs').doc(clubId).collection('Members').doc(userUID).delete();
      }
    }

    // Fetch all events the user has registered for
    var userEvents = await firestore.collection('users').doc(userUID).collection('Registered Events').get();

    // For each event, delete the user entry from the 'Attendees' subcollection in the 'events' collection
    for (var eventDoc in userEvents.docs) {
      var eventId = eventDoc.id;  // Document ID is the eventId
      await firestore.collection('events').doc(eventId).collection('Attendees').doc(userUID).delete();
    }

    // Fetch all friend requests with status 'Sent'
    var sentRequests = await firestore.collection('users').doc(userUID).collection('Friend Requests')
        .where('Status', isEqualTo: 'Sent').get();

    // For each sent request, delete the corresponding entry in the receiver's 'Friend Requests' subcollection
    for (var requestDoc in sentRequests.docs) {
      var receiverUID = requestDoc.id;  // Document ID is the receiver's UID
      await firestore.collection('users').doc(receiverUID).collection('Friend Requests').doc(userUID).delete();
    }

    // Fetch all friends of the user
    var userFriends = await firestore.collection('users').doc(userUID).collection('Friends').get();

    // For each friend, delete the user entry from their 'Friends' collection
    for (var friendDoc in userFriends.docs) {
      var friendId = friendDoc.id;
      await firestore.collection('users').doc(friendId).collection('Friends').doc(userUID).delete();
    }

    // Finally, delete the user's main document from the 'users' collection
    await firestore.collection('users').doc(userUID).delete();
  }

  @override
  Widget build(BuildContext context) {
    final friendsBloc = BlocProvider.of<FriendsBloc>(context);
    final clubsBloc = BlocProvider.of<ClubsBloc>(context);
    super.build(context);
    return Scaffold(
      backgroundColor: CupertinoColors.white,
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CupertinoActivityIndicator(color: Color(0xFF09152D)));
          } else if (state is ProfileLoaded) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(left: AppLayout.getWidth(20), right: AppLayout.getWidth(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.only(top: AppLayout.getHeight(10)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Profile',
                              style: TextStyle(
                                color: Color(0xFF09152D),
                                fontSize: 30,
                                fontFamily: 'Satoshi',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            CupertinoButton(
                              child: const Icon(CupertinoIcons.ellipsis_vertical, color: Color(0xFF09152D)),
                              onPressed: () {
                                showCupertinoModalPopup(
                                  context: context,
                                  builder: (BuildContext context) => CupertinoActionSheet(
                                    title: const Text(
                                      "Options",
                                      style: TextStyle(
                                        color: Color(0xFF677489),
                                        fontSize: 14,
                                        fontFamily: 'Satoshi',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    actions: [
                                      CupertinoActionSheetAction(
                                        child: const Text(
                                          "Blocked Users",
                                          style: TextStyle(
                                            color: Color(0xFF09152D),
                                            fontSize: 20,
                                            fontFamily: 'Satoshi',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop(); // Close the actionsheet
                                          Navigator.of(context).push(
                                            CupertinoPageRoute(builder: (context) => const BlockedProfilesScreen()),
                                          );
                                        },
                                      ),
                                      CupertinoActionSheetAction(
                                        child: const Text(
                                          "Blocked Clubs",
                                          style: TextStyle(
                                            color: Color(0xFF09152D),
                                            fontSize: 20,
                                            fontFamily: 'Satoshi',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop(); // Close the actionsheet
                                          Navigator.of(context).push(
                                            CupertinoPageRoute(builder: (context) => const BlockedClubsScreen()),
                                          );
                                        },
                                      ),
                                      CupertinoActionSheetAction(
                                        isDestructiveAction: true, // This makes the text red
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return CupertinoAlertDialog(
                                                title: const Text('Sign Out'),
                                                content: const Text('Are you sure you want to sign out?'),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: const Text('Cancel'),
                                                    onPressed: () {
                                                      Navigator.of(context).pop(); // Closes the dialog
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: const Text('Yes'),
                                                    onPressed: () async {
                                                      _profileBloc.add(UnloadProfile());
                                                      await FirebaseAuth.instance.signOut();
                                                      final prefs = await SharedPreferences.getInstance();
                                                      prefs.setBool('isLoggedIn', false);
                                                      if (context.mounted) {
                                                        Navigator.of(context).pushAndRemoveUntil(
                                                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                                                              (route) => false,
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: const Text(
                                          "SIGN OUT",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontFamily: 'Satoshi',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      CupertinoActionSheetAction(
                                        isDestructiveAction: true, // This makes the text red
                                        onPressed: () {
                                          TextEditingController emailController = TextEditingController();
                                          TextEditingController passwordController = TextEditingController();

                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              bool isLoading = false;
                                              return StatefulBuilder(
                                                  builder: (context, setState) {
                                                    return CupertinoAlertDialog(
                                                      title: const Text('Delete Account'),
                                                      content: isLoading
                                                          ? const CupertinoActivityIndicator()  // Display loading indicator
                                                          : const Text('Are you sure you want to permanently delete this account?'),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          child: const Text('Cancel'),
                                                          onPressed: () {
                                                            Navigator.of(context).pop(); // Closes the dialog
                                                          },
                                                        ),
                                                        TextButton(
                                                          child: const Text('Yes'),
                                                          onPressed: () async {
                                                            // Show re-authentication dialog
                                                            showDialog(
                                                              context: context,
                                                              barrierDismissible: false,
                                                              builder: (BuildContext context) {
                                                                return CupertinoAlertDialog(
                                                                  title: const Text('Re-authenticate'),
                                                                  content: Column(
                                                                    children: [
                                                                      CupertinoTextField(
                                                                        controller: emailController,
                                                                        placeholder: "Email",
                                                                      ),
                                                                      const SizedBox(height: 16),
                                                                      CupertinoTextField(
                                                                        controller: passwordController,
                                                                        placeholder: "Password",
                                                                        obscureText: true,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  actions: [
                                                                    TextButton(
                                                                      child: const Text('Cancel'),
                                                                      onPressed: () {
                                                                        Navigator.of(context).pop();
                                                                      },
                                                                    ),
                                                                    TextButton(
                                                                      child: const Text('Authenticate'),
                                                                      onPressed: () async {
                                                                        setState(() {
                                                                          isLoading = true;  // Set loading state to true when deletion starts
                                                                        });

                                                                        try {
                                                                          UserCredential credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                                                                            email: emailController.text.trim(),
                                                                            password: passwordController.text.trim(),
                                                                          );

                                                                          if (credential.user != null) {
                                                                            // If authentication is successful, delete the user's Firestore and Auth data
                                                                            await _deleteUserFromFirebase();
                                                                            await FirebaseAuth.instance.currentUser?.delete();

                                                                            _profileBloc.add(UnloadProfile());
                                                                            final prefs = await SharedPreferences.getInstance();
                                                                            prefs.setBool('isLoggedIn', false);

                                                                            if (context.mounted) {
                                                                              Navigator.of(context).pushAndRemoveUntil(
                                                                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                                                                                    (route) => false,
                                                                              );
                                                                            }
                                                                          }
                                                                        } catch (e) {
                                                                          print("Error during re-authentication: $e");

                                                                          // Show error message with another Cupertino dialog
                                                                          if (context.mounted) {
                                                                            showDialog(
                                                                              context: context,
                                                                              barrierDismissible: false,
                                                                              builder: (BuildContext context) {
                                                                                return CupertinoAlertDialog(
                                                                                  title: const Text('Authentication Failed'),
                                                                                  content: const Text('Please try again.'),
                                                                                  actions: [
                                                                                    TextButton(
                                                                                      child: const Text('OK'),
                                                                                      onPressed: () {
                                                                                        Navigator.of(context).pop();  // Close the error dialog
                                                                                      },
                                                                                    ),
                                                                                  ],
                                                                                );
                                                                              },
                                                                            );
                                                                          }
                                                                        } finally {
                                                                          setState(() {
                                                                            isLoading = false;  // Reset loading state once done
                                                                          });
                                                                        }
                                                                      },
                                                                    )
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  }
                                              );
                                            },
                                          );
                                        },
                                        child: const Text(
                                          "DELETE ACCOUNT",
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
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Gap(AppLayout.getHeight(25)),
                    BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (context, state) {
                        if (state is ProfileLoaded) {
                          final data = state.profile.data() as Map<String, dynamic>;
                          final imageUrl = state.imageUrl;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Center(
                                child: imageUrl == ''?
                                CircleAvatar(
                                  backgroundColor: const Color(0xFFA8B2C6),
                                  radius: 75,
                                  child: Text(
                                    "${state.profile.get('first_name')[0].toUpperCase()}${state.profile.get('last_name')[0].toUpperCase()}",
                                    style: const TextStyle(
                                      color: Color(0xFF09152D),
                                      fontSize: 60,
                                      fontFamily: 'Satoshi',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ) :
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FullScreenImage(imageUrl: imageUrl),
                                      ),
                                    );
                                  },
                                  child: CircleAvatar(
                                    radius: 75,
                                    backgroundColor: const Color(0xFFA8B2C6),
                                    backgroundImage: CachedNetworkImageProvider(imageUrl),
                                  ),
                                ),
                              ),
                              Gap(AppLayout.getHeight(20)),
                              Center(
                                child: Text(
                                  "${state.profile.get('first_name')} ${state.profile.get('last_name')}",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF09152D),
                                    fontSize: 28,
                                    fontFamily: 'Satoshi',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Gap(AppLayout.getHeight(20)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => FriendList(friendsBloc: friendsBloc),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      children: [
                                        Text(
                                          state.friendsCount.toString(), // assuming you have 'friendsCount' in your data
                                          style: const TextStyle(
                                            color: Color(0xFF09152D),
                                            fontSize: 20,
                                            fontFamily: 'Satoshi',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const Text(
                                          'Friends',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Color(0xFF747688),
                                            fontSize: 16,
                                            fontFamily: 'Satoshi',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Gap(AppLayout.getWidth(30)),
                                  Container(
                                    width: 1,
                                    height: 32,
                                    color: const Color(0xFF747688),
                                  ),
                                  Gap(AppLayout.getWidth(30)),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ClubList(clubsBloc: clubsBloc),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                        state.clubsCount.toString(), // assuming you have 'clubsCount' in your data
                                        style: const TextStyle(
                                          color: Color(0xFF09152D),
                                          fontSize: 20,
                                          fontFamily: 'Satoshi',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Text(
                                        'Clubs',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Color(0xFF747688),
                                          fontSize: 16,
                                          fontFamily: 'Satoshi',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                ],
                              ),
                              Gap(AppLayout.getHeight(25)),
                              CupertinoButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>  EditProfileScreen(profileBloc: _profileBloc),
                                      )
                                  );
                                },
                                child: Center(
                                  child: Container(
                                    width: AppLayout.getWidth(175), // Adjust the width as desired
                                    height: AppLayout.getHeight(50), // Adjust the height as desired
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF09152D),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Stack(
                                      children: [
                                        Center(
                                          child: Text(
                                            'Edit Profile',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Gap(AppLayout.getHeight(40)),
                              const Text(
                                'About Me',
                                style: TextStyle(
                                  color: Color(0xFF09152D),
                                  fontSize: 24,
                                  fontFamily: 'Satoshi',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Gap(AppLayout.getHeight(10)),
                              Text(
                                state.profile.get('about') ?? 'Edit Profile to add your About Me!', // using 'about' from your data
                                style: const TextStyle(
                                  color: Color(0xFF677489),
                                  fontSize: 16,
                                  fontFamily: 'Satoshi',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        } else if (state is ProfileError) {
                          return const Text("No data"); // snapshot.data would be null in this case
                        }
                        return const Center(child: CupertinoActivityIndicator(color: Color(0xFF09152D)));
                      },
                    ),
                  ],
                ),
              ),
            );
          } else if (state is ProfileError) {
            return const Center(child: Text("Error loading profile"));
          }

          // If none of the above conditions are met, return a fallback widget.
          return const Center(child: Text("Something went wrong"));
        },
      ),
    );
  }
}





