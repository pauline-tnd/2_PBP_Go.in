import 'package:flutter/material.dart';
import '../widgets/activity/activity_header.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      body: ActivityHeader(body: Center(child: Text('Activity Page'))),
    );
  }
}
