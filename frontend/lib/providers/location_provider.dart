import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:frontend/services/api_services.dart';

class LocationProvider extends ChangeNotifier {
  String _address = 'Choose Location';
  double? _lat;
  double? _lng;
  bool _isLoading = false;

  String get address => _address;
  double? get lat => _lat;
  double? get lng => _lng;
  bool get isLoading => _isLoading;
  bool get hasLocation => _lat != null;

  void setLocation(double lat, double lng, String address) {
    _lat = lat;
    _lng = lng;
    _address = address;
    notifyListeners();
  }

  void clearLocation() {
    _lat = null;
    _lng = null;
    _address = 'Choose Location';
    notifyListeners();
  }

  Future<bool> fetchCurrentLocation({
    Future<bool?> Function()? onGpsDisabled,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check whether GPS is enabled.
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Show dialog
        final shouldOpen = await onGpsDisabled?.call();
        if (shouldOpen == true) {
          await Geolocator.openLocationSettings();
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check location permission.
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Get the current position.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Reverse geocode via Nominatim.
      final addr = await ApiService.reverseGeocode(
        position.latitude,
        position.longitude,
      );

      setLocation(position.latitude, position.longitude, addr);
      return true;
    } catch (_) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
