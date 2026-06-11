import 'package:flutter/material.dart';
import 'package:frontend/models/addOn.dart';

class Room {
  final int id;
  final int hotelId;
  final String type;
  final String description;
  final double price;
  final int capacity;
  final String roomSize;
  final List<AddOnItem> addOns;
  final List<String> roomImages;
  final List<Map<String, dynamic>> roomFacilities;

  Room({
    required this.id,
    required this.hotelId,
    required this.type,
    required this.description,
    required this.price,
    required this.capacity,
    required this.roomSize,
    required this.addOns,
    required this.roomImages,
    this.roomFacilities = const [],
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0.0;
    }

    final rawAddOns = json['hotel']?['add_ons'] as List<dynamic>? ?? [];
    final rawFacilities = json['room_facilities'] as List<dynamic>? ?? [];

    return Room(
      id: json['id'] ?? 0,
      hotelId: json['hotel_id'] ?? 0,
      type: json['type'] ?? 'No Type',
      description: json['description'] ?? 'No Description',
      price: json['price'] ?? 0.0,
      capacity: json['capacity'] ?? 0,
      roomSize: json['room_size'] ?? 'No Size',
      addOns: rawAddOns
          .map(
            (e) => AddOnItem(
              name: e['name'] ?? '',
              price: double.tryParse(e['price'].toString()) ?? 0.0,
              icon: Icons.add_circle_outline_rounded,
            ),
          )
          .toList(),
      roomImages: (json['room_images'] as List<dynamic>? ?? [])
          .map((e) => e['image']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList(),
      roomFacilities: rawFacilities
          .map(
            (f) => {
              'name': f['name'] ?? '',
              'icon': Icons.check_circle_outline,
            },
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotel_id': hotelId,
      'type': type,
      'description': description,
      'price': price,
      'capacity': capacity,
      'room_size': roomSize,
    };
  }
}
