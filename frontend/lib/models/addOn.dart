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
    return AddOnItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      icon: Icons.room_service_outlined,
    );
  }
}
