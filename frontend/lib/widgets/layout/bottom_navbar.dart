import 'package:flutter/material.dart';
import 'package:frontend/utils/app_responsive.dart';

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
    final horizontalPadding = AppResponsive.horizontalPadding(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final navMaxWidth = AppResponsive.isDesktop(context)
        ? 720.0
        : AppResponsive.isTablet(context)
        ? 640.0
        : double.infinity;

    return Positioned(
      bottom: bottomInset > 0 ? bottomInset + 12 : 24,
      left: horizontalPadding,
      right: horizontalPadding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: navMaxWidth),
          child: Container(
            height: AppResponsive.isDesktop(context)
                ? 76
                : AppResponsive.isTablet(context)
                ? 72
                : 68,
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
                  context: context,
                  index: 0,
                  icon: Icons.home_rounded,
                  outlineIcon: Icons.home_outlined,
                  label: 'Home',
                ),
                _buildNavItem(
                  context: context,
                  index: 1,
                  icon: Icons.calendar_today_rounded,
                  outlineIcon: Icons.calendar_today_outlined,
                  label: 'Activity',
                ),
                _buildNavItem(
                  context: context,
                  index: 2,
                  icon: Icons.local_offer_rounded,
                  outlineIcon: Icons.local_offer_outlined,
                  label: 'Promo',
                ),
                _buildNavItem(
                  context: context,
                  index: 3,
                  icon: Icons.settings_rounded,
                  outlineIcon: Icons.settings_outlined,
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData outlineIcon,
    required String label,
  }) {
    final isActive = currentIndex == index;
    final itemWidth = AppResponsive.isDesktop(context)
        ? 88.0
        : AppResponsive.isTablet(context)
        ? 76.0
        : 64.0;
    final iconSize = AppResponsive.isDesktop(context)
        ? 28.0
        : AppResponsive.isTablet(context)
        ? 26.0
        : 24.0;
    final fontSize = AppResponsive.isDesktop(context)
        ? 12.5
        : AppResponsive.isTablet(context)
        ? 12.0
        : 11.0;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: itemWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? icon : outlineIcon,
                key: ValueKey(isActive),
                size: iconSize,
                color: isActive ? Colors.white : Colors.white.withAlpha(153),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: fontSize,
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
