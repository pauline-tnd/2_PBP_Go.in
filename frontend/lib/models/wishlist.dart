class Wishlist {
  final int id;
  final int userId;
  final int hotelId;
  final Map<String, dynamic>? hotel;

  Wishlist({
    required this.id,
    required this.userId,
    required this.hotelId,
    this.hotel,
  });

  factory Wishlist.fromJson(Map<String, dynamic> json) {
    return Wishlist(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      hotelId: json['hotel_id'] ?? 0,
      hotel: json['hotel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'hotel_id': hotelId,
    };
  }
}
