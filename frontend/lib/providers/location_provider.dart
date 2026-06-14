import 'package:flutter/foundation.dart';

class LocationProvider extends ChangeNotifier {
  double? _lat;
  double? _lng;
  String _address = '';

  double? get lat => _lat;
  double? get lng => _lng;
  String get address => _address;
  bool get hasLocation => _lat != null && _lng != null && _address.isNotEmpty;

  void setLocation(double lat, double lng, String address) {
    _lat = lat;
    _lng = lng;
    _address = address;
    notifyListeners();
  }

  Future<bool> fetchCurrentLocation() async {
    return false;
  }
}
