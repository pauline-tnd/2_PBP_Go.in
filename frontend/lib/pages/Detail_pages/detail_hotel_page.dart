import 'package:flutter/material.dart';
import 'package:frontend/models/hotel.dart';
import 'package:frontend/models/room.dart';
import 'package:frontend/widgets/room_card.dart';
import 'package:frontend/widgets/hotel_image.dart';
import 'package:frontend/services/api_services.dart';
import 'package:frontend/extensions/snackbar.dart';
import 'package:frontend/models/facility.dart';
import 'package:frontend/widgets/common/carousel.dart';
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
  LatLng _center = const LatLng(51.5071, -0.1417); // ganti plz
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
              Stack(
                clipBehavior: Clip.none,
                children: [
                  HotelImage(
                    imagePath: hotelImages.isNotEmpty
                        ? hotelImages.first
                        : hotel.imagePath,
                    placeholderColor: const Color(0xFF1E3A5F),
                    width: double.infinity,
                    height: 220,
                    borderRadius: BorderRadius.zero,
                  ),

                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.18),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: -60,
                    left: 16,
                    right: 16,
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
                            onTap: () {},
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

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                alignment: Alignment.topRight,
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 80),

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
                          final facility = Facility.fromJson(
                            f as Map<String, dynamic>,
                          );
                          return _FacilityChip(facility: facility);
                        }).toList(),
                      ),

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
                        return RoomCard(
                          room: room,
                          hotelName: hotel.name,
                          reviewScore:
                              double.tryParse(rating) ?? hotel.userRating,
                        );
                      }),

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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 220,
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _center,
                            initialZoom: 16,
                            interactionOptions: const InteractionOptions(
                              flags:
                                  InteractiveFlag.all & ~InteractiveFlag.rotate,
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
