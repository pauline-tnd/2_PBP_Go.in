import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/room.dart';

class ApiService {
  final String baseUrl = 'https://127.0.0.1:8000/api';

  Future<List<Room>> fetchRoom(int hotelId) async {
    final response = await http.get(Uri.parse('$baseUrl/hotel/$hotelId/rooms'));

    if (response.statusCode == 200) {
      // final data = jsonDecode(response.body);
      final data = jsonDecode(response.body)['data'];
      return data.map<Room>((room) => Room.fromJson(room)).toList();
    } else {
      throw Exception('Failed to load room');
    }
  }

  Future<Room> fetchRoomDetail(int hotelId, int roomId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/hotel/$hotelId/room/$roomId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Room.fromJson(data);
    } else {
      throw Exception('Failed to load room detail');
    }
  }
}
