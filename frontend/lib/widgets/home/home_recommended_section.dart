import 'package:flutter/material.dart';
import '../../models/hotel.dart';
import '../hotel_card.dart';

class HomeRecommendedSection extends StatefulWidget {
  final List<Hotel> hotels;
  final Map<String, HotelBadge> hotelBadges;

  const HomeRecommendedSection({
    super.key,
    required this.hotels,
    required this.hotelBadges,
  });

  @override
  State<HomeRecommendedSection> createState() => _HomeRecommendedSectionState();
}

class _HomeRecommendedSectionState extends State<HomeRecommendedSection> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // mulai animasi setelah scroll 30px
    final double progress = (_scrollOffset / 80).clamp(0.0, 1.0);
    final bool isScrolled = progress > 0.01;

    // Posisi & ukuran teks: animasi ke atas
    final double topPosition = lerpDouble(0, 0, progress)!;
    final double fontSize = lerpDouble(20, 13, progress)!;
    final double leftPadding = lerpDouble(24, 16, progress)!;

    return Transform.translate(
      offset: const Offset(0, -20),
      child: SizedBox(
        height: 420,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Background
            Positioned.fill(child: Container(color: const Color(0xFFD6E4FF))),
            // Judul Teks
            AnimatedPositioned(
              width: 250,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              top: lerpDouble(420 / 2 - 30, 14, progress),
              left: lerpDouble(24, 16, progress),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3B82F6),
                  height: 1.25,
                  decoration: TextDecoration.none,
                ),
                child: Text(
                  progress > 0.5
                      ? 'Recommended For You'
                      : 'Recommended\nFor You',
                ),
              ),
            ),

            // ListView hotel card
            Positioned.fill(
              child: widget.hotels.isEmpty
                  ? const Center(
                      child: Text(
                        'No recommendations yet',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.only(
                        left: lerpDouble(220, 24, progress)!,
                        right: 24,
                        top: lerpDouble(50, 50, progress)!,
                        bottom: 10,
                      ),
                      itemCount: widget.hotels.length,
                      itemBuilder: (context, index) {
                        final hotel = widget.hotels[index];
                        final badge = widget.hotelBadges[hotel.name];
                        return Padding(
                          padding: EdgeInsets.only(
                            right: index < widget.hotels.length - 1 ? 16 : 0,
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: HotelCard(hotel: hotel, badge: badge),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

double? lerpDouble(num a, num b, double t) {
  return a + (b - a) * t;
}
