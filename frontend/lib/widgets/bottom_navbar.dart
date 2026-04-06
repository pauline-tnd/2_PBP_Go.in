import 'package:flutter/material.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withAlpha(77),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              icon: Icons.home_rounded,
              outlineIcon: Icons.home_outlined,
              label: 'Home',
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.calendar_today_rounded,
              outlineIcon: Icons.calendar_today_outlined,
              label: 'Activity',
            ),
            _buildNavItem(
              index: 2,
              icon: Icons.local_offer_rounded,
              outlineIcon: Icons.local_offer_outlined,
              label: 'Promo',
            ),
            _buildNavItem(
              index: 3,
              icon: Icons.settings_rounded,
              outlineIcon: Icons.settings_outlined,
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData outlineIcon,
    required String label,
  }) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? icon : outlineIcon,
                key: ValueKey(isActive),
                size: 24,
                color: isActive ? Colors.white : Colors.white.withAlpha(153),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? Colors.white : Colors.white.withAlpha(153),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
