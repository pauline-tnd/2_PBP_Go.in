class HotelReviewDetail {
  final String hotelName;
  final String roomType;
  final String imageName;
  final DateTime checkOutDate;
  final List<String> facilities;

  HotelReviewDetail({
    required this.hotelName,
    required this.roomType,
    required this.imageName,
    required this.checkOutDate,
    required this.facilities,
  });

  factory HotelReviewDetail.fromJson(Map<String, dynamic> json) {
    var facilityList = json['hotel']['hotel_facilities'] as List? ?? [];
    List<String> parsedFacilities = facilityList
        .map((f) => f['name'].toString())
        .toList();

    var imageList = json['hotel']['hotel_images'] as List? ?? [];
    String img = '';
    if (imageList.isNotEmpty && imageList[0]['image'] != null) {
      img = imageList[0]['image'].toString();
    }
    return HotelReviewDetail(
      hotelName: json['hotel']['name'] ?? 'Unknown Hotel',
      roomType: json['room_type'] ?? 'Standard Room',
      imageName: img,
      checkOutDate: DateTime.parse(json['check_out']),
      facilities: parsedFacilities,
    );
  }

  String get relativeTime {
    final today = DateTime.now();
    final cleanToday = DateTime(today.year, today.month, today.day);
    final cleanCheckOut = DateTime(
      checkOutDate.year,
      checkOutDate.month,
      checkOutDate.day,
    );
    final difference = cleanToday.difference(cleanCheckOut).inDays;
    if (difference <= 0) {
      return "STAYED TODAY";
    } else if (difference == 1) {
      return "STAYED 1 DAY AGO";
    } else {
      return "STAYED $difference DAYS AGO";
    }
  }
}
