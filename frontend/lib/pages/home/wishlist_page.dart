import 'package:flutter/material.dart';
import 'package:frontend/extensions/snackbar.dart';
import 'package:frontend/models/hotel.dart';
import 'package:frontend/models/wishlist.dart';
import 'package:frontend/services/api_services.dart';
import 'package:frontend/utils/hotel_grid.dart';
import 'package:frontend/widgets/hotel/hotel_card.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class WishlistPage extends StatefulWidget {
  final VoidCallback? onBack;

  const WishlistPage({super.key, this.onBack});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  late Future<List<Wishlist>> _wishlistsFuture;

  @override
  void initState() {
    super.initState();
    _fetchWishlists();
  }

  Future<void> _fetchWishlists() async {
    setState(() {
      _wishlistsFuture = ApiService.fetchWishlists();
    });

    await _wishlistsFuture;
  }

  Future<void> _deleteWishlist(int wishlistId) async {
    try {
      await ApiService.deleteWishlist(wishlistId);
      if (mounted) {
        context.showAppSnackBar('Removed from wishlist');

        _fetchWishlists();
      }
    } catch (e) {
      if (mounted) {
        context.showAppSnackBar('Error removing wishlist: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Wishlist"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: widget.onBack == null
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: widget.onBack,
              ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchWishlists,
        child: FutureBuilder<List<Wishlist>>(
          future: _wishlistsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }

            final wishlists = snapshot.data!;
            final hotels = wishlists
                .map((w) {
                  return w.hotel != null ? Hotel.fromMap(w.hotel!) : null;
                })
                .whereType<Hotel>()
                .toList();

            final hotelBadges = assignBadges(hotels);

            return LayoutBuilder(
              builder: (context, constraints) {
                final config = getHotelGridConfig(constraints.maxWidth);

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 14.h),
                  physics: const BouncingScrollPhysics(),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: wishlists.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: config.crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: config.childAspectRatio,
                    ),
                    itemBuilder: (context, index) {
                      final wishlist = wishlists[index];

                      final hotelMap = wishlist.hotel;
                      if (hotelMap == null) {
                        return const SizedBox.shrink();
                      }

                      final hotel = Hotel.fromMap(hotelMap);
                      final badge = hotelBadges[hotel.name];

                      return HotelCard(
                        hotel: hotel,
                        badge: badge,
                        isWishlisted: true,
                        onFavoriteTap: () => _deleteWishlist(wishlist.id),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Column(
        children: [
          Icon(
            Icons.favorite_border_rounded,
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
