import 'package:flutter/material.dart';

class BookingDateProvider extends ChangeNotifier {
  DateTime? _checkIn;
  DateTime? _checkOut;

  DateTime? get checkIn => _checkIn;
  DateTime? get checkOut => _checkOut;
  bool get hasDates => _checkIn != null && _checkOut != null;

  void setDates(DateTime? checkIn, DateTime? checkOut) {
    _checkIn = checkIn;
    _checkOut = checkOut;
    notifyListeners();
  }
}
