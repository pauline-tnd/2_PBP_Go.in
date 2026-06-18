class HotelGridConfig {
  final int crossAxisCount;
  final double childAspectRatio;

  const HotelGridConfig({
    required this.crossAxisCount,
    required this.childAspectRatio,
  });
}

HotelGridConfig getHotelGridConfig(double width) {
  int crossAxisCount = 1;
  double childAspectRatio = 0.85;

  if (width >= 1200) {
    crossAxisCount = 4;
  } else if (width >= 900) {
    crossAxisCount = 3;
  } else if (width >= 600) {
    crossAxisCount = 2;
  }

  if (width >= 1200) {
    childAspectRatio = 0.72;
  } else if (width >= 1100) {
    childAspectRatio = 0.75;
  } else if (width >= 900) {
    childAspectRatio = 0.70;
  } else if (width >= 750) {
    childAspectRatio = 0.82;
  } else if (width >= 700) {
    childAspectRatio = 0.81;
  } else if (width >= 650) {
    childAspectRatio = 0.77;
  } else if (width >= 620) {
    childAspectRatio = 0.75;
  } else if (width >= 600) {
    childAspectRatio = 0.70;
  }

  return HotelGridConfig(
    crossAxisCount: crossAxisCount,
    childAspectRatio: childAspectRatio,
  );
}
