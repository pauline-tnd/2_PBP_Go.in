import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/hotel.dart';
import 'hotel_image.dart';
import 'package:intl/intl.dart';
import 'package:frontend/pages/Detail_pages/detail_hotel_page.dart';

class HotelCard extends StatefulWidget {
  final Hotel hotel;
  final HotelBadge? badge;
  final bool initialIsWishlisted;
  final bool isFavoriteLoading;
  final bool isWishlisted;
  final VoidCallback? onFavoriteTap;

  const HotelCard({
    super.key,
    required this.hotel,
    this.badge,
    this.initialIsWishlisted = false,
    this.isWishlisted = false,
    this.isFavoriteLoading = false,
    this.onFavoriteTap,
  });

  @override
  State<HotelCard> createState() => _HotelCardState();
}

class _HotelCardState extends State<HotelCard> {

  // versi langsung ke detail page
  // void _openDetailHotelPage() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) =>
  //           DetailHotelPage(hotel: widget.hotel, addOns: const []),
  //     ),
  //   );
  // }

  // pakai date-picker

  Future<void> _openDetailHotelPage() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(const Duration(days: 1)),
      ),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF3B82F6),
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (picked == null || !context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailHotelPage(
          hotel: widget.hotel,
          addOns: const [],
          checkIn: picked.start,
          checkOut: picked.end,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;
    final badge = widget.badge;

    return GestureDetector(
      onTap: _openDetailHotelPage,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E293B).withAlpha(15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                HotelImage(
                  imagePath: hotel.imagePath,
                  placeholderColor: hotel.placeholderColor,
                  width: double.infinity,
                  height: 160,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                if (badge != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: hotel.badgeColor(badge),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            hotel.badgeIcon(badge),
                            size: 12,
                            color: const Color(0xFFF5F7F8),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            hotel.badgeLabel(badge),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFF5F7F8),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (widget.isFavoriteLoading) return;
                      widget.onFavoriteTap?.call();
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(38),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withAlpha(51),
                              width: 0.5,
                            ),
                          ),
                          child: widget.isFavoriteLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  widget.isWishlisted
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  size: 20,
                                  color: widget.isWishlisted
                                      ? const Color(0xFFEF4444)
                                      : Colors.white,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          hotel.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          hotel.starRating,
                          (index) => const Padding(
                            padding: EdgeInsets.only(left: 1),
                            child: Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: Color(0xFFFBBF24),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hotel.location,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(height: 1, color: const Color(0xFFF1F5F9)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Start from',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF3B82F6),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                'Rp ${NumberFormat('#,###', 'id_ID').format(hotel.pricePerNight.toInt())}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF3B82F6),
                                ),
                              ),
                              const SizedBox(width: 3),
                              const Text(
                                '/ night',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 1),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              const SizedBox(width: 3),
                              const Text(
                                'Includes taxes & fees',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBBF24).withAlpha(31),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFFBBF24).withAlpha(77),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_border,
                              size: 16,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              hotel.userRating.toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFF97316),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
