import 'package:flutter/material.dart';

enum HotelBadge { topRated, recommended, verifiedPremium, bestDeals }

class Hotel {
  final int id;
  final String name;
  final String location;
  final int starRating;
  final double pricePerNight;
  final double userRating;
  final String? imagePath;
  final Color placeholderColor;
  final int popularity;
  final double distance;
  final List<String> amenities;
  final List<String> roomTypes;

  Hotel({
    required this.id,
    required this.name,
    required this.location,
    required this.starRating,
    required this.pricePerNight,
    required this.userRating,
    this.imagePath,
    required this.placeholderColor,
    required this.popularity,
    required this.distance,
    required this.amenities,
    required this.roomTypes,
  });

  factory Hotel.fromMap(Map<String, dynamic> map) {
    final images = map['hotel_images'] as List<dynamic>?;
    String? imageUrl = (images != null && images.isNotEmpty) 
        ? images.first['image'] 
        : null;
    final List<dynamic> roomsData = map['rooms'] as List<dynamic>? ?? [];
    double minPrice = 0;
    if (roomsData.isNotEmpty) {
      final prices = roomsData
        .map((room) => double.tryParse(room['price'].toString()) ?? 0.0)
        .where((p) => p > 0)
        .toList();
      if (prices.isNotEmpty) {
        minPrice = prices.reduce((curr, next) => curr < next ? curr : next);
      }
    }
    double averageRating = 0;
    List<num> allRatings = [];
    for (var room in roomsData) {
      final reviews = room['reviews'] as List<dynamic>? ?? [];
      for (var review in reviews) {
        if (review['rating'] != null) {
          allRatings.add(review['rating'] as num);
        }
      }
    }

    if (allRatings.isNotEmpty) {
      averageRating = allRatings.reduce((a, b) => a + b) / allRatings.length;
    }

    final facilitiesData = map['hotel_facilities'] as List<dynamic>? ?? [];
    final List<String> facilitiesList = facilitiesData
      .map((f) => f['name'].toString())
      .where((name) => name != 'null')
      .toList();

    return Hotel(
      id: map['id'] ?? 0,
      name: map['name'] ?? 'No Name',
      location: map['location'] ?? 'No Location',
      starRating: map['star'] ?? 0,
      pricePerNight: minPrice,
      userRating: averageRating,
      popularity: map['popularity'] ?? 0,
      distance: (map['distance'] ?? 0).toDouble(),
      imagePath: imageUrl,
      placeholderColor: const Color(0xFF1E3A5F),
      amenities: facilitiesList,
      roomTypes: map['room_types'] is List 
          ? List<String>.from(map['room_types']) 
          : [],
    );
  }

  String badgeLabel(HotelBadge badge) {
    switch (badge) {
      case HotelBadge.topRated:
        return 'TOP RATED';
      case HotelBadge.recommended:
        return 'RECOMMENDED FOR YOU';
      case HotelBadge.verifiedPremium:
        return 'VERIFIED PREMIUM';
      case HotelBadge.bestDeals:
        return 'BEST DEALS';
    }
  }

  Color badgeColor(HotelBadge badge) {
    switch (badge) {
      case HotelBadge.topRated:
        return const Color(0xFF3B82F6);
      case HotelBadge.recommended:
        return const Color(0xFF10B981);
      case HotelBadge.verifiedPremium:
        return const Color(0xFF6366F1);
      case HotelBadge.bestDeals:
        return const Color(0xFFF97316);
    }
  }

  IconData badgeIcon(HotelBadge badge) {
    switch (badge) {
      case HotelBadge.topRated:
        return Icons.star_rounded;
      case HotelBadge.recommended:
        return Icons.thumb_up_rounded;
      case HotelBadge.verifiedPremium:
        return Icons.verified_rounded;
      case HotelBadge.bestDeals:
        return Icons.local_offer_rounded;
    }
  }
}

Map<String, HotelBadge> assignBadges(List<Hotel> hotels) {
  if (hotels.isEmpty) return {};
  final Map<String, HotelBadge> badges = {};
  final Set<String> assigned = {};

  final topRated = hotels
      .where((h) => !assigned.contains(h.name))
      .reduce((a, b) => a.userRating > b.userRating
          ? a
          : (a.userRating == b.userRating
              ? (a.popularity < b.popularity ? a : b)
              : b));
  badges[topRated.name] = HotelBadge.topRated;
  assigned.add(topRated.name);

  final bestDeals = hotels
      .where((h) => !assigned.contains(h.name))
      .reduce((a, b) => a.pricePerNight < b.pricePerNight ? a : b);
  badges[bestDeals.name] = HotelBadge.bestDeals;
  assigned.add(bestDeals.name);

  final remaining = hotels.where((h) => !assigned.contains(h.name)).toList();
  if (remaining.isNotEmpty) {
    final premium = remaining
        .reduce((a, b) => a.pricePerNight > b.pricePerNight ? a : b);
    badges[premium.name] = HotelBadge.verifiedPremium;
    assigned.add(premium.name);
  }

  for (final hotel in hotels) {
    if (!assigned.contains(hotel.name)) {
      badges[hotel.name] = HotelBadge.recommended;
      assigned.add(hotel.name);
    }
  }
  return badges;
}

final List<Hotel> dummyHotels = [
  Hotel(
    id: 1,
    name: 'The Ritz London',
    location: 'Westminster Borough, London',
    starRating: 5,
    pricePerNight: 25600466,
    userRating: 4.8,
    placeholderColor: const Color(0xFF1E3A5F),
    popularity: 1,
    distance: 1.2,
    imagePath: 'assets/images/hotel/ritz-london-exterior.webp',
    amenities: ['WiFi', 'Spa', 'Restaurant', 'Gym', 'Parking', 'Swimming Pool', 'Water Heater'],
    roomTypes: ['Smoking', 'Non Smoking'],
  ),
  Hotel(
    id: 2,
    name: 'The Savoy',
    location: 'Strand, Westminster, London',
    starRating: 5,
    pricePerNight: 17314352,
    userRating: 4.6,
    placeholderColor: const Color(0xFF5E3A2D),
    popularity: 4,
    distance: 3.1,
    imagePath: 'assets/images/hotel/the-savoy-london.webp',
    amenities: ['WiFi', 'Restaurant', 'Gym', 'Parking', 'Laundry', 'Airport Shuttle', 'Water Heater'],
    roomTypes: ['Smoking', 'Non Smoking'],
  ),
  Hotel(
    id: 3,
    name: 'The Lanesborough',
    location: 'Strand, Westminster, London',
    starRating: 5,
    pricePerNight: 20683887,
    userRating: 4.9,
    placeholderColor: const Color(0xFF4A2D5E),
    popularity: 3,
    distance: 1.8,
    imagePath: 'assets/images/hotel/the-lanesborough-oetker-london.jpg',
    amenities: ['WiFi', 'Spa', 'Restaurant', 'Gym', 'Parking', 'Swimming Pool', 'Laundry', 'Pet Friendly', 'Water Heater'],
    roomTypes: ['Non Smoking'],
  ),
  Hotel(
    id: 4,
    name: 'Mandarin Oriental Hyde Par',
    location: 'Knightsbridge, Westminster Borough',
    starRating: 5,
    pricePerNight: 43684255,
    userRating: 4.7,
    placeholderColor: const Color(0xFF2D4A3E),
    popularity: 2,
    distance: 2.5,
    imagePath: 'assets/images/hotel/mandarin-oriental-hyde-park-london.jpg',
    amenities: ['WiFi', 'Spa', 'Restaurant', 'Gym', 'Swimming Pool', 'Laundry', 'Airport Shuttle', 'Water Heater'],
    roomTypes: ['Non Smoking'],
  ),
];

final Map<String, HotelBadge> hotelBadges = assignBadges(dummyHotels);