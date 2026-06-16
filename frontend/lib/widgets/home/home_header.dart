import 'package:flutter/material.dart';
import 'package:frontend/pages/main_shell.dart';
import 'package:frontend/widgets/layout/header.dart';
import 'package:frontend/pages/home/location_picker_page.dart';
import 'package:frontend/providers/location_provider.dart';
import 'package:provider/provider.dart';

class HomeHeader extends StatelessWidget {
  final Widget body;

  const HomeHeader({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationProvider>();

    return GradientScrollHeader(
      expandedHeight: 180,
      bodyTopPadding: 120,
      navbarColor: const Color(0xFF3B82F6),
      leading: HeaderLocation(
        location: location.address,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LocationPickerPage()),
        ),
      ),
      actions: [
        HeaderAction(
          icon: Icons.favorite_border_rounded,
          onTap: () {
            context.findAncestorStateOfType<MainShellState>()?.showWishlist();
          },
        ),
      ],
      body: body,
    );
  }
}
