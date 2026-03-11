import 'package:flutter/material.dart';

class Hotel {
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
}

final List<Hotel> dummyHotels = [
  Hotel(
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
    name: 'Mandarin Oriental Hyde Park',
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