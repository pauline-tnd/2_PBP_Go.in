import 'dart:convert';
import 'dart:io';

import 'package:frontend/models/booking.dart';
import 'package:frontend/models/nominatim.dart';
import 'package:frontend/models/review.dart';
import 'package:frontend/models/room.dart';
import 'package:frontend/models/wishlist.dart';
import 'package:frontend/services/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  static const String nominatimUrl = 'https://nominatim.openstreetmap.org';
  static const Map<String, String> headersNominatim = {
    'User-Agent': 'GoInApp/1.0',
    'Accept-Language': 'en',
  };

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> saveToken(String token) async {
    await _saveToken(token);
  }

  static Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    // final token = 'tokentempeldisini';
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String phone,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'phone': phone,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Register failed: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveToken(data['token']);
      return data;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> logout() async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      return jsonDecode(response.body);
    } else {
      throw Exception('Logout failed: ${response.body}');
    }
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<Map<String, dynamic>> getUser() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print(response.body);
      throw Exception('Failed to load user: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updateUser({
    String? username,
    String? phone,
    String? email,
  }) async {
    final headers = await _authHeaders();
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (phone != null) body['phone'] = phone;
    if (email != null) body['email'] = email;

    final response = await http.put(
      Uri.parse('$baseUrl/user'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final headers = await _authHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/user/password'),
      headers: headers,
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      }),
    );
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(response.body);
    }
  }

  static Future<Map<String, dynamic>> updateProfileImage(File imageFile) async {
    final headers = await _authHeaders();
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/user/profile'),
    );

    request.headers.addAll(headers);

    request.files.add(
      await http.MultipartFile.fromPath('profile_image', imageFile.path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update profile image: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> deleteUser() async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/user'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete user: ${response.body}');
    }
  }

  static Future<List<NominatimResult>> search(String query) async {
    if (query.trim().isEmpty) return [];

    final response = await http.get(
      Uri.parse('$nominatimUrl/search').replace(
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': '5',
          'addressdetails': '1',
          'countrycodes': 'id',
        },
      ),
      headers: headersNominatim,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => NominatimResult.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load location: ${response.body}');
    }
  }

  static Future<String> reverseGeocode(double lat, double lon) async {
    final response = await http.get(
      Uri.parse('$nominatimUrl/reverse').replace(
        queryParameters: {
          'lat': lat.toString(),
          'lon': lon.toString(),
          'format': 'json',
          'addressdetails': '1',
        },
      ),
      headers: headersNominatim,
    );

    String formatAddress(Map<String, dynamic> addr) {
      final parts = <String>[];

      if (addr['road'] != null) parts.add(addr['road']);
      if (addr['suburb'] != null) parts.add(addr['suburb']);
      if (addr['city'] != null) {
        parts.add(addr['city']);
      } else if (addr['town'] != null) {
        parts.add(addr['town']);
      } else if (addr['county'] != null) {
        parts.add(addr['county']);
      }

      return parts.isNotEmpty ? parts.join(', ') : 'Selected location';
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return formatAddress(data['address']);
    } else {
      throw Exception('Location unknown: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> fetchHotels({
    String? search,
    double? minPrice,
    double? maxPrice,
    List<int>? star,
    String? sortBy,
    double? userLat,
    double? userLng,
    List<int>? amenities,
    String? cursor,
  }) async {
    final headers = await _authHeaders();
    final queryParameters = <String, dynamic>{};

    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }
    if (minPrice != null) queryParameters['min_price'] = minPrice.toString();
    if (maxPrice != null) queryParameters['max_price'] = maxPrice.toString();
    if (sortBy != null) queryParameters['sort_by'] = sortBy;
    if (userLat != null) queryParameters['user_lat'] = userLat.toString();
    if (userLng != null) queryParameters['user_lng'] = userLng.toString();
    if (cursor != null) queryParameters['cursor'] = cursor;
    if (star != null && star.isNotEmpty) {
      queryParameters['star[]'] = star.map((s) => s.toString()).toList();
    }
    if (amenities != null && amenities.isNotEmpty) {
      queryParameters['amenities[]'] = amenities
          .map((a) => a.toString())
          .toList();
    }

    final uri = Uri.parse(
      '$baseUrl/hotels',
    ).replace(queryParameters: queryParameters);
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load hotels: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> fetchHotelDetail(int hotelId) async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/hotels/$hotelId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load hotel detail: ${response.body}');
    }
  }

  static Future<List<Room>> fetchRooms() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/rooms'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      return data.map<Room>((room) => Room.fromJson(room)).toList();
    } else {
      throw Exception('Failed to load rooms: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> fetchRoomDetail(int roomId) async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/rooms/$roomId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load room detail: ${response.body}');
    }
  }

  static Future<List<Wishlist>> fetchWishlists() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/wishlists'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      return data.map<Wishlist>((item) => Wishlist.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load wishlists: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> storeWishlist(int hotelId) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/wishlists'),
      headers: headers,
      body: jsonEncode({'hotel_id': hotelId}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to store wishlist: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> deleteWishlist(int wishlistId) async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/wishlists/$wishlistId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete wishlist: ${response.body}');
    }
  }

  static Future<List<Review>> fetchReviews() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/reviews'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map<Review>((item) => Review.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load reviews: ${response.body}');
    }
  }

  static Future<Review> fetchReviewById(int reviewId) async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/reviews/$reviewId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return Review.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load review: ${response.body}');
    }
  }

  static Future<List<Review>> fetchHotelReviews(int hotelId) async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/hotels/$hotelId/reviews'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map<Review>((item) => Review.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load hotel reviews: ${response.body}');
    }
  }

  static Future<List<Review>> fetchRoomReviews(int roomId) async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/rooms/$roomId/reviews'),
      headers: headers,
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final data = body as List;
      return data.map<Review>((item) => Review.fromJson(item)).toList();
    }

    if (body is Map && body['message'] == 'Belum ada data review') {
      return [];
    }

    throw Exception('Failed to load room reviews: ${response.body}');
  }

  static Future<List<Review>> fetchUserReviews(int userId) async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/reviews'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map<Review>((item) => Review.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load user reviews: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> storeReview({
    // required int userId,
    required int roomId,
    required int bookingDetailId,
    required int rating,
    required String description,
    required String createdAt,
    File? image,
  }) async {
    final headers = await _authHeaders();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/reviews'),
    );

    request.headers.addAll(headers);

    // request.fields['user_id'] = userId.toString();
    request.fields['room_id'] = roomId.toString();
    request.fields['booking_detail_id'] = bookingDetailId.toString();
    request.fields['rating'] = rating.toString();
    request.fields['description'] = description;
    request.fields['created_at'] = createdAt;

    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
          filename: image.path.split('/').last,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to store review: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updateReview(
    int reviewId, {
    int? userId,
    int? roomId,
    int? bookingDetailId,
    int? rating,
    String? description,
    File? image,
  }) async {
    final headers = await _authHeaders();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/reviews/$reviewId'),
    );
    request.fields['_method'] = 'PUT';
    request.headers.addAll(headers);

    if (userId != null) request.fields['user_id'] = userId.toString();
    if (roomId != null) request.fields['room_id'] = roomId.toString();
    if (bookingDetailId != null) {
      request.fields['booking_detail_id'] = bookingDetailId.toString();
    }
    if (rating != null) request.fields['rating'] = rating.toString();
    if (description != null) request.fields['description'] = description;

    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
          filename: image.path.split('/').last,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update review: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> deleteReview(int reviewId) async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/reviews/$reviewId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete review: ${response.body}');
    }
  }

  static Future<List<Booking>> fetchBookings() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/bookings'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map<Booking>((item) => Booking.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load bookings: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> fetchBookingById(int bookingId) async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/bookings/$bookingId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load booking: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> storeBooking({
    required String checkIn,
    required String checkOut,
    String? status,
  }) async {
    final headers = await _authHeaders();
    final body = <String, dynamic>{
      'check_in': checkIn,
      'check_out': checkOut,
      'status': status ?? 'pending',
    };
    if (status != null) body['status'] = status;

    final response = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to store booking: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updateBooking(
    int bookingId,
    String status,
  ) async {
    final headers = await _authHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/bookings/$bookingId'),
      headers: headers,
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update booking: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> deleteBooking(int bookingId) async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/bookings/$bookingId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete booking: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> fetchBookingDetails() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/booking-details'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load booking details: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> fetchBookingDetailById(int id) async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/booking-details/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load booking detail: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> storeBookingDetail({
    required int bookingId,
    required int roomId,
    required int totalRoom,
    String? notes,
  }) async {
    final headers = await _authHeaders();
    final body = <String, dynamic>{
      'booking_id': bookingId,
      'room_id': roomId,
      'total_room': totalRoom,
    };
    if (notes != null) body['notes'] = notes;

    final response = await http.post(
      Uri.parse('$baseUrl/booking-details'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to store booking detail: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updateBookingDetail(
    int id, {
    int? bookingId,
    int? roomId,
    int? totalRoom,
    String? notes,
  }) async {
    final headers = await _authHeaders();
    final body = <String, dynamic>{};
    if (bookingId != null) body['booking_id'] = bookingId;
    if (roomId != null) body['room_id'] = roomId;
    if (totalRoom != null) body['total_room'] = totalRoom;
    if (notes != null) body['notes'] = notes;

    final response = await http.put(
      Uri.parse('$baseUrl/booking-details/$id'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update booking detail: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> deleteBookingDetail(int id) async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/booking-details/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete booking detail: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> fetchReviewDetails(int bookingId) async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/bookings/$bookingId/review-details'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load review details: ${response.body}');
    }
  }

  static Future<List<dynamic>> fetchBookingDetailAddOns() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/booking-detail-addons'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List;
    } else {
      throw Exception('Failed to load addons: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> fetchBookingDetailAddOnById(
    int id,
  ) async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/booking-detail-addons/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load addon: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> fetchAddOnsByBookingDetail(
    int bookingDetailId,
  ) async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/booking-details/$bookingDetailId/addons'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load addons: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> storeBookingDetailAddOn({
    required int bookingDetailId,
    required int addOnId,
    required int qty,
    required double subTotal,
  }) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/booking-detail-addons'),
      headers: headers,
      body: jsonEncode({
        'booking_detail_id': bookingDetailId,
        'add_on_id': addOnId,
        'qty': qty,
        'sub_total': subTotal,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to store addon: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updateBookingDetailAddOn(
    int id, {
    int? qty,
    double? subTotal,
  }) async {
    final headers = await _authHeaders();
    final body = <String, dynamic>{};
    if (qty != null) body['qty'] = qty;
    if (subTotal != null) body['sub_total'] = subTotal;

    final response = await http.put(
      Uri.parse('$baseUrl/booking-detail-addons/$id'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update addon: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> deleteBookingDetailAddOn(int id) async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/booking-detail-addons/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete addon: ${response.body}');
    }
  }
}
