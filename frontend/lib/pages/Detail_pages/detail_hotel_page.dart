import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:frontend/models/hotel.dart';
import 'package:frontend/models/review.dart';
import 'package:frontend/models/room.dart';
import 'package:frontend/models/bookingDetail.dart' as details;
import 'package:frontend/models/facilityIcons.dart';
import 'package:frontend/models/addOn.dart';

import 'package:frontend/widgets/room/room_card.dart';
import 'package:frontend/widgets/hotel/hotel_image.dart';
import 'package:frontend/widgets/common/carousel.dart';
import 'package:frontend/widgets/booking_confirmation_pop_up.dart';

import 'package:frontend/services/api_services.dart';
import 'package:frontend/extensions/snackbar.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:frontend/pages/settings/review_detail_page.dart';
import 'package:frontend/pages/payment_confirmation_page.dart';

class DetailHotelPage extends StatefulWidget {
  final Hotel hotel;
  final List<AddOnItem> addOns;
  final DateTime? checkIn;
  final DateTime? checkOut;

  const DetailHotelPage({
    super.key,
    required this.hotel,
    required this.addOns,
    this.checkIn,
    this.checkOut,
  });

  @override
  State<DetailHotelPage> createState() => _DetailHotelPageState();
}

class _DetailHotelPageState extends State<DetailHotelPage> {
  static const String _maptilerKey = 'E9ZFe6B1DmH71sbyAHar';

  bool _isWishlisted = false;
  bool _isWishlistLoading = false;
  bool _isExpanded = false;
  int? _wishlistId;
  int? _bookingId;
  Map<String, dynamic>? _hotelDetail;
  List<Room> _rooms = [];
  List<details.BookingDetail> _tempBookedList = [];
  List<Review> _hotelReviews = [];
  bool _loading = true;
  String? _error;
  final MapController _mapController = MapController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _mapKey = GlobalKey();
  LatLng _center = const LatLng(51.5071, -0.1417);
  String _pickedAddress = '';
  List<AddOnItem> _addOns = [];

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
      List<Review> rawReviews = [];
      try {
        rawReviews = await ApiService.fetchHotelReviews(widget.hotel.id);
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _hotelDetail = hotelDetail;
        _isWishlisted = data['is_wishlist'] ?? false;
        _rooms = [];
        _addOns = (hotelDetail['add_ons'] as List<dynamic>? ?? [])
            .map(
              (e) => AddOnItem(
                id: int.tryParse(e['id']?.toString() ?? '') ?? 0,
                name: e['name'] ?? '',
                price: double.tryParse(e['price'].toString()) ?? 0.0,
                icon:
                    FacilityIcons.iconMap[e['icon']?['icon']
                        ?.toString()
                        .trim()] ??
                    Icons.room_service_outlined,
              ),
            )
            .toList();

        for (final r in roomsRaw) {
          try {
            final roomData = Map<String, dynamic>.from(r);

            roomData['price'] =
                double.tryParse(roomData['price']?.toString() ?? '') ?? 0.0;

            _rooms.add(Room.fromJson({...roomData, 'hotel': hotelDetail}));
          } catch (e, s) {
            debugPrint('ROOM ERROR: $e');
            debugPrint('$s');
          }
        }

        if (lat != null && lng != null) {
          _center = LatLng(lat, lng);
        } else {
          _getCoordinatesFromName(
            '${widget.hotel.name} ${widget.hotel.location}',
          );
        }

        _hotelReviews = rawReviews;
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
        }

        if (mounted) {
          setState(() {
            _isWishlisted = false;
            _wishlistId = null;
          });

          context.showAppSnackBar('Removed from wishlist');
        }
      } else {
        await ApiService.storeWishlist(widget.hotel.id);

        if (mounted) {
          setState(() {
            _isWishlisted = true;
          });

          context.showAppSnackBar('Added to wishlist');
        }
      }
    } catch (e, s) {
      debugPrint('Wishlist error: $e');
      debugPrint('$s');

      if (mounted) {
        context.showAppSnackBar('Failed: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isWishlistLoading = false);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildMiniBookingBar() {
    final count = _tempBookedList.length;
    final title = count == 1
        ? _tempBookedList.first.room.type
        : '$count rooms selected';

    return GestureDetector(
      onTap: _showFullConfirmation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF94A3B8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: Color(0xFF94A3B8),
                      size: 24,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullConfirmation() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BookingConfirmationPopUp(
        bookingDetails: _tempBookedList,
        allAddOns: widget.addOns,
        hotelName: widget.hotel.name,
        hotelLocation: widget.hotel.location,
        previewImageUrl: widget.hotel.imagePath ?? '',
        onCustomAnother: () => Navigator.pop(sheetContext),
        onBookNow: (bookingList) {
          Navigator.pop(sheetContext);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PaymentConfirmationPage(
                hotelName: widget.hotel.name,
                hotelLocation: widget.hotel.location,
                previewImageUrl: widget.hotel.imagePath ?? '',
                bookingDetails: List.from(bookingList),
              ),
            ),
          );
        },
        onBookingListChanged: (updatedList) {
          setState(() {
            _tempBookedList = List.from(updatedList);
          });
        },
      ),
    );
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
            expandedHeight: 0,
            toolbarHeight: kToolbarHeight,
            pinned: true,
            backgroundColor: const Color.fromARGB(
              255,
              3,
              49,
              122,
            ).withAlpha(240),
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26.withAlpha(0),
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
              GestureDetector(
                onTap: _isWishlistLoading ? null : _toggleWishlist,
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(
                        color: Colors.white.withAlpha(40),
                        child: Center(
                          child: Icon(
                            _isWishlisted
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(child: _buildBody(widget.hotel)),
        ],
      ),
      bottomNavigationBar: _tempBookedList.isNotEmpty
          ? _buildMiniBookingBar()
          : null,
    );
  }

  Widget _buildBody(Hotel hotel) {
    final hotelImages = (_hotelDetail?['hotel_images'] as List<dynamic>? ?? [])
        .map((e) => e['image']?.toString())
        .whereType<String>()
        .toList();

    final roomsRaw = _hotelDetail?['rooms'] as List<dynamic>? ?? [];

    final List<String> allRoomImages = roomsRaw.expand((r) {
      if (r is! Map<String, dynamic>) return <String>[];
      return (r['room_images'] as List<dynamic>? ?? [])
          .map((e) => e['image']?.toString() ?? '')
          .where((img) => img.isNotEmpty);
    }).toList();

    final List<String> carouselImages = [
      ...hotelImages,
      ...allRoomImages.take(3),
    ];
    final List<String> displayImages = carouselImages.isNotEmpty
        ? carouselImages
        : [
            ...hotelImages,
            'assets/images/RoomDefault/hotel_room_1.png',
            'assets/images/RoomDefault/hotel_room_2.png',
          ];

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
        SizedBox(
          height: 400,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                child: SizedBox(
                  height: 280,
                  width: double.infinity,
                  child: widget.hotel.imagePath != null
                      ? HotelImage(
                          imagePath: widget.hotel.imagePath,
                          placeholderColor: const Color(0xFF1E3A5F),
                          width: double.infinity,
                          height: 280,
                          borderRadius: BorderRadius.zero,
                        )
                      : Container(color: const Color(0xFF1E3A5F)),
                ),
              ),

              Positioned(
                left: 16,
                right: 16,
                bottom: 10,
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
                              5,
                              (index) => Icon(
                                // index < num.parse(rating) ?
                                Icons
                                    .star, // plan awalnya sesuai review, tapi mengikuti desain
                                // : Icons.star_border_outlined
                                size: 18,
                                color: Color(0xFFFBBF24),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _scrollToMap();
                          },
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
                      ),

                      const SizedBox(height: 12),
                      Container(height: 1, color: const Color(0xFFF1F5F9)),
                      const SizedBox(height: 10),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 300;

                          final ratingBadge = Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
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
                          );

                          final avatarRow = Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                          );

                          return Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                try {
                                  final reviews = _hotelReviews;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReviewDetailPage(
                                        reviews: reviews,
                                        title: "Hotel Reviews",
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  debugPrint('Review parse error: $e');
                                }
                              },
                              child: isNarrow
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        ratingBadge,
                                        const SizedBox(height: 8),
                                        avatarRow,
                                      ],
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ratingBadge,
                                        const SizedBox(width: 14),
                                        avatarRow,
                                      ],
                                    ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 44),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Carousel(imageUrls: displayImages, height: 220),
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
                    final raw = Map<String, dynamic>.from(
                      f as Map<String, dynamic>,
                    );

                    final facility = FacilityIcons.fromJson(raw);

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

                  final List<String> combinedImages = roomImages.isNotEmpty
                      ? roomImages.cast<String>()
                      : hotelImages.isNotEmpty
                      ? <String>[hotelImages.first]
                      : <String>[];

                  return RoomCard(
                    room: room,
                    addOns: _addOns,
                    imageUrl: combinedImages.isNotEmpty
                        ? combinedImages.first
                        : null,
                    imageUrls: combinedImages,
                    facilities: facilities
                        .map(
                          (f) => Map<String, dynamic>.from(
                            f as Map<String, dynamic>,
                          ),
                        )
                        .toList(),
                    hotelName: hotel.name,
                    hotelLocation: hotel.location,
                    reviewScore: double.tryParse(rating) ?? hotel.userRating,
                    tempBookedList: _tempBookedList,
                    checkIn: widget.checkIn,
                    checkOut: widget.checkOut,
                    existingBookingId: _bookingId,
                    onNavigatedBack: (result) {
                      if (mounted && result != null) {
                        setState(() {
                          _tempBookedList = List.from(result['list'] as List);
                          _bookingId = result['bookingId'] as int?; // ADD
                        });
                      }
                    },
                  );
                }),

              const SizedBox(height: 20),
              Container(height: 1, color: const Color(0xFFF1F5F9)),
              const SizedBox(height: 20),

              Container(
                key: _mapKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    final raw = Map<String, dynamic>.from(
                      f as Map<String, dynamic>,
                    );

                    raw['name'] = raw['name']?.toString() ?? '';

                    final facility = FacilityIcons.fromJson(raw);
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
  final FacilityIcons facility;
  const _FacilityChip({required this.facility});

  IconData getFacilityIcon(String icon) {
    return FacilityIcons.iconMap[icon] ?? Icons.help_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final icon = getFacilityIcon(facility.icon);

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
