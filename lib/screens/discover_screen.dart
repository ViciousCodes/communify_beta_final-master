import 'package:communify_beta_final/app_layout.dart';
import 'package:communify_beta_final/screens/discover_tabs/clubs_list_algolia.dart';
import 'package:communify_beta_final/screens/discover_tabs/friends_list_algolia.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  DiscoverScreenState createState() => DiscoverScreenState();
}

class DiscoverScreenState extends State<DiscoverScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: CupertinoColors.white,
          body: Padding(
            padding: EdgeInsets.only(left: AppLayout.getWidth(20), right: AppLayout.getWidth(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(top: AppLayout.getHeight(10)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Discover',
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
                Gap(AppLayout.getHeight(10)),
                TabBar(
                  indicator: UnderlineTabIndicator(
                    insets: EdgeInsets.only(left: AppLayout.getWidth(30), right: AppLayout.getWidth(30)),
                    borderSide: const BorderSide(
                      color: Color(0xFF09152D),
                      width: 3,
                    ),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const <Widget>[
                    Tab(
                      child: Text(
                        'FRIENDS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF09152D),
                          fontSize: 18,
                          fontFamily: 'Satoshi',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.16,
                        ),
                      )
                    ),
                    Tab(
                        child: Text(
                          'CLUBS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF09152D),
                            fontSize: 18,
                            fontFamily: 'Satoshi',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.16,
                          ),
                        )
                    ),
                  ],
                ),
                const Expanded(
                  child: TabBarView(
                    children: <Widget>[
                      FriendsListAlgolia(),
                      ClubsListAlgolia(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
