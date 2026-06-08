import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';
import 'home_page.dart';
import 'activity_page.dart';
import 'promo_page.dart';
import 'settings/settings_page.dart';
import 'package:frontend/widgets/bottom_navbar.dart';
import 'package:frontend/pages/home_page.dart';
import 'package:frontend/pages/activity_page.dart';
import 'package:frontend/pages/promo_page.dart';
import 'package:frontend/pages/settings/settings_page.dart';
import 'package:frontend/pages/wishlist_page.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  late int _currentIndex;
  bool _showWishlist = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _pages = const [
    HomePage(), // 0
    ActivityPage(), // 1
    PromoPage(), // 2
    SettingsPage(), // 3
  ];

  void showWishlist() {
    setState(() {
      _showWishlist = true;
    });
  }

  void _hideWishlist() {
    setState(() {
      _showWishlist = false;
    });
  }

  void switchTab(int index) {
    setState(() {
      _showWishlist = false;
      _currentIndex = index;
    });
  }

  void _handleNavTap(int index) {
    switchTab(index);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Back button
      canPop: !_showWishlist, // if not a wishlist page, can pop / back
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _showWishlist) {
          _hideWishlist();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: KeyedSubtree(
                // Make sure if widget changed, so AnimatedSwitcher could work properly
                key: ValueKey(_showWishlist ? 'wishlist' : _currentIndex),
                child: _showWishlist
                    ? WishlistPage(onBack: _hideWishlist)
                    : _pages[_currentIndex],
              ),
            ),
            BottomNavbar(currentIndex: _currentIndex, onTap: _handleNavTap),
          ],
        ),
      ),
    );
  }
}
