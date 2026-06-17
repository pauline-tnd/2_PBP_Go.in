import 'package:flutter/material.dart';

enum SortOption {
  none,
  priceHighToLow,
  priceLowToHigh,
  ratingHighToLow,
  popularity,
}

class SortingBar extends StatelessWidget {
  final SortOption selectedSort;
  final Function(SortOption) onSortChanged;

  const SortingBar({
    super.key,
    required this.selectedSort,
    required this.onSortChanged,
  });

  String _sortLabel(SortOption option) {
    switch (option) {
      case SortOption.none:
        return 'None';
      case SortOption.priceHighToLow:
        return 'Price: High to Low';
      case SortOption.priceLowToHigh:
        return 'Price: Low to High';
      case SortOption.ratingHighToLow:
        return 'Rating: High to Low';
      case SortOption.popularity:
        return 'Popularity';
      // case SortOption.distance:
      //   return 'Distance';
    }
  }

  IconData _sortIcon(SortOption option) {
    switch (option) {
      case SortOption.none:
        return Icons.remove_rounded;
      case SortOption.priceHighToLow:
        return Icons.arrow_downward_rounded;
      case SortOption.priceLowToHigh:
        return Icons.arrow_upward_rounded;
      case SortOption.ratingHighToLow:
        return Icons.star_outline_rounded;
      case SortOption.popularity:
        return Icons.local_fire_department_outlined;
      // case SortOption.distance:
      //   return Icons.near_me_outlined;
    }
  }

  void _showSortMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sort By',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            ...SortOption.values.map((option) {
              final isSelected = selectedSort == option;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                onTap: () {
                  onSortChanged(option);
                  Navigator.pop(context);
                },
                leading: Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: isSelected
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF94A3B8),
                  size: 22,
                ),
                title: Row(
                  children: [
                    Icon(
                      _sortIcon(option),
                      size: 18,
                      color: isSelected
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _sortLabel(option),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPill({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF3B82F6).withAlpha(46)
              : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? const Color(0xFF3B82F6)
                : const Color(0xFF94A3B8).withAlpha(97),
            width: isActive ? 1.0 : 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 3),
            Icon(
              icon,
              size: 14,
              color: isActive
                  ? const Color(0xFF3B82F6)
                  : const Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isPriceActive =
        selectedSort == SortOption.priceHighToLow ||
        selectedSort == SortOption.priceLowToHigh;
    final bool isRatingActive = selectedSort == SortOption.ratingHighToLow;
    // final bool isDistanceActive = selectedSort == SortOption.distance;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // sort (antara header-list hotel) : price, rating, jarak
          GestureDetector(
            onTap: () => _showSortMenu(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: selectedSort != SortOption.none
                    ? const Color(0xFF3B82F6).withAlpha(46)
                    : const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selectedSort != SortOption.none
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF94A3B8).withAlpha(97),
                  width: selectedSort != SortOption.none ? 1.0 : 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sort_rounded,
                    size: 16,
                    color: selectedSort != SortOption.none
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Sort',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selectedSort != SortOption.none
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // price
          _buildPill(
            label: 'Price',
            icon: Icons.arrow_upward_rounded,
            isActive: isPriceActive,
            onTap: () {
              if (isPriceActive) {
                onSortChanged(SortOption.none);
              } else {
                onSortChanged(SortOption.priceLowToHigh);
              }
            },
          ),
          const SizedBox(width: 8),

          // rating
          _buildPill(
            label: 'Rating',
            icon: Icons.arrow_upward_rounded,
            isActive: isRatingActive,
            onTap: () {
              if (isRatingActive) {
                onSortChanged(SortOption.none);
              } else {
                onSortChanged(SortOption.ratingHighToLow);
              }
            },
          ),
          const SizedBox(width: 8),

          // jarak
          // _buildPill(
          //   label: 'Distance',
          //   icon: Icons.near_me_outlined,
          //   isActive: isDistanceActive,
          //   onTap: () {
          //     if (isDistanceActive) {
          //       onSortChanged(SortOption.none);
          //     } else {
          //       onSortChanged(SortOption.distance);
          //     }
          //   },
          // ),
          // const SizedBox(width: 8),

          // dll, tapi skarang ga kliatan karna uda mentok si jaraknya
          // kl cm 2 tanpa jarak, sisa stlh 3 titik kebanyakan
          GestureDetector(
            onTap: () => _showSortMenu(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF94A3B8).withAlpha(97),
                  width: 0.5,
                ),
              ),
              child: const Icon(
                Icons.more_horiz_rounded,
                size: 18,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
