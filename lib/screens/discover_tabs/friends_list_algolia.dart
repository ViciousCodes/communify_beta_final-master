import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communify_beta_final/app_layout.dart';
import 'package:communify_beta_final/screens/discover_tabs/friends_list_item.dart';
import 'package:communify_beta_final/screens/other_user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class UserFriend {
  final String firstName;
  final String lastName;
  final String imageUrl;
  final String uid;

  UserFriend(this.firstName, this.lastName, this.imageUrl, this.uid);

  static UserFriend fromJson(Map<String, dynamic> json) {
    return UserFriend(json['first_name'], json['last_name'], json['image_low_url'], json['objectID']);
  }
}

class HitsPage {
  const HitsPage(this.items, this.pageKey, this.nextPageKey);

  final List<UserFriend> items;
  final int pageKey;
  final int? nextPageKey;

  factory HitsPage.fromResponse(SearchResponse response, List<String> friendsIds, String? currentUserId) {
    final items = response.hits.map(UserFriend.fromJson).toList()
        .where((userFriend) =>
        userFriend.uid != currentUserId &&
        !friendsIds.contains(userFriend.uid)
    ).toList();
    final isLastPage = response.page >= response.nbPages;
    final nextPageKey = isLastPage ? null : response.page + 1;
    return HitsPage(items, response.page, nextPageKey);
  }
}

class FriendsListAlgolia extends StatefulWidget {
  const FriendsListAlgolia({Key? key}) : super(key: key);

  @override
  FriendsListAlgoliaState createState() => FriendsListAlgoliaState();
}

class FriendsListAlgoliaState extends State<FriendsListAlgolia> with AutomaticKeepAliveClientMixin<FriendsListAlgolia> {

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

  final _friendsSearcher = HitsSearcher(
      applicationID: 'CZTVB1B06Y',
      apiKey: 'd84fa9192170cc279ddea7ce9032fa63',
      indexName: 'users',
  );

  final _searchTextController = TextEditingController();
  final PagingController<int, UserFriend> _pagingController = PagingController(firstPageKey: 0);

  Stream<HitsPage> get _searchPage => _friendsSearcher.responses.map((response) {
    return HitsPage.fromResponse(response, _friendsIds, FirebaseAuth.instance.currentUser?.uid);
  });

  List<String> _friendsIds = [];

  Future<List<String>> getCurrentUserFriendsAndRequests() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;
    List<String> friendsAndRequests = [];

    if (firebaseUser != null) {
      // Fetch both collections concurrently
      final responses = await Future.wait([
        firestore.collection('users').doc(firebaseUser.uid).collection('Friends').get(),
        firestore.collection('users').doc(firebaseUser.uid).collection('Friend Requests').get(),
        firestore.collection('users').doc(firebaseUser.uid).get() // Get the user document for blocked users
      ]);

      // Friend collection
      QuerySnapshot friendsSnapshot = responses[0] as QuerySnapshot;
      for (var doc in friendsSnapshot.docs) {
        friendsAndRequests.add(doc.id);
      }

      // Friend request collection
      QuerySnapshot friendRequestsSnapshot = responses[1] as QuerySnapshot;
      for (var doc in friendRequestsSnapshot.docs) {
        friendsAndRequests.add(doc.id);
      }

      // Blocked users
      DocumentSnapshot userSnapshot = responses[2] as DocumentSnapshot;
      final blockedUsers = List<String>.from((userSnapshot.data() as Map<String, dynamic>)['blocked'] ?? []);
      friendsAndRequests.addAll(blockedUsers);
    }

    return friendsAndRequests;
  }

  bool _isLoading = false;
  @override
  void initState() {
    super.initState();

    _searchTextController.addListener(() {
      _friendsSearcher.applyState((state) => state.copyWith(query: _searchTextController.text, page: 0));
      _pagingController.refresh();
    });

    _searchPage.listen((page) {
      if (_isLoading) {
        _isLoading = false;
        if (page.items.isEmpty) {
          if (page.nextPageKey != null) {
            _isLoading = true;
            _friendsSearcher.applyState((state) => state.copyWith(page: page.nextPageKey!));
          } else {
            _pagingController.appendLastPage([]);
          }
        } else {
          _pagingController.appendPage(page.items, page.nextPageKey);
        }
      }
    }).onError((error) => _pagingController.error = error);

    _pagingController.addPageRequestListener((pageKey) {
      if (!_isLoading) {
        _isLoading = true;
        _friendsSearcher.applyState((state) => state.copyWith(page: pageKey));
      }
    });

    getCurrentUserFriendsAndRequests().then((value) => _friendsIds = value);
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    _friendsSearcher.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  Widget _hits(BuildContext context) => PagedListView<int, UserFriend>(
      padding: EdgeInsets.zero,
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<UserFriend>(
        animateTransitions: true,
        transitionDuration: const Duration(milliseconds: 500),
        noItemsFoundIndicatorBuilder: (_) => Center(
          child: Padding(
            padding: EdgeInsets.only(top: AppLayout.getHeight(100.0), left: AppLayout.getWidth(20.0), right: AppLayout.getWidth(20.0)),
            child: Column(
              children: <Widget>[
                Gap(AppLayout.getHeight(50)),
                const Icon(
                  Icons.no_accounts_outlined,
                  color: Color(0xFF09152D),
                  size: 100.0,
                ),
                const Text(
                  'No Friends Found',
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
        ),
        itemBuilder: (_, item, __) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              navigateToFriendProfile(item);
            },
            child: FriendListItem(item: item),
          );
        },
        firstPageProgressIndicatorBuilder: (_) => const CupertinoActivityIndicator(),
        newPageProgressIndicatorBuilder: (_) => Container(),
      )
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: <Widget>[
        Gap(AppLayout.getHeight(15)),
        Padding(
          padding: EdgeInsets.only(left: AppLayout.getWidth(15), right: AppLayout.getWidth(15)),
          child: CupertinoTextField(
            controller: _searchTextController,
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
            color: const Color(0xFF09152D),
            onRefresh: () async {
              _friendsIds = await getCurrentUserFriendsAndRequests();
              _pagingController.refresh();
            },
            child: _hits(
              context
            ),
          ),
        ),
      ],
    );
  }
}