import 'package:flutter/material.dart';

class FacilityIcons {
  final String name;
  final String icon;

  FacilityIcons({required this.name, required this.icon});

  static final Map<String, IconData> iconMap = {
    'wifi_rounded': Icons.wifi_rounded,
    'spa_rounded': Icons.spa_rounded,
    'restaurant_rounded': Icons.restaurant_rounded,
    'local_laundry_service_rounded': Icons.local_laundry_service_rounded,
    'pool_rounded': Icons.pool_rounded,
    'local_parking_rounded': Icons.local_parking_rounded,
    'airport_shuttle_rounded': Icons.airport_shuttle_rounded,
    'fitness_center_rounded': Icons.fitness_center_rounded,
    'pets_rounded': Icons.pets_rounded,
    'hot_tub_rounded': Icons.hot_tub_rounded,
  };

  factory FacilityIcons.fromJson(Map<String, dynamic> json) {
    return FacilityIcons(
      name: json['name'] ?? '',
      icon: json['icon']?['icon']?.toString().trim() ?? '',
    );
  }
}
