import 'package:flutter/material.dart';
import 'package:frontend/models/hotel.dart';
import 'package:frontend/widgets/bottom_navbar.dart';
import 'package:frontend/widgets/hotel_card.dart';

class WishlistPage extends StatefulWidget {
  final List<Hotel> hotels;
  final Map<String, HotelBadge> hotelBadges;

  const WishlistPage({
    super.key,
    required this.hotels,
    required this.hotelBadges,
  });

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Wishlist")),
      body: Stack(
        children: [
          // Positioned(
          //   left: 24,
          //   right: 24,
          //   bottom: 24,
          //   child: Container(
          //     height: 60,
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       borderRadius: BorderRadius.circular(20),
          //     ),
          //   ),
          // ),
          Column(
            children: [
              if (widget.hotels.isEmpty)
                _buildEmptyState()
              else
                ...widget.hotels.map((hotel) {
                  final badge = widget.hotelBadges[hotel.name];
                  return HotelCard(hotel: hotel, badge: badge);
                }),
            ],
          ),
          BottomNavbar(currentIndex: 0, onTap: (index) {}),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 120),
      child: Column(
        children: [
          Icon(
            Icons.hotel_rounded,
            size: 48,
            color: const Color(0xFF94A3B8).withAlpha(128),
          ),
          const SizedBox(height: 12),
          const Text(
            'No hotels added yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Add some hotels to your wishlist.',
            style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}
