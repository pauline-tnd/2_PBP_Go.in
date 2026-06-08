import 'package:frontend/models/review_user.dart';

class Review {
  final int id;
  final int userId;
  final int roomId;
  final int bookingDetailId;
  final int rating;
  final String description;
  final String? image;
  final String? createdAt;
  final ReviewUser? user;

  Review({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.bookingDetailId,
    required this.rating,
    required this.description,
    this.image,
    this.createdAt,
    this.user,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      roomId: json['room_id'] ?? 0,
      bookingDetailId: json['booking_detail_id'] ?? 0,
      rating: json['rating'] ?? 0,
      description: json['description'] ?? '',
      image: json['image'],
      createdAt: json['created_at'],
      user: json['user'] != null ? ReviewUser.fromJson(json['user']) : null,
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
