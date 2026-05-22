import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Review {
  final int id;
  final int userId;
  final int roomId;
  final int bookingDetailId;
  final double rating;
  final String description;
  final int capacity;

  Review({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.bookingDetailId,
    this.createdAt,
    required this.capacity,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      roomId: json['room_id'] ?? 0,
      bookingDetailId: json['booking_detail_id'] ?? 0,
      rating: json['rating'] ?? 0,
      description: json['description'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'room_id': roomId,
      'booking_detail_id': bookingDetailId,
      'rating': rating,
      'description': description,
      'image': image,
      'created_at': createdAt,
    };
  }
}
