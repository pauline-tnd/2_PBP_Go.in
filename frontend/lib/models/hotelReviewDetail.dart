class HotelReviewDetail {
  final String hotelName;
  final String imageName;
  final String relativeTime;
  final String roomType;
  final List<String> facilities;
  final int? userId;
  final int? roomId;
  final int? bookingDetailId;

  HotelReviewDetail({
    required this.hotelName,
    required this.imageName,
    required this.relativeTime,
    required this.roomType,
    required this.facilities,
    this.userId,
    this.roomId,
    this.bookingDetailId,
  });

  factory HotelReviewDetail.fromJson(Map<String, dynamic> json) {
    final images = json['hotel_images'] as List<dynamic>? ?? [];
    final facilities = json['hotel_facilities'] as List<dynamic>? ?? [];

    return HotelReviewDetail(
      hotelName: json['hotel']?['name'] ?? '',
      imageName: images.isNotEmpty ? images.first['image'] ?? '' : '',
      relativeTime: json['check_out'] ?? '',
      roomType: json['room_type'] ?? '',
      facilities: facilities.map((f) => f['name'].toString()).toList(),
      userId: json['user_id'],
      roomId: json['room_id'],
      bookingDetailId: json['booking_detail_id'],
    );
  }
}
