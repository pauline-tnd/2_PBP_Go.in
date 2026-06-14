class NominatimResult {
  final String displayName;
  final double lat;
  final double lon;

  NominatimResult({
    required this.displayName,
    required this.lat,
    required this.lon,
  });

  factory NominatimResult.fromJson(Map<String, dynamic> json) {
    return NominatimResult(
      displayName: json['display_name'] ?? '',
      lat: double.parse(json['lat']),
      lon: double.parse(json['lon']),
    );
  }
}
