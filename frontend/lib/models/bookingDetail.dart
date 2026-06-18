import 'package:flutter/material.dart';
import 'package:frontend/models/addOn.dart';

class BookingDetail {
  final int id;
  final Room room;
  int quantity;
  String notes;
  final String roomImage;
  List<AddOnItem> selectedAddOns;

  BookingDetail({
    required this.id,
    required this.room,
    required this.quantity,
    required this.notes,
    required this.roomImage,
    required this.selectedAddOns,
  });

  factory BookingDetail.fromJson(Map<String, dynamic> json) {
    return BookingDetail(
      id: json['id'] ?? 0,

      room: Room.fromJson(json['room'] ?? {}),

      quantity: json['quantity'] ?? json['total_room'] ?? 1,

      notes: json['notes'] ?? '',

      roomImage: json['room_image'] ?? json['roomImage'] ?? json['image'] ?? '',

      selectedAddOns: ((json['add_ons'] ?? json['addOns'] ?? []) as List)
          .map<AddOnItem>((e) {
            return AddOnItem(
              id: int.tryParse(e['id']?.toString() ?? '') ?? 0,
              name: e['name']?.toString() ?? '',

              price: double.tryParse(e['price'].toString()) ?? 0,

              icon: Icons.add_circle_outline,
            );
          })
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "room": room.toJson(),
      "quantity": quantity,
      "notes": notes,
      "room_image": roomImage,
      "add_ons": selectedAddOns
          .map((e) => {"id": e.id, "name": e.name, "price": e.price})
          .toList(),
    };
  }
}

class Room {
  final int id;
  final String type;
  final double price;

  Room({required this.id, required this.type, required this.price});

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? 0,
      type: json['type'] ?? json['name'] ?? 'Room',
      price: double.tryParse(json['price'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "type": type, "price": price};
  }
}
