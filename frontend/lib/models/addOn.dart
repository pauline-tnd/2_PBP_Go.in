import 'package:flutter/material.dart';

class AddOnItem {
  final int id;
  final String name;
  final double price;
  final IconData icon;

  const AddOnItem({
    this.id = 0,
    required this.name,
    required this.price,
    required this.icon,
  });

  factory AddOnItem.fromJson(Map<String, dynamic> json) {
    final iconData = json['icon'];
    String iconKey = '';
    if (iconData is Map<String, dynamic>) {
      iconKey = iconData['icon']?.toString() ?? '';
    } else if (iconData is String) {
      iconKey = iconData;
    }
    if (iconKey.isEmpty) iconKey = json['name']?.toString() ?? '';

    return AddOnItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      icon: _getIconForAddOn(iconKey),
    );
  }

  static IconData _getIconForAddOn(String iconName) {
    final normalized = iconName.toLowerCase().trim();
    final Map<String, IconData> iconMap = {
      'wifi_rounded': Icons.wifi,
      'spa_rounded': Icons.spa,
      'restaurant_rounded': Icons.restaurant,
      'access_time_outlined': Icons.access_time,
      'bed_outlined': Icons.single_bed,
      'extra bed': Icons.single_bed,
      'massage': Icons.spa,
      'breakfast': Icons.restaurant,
      'early check in': Icons.access_time,
      'late check out': Icons.single_bed,
    };
    return iconMap[normalized] ?? Icons.room_service_outlined;
  }
}
