import 'package:communify_beta_final/screens/club_screens/club_event_screen.dart';
import 'package:communify_beta_final/screens/club_screens/club_profile.dart';
import 'package:communify_beta_final/screens/club_screens/qr_code_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomNavClub extends StatefulWidget {
  const BottomNavClub({Key? key}) : super(key: key);

  @override
  State<BottomNavClub> createState() => _BottomNavClubState();
}

class _BottomNavClubState extends State<BottomNavClub> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  static final List<Widget> _widgetOptions = <Widget> [
    const ClubEventsScreen(),
    const QrCodeScreen(),
    const ClubProfileScreen(),
  ];

  void onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    ScrollPhysics physics;
    if (_currentIndex == 0) {
      physics = const CustomScrollPhysics(canSwipeLeft: false);
    } else if (_currentIndex == _widgetOptions.length - 1) {
      physics = const CustomScrollPhysics(canSwipeRight: false);
    } else {
      physics = const BouncingScrollPhysics();
    }
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        physics: physics,
        children: _widgetOptions,
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        activeColor: const Color(0xFF09152D),
        inactiveColor: const Color(0xFF677489),
        items: const [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.house), activeIcon: Icon(CupertinoIcons.house_fill), label: "Home"),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.camera), activeIcon: Icon(CupertinoIcons.camera_fill), label: "QR Code"),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.person_3), activeIcon: Icon(CupertinoIcons.person_3_fill), label: "Profile"),
        ],
      ),
    );
  }
}

class CustomScrollPhysics extends ScrollPhysics {
  final bool canSwipeLeft;
  final bool canSwipeRight;

  const CustomScrollPhysics({this.canSwipeLeft = true, this.canSwipeRight = true, ScrollPhysics? parent})
      : super(parent: parent);

  @override
  CustomScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomScrollPhysics(
        canSwipeLeft: canSwipeLeft,
        canSwipeRight: canSwipeRight,
        parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    if (offset > 0.0 && !canSwipeLeft) {
      return 0.0;
    }
    if (offset < 0.0 && !canSwipeRight) {
      return 0.0;
    }
    return offset;
  }
}

