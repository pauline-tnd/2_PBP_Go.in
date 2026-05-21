import 'package:flutter/material.dart';

class SettingsItemTile extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isFirst;
  final bool isLast;

  const SettingsItemTile({
    super.key,
    this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = subtitle != null;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.vertical(
              top: isFirst
                  ? const Radius.circular(16)
                  : Radius.zero,
              bottom: isLast
                  ? const Radius.circular(16)
                  : Radius.zero,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 18,
                vertical: hasSubtitle ? 18 : 16,
              ),
              child: Row(
                crossAxisAlignment: hasSubtitle
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Container(
                      width: hasSubtitle ? 58 : 38,
                      height: hasSubtitle ? 58 : 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6)
                            .withAlpha(20),
                        borderRadius: BorderRadius.circular(
                          hasSubtitle ? 18 : 10,
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: hasSubtitle ? 30 : 20,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                  Expanded(
                    child: hasSubtitle
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitle!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          )
                        : Text(
                            label,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: EdgeInsets.only(
                      top: hasSubtitle ? 6 : 0,
                    ),
                    child:
                        trailing ??
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 22,
                          color: Color(0xFF94A3B8),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
            ),
            child: Container(
              height: 1,
              color: const Color(0xFFF1F5F9),
            ),
          ),
      ],
    );
  }
}