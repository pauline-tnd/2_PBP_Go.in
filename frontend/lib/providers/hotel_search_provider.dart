import 'package:flutter/material.dart';
import 'package:frontend/models/hotel.dart';
import 'package:frontend/services/api_services.dart';

class HotelSearchProvider extends ChangeNotifier {
  List<Hotel> _hotels = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Hotel> get hotels => _hotels;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasResult => _hotels.isNotEmpty;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _hotels = [];
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ApiService.fetchHotels(search: query);
      final rawList = ApiService.extractPaginatedItems(result);

      _hotels = rawList
          .map((item) => Hotel.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _errorMessage = "Failed to search hotels";
      _hotels = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _hotels = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
