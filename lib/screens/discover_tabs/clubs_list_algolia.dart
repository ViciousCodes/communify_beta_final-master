import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communify_beta_final/app_layout.dart';
import 'package:communify_beta_final/screens/discover_tabs/clubs_list_item.dart';
import 'package:communify_beta_final/screens/other_club_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class Club {
  final String clubName;
  final String imageUrl;
  final String uid;

  Club(this.clubName, this.imageUrl, this.uid);

  static Club fromJson(Map<String, dynamic> json) {
    return Club(json['club_name'], json['image_low_url'], json['objectID']);
  }
}

class HitsPage {
  const HitsPage(this.items, this.pageKey, this.nextPageKey);

  final List<Club> items;
  final int pageKey;
  final int? nextPageKey;

  factory HitsPage.fromResponse(SearchResponse response, List<String> clubIds) {
    final items = response.hits.map(Club.fromJson).toList()
        .where((club) => !clubIds.contains(club.uid)).toList();
    final isLastPage = response.page >= response.nbPages;
    final nextPageKey = isLastPage ? null : response.page + 1;
    return HitsPage(items, response.page, nextPageKey);
  }
}

class ClubsListAlgolia extends StatefulWidget {
  const ClubsListAlgolia({Key? key}) : super(key: key);

  @override
  ClubsListAlgoliaState createState() => ClubsListAlgoliaState();
}

class ClubsListAlgoliaState extends State<ClubsListAlgolia> with AutomaticKeepAliveClientMixin<ClubsListAlgolia> {
  @override
  bool get wantKeepAlive => true;

  void navigateToClubProfile(club) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewClubProfileScreen(club: club),
      ),
    );
  }

  final _clubsSearcher = HitsSearcher(
    applicationID: 'CZTVB1B06Y',
    apiKey: 'd84fa9192170cc279ddea7ce9032fa63',
    indexName: 'clubs',
  );

  final _searchTextController = TextEditingController();
  final PagingController<int, Club> _pagingController = PagingController(firstPageKey: 0);

  Stream<HitsPage> get _searchPage => _clubsSearcher.responses.map((response) {
    return HitsPage.fromResponse(response, _clubsIds);
  });

  List<String> _clubsIds = [];

  Future<List<String>> getCurrentUserClubs() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;
    List<String> userClubs = [];

    if (firebaseUser != null) {

      final responses = await Future.wait([
        firestore.collection('users').doc(firebaseUser.uid).collection('Clubs').get(),
        firestore.collection('users').doc(firebaseUser.uid).get() // Get the user document for blocked users
      ]);

      QuerySnapshot clubsSnapshot = responses[0] as QuerySnapshot;
      for (var doc in clubsSnapshot.docs) {
        userClubs.add(doc.id);
      }

      DocumentSnapshot clubsBlockedSnapshot = responses[1] as DocumentSnapshot;
      final blockedUsers = List<String>.from((clubsBlockedSnapshot.data() as Map<String, dynamic>)['blockedClubs'] ?? []);
      userClubs.addAll(blockedUsers);

    }

    return userClubs;
  }

  bool _isLoading = false;
  @override
  void initState() {
    super.initState();

    _searchTextController.addListener(() {
      _clubsSearcher.applyState((state) => state.copyWith(query: _searchTextController.text, page: 0));
      _pagingController.refresh();
    });

    _searchPage.listen((page) {
      if (_isLoading) {
        _isLoading = false;
        if (page.items.isEmpty) {
          if (page.nextPageKey != null) {
            _isLoading = true;
            _clubsSearcher.applyState((state) => state.copyWith(page: page.nextPageKey!));
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
        _clubsSearcher.applyState((state) => state.copyWith(page: pageKey));
      }
    });

    getCurrentUserClubs().then((value) => _clubsIds = value);
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    _clubsSearcher.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  Widget _hits(BuildContext context) => PagedListView<int, Club>(
      padding: EdgeInsets.zero,
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<Club>(
        animateTransitions: true,
        transitionDuration: const Duration(milliseconds: 500),
        noItemsFoundIndicatorBuilder: (_) => Center(
          child: Padding(
            padding: EdgeInsets.only(top: AppLayout.getHeight(100.0), left: AppLayout.getWidth(20.0), right: AppLayout.getWidth(20.0)),
            child: Column(
              children: <Widget>[
                Gap(AppLayout.getHeight(50)),
                const Icon(
                  CupertinoIcons.building_2_fill,
                  color: Color(0xFF09152D),
                  size: 100.0,
                ),
                const Text(
                  'No Clubs Found',
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
              navigateToClubProfile(item);
            },
            child: ClubListItem(item: item),
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
              _clubsIds = await getCurrentUserClubs();
              _pagingController.refresh();
            },
            child: _hits(context),
          ),
        ),
      ],
    );
  }

}


