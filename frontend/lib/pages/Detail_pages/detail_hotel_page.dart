import 'package:flutter/material.dart';
import 'package:frontend/models/hotel.dart';
import 'package:frontend/models/room.dart';
import 'package:frontend/widgets/room_card.dart';
import 'package:frontend/widgets/hotel_image.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/services/api_services.dart';
import 'package:frontend/extensions/snackbar.dart';
import 'package:frontend/models/facility.dart';
import 'package:frontend/widgets/common/carousel.dart';
import 'package:frontend/pages/review_page.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DetailHotelPage extends StatefulWidget {
  final Hotel hotel;

  const DetailHotelPage({super.key, required this.hotel});

  @override
  State<DetailHotelPage> createState() => _DetailHotelPageState();
}

class _DetailHotelPageState extends State<DetailHotelPage> {
  static const String _maptilerKey = 'E9ZFe6B1DmH71sbyAHar';

  bool _isWishlisted = false;
  bool _isWishlistLoading = false;
  bool _isExpanded = false;
  int? _wishlistId;
  Map<String, dynamic>? _hotelDetail;
  List<Room> _rooms = [];
  bool _loading = true;
  String? _error;
  final MapController _mapController = MapController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _mapKey = GlobalKey();
  LatLng _center = const LatLng(51.5071, -0.1417);
  String _pickedAddress = '';

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _reverseGeocode(LatLng center) async {
    final url =
        'https://api.maptiler.com/geocoding/${center.longitude},${center.latitude}.json?key=$_maptilerKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;
        if (features.isNotEmpty) {
          setState(() {
            _pickedAddress = features.first['place_name'] ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint("Geocoding failed: $e");
    }
  }

  Future<void> _getCoordinatesFromName(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url =
        'https://api.maptiler.com/geocoding/$encodedQuery.json?key=$_maptilerKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;
        if (features.isNotEmpty) {
          final coords = features.first['center'] as List;
          final lng = coords[0] as double;
          final lat = coords[1] as double;
          if (mounted) {
            setState(() {
              _center = LatLng(lat, lng);
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              try {
                _mapController.move(_center, 16);
              } catch (e) {
                debugPrint("Map controller movement postponed: $e");
              }
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Forward geocoding failed: $e");
    }
  }

  Future<void> _loadDetail() async {
    try {
      final data = await ApiService.fetchHotelDetail(widget.hotel.id);
      final hotelDetail = data['data'] as Map<String, dynamic>? ?? {};
      final roomsRaw = hotelDetail['rooms'] as List<dynamic>? ?? [];

      final lat = double.tryParse(hotelDetail['latitude']?.toString() ?? '');
      final lng = double.tryParse(hotelDetail['longitude']?.toString() ?? '');

      if (!mounted) return;
      setState(() {
        _hotelDetail = hotelDetail;
        _isWishlisted = data['is_wishlist'] ?? false;
        _rooms = roomsRaw
            .whereType<Map<String, dynamic>>()
            .map((r) => Room.fromJson({...r, 'hotel': hotelDetail}))
            .toList();

        if (lat != null && lng != null) {
          _center = LatLng(lat, lng);
        } else {
          _getCoordinatesFromName(
            '${widget.hotel.name} ${widget.hotel.location}',
          );
        }

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
          // } else {
          //   await ApiService.deleteWishlistByHotelId(widget.hotel.id);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(body: Center(child: Text('Error: $_error')));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 280, // photo height
            pinned: true,
            backgroundColor: const Color(0xFF0E4399),
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // hotel photo fills header
                  widget.hotel.imagePath != null
                      ? Image.network(
                          widget.hotel.imagePath!,
                          fit: BoxFit.cover,
                        )
                      : Container(color: const Color(0xFF1E3A5F)),
                  // transparent-to-dark gradient overlay
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black26],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ],
                ),
              ),
            ),
            title: const Text(
              'Hotel Detail',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isWishlisted
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: Colors.white,
                ),
                onPressed: _isWishlistLoading ? null : _toggleWishlist,
              ),
            ],
          ),
          SliverToBoxAdapter(child: _buildBody(widget.hotel)),
        ],
      ),
    );
  }

  Widget _buildBody(Hotel hotel) {
    final hotelImages = (_hotelDetail?['hotel_images'] as List<dynamic>? ?? [])
        .map((e) => e['image']?.toString())
        .whereType<String>()
        .toList();

    final facilities =
        (_hotelDetail?['hotel_facilities'] as List<dynamic>? ?? []);
    final displayFacilities = facilities.take(6).toList();
    final hasMoreFacilities = facilities.length > 6;

    final description = _hotelDetail?['description']?.toString() ?? '';
    final truncated = description.length > 120
        ? description.substring(0, 120)
        : description;
    final aboutText = description.isEmpty
        ? 'No description available.'
        : _isExpanded
        ? description
        : description.length > 120
        ? '$truncated...'
        : description;

    final rating =
        double.tryParse(
          _hotelDetail?['hotel_rating']?.toString() ?? '',
        )?.toStringAsFixed(1) ??
        hotel.userRating.toStringAsFixed(1);

    final totalReviews = _hotelDetail?['total_reviews'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
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
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: List.generate(
                        hotel.starRating,
                        (_) => const Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: Color(0xFFFBBF24),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                GestureDetector(
                  onTap: _scrollToMap,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: Color(0xFF3B82F6),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hotel.location,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF3B82F6),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: Color(0xFF3B82F6),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                Container(height: 1, color: const Color(0xFFF1F5F9)),
                const SizedBox(height: 10),
                // rating + reviews row (keep as-is)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ReviewPage(bookingId: '0'),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star_outline_rounded,
                                  color: Color(0xFFF59E0B),
                                  size: 16,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '$rating / 5',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFF59E0B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          SizedBox(
                            width: 72,
                            height: 30,
                            child: Stack(
                              children: [
                                for (int i = 0; i < 3; i++)
                                  Positioned(
                                    left: i * 20.0,
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: [
                                          const Color(0xFF94A3B8),
                                          const Color(0xFF64748B),
                                          const Color(0xFF3B82F6),
                                        ][i],
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${totalReviews > 99 ? '99+' : totalReviews}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
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
        ),

        const SizedBox(height: 24),

        if (hotelImages.length >= 2)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Carousel(imageUrls: hotelImages, height: 220),
          ),

        const SizedBox(height: 24),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      child: Icon(
                        Icons.more_vert_outlined,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (displayFacilities.isEmpty)
                const Text(
                  'No amenities listed yet.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: displayFacilities.map((f) {
                    final facility = Facility.fromJson(
                      f as Map<String, dynamic>,
                    );
                    return _FacilityChip(facility: facility);
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
                  style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                )
              else
                ..._rooms.map((room) {
                  final roomsDetail =
                      _hotelDetail?['rooms'] as List<dynamic>? ?? [];
                  final roomImagesRaw =
                      roomsDetail.firstWhere(
                            (r) =>
                                r is Map<String, dynamic> && r['id'] == room.id,
                            orElse: () => <String, dynamic>{},
                          )
                          as Map<String, dynamic>;
                  final roomImages =
                      (roomImagesRaw['room_images'] as List<dynamic>? ?? [])
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
                    reviewScore: double.tryParse(rating) ?? hotel.userRating,
                  );
                }),

              const SizedBox(height: 20),
              Container(height: 1, color: const Color(0xFFF1F5F9)),
              const SizedBox(height: 20),

              const Text(
                'Locations',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              // new
              ClipRRect(
                key: _mapKey,
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 220,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _center,
                      initialZoom: 16,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=$_maptilerKey',
                        userAgentPackageName: 'com.example.frontend',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _center,
                            width: 50,
                            height: 50,
                            alignment: Alignment.topCenter,
                            child: const Icon(
                              Icons.location_on,
                              color: Color(0xFFEF4444),
                              size: 45,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  void _scrollToMap() {
    final ctx = _mapKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      alignment: 0.1,
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
                    color: Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: facilities.map((f) {
                    final facility = Facility.fromJson(
                      f as Map<String, dynamic>,
                    );
                    return _FacilityChip(facility: facility);
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

class _FacilityChip extends StatelessWidget {
  final Facility facility;
  const _FacilityChip({required this.facility});

  @override
  Widget build(BuildContext context) {
    final icon =
        Facility.iconMap[facility.icon] ?? Icons.check_circle_outline_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF3B82F6)),
          const SizedBox(width: 8),
          Text(
            facility.name,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF3B82F6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
