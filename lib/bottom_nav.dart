import 'package:communify_beta_final/screens/Feed/event_gallery_screen.dart';
import 'package:communify_beta_final/screens/discover_screen.dart';
import 'package:communify_beta_final/screens/home_screen.dart';
import 'package:communify_beta_final/screens/profile_screen.dart';
import 'package:communify_beta_final/screens/registered_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomNav extends StatefulWidget {
  final int initialIndex;
  const BottomNav({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  late int _currentIndex;
  late PageController _pageController;

  static final List<Widget> _widgetOptions = <Widget> [
    const HomeScreen(),
    const DiscoverScreen(),
    // const EventGallery(),
    const RegisteredScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

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
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.search), activeIcon: Icon(CupertinoIcons.search), label: "Discover"),
          // BottomNavigationBarItem(icon: Icon(CupertinoIcons.camera), activeIcon: Icon(CupertinoIcons.camera_fill), label: "Communified"),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.bookmark), activeIcon: Icon(CupertinoIcons.bookmark_fill), label: "Registered"),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.person), activeIcon: Icon(CupertinoIcons.person_fill), label: "Profile"),
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

