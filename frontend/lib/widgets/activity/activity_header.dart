import 'package:flutter/material.dart';
import '../header.dart';

class ActivityHeader extends StatelessWidget {
  final Widget body;

  const ActivityHeader({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return GradientScrollHeader(
      expandedHeight: 180, // Adjust as needed to match previous bottom padding
      navbarColor: const Color(0xFF3B82F6),
      leading: Center(
        child: Text(
          'Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      bodyTopPadding: 110,
      body: body,
    );
  }
}
