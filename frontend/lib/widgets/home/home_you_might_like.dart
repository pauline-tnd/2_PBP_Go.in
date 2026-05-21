import 'package:flutter/material.dart';
import '../../models/hotel.dart';
import '../hotel_card.dart';

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
            ...hotels.map((hotel) {
              final badge = hotelBadges[hotel.name];
              return HotelCard(
                hotel: hotel,
                badge: badge,
                initialIsWishlisted: wishlistedHotelIds.contains(hotel.id),
                isFavoriteLoading: favoriteLoadingHotelIds.contains(hotel.id),
                onFavoriteTap: () => onFavoriteTap?.call(hotel),
              );
            }),
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
