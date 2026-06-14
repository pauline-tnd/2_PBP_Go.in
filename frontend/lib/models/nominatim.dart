class NominatimResult {
  final String displayName;
  final double lat;
  final double lon;

  const NominatimResult({
    required this.displayName,
    required this.lat,
    required this.lon,
  });

  factory NominatimResult.fromJson(Map<String, dynamic> json) {
    return NominatimResult(
      displayName: json['display_name']?.toString() ?? 'Selected location',
      lat: double.tryParse(json['lat']?.toString() ?? '') ?? 0,
      lon: double.tryParse(json['lon']?.toString() ?? '') ?? 0,
    );
  }
}
