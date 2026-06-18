import 'package:flutter/material.dart';
import 'package:frontend/utils/hotel_grid.dart';
import '../../models/hotel.dart';
import '../hotel/hotel_card.dart';

class HomeYouMightLike extends StatelessWidget {
  final List<Hotel> hotels;
  final Map<String, HotelBadge> hotelBadges;
  final Set<int> wishlistedHotelIds;
  final Set<int> favoriteLoadingHotelIds;
  final ValueChanged<Hotel>? onFavoriteTap;
  final VoidCallback? onEndReached;
  final bool isLoadingMore;

  const HomeYouMightLike({
    super.key,
    required this.hotels,
    required this.hotelBadges,
    this.wishlistedHotelIds = const {},
    this.favoriteLoadingHotelIds = const {},
    this.onFavoriteTap,
    this.onEndReached,
    this.isLoadingMore = false,
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
              onEndReached: onEndReached,
            ),
          if (isLoadingMore) ...[
            const SizedBox(height: 12),
            const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ],
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
  final VoidCallback? onEndReached;

  const _HomeYouMightLikeGrid({
    required this.hotels,
    required this.hotelBadges,
    required this.wishlistedHotelIds,
    required this.favoriteLoadingHotelIds,
    required this.onFavoriteTap,
    required this.onEndReached,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final config = getHotelGridConfig(constraints.maxWidth);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: hotels.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: config.crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: config.childAspectRatio,
          ),
          itemBuilder: (context, index) {
            if (index >= hotels.length - config.crossAxisCount) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onEndReached?.call();
              });
            }

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
