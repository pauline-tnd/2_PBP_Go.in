import 'package:flutter/material.dart';
import 'package:frontend/models/hotel.dart';
import 'package:frontend/models/room.dart';
import 'package:frontend/widgets/room_card.dart';
import 'package:frontend/widgets/hotel_image.dart';
import 'package:frontend/services/api_services.dart';
import 'package:frontend/extensions/snackbar.dart';

class DetailHotelPage extends StatefulWidget {
  final Hotel hotel;

  const DetailHotelPage({super.key, required this.hotel});

  @override
  State<DetailHotelPage> createState() => _DetailHotelPageState();
}

class _DetailHotelPageState extends State<DetailHotelPage> {
  bool _isWishlisted = false;
  bool _isWishlistLoading = false;
  bool _isExpanded = false;
  int? _wishlistId;
  Map<String, dynamic>? _hotelDetail;
  List<Room> _rooms = [];
  bool _loading = true;
  String? _error;

  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final data = await ApiService.fetchHotelDetail(widget.hotel.id);
      final hotelDetail = data['data'] as Map<String, dynamic>? ?? {};
      final roomsRaw = hotelDetail['rooms'] as List<dynamic>? ?? [];
      if (!mounted) return;
      setState(() {
        _hotelDetail = hotelDetail;
        _isWishlisted = data['is_wishlist'] ?? false;
        _rooms = roomsRaw
            .whereType<Map<String, dynamic>>()
            .map((r) => Room.fromJson({...r, 'hotel': hotelDetail}))
            .toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _toggleWishlist() async {
    if (_isWishlistLoading) return;
    setState(() => _isWishlistLoading = true);
    try {
      if (_isWishlisted) {
        if (_wishlistId != null) {
          await ApiService.deleteWishlist(_wishlistId!);
        } else {
          await ApiService.deleteWishlistByHotelId(widget.hotel.id);
        }
        _wishlistId = null;
        if (mounted) context.showAppSnackBar('Removed from wishlist');
      } else {
        final response = await ApiService.storeWishlist(widget.hotel.id);
        final data = response['data'];
        _wishlistId = data is Map<String, dynamic>
            ? int.tryParse(data['id'].toString())
            : null;
        if (mounted) context.showAppSnackBar('Added to wishlist');
      }
      if (mounted) setState(() => _isWishlisted = !_isWishlisted);
    } catch (e) {
      if (mounted) context.showAppSnackBar('Failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isWishlistLoading = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : _buildBody(hotel),
    );
  }

  Widget _buildBody(Hotel hotel) {
    final hotelImages = (_hotelDetail?['hotel_images'] as List<dynamic>? ?? [])
        .map((e) => e['image']?.toString())
        .whereType<String>()
        .toList();

    final facilities =
        (_hotelDetail?['hotel_facilities'] as List<dynamic>? ?? []);
    final displayFacilities = facilities.take(3).toList();
    final hasMoreFacilities = facilities.length > 3;

    final description = _hotelDetail?['description']?.toString() ?? '';
    final truncated = description.length > 150
        ? description.substring(0, 150)
        : description;
    final aboutText = description.isEmpty
        ? 'No description available.'
        : _isExpanded
        ? description
        : description.length > 150
        ? '$truncated...'
        : description;

    final rating =
        double.tryParse(
          _hotelDetail?['hotel_rating']?.toString() ?? '',
        )?.toStringAsFixed(1) ??
        hotel.userRating.toStringAsFixed(1);

    final totalReviews = _hotelDetail?['total_reviews'] ?? 0;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          pinned: true,
          expandedHeight: 0,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: Color(0xFF1E293B),
                size: 24,
              ),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: _toggleWishlist,
              child: Container(
                margin: const EdgeInsets.all(8),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _isWishlistLoading
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _isWishlisted
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: _isWishlisted
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF94A3B8),
                        size: 22,
                      ),
              ),
            ),
          ],
          title: const Text(
            'Hotel Detail',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),

        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hotelImages.isNotEmpty)
                SizedBox(
                  height: 260,
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: hotelImages.length,
                        onPageChanged: (i) =>
                            setState(() => _currentImageIndex = i),
                        itemBuilder: (context, index) => HotelImage(
                          imagePath: hotelImages[index],
                          placeholderColor: const Color(0xFF1E3A5F),
                          width: double.infinity,
                          height: 260,
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      if (hotelImages.length > 1)
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              hotelImages.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                width: i == _currentImageIndex ? 18 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: i == _currentImageIndex
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              else
                HotelImage(
                  imagePath: hotel.imagePath,
                  placeholderColor: const Color(0xFF1E3A5F),
                  width: double.infinity,
                  height: 260,
                  borderRadius: BorderRadius.zero,
                ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: List.generate(
                            hotel.starRating,
                            (_) => const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: Color(0xFFFBBF24),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    GestureDetector(
                      onTap: () {
                        /* open map */
                      },
                      child: Row(
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
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: Color(0xFF3B82F6),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFF59E0B),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$rating / 5',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFF59E0B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '$totalReviews reviews',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    Container(height: 1, color: const Color(0xFFF1F5F9)),
                    const SizedBox(height: 20),

                    const Text(
                      'About',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      aboutText,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        height: 1.6,
                      ),
                    ),
                    if (description.length > 150)
                      GestureDetector(
                        onTap: () => setState(() => _isExpanded = !_isExpanded),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _isExpanded ? 'Show less' : 'Read more',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),
                    Container(height: 1, color: const Color(0xFFF1F5F9)),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Amenities',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        if (hasMoreFacilities)
                          GestureDetector(
                            onTap: _showAmenitiesSheet,
                            child: const Text(
                              'See all',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF3B82F6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (displayFacilities.isEmpty)
                      const Text(
                        'No amenities listed yet.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: displayFacilities.map((f) {
                          final name = f['name']?.toString() ?? '';
                          return _AmenityChip(name: name);
                        }).toList(),
                      ),

                    const SizedBox(height: 20),
                    Container(height: 1, color: const Color(0xFFF1F5F9)),
                    const SizedBox(height: 20),

                    const Text(
                      'Available Rooms',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_rooms.isEmpty)
                      const Text(
                        'No rooms available yet.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                        ),
                      )
                    else
                      ..._rooms.map((room) {
                        final roomsDetail =
                            _hotelDetail?['rooms'] as List<dynamic>? ?? [];
                        final roomImagesRaw =
                            roomsDetail.firstWhere(
                                  (r) =>
                                      r is Map<String, dynamic> &&
                                      r['id'] == room.id,
                                  orElse: () => <String, dynamic>{},
                                )
                                as Map<String, dynamic>;
                        final roomImages =
                            (roomImagesRaw['room_images'] as List<dynamic>? ??
                                    [])
                                .map((e) => e['image']?.toString() ?? '')
                                .where((image) => image.isNotEmpty)
                                .toList();
                        final firstImage = roomImages.isNotEmpty
                            ? roomImages.first
                            : null;

                        return RoomCard(
                          room: room,
                          imageUrl: firstImage,
                          imageUrls: roomImages,
                          hotelName: hotel.name,
                          reviewScore:
                              double.tryParse(rating) ?? hotel.userRating,
                        );
                      }),

                    const SizedBox(height: 20),
                    Container(height: 1, color: const Color(0xFFF1F5F9)),
                    const SizedBox(height: 20),

                    const Text(
                      'Locations',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 180,
                        color: const Color(0xFFE2E8F0),
                        child: const Center(
                          child: Icon(
                            Icons.map_outlined,
                            color: Color(0xFF94A3B8),
                            size: 40,
                          ),
                        ),
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
    );
  }

  void _showAmenitiesSheet() {
    final facilities =
        (_hotelDetail?['hotel_facilities'] as List<dynamic>? ?? []);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Amenities',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: facilities.map((f) {
                    final name = f['name']?.toString() ?? '';
                    return _AmenityChip(name: name);
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AmenityChip extends StatelessWidget {
  final String name;
  const _AmenityChip({required this.name});

  static const _icons = {
    'Wi-Fi': Icons.wifi_rounded,
    'Wifi': Icons.wifi_rounded,
    'Parking': Icons.local_parking_rounded,
    'Pool': Icons.pool_rounded,
    'Gym': Icons.fitness_center_rounded,
    'Restaurant': Icons.restaurant_rounded,
    'Spa': Icons.spa_rounded,
    'Non-Smoking': Icons.smoke_free_rounded,
    'Bar': Icons.local_bar_rounded,
    'Laundry': Icons.local_laundry_service_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final icon = _icons.entries
        .firstWhere(
          (e) => name.toLowerCase().contains(e.key.toLowerCase()),
          orElse: () => const MapEntry('', Icons.check_circle_outline_rounded),
        )
        .value;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF3B82F6)),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
