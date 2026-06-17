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
    'bed_outlined': Icons.bed_rounded,
    'access_time_outlined': Icons.access_time_rounded,

    'free_breakfast_rounded': Icons.free_breakfast_rounded,
    'room_service_rounded': Icons.room_service_rounded,
    'self_improvement_rounded': Icons.self_improvement_rounded,
    'login_rounded': Icons.login_rounded,
    'logout_rounded': Icons.logout_rounded,
    'king_bed_rounded': Icons.king_bed_rounded,
  };

  factory FacilityIcons.fromJson(Map<String, dynamic> json) {
    return FacilityIcons(
      name: json['name'] ?? json['icon']?['name'] ?? '',
      icon: json['icon']?['icon']?.toString().trim() ?? '',
    );
  }
}
