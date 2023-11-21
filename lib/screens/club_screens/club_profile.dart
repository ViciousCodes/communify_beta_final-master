import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communify_beta_final/app_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:communify_beta_final/bloc/ClubProfileBloc/club_profile_bloc.dart';
import 'package:communify_beta_final/bloc/ClubProfileBloc/club_profile_state.dart';
import 'package:communify_beta_final/bloc/ClubProfileBloc/club_profile_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/ViewMembersListBloc/view_members_list_bloc.dart';
import '../login_screen.dart';
import '../view_members_list_screen.dart';
import 'club_edit_profile_screen.dart';

class ClubProfileScreen extends StatelessWidget {
  const ClubProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ViewMembersBloc()),
        BlocProvider(create: (context) => ClubProfileBloc()..add(LoadProfile())),
    ],

      child: const ClubProfileView(),
    );
  }
}

class ClubProfileView extends StatefulWidget {
  const ClubProfileView({Key? key}) : super(key: key);

  @override
  ClubProfileViewState createState() => ClubProfileViewState();
}

class ClubProfileViewState extends State<ClubProfileView> with AutomaticKeepAliveClientMixin<ClubProfileView> {
  late final ClubProfileBloc _clubProfileBloc;
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _clubProfileBloc = BlocProvider.of<ClubProfileBloc>(context, listen: false)..add(LoadProfile());
  }

  @override
  void dispose() {
    _clubProfileBloc.close();
    super.dispose();
  }

  Future<void> _deleteClubFromFirebase() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String userUID = user.uid;

    // Get the reference to Firestore
    var firestore = FirebaseFirestore.instance;

    var clubMembers = await firestore.collection('clubs').doc(userUID).collection('Members').get();

    // 2. For each member...
    for (var memberDoc in clubMembers.docs) {

      // Get their UID which is the ID of the memberDoc
      var memberUID = memberDoc.id;

      // 3. Find the corresponding user in the 'users' collection
      // and navigate to the 'Clubs' subcollection for that user
      var userClubs = await firestore.collection('users').doc(memberUID).collection('Clubs').get();

      // 4. Delete the entries where the document ID matches the UID of the current club
      for (var clubDoc in userClubs.docs) {
        if (clubDoc.id == userUID) {
          await clubDoc.reference.delete();
        }
      }

      await memberDoc.reference.delete();
    }

    // Get all events organized by this club
    var clubEvents = await firestore.collection('events').where('organizerId', isEqualTo: userUID).get();

    // For each event...
    for (var eventDoc in clubEvents.docs) {

      // 1. Get all attendees of that event
      var attendees = await eventDoc.reference.collection('Attendees').get();

      // 2. For each attendee...
      for (var attendeeDoc in attendees.docs) {

        // Get their UID which is the ID of the attendeeDoc
        var attendeeUID = attendeeDoc.id;

        // 3. Find their corresponding document in the 'users' collection
        // Go to the 'Registered Events' subcollection of that user
        var registeredEvents = await firestore.collection('users').doc(attendeeUID).collection('Registered Events').get();

        // Delete any event entries that were organized by the club we are deleting
        for (var regEventDoc in registeredEvents.docs) {
          if (regEventDoc.data()['organizerId'] == userUID) {
            await regEventDoc.reference.delete();
          }
        }

        await attendeeDoc.reference.delete();
      }

      // After cleaning up all attendees' registered events, delete the main event
      await eventDoc.reference.delete();
    }

    await firestore.collection('clubs').doc(userUID).delete();
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    final membersBloc = BlocProvider.of<ViewMembersBloc>(context);
    return Scaffold(
      backgroundColor: CupertinoColors.white,
      body: BlocBuilder<ClubProfileBloc, ClubProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CupertinoActivityIndicator(color: Color(0xFF09152D)));
          } else if (state is ProfileLoaded) {
            return Padding(
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
                          IconButton(
                            icon: const Icon(CupertinoIcons.ellipsis_vertical, color: Color(0xFF09152D)),
                            onPressed: () {
                              showCupertinoModalPopup(
                                context: context,
                                builder: (BuildContext context) {
                                  return CupertinoActionSheet(
                                    title: const Text('Sign Out'),
                                    actions: <Widget>[
                                      CupertinoActionSheetAction(
                                        isDestructiveAction: true,
                                        onPressed: () {
                                          Navigator.of(context).pop(); // Close the action sheet

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
                                                      _clubProfileBloc.add(UnloadProfile());
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
                                                                            await _deleteClubFromFirebase();
                                                                            await FirebaseAuth.instance.currentUser?.delete();

                                                                            _clubProfileBloc.add(UnloadProfile());
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
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gap(AppLayout.getHeight(25)),
                  Expanded(
                    flex: 1,
                    child: BlocBuilder<ClubProfileBloc, ClubProfileState>(
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
                                    "${state.profile.get('club_name')[0].toUpperCase()}",
                                    style: const TextStyle(
                                      color: Color(0xFF09152D),
                                      fontSize: 60,
                                      fontFamily: 'Satoshi',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ) :
                                CircleAvatar(
                                  radius: 75,
                                  backgroundColor: const Color(0xFFA8B2C6),
                                  backgroundImage: CachedNetworkImageProvider(imageUrl),
                                ),
                              ),
                              Gap(AppLayout.getHeight(20)),
                              Center(
                                child: Text(
                                  "${state.profile.get('club_name')}",
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
                                          builder: (context) => MembersList(membersBloc: membersBloc),
                                        ),
                                      );
                                    },
                                  child: Column(
                                    children: [
                                      Text(
                                        state.membersCount.toString(), // assuming you have 'friendsCount' in your data
                                        style: const TextStyle(
                                          color: Color(0xFF09152D),
                                          fontSize: 20,
                                          fontFamily: 'Satoshi',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Text(
                                        'Members',
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
                                  Column(
                                    children: [
                                      Text(
                                        state.eventsCount.toString(), // assuming you have 'clubsCount' in your data
                                        style: const TextStyle(
                                          color: Color(0xFF09152D),
                                          fontSize: 20,
                                          fontFamily: 'Satoshi',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Text(
                                        'Events',
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
                                ],
                              ),
                              Gap(AppLayout.getHeight(25)),
                              CupertinoButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>  ClubEditProfileScreen(clubProfileBloc: _clubProfileBloc),
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
                  ),
                ],
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





