import 'package:flutter/material.dart';
import 'package:frontend/pages/main_shell.dart';
import 'package:frontend/models/hotel.dart';
import 'package:frontend/models/wishlist.dart';
import 'package:frontend/providers/location_provider.dart';
import 'package:frontend/services/api_services.dart';
import 'package:frontend/widgets/home/home_header.dart';
import 'package:frontend/widgets/home/home_search_card.dart';
import 'package:frontend/widgets/home/home_promo_banner.dart';
import 'package:frontend/widgets/home/home_recommended_section.dart';
import 'package:frontend/widgets/home/home_you_might_like.dart';
import 'package:frontend/widgets/layout/skeleton_loader.dart';
import 'package:frontend/extensions/snackbar.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Hotel> _allHotels = [];
  List<Hotel> _recommendHotels = [];
  bool _isLoading = true;
  Map<String, HotelBadge> _hotelBadges = {};
  Set<int> _wishlistedHotelIds = {};
  Map<int, int> _wishlistIdsByHotelId = {};
  final Set<int> _favoriteLoadingHotelIds = {};
  String _lastAddress = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final location = context.watch<LocationProvider>();

    if (location.address != _lastAddress) {
      _lastAddress = location.address;
      _fetchHotels();
    }
  }

  Future<void> _fetchHotels() async {
    final location = context.read<LocationProvider>();

    final hasLocation =
        location.lat != null &&
        location.lng != null &&
        location.address != "Choose Location";

    try {
      final hotelsResponse = await ApiService.fetchHotels();

      final hotelItems = _extractHotelItems(hotelsResponse);

      final List<Hotel> fetchedHotels = hotelItems.map((item) {
        return Hotel.fromMap(item as Map<String, dynamic>);
      }).toList();

      List<Hotel> recommendedHotels = fetchedHotels;

      if (hasLocation) {
        print('Lat : ${location.lat}');
        print('Lng : ${location.lng}');

        final recommendResponse = await ApiService.fetchHotels(
          userLat: location.lat,
          userLng: location.lng,
          sortBy: 'distance',
        );

        final recommendItems = _extractHotelItems(recommendResponse);

        recommendedHotels = recommendItems.map((item) {
          return Hotel.fromMap(item as Map<String, dynamic>);
        }).toList();
      }

      final wishlists = await ApiService.fetchWishlists();

      if (!mounted) return;

      setState(() {
        _allHotels = fetchedHotels;
        _recommendHotels = recommendedHotels;
        _hotelBadges = assignBadges(fetchedHotels);
        _setWishlists(wishlists);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  List<dynamic> _extractHotelItems(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is List) return data;
    if (data is Map<String, dynamic> && data['data'] is List) {
      return data['data'] as List;
    }
    return [];
  }

  void _setWishlists(List<Wishlist> wishlists) {
    _wishlistIdsByHotelId = {
      for (final wishlist in wishlists) wishlist.hotelId: wishlist.id,
    };
    _wishlistedHotelIds = _wishlistIdsByHotelId.keys.toSet();
  }

  Future<void> _toggleWishlist(Hotel hotel) async {
    if (_favoriteLoadingHotelIds.contains(hotel.id)) return;

    final isWishlisted = _wishlistedHotelIds.contains(hotel.id);
    final previousWishlistId = _wishlistIdsByHotelId[hotel.id];

    setState(() {
      _favoriteLoadingHotelIds.add(hotel.id);
      if (isWishlisted) {
        _wishlistedHotelIds.remove(hotel.id);
        _wishlistIdsByHotelId.remove(hotel.id);
      } else {
        _wishlistedHotelIds.add(hotel.id);
      }
    });

    try {
      if (isWishlisted) {
        final wishlistId = previousWishlistId;
        if (wishlistId == null) return;
        await ApiService.deleteWishlist(wishlistId);
      } else {
        final response = await ApiService.storeWishlist(hotel.id);
        final data = response['data'];
        final wishlistId = data is Map<String, dynamic>
            ? int.tryParse(data['id'].toString())
            : null;
        if (wishlistId != null && mounted) {
          setState(() {
            _wishlistIdsByHotelId[hotel.id] = wishlistId;
          });
        }
      }

      if (!mounted) return;
      context.showAppSnackBar(
        isWishlisted ? 'Removed from wishlist' : 'Added to wishlist',
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        if (isWishlisted) {
          _wishlistedHotelIds.add(hotel.id);
          if (previousWishlistId != null) {
            _wishlistIdsByHotelId[hotel.id] = previousWishlistId;
          }
        } else {
          _wishlistedHotelIds.remove(hotel.id);
          _wishlistIdsByHotelId.remove(hotel.id);
        }
      });
      context.showAppSnackBar('Wishlist update failed: $error', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _favoriteLoadingHotelIds.remove(hotel.id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      body: HomeHeader(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search card
            const HomeSearchCard(),

            // Promo banner
            HomePromoBanner(
              onTap: () {
                final mainShellState = context
                    .findAncestorStateOfType<MainShellState>();
                mainShellState?.switchTab(2); // PromoPage
              },
            ),

            // Recommended For You section
            _isLoading
                ? const HomeDataSkeleton()
                : Column(
                    children: [
                      HomeRecommendedSection(
                        hotels: _allHotels,
                        hotelBadges: _hotelBadges,
                        wishlistedHotelIds: _wishlistedHotelIds,
                        favoriteLoadingHotelIds: _favoriteLoadingHotelIds,
                        onFavoriteTap: _toggleWishlist,
                      ),
                      const SizedBox(height: 8),
                      HomeYouMightLike(
                        hotels: _recommendHotels,
                        hotelBadges: _hotelBadges,
                        wishlistedHotelIds: _wishlistedHotelIds,
                        favoriteLoadingHotelIds: _favoriteLoadingHotelIds,
                        onFavoriteTap: _toggleWishlist,
                      ),
                    ],
                  ),

            // Bottom padding for navbar
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
