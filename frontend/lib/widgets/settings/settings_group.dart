import 'package:flutter/material.dart';
import 'settings_item_tile.dart';

class SettingsGroupItem {
  final IconData? icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  SettingsGroupItem({
    this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
    this.trailing,
  });
}

class SettingsGroup extends StatelessWidget {
  final List<SettingsGroupItem> items;
  const SettingsGroup({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(
          items.length,
          (index) {
            final item = items[index];
            return SettingsItemTile(
              icon: item.icon,
              label: item.label,
              subtitle: item.subtitle,
              onTap: item.onTap,
              trailing: item.trailing,
              isFirst: index == 0,
              isLast: index == items.length - 1,
            );
          },
        ),
      ),
    );
  }
}