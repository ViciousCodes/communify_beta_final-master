import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../app_layout.dart';
import '../../bloc/FriendBloc/friend_bloc.dart';
import '../../bloc/FriendBloc/friend_event.dart';
import '../../bloc/FriendBloc/friend_state.dart';
import '../../screens/other_user_profile.dart';

class FriendsList extends StatefulWidget {
  const FriendsList({Key? key}) : super(key: key);

  @override
  FriendsListState createState() => FriendsListState();
}

class FriendsListState extends State<FriendsList>
    with AutomaticKeepAliveClientMixin<FriendsList> {
  final TextEditingController _search = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  void navigateToFriendProfile(friend) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FriendProfileScreen(friend: friend),
      ),
    );
  }
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (context) => FriendsBloc(firestore, storage)..add(LoadFriends()),
      child: BlocBuilder<FriendsBloc, FriendsState>(
        builder: (context, state) {
          if (state is FriendsInitial) {
            return const Text("Please load your friends list.");
          } else if (state is FriendsLoading) {
            return const Center(child: CupertinoActivityIndicator(color: Color(0xFF09152D)));
          } else if (state is FriendsLoaded || state is FriendsSearchResults) {
            final friends = (state is FriendsLoaded) ? state.friends : (state as FriendsSearchResults).friends;
            return Column(
              children: [
                Gap(AppLayout.getHeight(15)),
                Padding(
                  padding: EdgeInsets.only(left: AppLayout.getWidth(15), right: AppLayout.getWidth(15)),
                  child: CupertinoTextField(
                    controller: _search,
                    onChanged: (value) => context.read<FriendsBloc>().add(SearchFriends(value)),
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
                    padding: EdgeInsets.only(left: AppLayout.getWidth(5), top: AppLayout.getHeight(7), bottom: AppLayout.getHeight(7)),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<FriendsBloc>().add(LoadFriends());
                    },
                    color: const Color(0xFF09152D),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        final friend = friends[index];
                        return GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            // Navigate to the friend's profile when the user taps on the list item
                            navigateToFriendProfile(friend);
                          },
                          child: Center(
                            child: ListTile(
                              leading: friend.imageUrl == '' ?
                              CircleAvatar(
                                backgroundColor: const Color(0xFFA8B2C6),
                                radius: 30.0,
                                child: Text(
                                  "${friend.firstName[0].toUpperCase()}${friend.lastName[0].toUpperCase()}",
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
                                backgroundImage: CachedNetworkImageProvider(friend.imageUrl),
                              ),
                              title: Text(
                                "${friend.firstName} ${friend.lastName}",
                                style: const TextStyle(
                                  color: Color(0xFF09152D),
                                  fontSize: 17,
                                  fontFamily: 'Satoshi',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                'Friends: ${friend.friendCount}',
                                style: const TextStyle(
                                  color: Color(0xFF677489),
                                  fontSize: 14,
                                  fontFamily: 'Satoshi',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: IconButton(
                                icon: friend.isRequestPending
                                    ? const Icon(CupertinoIcons.checkmark_alt, color: CupertinoColors.activeGreen)
                                    : const Icon(CupertinoIcons.person_add_solid, color: Color(0xFF09152D)),
                                onPressed: () {
                                  if (!friend.isRequestPending) {
                                    context.read<FriendsBloc>().add(SendFriendRequest(friend.id));
                                  }
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
          } else if (state is FriendsError) {
            return Text("An error occurred: ${state.message}");
          } else {
            return const Text("Unknown state");
          }
        },
      ),
    );
  }
}