import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communify_beta_final/app_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../bloc/ViewFriendProfileBloc/friend_profile_bloc.dart';
import '../bloc/ViewMembersListBloc/view_members_list_bloc.dart';
import 'friend_profile_screen.dart';


class MembersList extends StatefulWidget {
  final ViewMembersBloc membersBloc;

  const MembersList({required this.membersBloc, Key? key}) : super(key: key);

  @override
  MembersListState createState() => MembersListState();
}


class MembersListState extends State<MembersList> with AutomaticKeepAliveClientMixin<MembersList> {
  final TextEditingController _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.membersBloc.add(LoadMembers());
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: CupertinoColors.white,
      body: Padding(
        padding: EdgeInsets.only(left: AppLayout.getWidth(20), right: AppLayout.getWidth(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(top: AppLayout.getHeight(20)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    BackButton(color: Color(0xFF09152D)),
                    Text(
                      'Your Members',
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
              child: BlocBuilder(
                bloc: widget.membersBloc,
                builder: (BuildContext context, ViewMembersState state) {
                  if (state is MembersLoading) {
                    return const Center(child: CupertinoActivityIndicator(color: Color(0xFF09152D)));
                  } else if (state is MembersLoaded) {
                    return GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                      },
                      child: Column(
                        children: [
                          CupertinoTextField(
                            controller: _searchController,
                            onChanged: (value) => widget.membersBloc.add(SearchMembers(searchText: value)),
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
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: () async {
                                widget.membersBloc.add(LoadMembers());
                              },
                              color: const Color(0xFF09152D),
                              child: state.members.isEmpty ?
                              Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.person_add_disabled_rounded,
                                        color: Color(0xFF09152D),
                                        size: 100.0,
                                      ),
                                      const Text(
                                        'No Members',
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
                                            context.read<ViewMembersBloc>().add(LoadMembers());
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
                                padding: EdgeInsets.zero,
                                itemCount: state.members.length,
                                itemBuilder: (context, index) {
                                  final member = state.members[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: ListTile(
                                      leading: member.imageUrl.isEmpty
                                          ? CircleAvatar(
                                        backgroundColor: const Color(0xFFA8B2C6),
                                        radius: 30.0,
                                        child: Text(
                                          "${member.firstName[0].toUpperCase()}${member.lastName[0].toUpperCase()}",
                                          style: const TextStyle(
                                            color: Color(0xFF09152D),
                                            fontSize: 25,
                                            fontFamily: 'Satoshi',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ) : CircleAvatar(
                                        radius: 30.0,
                                        backgroundImage: CachedNetworkImageProvider(member.imageUrl),
                                      ),
                                      title: Text(
                                        "${member.firstName} ${member.lastName}",
                                        style: const TextStyle(
                                          color: Color(0xFF09152D),
                                          fontSize: 18,
                                          fontFamily: 'Satoshi',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BlocProvider(
                                              create: (_) => FriendProfileBloc()..add(FetchFriendProfile(friendUid: member.id)),
                                              child: FriendProfileScreen(friend: member),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (state is MembersError) {
                    return Text('Error: ${state.message}');
                  }
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
