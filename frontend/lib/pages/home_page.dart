import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/hotel.dart';
import '../widgets/home/home_header.dart';
import '../widgets/home/home_search_card.dart';
import '../widgets/home/home_promo_banner.dart';
import '../widgets/home/home_recommended_section.dart';
import '../widgets/home/home_you_might_like.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Hotel> _allHotels = [];
  bool _isLoading = true;
  Map<String, HotelBadge> _hotelBadges = {};

  @override
  void initState() {
    super.initState();
    _fetchHotels();
  }

  Future<void> _fetchHotels() async {
    try {
      final response = await Supabase.instance.client.from('hotels').select('''
          *, 
          hotel_images(image),
          hotel_facilities(name),
          rooms(
            price,
            reviews(rating)
          )
        ''');

      final List<Hotel> fetchedHotels = (response as List<dynamic>).map((item) {
        return Hotel.fromMap(item as Map<String, dynamic>);
      }).toList();

      setState(() {
        _allHotels = fetchedHotels;
        _hotelBadges = assignBadges(_allHotels);
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const HomeHeader(),

            // Search card
            HomeSearchCard(
              onSearch: () {
                Navigator.pushNamed(context, '/search-results');
              },
            ),

            // Promo banner
            const HomePromoBanner(),

            // Recommended For You section
            _isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF3B82F6),
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                : HomeRecommendedSection(
                    hotels: _allHotels,
                    hotelBadges: _hotelBadges,
                  ),

            const SizedBox(height: 8),

            // You Might Like section
            _isLoading
                ? const SizedBox.shrink()
                : HomeYouMightLike(
                    hotels: _allHotels,
                    hotelBadges: _hotelBadges,
                  ),

            // Bottom padding for navbar
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
