class ClimateLocationInfo {
  final String displayName;
  final String assetPath;
  final double lat;
  final double lon;
  final int startYear;
  final int endYear;

  const ClimateLocationInfo({
    required this.displayName,
    required this.assetPath,
    required this.lat,
    required this.lon,
    required this.startYear,
    required this.endYear,
  });
}

class WeatherLocationInfo {
  final String displayName;
  final double lat;
  final double lon;
  final String? country;
  final String? state;
  final String? county;

  const WeatherLocationInfo({
    required this.displayName,
    required this.lat,
    required this.lon,
    this.country,
    this.state,
    this.county,
  });

  // Helper method to format location as "City, State, Country"
  String get formattedLocation {
    final parts = [displayName];
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }
}

class LocationSuggestion {
  final String name;
  final double lat;
  final double lon;
  final String? country;
  final String? state;
  final String? county;

  LocationSuggestion({
    required this.name,
    required this.lat,
    required this.lon,
    this.country,
    this.state,
    this.county,
  });

  // Helper method to format location as "City, State, Country"
  String get formattedLocation {
    final parts = [name];
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }
}
