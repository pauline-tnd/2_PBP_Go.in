import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/services/api_services.dart';

import 'package:frontend/models/bookingDetail.dart' as booking_detail;
import 'package:frontend/models/room.dart';
import 'package:frontend/models/addOn.dart';
import 'package:frontend/models/review.dart';
import 'package:frontend/models/facilityIcons.dart';
import 'package:frontend/pages/settings/review_detail_page.dart';
import 'package:frontend/pages/payment_confirmation_page.dart';
import 'package:frontend/widgets/review/review_card.dart';
import 'package:frontend/widgets/booking_confirmation_pop_up.dart';
import 'package:frontend/widgets/room/room_image.dart';
import 'package:frontend/widgets/room/add_on_pop_up.dart';

class DetailRoomPage extends StatefulWidget {
  final Room room;
  final List<String> imageUrls;
  final List<Map<String, dynamic>> facilities;
  final List<AddOnItem> addOns;
  final List<Map<String, dynamic>> roomAmenities;
  final List<Map<String, dynamic>> reviews;
  final String hotelName;
  final String hotelLocation;
  final double reviewScore;
  final List<booking_detail.BookingDetail> tempBookedList;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int? existingBookingId;

  const DetailRoomPage({
    super.key,
    required this.room,
    required this.imageUrls,
    required this.facilities,
    required this.addOns,
    required this.roomAmenities,
    required this.reviews,
    required this.hotelName,
    this.hotelLocation = '',
    required this.reviewScore,
    this.tempBookedList = const [],
    this.checkIn,
    this.checkOut,
    this.existingBookingId,
  });

  @override
  State<DetailRoomPage> createState() => _DetailRoomPageState();
}

class _DetailRoomPageState extends State<DetailRoomPage> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  late List<booking_detail.BookingDetail> _localTempList;
  int? _bookingId;

  static const List<String> _defaultRoomImages = [
    'assets/images/RoomDefault/hotel_room_1.png',
    'assets/images/RoomDefault/hotel_room_2.png',
    'assets/images/RoomDefault/hotel_room_3.png',
    'assets/images/RoomDefault/hotel_room_4.png',
    'assets/images/RoomDefault/hotel_room_5.png',
    'assets/images/RoomDefault/hotel_room_6.png',
    'assets/images/RoomDefault/hotel_room_7.png',
    'assets/images/RoomDefault/hotel_room_8.png',
  ];

  @override
  void initState() {
    super.initState();
    _localTempList = List.from(widget.tempBookedList);
    _bookingId = widget.existingBookingId;
  }

  List<Map<String, dynamic>> _getMainAmenities() {
    return widget.facilities.toList();
  }

  List<Map<String, dynamic>> _getRoomAmenities() {
    const mainAmenitiesList = [
      'Free WiFi',
      'Housekeeping',
      '24-hour room service',
      'Telephone',
      'Non-smoking room',
    ];
    return widget.roomAmenities
        .where((f) => !mainAmenitiesList.contains(f['name']))
        .toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openAddOnPopUp({int? editIndex}) {
    final pageContext = context;

    showModalBottomSheet(
      context: pageContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddOnPopUp(
        roomType: widget.room.type,
        addOns: widget.addOns,
        room: booking_detail.Room(
          id: widget.room.id,
          type: widget.room.type,
          price: widget.room.price,
        ),
        roomImage: widget.imageUrls.isNotEmpty ? widget.imageUrls.first : '',
        existingBookings: _localTempList,
        editIndex: editIndex,
        checkIn: widget.checkIn,
        checkOut: widget.checkOut,
        existingBookingId: _bookingId,

        onContinue: editIndex != null
            ? (selected, notes) async {
                final detail = _localTempList[editIndex!];

                if (detail.id != 0) {
                  await ApiService.updateBookingDetail(detail.id, notes: notes);

                  try {
                    final res = await ApiService.fetchAddOnsByBookingDetail(
                      detail.id,
                    );
                    final existing = res['data'] as List;
                    for (final ao in existing) {
                      await ApiService.deleteBookingDetailAddOn(
                        ao['id'] as int,
                      );
                    }
                  } catch (_) {}

                  for (final addOn in selected) {
                    await ApiService.storeBookingDetailAddOn(
                      bookingDetailId: detail.id,
                      addOnId: addOn.id,
                      qty: 1,
                      subTotal: addOn.price,
                    );
                  }
                }

                if (mounted) {
                  setState(() {
                    detail.selectedAddOns = selected;
                    detail.notes = notes;
                  });
                }
              }
            : null,

        onConfirmationCustomAnother: (updatedList, bookingId) {
          if (!mounted) return;
          setState(() {
            _localTempList = List.from(updatedList);
            _bookingId = bookingId;
          });

          showModalBottomSheet(
            context: pageContext,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (popupContext) => BookingConfirmationPopUp(
              bookingDetails: List.from(updatedList),
              allAddOns: widget.addOns,
              hotelName: widget.hotelName,
              hotelLocation: widget.hotelLocation,
              previewImageUrl: widget.imageUrls.isNotEmpty
                  ? widget.imageUrls.first
                  : '',
              checkIn: widget.checkIn,
              checkOut: widget.checkOut,
              onCustomAnother: () {
                Navigator.pop(popupContext);
                Future.delayed(const Duration(milliseconds: 150), () {
                  if (mounted) {
                    Navigator.pop(pageContext, {
                      'list': _localTempList,
                      'bookingId': _bookingId,
                    });
                  }
                });
              },
              onBookNow: (bookingList, bookingId) {
                Navigator.pop(popupContext);
                Navigator.of(pageContext).push(
                  MaterialPageRoute(
                    builder: (_) => PaymentConfirmationPage(
                      hotelName: widget.hotelName,
                      hotelLocation: widget.hotelLocation,
                      previewImageUrl: widget.imageUrls.isNotEmpty
                          ? widget.imageUrls.first
                          : '',
                      bookingDetails: List.from(bookingList),
                      bookingId: bookingId,
                      checkIn: widget.checkIn,
                      checkOut: widget.checkOut,
                    ),
                  ),
                );
              },
              onBookingListChanged: (bookingList) {
                if (!mounted) return;
                setState(() {
                  _localTempList = List.from(bookingList);
                });
              },
            ),
          );
        },
      ),
    );
  }

  void _showAddOnsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add On',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4F8DF7),
                ),
              ),
              const SizedBox(height: 16),
              ...widget.addOns.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      const Text(
                        '• ',
                        style: TextStyle(color: Color(0xFF94A3B8)),
                      ),
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMainAmenitiesSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Main Amenities',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4F8DF7),
                ),
              ),
              const SizedBox(height: 16),
              ..._getMainAmenities().map((f) {
                final facility = FacilityIcons.fromJson(f);
                final icon =
                    FacilityIcons.iconMap[facility.icon] ??
                    Icons.check_circle_outline_rounded;
                return _FacilityRow(icon: icon, name: facility.name);
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showRoomAmenitiesSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Room Amenities',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4F8DF7),
                ),
              ),
              const SizedBox(height: 16),
              ..._getRoomAmenities().map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      const Text(
                        '• ',
                        style: TextStyle(color: Color(0xFF94A3B8)),
                      ),
                      Text(
                        item['name'] ?? item,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final priceFormatted = NumberFormat(
      '#,###',
      'id_ID',
    ).format(room.price.toInt());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            pinned: true,
            expandedHeight: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context, {
                'list': _localTempList,
                'bookingId': _bookingId,
              }),
              icon: const Icon(
                Icons.chevron_left_rounded,
                color: Color(0xFF0F172A),
                size: 28,
              ),
            ),
            title: const Text(
              'Room Detail',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            centerTitle: true,
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 240,
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: widget.imageUrls.isNotEmpty
                            ? widget.imageUrls.length
                            : _defaultRoomImages.length,
                        onPageChanged: (index) =>
                            setState(() => _currentImageIndex = index),
                        itemBuilder: (context, index) {
                          final effectiveImages = widget.imageUrls.isNotEmpty
                              ? widget.imageUrls
                              : _defaultRoomImages;
                          final url = effectiveImages[index];
                          return RoomImage(
                            imagePath: url,
                            placeholderColor: const Color(0xFF94A3B8),
                            width: double.infinity,
                            height: 240,
                            borderRadius: BorderRadius.zero,
                          );
                        },
                      ),
                      if ((widget.imageUrls.isNotEmpty
                              ? widget.imageUrls.length
                              : _defaultRoomImages.length) >
                          1)
                        Positioned(
                          left: 12,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: _CarouselButton(
                              icon: Icons.chevron_left_rounded,
                              onTap: () {
                                if (_currentImageIndex > 0) {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      Positioned(
                        right: 12,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _CarouselButton(
                            icon: Icons.chevron_right_rounded,
                            onTap: () {
                              if (_currentImageIndex <
                                  (widget.imageUrls.isNotEmpty
                                          ? widget.imageUrls.length
                                          : _defaultRoomImages.length) -
                                      1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            widget.imageUrls.isNotEmpty
                                ? widget.imageUrls.length
                                : _defaultRoomImages.length,
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: i == _currentImageIndex ? 18 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: i == _currentImageIndex
                                    ? const Color(0xFFCBD5E1)
                                    : const Color(
                                        0xFF94A3B8,
                                      ).withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              widget.hotelName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF4F8DF7),
                              ),
                              softWrap: true,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Rp $priceFormatted',
                                style: const TextStyle(
                                  fontSize: 14, // ← reduced from 18
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF4F8DF7),
                                ),
                              ),
                              const Text(
                                '/night',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Text(
                        room.type,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        room.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 16),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 280;
                          if (isNarrow) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _InfoChip(
                                  icon: Icons.person_outline_rounded,
                                  label: 'CAPACITY',
                                  value: '${room.capacity} Guest',
                                  expand: false,
                                ),
                                const SizedBox(height: 8),
                                _InfoChip(
                                  icon: Icons.square_foot_rounded,
                                  label: 'SIZE',
                                  value: '${room.roomSize} m\u00B2',
                                  expand: false,
                                ),
                                const SizedBox(height: 8),
                                _InfoChip(
                                  icon: Icons.hotel_outlined,
                                  label: 'BED TYPE',
                                  value: '1 King',
                                  expand: false,
                                ),
                              ],
                            );
                          }
                          return Row(
                            children: [
                              _InfoChip(
                                icon: Icons.person_outline_rounded,
                                label: 'CAPACITY',
                                value: '${room.capacity} Guest',
                              ),
                              const SizedBox(width: 8),
                              _InfoChip(
                                icon: Icons.square_foot_rounded,
                                label: 'SIZE',
                                value: '${room.roomSize} m\u00B2',
                              ),
                              const SizedBox(width: 8),
                              _InfoChip(
                                icon: Icons.hotel_outlined,
                                label: 'BED TYPE',
                                value: '1 King',
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      _SectionHeader(
                        title: 'Main Amenities',
                        trailing: _getMainAmenities().length > 4
                            ? GestureDetector(
                                onTap: _showMainAmenitiesSheet,
                                child: const Icon(
                                  Icons.more_vert_outlined,
                                  color: Color(0xFF4F8DF7),
                                ),
                              )
                            : null,
                      ),

                      const SizedBox(height: 12),

                      ..._getMainAmenities().take(4).map((f) {
                        final facility = FacilityIcons.fromJson(f);
                        final icon =
                            FacilityIcons.iconMap[facility.icon] ??
                            Icons.check_circle_outline_rounded;
                        return _FacilityRow(icon: icon, name: facility.name);
                      }),
                      const SizedBox(height: 20),

                      _SectionHeader(
                        title: 'Room Amenities',
                        trailing: _getRoomAmenities().length > 4
                            ? GestureDetector(
                                onTap: _showRoomAmenitiesSheet,
                                child: const Icon(
                                  Icons.more_vert_outlined,
                                  color: Color(0xFF4F8DF7),
                                ),
                              )
                            : null,
                      ),

                      const SizedBox(height: 12),

                      ..._getRoomAmenities()
                          .take(4)
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                children: [
                                  const Text(
                                    '• ',
                                    style: TextStyle(color: Color(0xFF94A3B8)),
                                  ),
                                  Text(
                                    item['name'] ?? item,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Add On',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          if (widget.addOns.length > 4)
                            GestureDetector(
                              onTap: _showAddOnsSheet,
                              child: const Icon(
                                Icons.more_vert_outlined,
                                color: Color(0xFF4F8DF7),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...widget.addOns
                          .take(4)
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                children: [
                                  const Text(
                                    '• ',
                                    style: TextStyle(color: Color(0xFF94A3B8)),
                                  ),
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                      const SizedBox(height: 24),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 280;
                          final starBadge = Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFF59E0B),
                                  size: 14,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${widget.reviewScore} / 5',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFF59E0B),
                                  ),
                                ),
                              ],
                            ),
                          );
                          final seeAll = GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReviewDetailPage(
                                  reviews: widget.reviews
                                      .map((r) => Review.fromJson(r))
                                      .toList(),
                                  title: "Room's Reviews",
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'See All',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF4F8DF7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: Color(0xFF4F8DF7),
                                  size: 18,
                                ),
                              ],
                            ),
                          );

                          if (isNarrow) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Room's review",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                starBadge,
                                const SizedBox(height: 4),
                                seeAll,
                              ],
                            );
                          }

                          return Row(
                            children: [
                              const Text(
                                "Room's review",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(width: 8),
                              starBadge,
                              const Spacer(),
                              seeAll,
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        height: 130,
                        child: widget.reviews.isEmpty
                            ? const Center(
                                child: Text(
                                  'No reviews yet',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: widget.reviews.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final review = Review.fromJson(
                                    widget.reviews[index],
                                  );
                                  return SizedBox(
                                    width: 260,
                                    child: GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ReviewDetailPage(
                                            reviews: widget.reviews
                                                .map((r) => Review.fromJson(r))
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                      child: ReviewCard(review: review),
                                    ),
                                  );
                                },
                              ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: _localTempList.isEmpty
              ? SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _openAddOnPopUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F8DF7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _openAddOnPopUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F8DF7),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Add New Room',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _CarouselButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CarouselButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool expand;
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: expand ? null : double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF4F8DF7), size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
    return expand ? Expanded(child: content) : content;
  }
}

class _FacilityRow extends StatelessWidget {
  final IconData icon;
  final String name;
  const _FacilityRow({required this.icon, required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4F8DF7), size: 20),
          const SizedBox(width: 10),
          Text(
            name,
            style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 280;
        final titleWidget = Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        );
        if (trailing == null) return titleWidget;
        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [titleWidget, const SizedBox(height: 4), trailing!],
          );
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [titleWidget, trailing!],
        );
      },
    );
  }
}
