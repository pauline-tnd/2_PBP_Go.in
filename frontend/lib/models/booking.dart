class Booking {
  final int id;
  final int userId;
  final String bookingNumber;
  final String qrCode;
  final String checkIn;
  final String checkOut;
  final double totalPrice;
  final String status;
  final String updatedAt;

  // Nested relationship fields (from booking_details → room → hotel)
  final String? hotelName;
  final String? roomType;
  final String? roomImageUrl;
  final int? reviewRating;
  final int? reviewId;
  final bool hasReview;
  final List<BookingDetailLine> details;

  Booking({
    required this.id,
    required this.userId,
    required this.bookingNumber,
    required this.qrCode,
    required this.checkIn,
    required this.checkOut,
    required this.totalPrice,
    required this.status,
    required this.updatedAt,
    this.hotelName,
    this.roomType,
    this.roomImageUrl,
    this.reviewRating,
    this.reviewId,
    this.hasReview = false,
    this.details = const [],
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    String? hotelName;
    String? roomType;
    String? roomImageUrl;
    final details = <BookingDetailLine>[];
    Map<String, dynamic>? review;
    final rawDetails =
        json['booking_details'] ?? json['bookingDetails'] ?? json['details'];
    if (rawDetails is List && rawDetails.isNotEmpty) {
      final detail = rawDetails.first as Map<String, dynamic>? ?? {};
      review = detail['review'] as Map<String, dynamic>?;
      final room = detail['room'] as Map<String, dynamic>?;
      final hotel = room?['hotel'] as Map<String, dynamic>?;
      hotelName = hotel?['name']?.toString();
      roomType =
          room?['type']?.toString() ??
          room?['name']?.toString() ??
          room?['room_type']?.toString();
      roomImageUrl =
          // room?['image_url']?.toString() ??
          // room?['image']?.toString() ??
          hotel?['hotel_image']?['image'].toString();

      for (final rawDetail in rawDetails) {
        if (rawDetail is Map<String, dynamic>) {
          details.add(BookingDetailLine.fromJson(rawDetail));
        }
      }
    }

    return Booking(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      bookingNumber: json['booking_number'] ?? '',
      qrCode: json['qr_code']?.toString() ?? '',
      checkIn: json['check_in'] ?? '',
      checkOut: json['check_out'] ?? '',
      totalPrice: double.tryParse(json['total_price'].toString()) ?? 0.0,
      status: json['status'] ?? 'pending',
      updatedAt: json['updated_at']?.toString() ?? '',
      hotelName: hotelName,
      roomType: roomType,
      roomImageUrl: roomImageUrl,
      reviewRating: review?['rating'],
      reviewId: review?['id'],
      hasReview: review != null,
      details: details,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'booking_number': bookingNumber,
      'qr_code': qrCode,
      'check_in': checkIn,
      'check_out': checkOut,
      'total_price': totalPrice,
      'status': status,
      'updated_at': updatedAt,
    };
  }
}

class BookingDetailLine {
  final int id;
  final int totalRoom;
  final double subTotal;
  final String? notes;
  final String? roomType;
  final String? hotelName;
  final List<BookingAddOnLine> addOns;

  const BookingDetailLine({
    required this.id,
    required this.totalRoom,
    required this.subTotal,
    this.notes,
    this.roomType,
    this.hotelName,
    this.addOns = const [],
  });

  factory BookingDetailLine.fromJson(Map<String, dynamic> json) {
    final room = json['room'] as Map<String, dynamic>?;
    final hotel = room?['hotel'] as Map<String, dynamic>?;
    final rawAddOns = json['add_ons'] ?? json['addOns'] ?? json['addons'];
    final addOns = <BookingAddOnLine>[];

    if (rawAddOns is List) {
      for (final rawAddOn in rawAddOns) {
        if (rawAddOn is Map<String, dynamic>) {
          addOns.add(BookingAddOnLine.fromJson(rawAddOn));
        }
      }
    }

    return BookingDetailLine(
      id: json['id'] ?? 0,
      totalRoom: int.tryParse(json['total_room']?.toString() ?? '') ?? 1,
      subTotal: double.tryParse(json['sub_total']?.toString() ?? '') ?? 0,
      notes: json['notes']?.toString(),
      roomType:
          room?['type']?.toString() ??
          room?['name']?.toString() ??
          room?['room_type']?.toString(),
      hotelName: hotel?['name']?.toString(),
      addOns: addOns,
    );
  }
}

class BookingAddOnLine {
  final int quantity;
  final double subTotal;
  final String name;

  const BookingAddOnLine({
    required this.quantity,
    required this.subTotal,
    required this.name,
  });

  factory BookingAddOnLine.fromJson(Map<String, dynamic> json) {
    final addOn = json['add_on'] ?? json['addOn'] ?? json['addon'];
    final addOnMap = addOn is Map<String, dynamic> ? addOn : null;

    return BookingAddOnLine(
      quantity: int.tryParse(json['qty']?.toString() ?? '') ?? 1,
      subTotal: double.tryParse(json['sub_total']?.toString() ?? '') ?? 0,
      name:
          addOnMap?['name']?.toString() ?? json['name']?.toString() ?? 'Add on',
    );
  }
}
