import 'package:flutter/material.dart';
import 'package:frontend/pages/wishlist_page.dart';
import '../header.dart';

class HomeHeader extends StatelessWidget {
  final Widget body;

  const HomeHeader({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return GradientScrollHeader(
      expandedHeight: 180, // Adjust as needed to match previous bottom padding
      navbarColor: const Color(0xFF3B82F6),
      leading: HeaderLocation(
        location: 'Walter Street, Yongha',
        onTap: () {
          // Buka halaman pilih lokasi
        },
      ),
      actions: [
        HeaderAction(
          icon: Icons.favorite_border_rounded,
          onTap: () {
            // Buka wishlist
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const WishlistPage(hotels: [], hotelBadges: {}),
              ),
            );
          },
        ),
      ],
      body: body,
    );
  }
}
