class Booking {
  final int id;
  final int userId;
  final String bookingNumber;
  final String checkIn;
  final String checkOut;
  final double totalPrice;
  final String status;

  // Nested relationship fields (from booking_details → room → hotel)
  final String? hotelName;
  final String? roomType;
  final String? roomImageUrl;

  Booking({
    required this.id,
    required this.userId,
    required this.bookingNumber,
    required this.checkIn,
    required this.checkOut,
    required this.totalPrice,
    required this.status,
    this.hotelName,
    this.roomType,
    this.roomImageUrl,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    String? hotelName;
    String? roomType;
    String? roomImageUrl;

    // Try to extract nested hotel/room info from booking_details relationship
    final rawDetails =
        json['booking_details'] ?? json['bookingDetails'] ?? json['details'];
    if (rawDetails is List && rawDetails.isNotEmpty) {
      final detail = rawDetails.first as Map<String, dynamic>? ?? {};
      final room = detail['room'] as Map<String, dynamic>?;
      final hotel = room?['hotel'] as Map<String, dynamic>?;
      hotelName = hotel?['name']?.toString();
      roomType = room?['name']?.toString() ??
          room?['type']?.toString() ??
          room?['room_type']?.toString();
      roomImageUrl = room?['image_url']?.toString() ??
          room?['image']?.toString() ??
          hotel?['image_url']?.toString() ??
          hotel?['image']?.toString();
    }

    return Booking(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      bookingNumber: json['booking_number'] ?? '',
      checkIn: json['check_in'] ?? '',
      checkOut: json['check_out'] ?? '',
      totalPrice: double.tryParse(json['total_price'].toString()) ?? 0.0,
      status: json['status'] ?? 'pending',
      hotelName: hotelName,
      roomType: roomType,
      roomImageUrl: roomImageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'booking_number': bookingNumber,
      'check_in': checkIn,
      'check_out': checkOut,
      'total_price': totalPrice,
      'status': status,
    };
  }
}
