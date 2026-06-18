import 'package:flutter/material.dart';
import '../../models/hotel.dart';
import '../hotel/hotel_card.dart';

class HomeYouMightLike extends StatelessWidget {
  final List<Hotel> hotels;
  final Map<String, HotelBadge> hotelBadges;
  final Set<int> wishlistedHotelIds;
  final Set<int> favoriteLoadingHotelIds;
  final ValueChanged<Hotel>? onFavoriteTap;

  const HomeYouMightLike({
    super.key,
    required this.hotels,
    required this.hotelBadges,
    this.wishlistedHotelIds = const {},
    this.favoriteLoadingHotelIds = const {},
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul section
          const Text(
            'You Might Like',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          // Hotel list
          if (hotels.isEmpty)
            _buildEmptyState()
          else
            _HomeYouMightLikeGrid(
              hotels: hotels,
              hotelBadges: hotelBadges,
              wishlistedHotelIds: wishlistedHotelIds,
              favoriteLoadingHotelIds: favoriteLoadingHotelIds,
              onFavoriteTap: onFavoriteTap,
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.hotel_rounded,
            size: 48,
            color: const Color(0xFF94A3B8).withAlpha(128),
          ),
          const SizedBox(height: 12),
          const Text(
            'No hotels available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Check back later for recommendations',
            style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}

class _HomeYouMightLikeGrid extends StatelessWidget {
  final List<Hotel> hotels;
  final Map<String, HotelBadge> hotelBadges;
  final Set<int> wishlistedHotelIds;
  final Set<int> favoriteLoadingHotelIds;
  final ValueChanged<Hotel>? onFavoriteTap;

  const _HomeYouMightLikeGrid({
    required this.hotels,
    required this.hotelBadges,
    required this.wishlistedHotelIds,
    required this.favoriteLoadingHotelIds,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        double childAspectRatio = 1.038;

        if (constraints.maxWidth >= 1200) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth >= 900) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 2;
        }

        if (constraints.maxWidth >= 1200) {
          childAspectRatio = 0.78;
        } else if (constraints.maxWidth >= 1100) {
          childAspectRatio = 0.75;
        } else if (constraints.maxWidth >= 900) {
          childAspectRatio = 0.70;
        } else if (constraints.maxWidth >= 750) {
          childAspectRatio = 0.82;
        } else if (constraints.maxWidth >= 700) {
          childAspectRatio = 0.81;
        } else if (constraints.maxWidth >= 650) {
          childAspectRatio = 0.77;
        } else if (constraints.maxWidth >= 620) {
          childAspectRatio = 0.75;
        } else if (constraints.maxWidth >= 600) {
          childAspectRatio = 0.70;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: hotels.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) {
            final hotel = hotels[index];
            final badge = hotelBadges[hotel.name];

            return HotelCard(
              hotel: hotel,
              badge: badge,
              isWishlisted: wishlistedHotelIds.contains(hotel.id),
              isFavoriteLoading: favoriteLoadingHotelIds.contains(hotel.id),
              onFavoriteTap: () => onFavoriteTap?.call(hotel),
            );
          },
        );
      },
    );
  }
}
