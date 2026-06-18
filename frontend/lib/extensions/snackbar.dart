import 'package:flutter/material.dart';

extension SnackbarExtension on BuildContext {
  void showAppSnackBar(
    String message, {
    bool isError = false,
    bool isWarning = false,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(this);
    if (messenger == null) return;
    final media = MediaQuery.of(this);
    final width = media.size.width;
    final horizontalMargin = width < 600 ? 20.0 : (width - 520) / 2;
    final bottomMargin = media.padding.bottom + (width < 600 ? 96.0 : 28.0);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(
            horizontalMargin,
            0,
            horizontalMargin,
            bottomMargin,
          ),
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
