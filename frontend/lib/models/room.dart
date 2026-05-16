class Room {
  final int id;
  final int hotelId;
  final String type;
  final String description;
  final double price;
  final int capacity;
  final String roomSize;

  Room({
    required this.id,
    required this.hotelId,
    required this.type,
    required this.description,
    required this.price,
    required this.capacity,
    required this.roomSize,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? 0,
      hotelId: json['hotel_id'] ?? 0,
      type: json['type'] ?? 'No Type',
      description: json['description'] ?? 'No Description',
      price: json['price'] ?? 0.0,
      capacity: json['capacity'] ?? 0,
      roomSize: json['room_size'] ?? 'No Size',
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
