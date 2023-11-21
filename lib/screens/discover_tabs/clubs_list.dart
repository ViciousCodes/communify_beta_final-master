import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../app_layout.dart';
import '../../bloc/DiscoverClubBloc/club_event.dart';
import '../../bloc/DiscoverClubBloc/club_bloc.dart';
import '../../bloc/DiscoverClubBloc/club_state.dart';
import '../view_club_profile_screen.dart';

class ClubsList extends StatefulWidget {
  const ClubsList({Key? key}) : super(key: key);

  @override
  ClubsListState createState() => ClubsListState();
}

class ClubsListState extends State<ClubsList> with AutomaticKeepAliveClientMixin<ClubsList> {
  final TextEditingController _search = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  void navigateToClubsProfile(club) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewClubProfileScreen(club: club),
      ),
    );
  }


  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (context) => ClubBloc(firestore, storage)..add(LoadClubs()),
      child: BlocBuilder<ClubBloc, ClubState>(
        builder: (context, state) {
          if (state is ClubsInitial) {
            return const Text("Please load your clubs list.");
          } else if (state is ClubsLoading) {
            return const Center(child: CupertinoActivityIndicator(color: Color(0xFF09152D)));
          } else if (state is ClubsLoaded || state is ClubsSearchResults) {
            final clubs = (state is ClubsLoaded) ? state.clubs : (state as ClubsSearchResults).clubs;
            return Column(
              children: [
                Gap(AppLayout.getHeight(15)),
                Padding(
                  padding: EdgeInsets.only(left: AppLayout.getWidth(15), right: AppLayout.getWidth(15)),
                  child: CupertinoTextField(
                    controller: _search,
                    onChanged: (value) => context.read<ClubBloc>().add(SearchClubs(value)),
                    prefix: Padding(
                      padding: EdgeInsets.only(left: AppLayout.getWidth(5)),
                      child: const Icon(
                        CupertinoIcons.search,
                        color: Color(0xFF677489),
                        size: 22,  // adjust as needed
                      ),
                    ),
                    placeholder: "Search...",
                    placeholderStyle: const TextStyle(
                      color: Color(0xFF677489),
                      fontSize: 15,
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.w400,
                    ),
                    style: const TextStyle(
                      color: Color(0xFF677489),
                      fontSize: 15,
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      border: Border.all(width: 1, color: const Color(0xFF677489)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.only(left: AppLayout.getWidth(5), top: AppLayout.getHeight(7), bottom: AppLayout.getHeight(7)), // adjust as needed
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<ClubBloc>().add(LoadClubs());
                    },
                    color: const Color(0xFF09152D),
                    child:
                      clubs.isEmpty ?
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.domain_disabled_rounded,
                              color: Color(0xFF09152D),
                              size: 100.0,
                            ),
                            const Text(
                              'No Discoverable Clubs',
                              style: TextStyle(
                                color: Color(0xFF09152D),
                                fontSize: 22,
                                fontFamily: 'Satoshi',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            IconButton(
                                iconSize: 40,
                                onPressed: () {
                                  context.read<ClubBloc>().add(LoadClubs());
                                },
                                icon: const FittedBox(
                                  fit: BoxFit.contain,
                                  child: Icon(CupertinoIcons.refresh_circled_solid, color: Color(0xFF09152D)),
                                )
                            )
                          ],
                        )
                      ) :
                      ListView.builder(
                        padding: EdgeInsets.only(top: AppLayout.getWidth(20)),
                        itemCount: clubs.length,
                        itemBuilder: (context, index) {
                          final club = clubs[index];
                          return GestureDetector(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                // Navigate to the friend's profile when the user taps on the list item
                                navigateToClubsProfile(club);
                              },
                          child: Center(
                            child: ListTile(
                              leading: club.imageUrl == '' ?
                                CircleAvatar(
                                  backgroundColor: const Color(0xFFA8B2C6),
                                  radius: 30.0,
                                  child: Text(
                                    club.clubName[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Color(0xFF09152D),
                                      fontSize: 30,
                                      fontFamily: 'Satoshi',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ) :
                                CircleAvatar(
                                  radius: 30.0,
                                  backgroundColor: const Color(0xFFA8B2C6),
                                  backgroundImage: CachedNetworkImageProvider(club.imageUrl),
                                ),
                              title: Text(
                                club.clubName,
                                style: const TextStyle(
                                  color: Color(0xFF09152D),
                                  fontSize: 17,
                                  fontFamily: 'Satoshi',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                'Members: ${club.memberCount}',
                                style: const TextStyle(
                                  color: Color(0xFF677489),
                                  fontSize: 14,
                                  fontFamily: 'Satoshi',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: IconButton(
                                icon: club.isMembershipPending ?
                                const Icon(CupertinoIcons.checkmark_alt, color: CupertinoColors.activeGreen) :
                                const Icon(CupertinoIcons.person_add_solid, color: Color(0xFF09152D)),
                                onPressed: () {
                                  context.read<ClubBloc>().add(AddMemberToClub(club.id));
                                },
                              ),
                            ),
                          ),
                          );
                        },
                      ),
                  ),
                ),
              ],
            );
          } else if (state is ClubsError) {
            return Text("An error occurred: ${state.message}");
          } else {
            return const Text("Unknown state");
          }
        },
      ),
    );
  }
}
