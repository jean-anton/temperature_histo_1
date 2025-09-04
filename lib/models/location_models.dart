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

  const WeatherLocationInfo({
    required this.displayName,
    required this.lat,
    required this.lon,
  });
}

class LocationSuggestion {
  final String name;
  final double lat;
  final double lon;

  LocationSuggestion({
    required this.name,
    required this.lat,
    required this.lon,
  });
}
