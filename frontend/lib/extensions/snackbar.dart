import 'package:flutter/material.dart';

extension SnackbarExtension on BuildContext {
  void showAppSnackBar(
    String message, {
    bool isError = false,
    bool isWarning = false,
  }) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: TextStyle(fontWeight: FontWeight.bold)),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 650),
          backgroundColor: isError
              ? const Color(0xFFEF4444)
              : isWarning
              ? const Color.fromARGB(255, 255, 193, 8)
              : const Color(0xFF10B981),
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      );
  }
}
