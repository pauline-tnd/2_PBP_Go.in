import 'package:flutter/material.dart';

class AppResponsive {
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1400) return width * 0.14;
    if (width >= 1100) return width * 0.1;
    if (width >= 768) return width * 0.07;
    return 24;
  }

  static double contentMaxWidth(
    BuildContext context, {
    double mobile = 420,
    double tablet = 560,
    double desktop = 680,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }
}
