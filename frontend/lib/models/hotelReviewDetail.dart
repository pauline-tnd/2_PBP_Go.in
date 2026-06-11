class HotelReviewDetail {
  final int? userId;
  final int? roomId;
  final int? bookingDetailId;

  final String hotelName;
  final String roomType;
  final String relativeTime;
  final String imageName;
  final List<String> facilities;

  HotelReviewDetail({
    this.userId,
    this.roomId,
    this.bookingDetailId,
    required this.hotelName,
    required this.roomType,
    required this.relativeTime,
    required this.imageName,
    required this.facilities,
  });

  factory HotelReviewDetail.fromJson(Map<String, dynamic> json) {
    final hotelJson = json['hotel'] ?? {};
    final images = hotelJson['hotel_images'] as List? ?? [];
    final facilitiesList = hotelJson['hotel_facilities'] as List? ?? [];

    return HotelReviewDetail(
      userId: json['user_id'],
      roomId: json['room_id'],
      bookingDetailId: json['booking_detail_id'],

      hotelName: hotelJson['name'] ?? 'Unknown Hotel',
      roomType: json['room_type'] ?? 'Standard Room',
      relativeTime: json['check_out'] ?? '',
      imageName: images.isNotEmpty ? images[0]['image_url'] ?? '' : '',
      facilities: facilitiesList.map((f) => f['name'].toString()).toList(),
    );
  }
}
