import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../models/hotel.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/hotel_card.dart';
import '../widgets/sorting_bar.dart';
import 'package:frontend/models/hotel.dart';
import 'package:frontend/widgets/hotel_card.dart';
import 'package:frontend/widgets/sorting_bar.dart';
import 'package:frontend/widgets/skeleton_loader.dart';
import 'package:frontend/services/api_services.dart';
import 'package:frontend/pages/main_shell.dart';

class FilterState {
  final RangeValues priceRange;
  final Set<int> selectedStars;
  final Set<String> selectedAmenities;
  // final Set<String> selectedRoomTypes;

  const FilterState({
    this.priceRange = const RangeValues(0, 200000000),
    this.selectedStars = const {},
    this.selectedAmenities = const {},
    // this.selectedRoomTypes = const {},
  });

  bool get hasActiveFilters =>
      selectedStars.isNotEmpty ||
      selectedAmenities.isNotEmpty ||
      // selectedRoomTypes.isNotEmpty ||
      priceRange.start > 0 ||
      priceRange.end < 200000000;

  FilterState copyWith({
    RangeValues? priceRange,
    Set<int>? selectedStars,
    Set<String>? selectedAmenities,
    Set<String>? selectedRoomTypes,
  }) {
    return FilterState(
      priceRange: priceRange ?? this.priceRange,
      selectedStars: selectedStars ?? this.selectedStars,
      selectedAmenities: selectedAmenities ?? this.selectedAmenities,
      // selectedRoomTypes: selectedRoomTypes ?? this.selectedRoomTypes,
    );
  }
}

class SearchResultsPage extends StatefulWidget {
  final String? initialQuery;
  final String? location;
  final String? dateRange;

  const SearchResultsPage({
    super.key,
    this.initialQuery,
    this.location,
    this.dateRange,
  });

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  SortOption _currentSort = SortOption.none;
  FilterState _filterState = const FilterState();

  List<Hotel> _allHotels = [];
  bool _isLoading = true;
  Map<String, HotelBadge> _hotelBadges = {};

  @override
  void initState() {
    super.initState();
    // _fetchHotelsFromSupabase();
    _fetchHotels();
  }

  Future<void> _fetchHotels() async {
    try {
      final response = await ApiService.fetchHotels();
      final data = response['data'];
      final List<dynamic> hotelItems = data is List
          ? data
          : (data is Map<String, dynamic> && data['data'] is List)
          ? data['data']
          : [];
      final List<Hotel> fetchedHotels = hotelItems
          .map((item) => Hotel.fromMap(item as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      setState(() {
        _allHotels = fetchedHotels;
        _hotelBadges = assignBadges(_allHotels);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Hotel> get _filteredAndSortedHotels {
    List<Hotel> result = _allHotels.where((hotel) {
      if (hotel.pricePerNight < _filterState.priceRange.start ||
          hotel.pricePerNight > _filterState.priceRange.end) {
        return false;
      }
      if (_filterState.selectedStars.isNotEmpty &&
          !_filterState.selectedStars.contains(hotel.starRating)) {
        return false;
      }
      if (_filterState.selectedAmenities.isNotEmpty) {
        for (final amenity in _filterState.selectedAmenities) {
          if (!hotel.amenities.contains(amenity)) {
            return false;
          }
        }
      }
      // if (_filterState.selectedRoomTypes.isNotEmpty) {
      //   bool hasMatch = false;
      //   for (final roomType in _filterState.selectedRoomTypes) {
      //     if (hotel.roomTypes.contains(roomType)) {
      //       hasMatch = true;
      //       break;
      //     }
      //   }
      //   if (!hasMatch) return false;
      // }
      return true;
    }).toList();

    switch (_currentSort) {
      case SortOption.none:
        break;
      case SortOption.priceHighToLow:
        result.sort((a, b) => b.pricePerNight.compareTo(a.pricePerNight));
        break;
      case SortOption.priceLowToHigh:
        result.sort((a, b) => a.pricePerNight.compareTo(b.pricePerNight));
        break;
      case SortOption.ratingHighToLow:
        result.sort((a, b) => b.userRating.compareTo(a.userRating));
        break;
      case SortOption.popularity:
        result.sort((a, b) => a.popularity.compareTo(b.popularity));
        break;
      case SortOption.distance:
        result.sort((a, b) => a.distance.compareTo(b.distance));
        break;
    }

    return result;
  }

  void _sortHotels(SortOption option) {
    setState(() {
      _currentSort = option;
    });
  }

  void _showFilterSheet() async {
    final result = await showModalBottomSheet<FilterState>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => _FilterBottomSheet(initialFilter: _filterState),
    );

    if (result != null) {
      setState(() {
        _filterState = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SearchResultsSkeletonPage();
    }
    final hotels = _filteredAndSortedHotels;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      body: Stack(
        children: [
          Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 14.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        child: SortingBar(
                          selectedSort: _currentSort,
                          onSortChanged: _sortHotels,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        child: hotels.isEmpty
                            ? _buildEmptyState()
                            : LayoutBuilder(
                                builder: (context, constraints) {
                                  int crossAxisCount = 1;
                                  double childAspectRatio = 1.038;
                                  if (constraints.maxWidth >= 1200) {
                                    crossAxisCount = 4;
                                    childAspectRatio = 0.78;
                                  } else if (constraints.maxWidth >= 900) {
                                    crossAxisCount = 3;
                                    childAspectRatio = 0.82;
                                  } else if (constraints.maxWidth >= 600) {
                                    crossAxisCount = 2;
                                    childAspectRatio = 0.94;
                                  }
                                  return GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: hotels.length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: crossAxisCount,
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 16,
                                          childAspectRatio: childAspectRatio,
                                        ),
                                    itemBuilder: (context, index) {
                                      final hotel = hotels[index];
                                      final badge = _hotelBadges[hotel.name];
                                      return HotelCard(
                                        hotel: hotel,
                                        badge: badge,
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 24.sp,
            color: const Color(0xFF94A3B8).withAlpha(128),
          ),
          SizedBox(height: 2.h),
          const Text(
            'No hotels found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(fontSize: 14.sp, color: Color(0xFF94A3B8)),
          ),
          SizedBox(height: 3.h),
          GestureDetector(
            onTap: () {
              setState(() {
                _filterState = const FilterState();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(4.w),
              ),
              child: Text(
                'Clear Filters',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 1.5.h,
        bottom: 1.8.h,
        left: 5.w,
        right: 5.w,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              final mainShell = context
                  .findAncestorStateOfType<MainShellState>();
              mainShell?.hideOverlayPage();
            },
            child: const SizedBox(
              width: 32,
              height: 40,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 22,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.location ?? widget.initialQuery ?? 'Anywhere',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.dateRange ?? 'ANY DATE',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _showFilterSheet,
            child: Stack(
              children: [
                Container(
                  width: 10.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: _filterState.hasActiveFilters
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFF3B82F6).withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: _filterState.hasActiveFilters
                        ? Colors.white
                        : const Color(0xFF3B82F6),
                  ),
                ),
                if (_filterState.hasActiveFilters)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final FilterState initialFilter;

  const _FilterBottomSheet({required this.initialFilter});

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late RangeValues _priceRange;
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  late Set<int> _selectedStars;
  late Set<String> _selectedAmenities;
  // late Set<String> _selectedRoomTypes;

  final List<Map<String, dynamic>> _amenities = [
    {'name': 'WiFi', 'icon': Icons.wifi_rounded},
    {'name': 'Spa', 'icon': Icons.spa_rounded},
    {'name': 'Restaurant', 'icon': Icons.restaurant_rounded},
    {'name': 'Laundry', 'icon': Icons.local_laundry_service_rounded},
    {'name': 'Swimming Pool', 'icon': Icons.pool_rounded},
    {'name': 'Parking', 'icon': Icons.local_parking_rounded},
    {'name': 'Airport Shuttle', 'icon': Icons.airport_shuttle_rounded},
    {'name': 'Gym', 'icon': Icons.fitness_center_rounded},
    {'name': 'Pet Friendly', 'icon': Icons.pets_rounded},
    {'name': 'Water Heater', 'icon': Icons.hot_tub_rounded},
  ];

  // final List<Map<String, dynamic>> _roomTypes = [
  //   {'name': 'Smoking', 'icon': Icons.smoking_rooms_rounded},
  //   {'name': 'Non Smoking', 'icon': Icons.smoke_free_rounded},
  // ];

  @override
  void initState() {
    super.initState();
    _priceRange = widget.initialFilter.priceRange;
    _selectedStars = Set.from(widget.initialFilter.selectedStars);
    _selectedAmenities = Set.from(widget.initialFilter.selectedAmenities);
    // _selectedRoomTypes = Set.from(widget.initialFilter.selectedRoomTypes);
    _minPriceController = TextEditingController(
      text: _formatPrice(_priceRange.start.toInt()),
    );
    _maxPriceController = TextEditingController(
      text: _formatPrice(_priceRange.end.toInt()),
    );
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  String _formatPrice(int price) {
    return NumberFormat('#,###', 'id_ID').format(price);
  }

  int _parsePrice(String text) {
    final cleaned = text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned) ?? 0;
  }

  void _onMinPriceSubmitted(String value) {
    final parsed = _parsePrice(value);
    final clamped = parsed.clamp(0, _priceRange.end.toInt());
    setState(() {
      _priceRange = RangeValues(clamped.toDouble(), _priceRange.end);
      _minPriceController.text = _formatPrice(clamped);
    });
  }

  void _onMaxPriceSubmitted(String value) {
    final parsed = _parsePrice(value);
    final clamped = parsed.clamp(_priceRange.start.toInt(), 200000000);
    setState(() {
      _priceRange = RangeValues(_priceRange.start, clamped.toDouble());
      _maxPriceController.text = _formatPrice(clamped);
    });
  }

  void _resetFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 200000000);
      _minPriceController.text = _formatPrice(0);
      _maxPriceController.text = _formatPrice(200000000);
      _selectedStars = {};
      _selectedAmenities = {};
      // _selectedRoomTypes = {};
    });
  }

  void _applyFilters() {
    Navigator.pop(
      context,
      FilterState(
        priceRange: _priceRange,
        selectedStars: _selectedStars,
        selectedAmenities: _selectedAmenities,
        // selectedRoomTypes: _selectedRoomTypes,
      ),
    );
  }

  int get _activeFilterCount {
    int count = 0;
    if (_priceRange.start > 0 || _priceRange.end < 200000000) count++;
    if (_selectedStars.isNotEmpty) count++;
    if (_selectedAmenities.isNotEmpty) count++;
    // if (_selectedRoomTypes.isNotEmpty) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      behavior: HitTestBehavior.opaque,
      child: GestureDetector(
        onTap: () {},
        child: DraggableScrollableSheet(
          initialChildSize: 0.82,
          maxChildSize: 0.93,
          minChildSize: 0.5,
          builder: (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: Icon(
                    Icons.horizontal_rule,
                    color: Colors.grey,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Filters',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        if (_activeFilterCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$_activeFilterCount',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    GestureDetector(
                      onTap: _resetFilters,
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  'Price Range',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Min (Rp)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7F8),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: TextField(
                              controller: _minPriceController,
                              keyboardType: TextInputType.number,
                              onSubmitted: _onMinPriceSubmitted,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                border: InputBorder.none,
                                hintText: '0',
                                hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '—',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Max (Rp)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7F8),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: TextField(
                              controller: _maxPriceController,
                              keyboardType: TextInputType.number,
                              onSubmitted: _onMaxPriceSubmitted,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                border: InputBorder.none,
                                hintText: '200.000.000',
                                hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 200000000,
                  divisions: 200,
                  activeColor: const Color(0xFF3B82F6),
                  inactiveColor: const Color(0xFFE2E8F0),
                  labels: RangeLabels(
                    'Rp ${_formatPrice(_priceRange.start.toInt())}',
                    'Rp ${_formatPrice(_priceRange.end.toInt())}',
                  ),
                  onChanged: (values) {
                    setState(() {
                      _priceRange = values;
                      _minPriceController.text = _formatPrice(
                        values.start.toInt(),
                      );
                      _maxPriceController.text = _formatPrice(
                        values.end.toInt(),
                      );
                    });
                  },
                ),
                SizedBox(height: 3.h),
                Text(
                  'Hotel Class',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(5, (index) {
                    final star = index + 1;
                    final isSelected = _selectedStars.contains(star);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedStars.remove(star);
                          } else {
                            _selectedStars.add(star);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF3B82F6).withAlpha(46)
                              : const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(4.w),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF3B82F6)
                                : const Color(0xFF94A3B8).withAlpha(97),
                            width: isSelected ? 1.0 : 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...List.generate(
                              star,
                              (_) => const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: Color(0xFFFBBF24),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$star',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Amenities',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _amenities.map((amenity) {
                    final name = amenity['name'] as String;
                    final icon = amenity['icon'] as IconData;
                    final isSelected = _selectedAmenities.contains(name);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedAmenities.remove(name);
                          } else {
                            _selectedAmenities.add(name);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF3B82F6).withAlpha(46)
                              : const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(4.w),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF3B82F6)
                                : const Color(0xFF94A3B8).withAlpha(97),
                            width: isSelected ? 1.0 : 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icon,
                              size: 16,
                              color: const Color(0xFF3B82F6),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 3.h),
                // Text(
                //   'Room Type',
                //   style: TextStyle(
                //     fontSize: 16.sp,
                //     fontWeight: FontWeight.w600,
                //     color: Color(0xFF1E293B),
                //   ),
                // ),
                // const SizedBox(height: 12),
                // Wrap(
                //   spacing: 10,
                //   runSpacing: 10,
                //   children: _roomTypes.map((roomType) {
                //     final name = roomType['name'] as String;
                //     final icon = roomType['icon'] as IconData;
                //     final isSelected = _selectedRoomTypes.contains(name);
                //     return GestureDetector(
                //       onTap: () {
                //         setState(() {
                //           if (isSelected) {
                //             _selectedRoomTypes.remove(name);
                //           } else {
                //             _selectedRoomTypes.add(name);
                //           }
                //         });
                //       },
                //       child: Container(
                //         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                //         decoration: BoxDecoration(
                //           color: isSelected
                //               ? const Color(0xFF3B82F6).withAlpha(46)
                //               : const Color(0xFFFFFFFF),
                //           borderRadius: BorderRadius.circular(4.w),
                //           border: Border.all(
                //             color: isSelected
                //                 ? const Color(0xFF3B82F6)
                //                 : const Color(0xFF94A3B8).withAlpha(97),
                //             width: isSelected ? 1.0 : 0.5,
                //           ),
                //         ),
                //         child: Row(
                //           mainAxisSize: MainAxisSize.min,
                //           children: [
                //             Icon(icon, size: 16, color: const Color(0xFF3B82F6)),
                //             const SizedBox(width: 8),
                //             Text(
                //               name,
                //               style: const TextStyle(
                //                 fontSize: 13,
                //                 fontWeight: FontWeight.w500,
                //                 color: Color(0xFF3B82F6),
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     );
                //   }).toList(),
                // ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 6.5.h,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
