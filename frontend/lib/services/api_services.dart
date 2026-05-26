import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/models/room.dart';
import 'package:frontend/models/booking.dart';
import 'package:frontend/models/wishlist.dart';
import 'package:frontend/models/review.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.18.135:8000/api';

  // ── Token Helpers ─────────────────────────────────────────────

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── Authentication ────────────────────────────────────────────
  // POST /register
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
      throw Exception('Register gagal: ${response.body}');
    }
  }

  // POST /login
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
      throw Exception('Login gagal: ${response.body}');
    }
  }

  // POST /logout
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
      throw Exception('Logout gagal: ${response.body}');
    }
  }

  // ── User Profile ──────────────────────────────────────────────
  // GET /user
  static Future<Map<String, dynamic>> getUser() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user: ${response.body}');
    }
  }

  // PUT /user
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

  // PUT /user/password
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

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update password: ${response.body}');
    }
  }

  // PUT /user/profile (multipart - file upload)
  static Future<Map<String, dynamic>> updateProfileImage(File imageFile) async {
    final token = await _getToken();
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/user/profile'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
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

  // DELETE /user
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

  // ── Hotels ────────────────────────────────────────────────────
  // GET /hotels
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
    final queryParts = <String>[];

    if (search != null) queryParts.add('search=$search');
    if (minPrice != null) queryParts.add('min_price=$minPrice');
    if (maxPrice != null) queryParts.add('max_price=$maxPrice');
    if (sortBy != null) queryParts.add('sort_by=$sortBy');
    if (userLat != null) queryParts.add('user_lat=$userLat');
    if (userLng != null) queryParts.add('user_lng=$userLng');
    if (cursor != null) queryParts.add('cursor=$cursor');
    if (star != null) {
      for (var s in star) {
        queryParts.add('star[]=$s');
      }
    }
    if (amenities != null) {
      for (var a in amenities) {
        queryParts.add('amenities[]=$a');
      }
    }

    final queryString = queryParts.isNotEmpty ? '?${queryParts.join('&')}' : '';
    final response = await http.get(
      Uri.parse('$baseUrl/hotels$queryString'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load hotels: ${response.body}');
    }
  }

  // GET /hotels/{hotel}
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

  // ── Rooms ─────────────────────────────────────────────────────
  // GET /rooms
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

  // GET /rooms/{room}
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

  // ── Wishlists ─────────────────────────────────────────────────
  // GET /wishlists
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

  // POST /wishlists
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

  // DELETE /wishlists/{wishlist}
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

  // ── Reviews ───────────────────────────────────────────────────
  // GET /reviews
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

  // GET /reviews/{review}
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

  // GET /hotels/{hotel}/reviews
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

  // GET /rooms/{room}/reviews
  static Future<List<Review>> fetchRoomReviews(int roomId) async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/rooms/$roomId/reviews'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map<Review>((item) => Review.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load room reviews: ${response.body}');
    }
  }

  // GET /users/{user}/reviews
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

  // POST /reviews (multipart - supports image upload)
  static Future<Map<String, dynamic>> storeReview({
    required int userId,
    required int roomId,
    required int bookingDetailId,
    required int rating,
    required String description,
    required String createdAt,
    File? image,
  }) async {
    final token = await _getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/reviews'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.fields['user_id'] = userId.toString();
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

  // PUT /reviews/{review} (multipart - supports image upload)
  static Future<Map<String, dynamic>> updateReview(
    int reviewId, {
    int? userId,
    int? roomId,
    int? bookingDetailId,
    int? rating,
    String? description,
    File? image,
  }) async {
    final token = await _getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/reviews/$reviewId'),
    );
    // Laravel doesn't support PUT multipart natively, use _method override
    request.fields['_method'] = 'PUT';
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

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

  // DELETE /reviews/{review}
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

  // ── Bookings ──────────────────────────────────────────────────
  // GET /bookings
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

  // GET /bookings/{booking}
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

  // POST /bookings
  static Future<Map<String, dynamic>> storeBooking({
    required String checkIn,
    required String checkOut,
    required double totalPrice,
    String? status,
  }) async {
    final headers = await _authHeaders();
    final body = <String, dynamic>{
      'check_in': checkIn,
      'check_out': checkOut,
      'total_price': totalPrice,
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

  // PUT /bookings/{booking}
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

  // DELETE /bookings/{booking}
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

  // ── Booking Details ───────────────────────────────────────────
  // GET /booking-details
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

  // GET /booking-details/{id}
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

  // POST /booking-details
  static Future<Map<String, dynamic>> storeBookingDetail({
    required int bookingId,
    required int roomId,
    required int totalRoom,
    required double subTotal,
    String? notes,
  }) async {
    final headers = await _authHeaders();
    final body = <String, dynamic>{
      'booking_id': bookingId,
      'room_id': roomId,
      'total_room': totalRoom,
      'sub_total': subTotal,
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

  // PUT /booking-details/{id}
  static Future<Map<String, dynamic>> updateBookingDetail(
    int id, {
    int? bookingId,
    int? roomId,
    int? totalRoom,
    double? subTotal,
    String? notes,
  }) async {
    final headers = await _authHeaders();
    final body = <String, dynamic>{};
    if (bookingId != null) body['booking_id'] = bookingId;
    if (roomId != null) body['room_id'] = roomId;
    if (totalRoom != null) body['total_room'] = totalRoom;
    if (subTotal != null) body['sub_total'] = subTotal;
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

  // DELETE /booking-details/{id}
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

  // GET /bookings/{booking}/review-details
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

  // ── Booking Detail Add-Ons ────────────────────────────────────
  // GET /booking-detail-addons
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

  // GET /booking-detail-addons/{id}
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

  // GET /booking-details/{bookingDetail}/addons
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

  // POST /booking-detail-addons
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

  // PUT /booking-detail-addons/{id}
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

  // DELETE /booking-detail-addons/{id}
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
