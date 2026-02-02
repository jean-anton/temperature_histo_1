import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aeroclim/features/locations/domain/location_model.dart';
import 'package:aeroclim/core/services/geolocation_service.dart';

class LocationRepository {
  final GeolocationService _geolocationService;

  LocationRepository(this._geolocationService);
  static const String _kCustomCitiesKey = 'custom_weather_cities';
  static const String _kHomeLocationKey = 'home_location_key';

  // Hard-coded climate locations
  final Map<String, ClimateLocationInfo> climateLocationData = {
    '00460_Berus_1961_1990': const ClimateLocationInfo(
      displayName: 'Berus (DE)',
      assetPath: 'assets/data/climatologie_00460_Berus_1961_1990.csv',
      lat: 49.2641,
      lon: 6.6868,
      startYear: 1961,
      endYear: 1990,
    ),
    '04336_Saarbrücken-Ensheim_1961_1990': const ClimateLocationInfo(
      displayName: 'Saarbrücken-Ensheim (DE)',
      assetPath:
          'assets/data/climatologie_04336_Saarbrücken-Ensheim_1961_1990.csv',
      lat: 49.2128,
      lon: 7.1077,
      startYear: 1961,
      endYear: 1990,
    ),
    '04339_Saarbrücken-Sankt-Johann_1961_1990': const ClimateLocationInfo(
      displayName: 'Saarbrücken-St. Johann (DE)',
      assetPath:
          'assets/data/climatologie_04339_Saarbrücken-Sankt-Johann_1961_1990.csv',
      lat: 49.2231,
      lon: 7.0168,
      startYear: 1961,
      endYear: 1990,
    ),
    '05244_Völklingen-Stadt_1961_1982': const ClimateLocationInfo(
      displayName: 'Völklingen-Stadt (DE)',
      assetPath:
          'assets/data/climatologie_05244_Völklingen-Stadt_1961_1982.csv',
      lat: 49.25,
      lon: 6.85,
      startYear: 1961,
      endYear: 1982,
    ),
    '06217_Saarbrücken-Burbach_2001_2010': const ClimateLocationInfo(
      displayName: 'Saarbrücken-Burbach (DE)',
      assetPath:
          'assets/data/climatologie_06217_Saarbrücken-Burbach_2001_2010.csv',
      lat: 49.2406,
      lon: 6.9351,
      startYear: 2001,
      endYear: 2010,
    ),
    '01072_Bad-Dürkheim_1961_1990': const ClimateLocationInfo(
      displayName: 'Bad Dürkheim (DE)',
      assetPath: 'assets/data/climatologie_01072_Bad-Dürkheim_1961_1990.csv',
      lat: 49.4719,
      lon: 8.1929,
      startYear: 1961,
      endYear: 1990,
    ),
  };

  Future<Map<String, WeatherLocationInfo>> loadWeatherLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final weatherLocations = <String, WeatherLocationInfo>{};

    // Load custom cities from shared_preferences
    final customCitiesJson = prefs.getStringList(_kCustomCitiesKey) ?? [];
    for (final cityJson in customCitiesJson) {
      try {
        final cityData = jsonDecode(cityJson);
        final key = cityData['key'] as String;
        weatherLocations[key] = WeatherLocationInfo(
          displayName: cityData['displayName'] as String,
          lat: (cityData['lat'] as num).toDouble(),
          lon: (cityData['lon'] as num).toDouble(),
          country: cityData['country'] as String?,
          state: cityData['state'] as String?,
          county: cityData['county'] as String?,
        );
      } catch (e) {
        // Skip invalid entries
        continue;
      }
    }

    return weatherLocations;
  }

  Future<List<LocationSuggestion>> fetchSuggestions(String query) async {
    const double lat = 48.821; // Bischwiller latitude
    const double lon = 7.951; // Bischwiller longitude

    return await _geolocationService.fetchSuggestions(
      query,
      lat: lat,
      lon: lon,
    );
  }

  Future<LocationSuggestion?> reverseGeocode(double lat, double lon) async {
    return await _geolocationService.reverseGeocode(lat, lon);
  }

  Future<void> addCity(LocationSuggestion suggestion) async {
    final prefs = await SharedPreferences.getInstance();
    final customCitiesJson = prefs.getStringList(_kCustomCitiesKey) ?? [];

    // Generate a unique key for the city
    final key = 'custom_${DateTime.now().millisecondsSinceEpoch}';

    final cityData = {
      'key': key,
      'displayName': suggestion.name,
      'lat': suggestion.lat,
      'lon': suggestion.lon,
      'country': suggestion.country,
      'state': suggestion.state,
      'county': suggestion.county,
    };

    customCitiesJson.add(jsonEncode(cityData));
    await prefs.setStringList(_kCustomCitiesKey, customCitiesJson);
  }

  Future<void> addManualCity({
    required String name,
    required double lat,
    required double lon,
    String? country,
    String? state,
    String? county,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final customCitiesJson = prefs.getStringList(_kCustomCitiesKey) ?? [];

    final key = 'custom_${DateTime.now().millisecondsSinceEpoch}';

    final cityData = {
      'key': key,
      'displayName': name,
      'lat': lat,
      'lon': lon,
      'country': country,
      'state': state,
      'county': county,
    };

    customCitiesJson.add(jsonEncode(cityData));
    await prefs.setStringList(_kCustomCitiesKey, customCitiesJson);
  }

  Future<void> deleteCity(String cityKey) async {
    final prefs = await SharedPreferences.getInstance();
    final customCitiesJson = prefs.getStringList(_kCustomCitiesKey) ?? [];

    customCitiesJson.removeWhere((cityJson) {
      try {
        final cityData = jsonDecode(cityJson);
        return cityData['key'] == cityKey;
      } catch (e) {
        return false;
      }
    });

    await prefs.setStringList(_kCustomCitiesKey, customCitiesJson);
  }

  bool isCustomCity(String cityKey) {
    // All weather locations are now custom/user-added
    return true;
  }

  Future<String> exportCustomCities() async {
    final prefs = await SharedPreferences.getInstance();
    final customCitiesJson = prefs.getStringList(_kCustomCitiesKey) ?? [];

    // Return as a pretty-printed JSON array
    final List<dynamic> cities = customCitiesJson
        .map((s) => jsonDecode(s))
        .toList();
    return const JsonEncoder.withIndent('  ').convert(cities);
  }

  Future<int> importCustomCities(String jsonContent) async {
    final prefs = await SharedPreferences.getInstance();
    final currentCustomCitiesJson =
        prefs.getStringList(_kCustomCitiesKey) ?? [];

    final List<dynamic> importedCities = jsonDecode(jsonContent);
    int addedCount = 0;

    for (var cityData in importedCities) {
      if (cityData is! Map<String, dynamic>) continue;

      // Check if this city already exists (by lat/lon)
      bool exists = false;
      for (var existingJson in currentCustomCitiesJson) {
        try {
          final existingData = jsonDecode(existingJson);
          if ((existingData['lat'] as double).toStringAsFixed(4) ==
                  (cityData['lat'] as double).toStringAsFixed(4) &&
              (existingData['lon'] as double).toStringAsFixed(4) ==
                  (cityData['lon'] as double).toStringAsFixed(4)) {
            exists = true;
            break;
          }
        } catch (_) {}
      }

      if (!exists) {
        // Ensure it has a new unique key to avoid conflicts
        cityData['key'] =
            'custom_${DateTime.now().millisecondsSinceEpoch}_$addedCount';
        currentCustomCitiesJson.add(jsonEncode(cityData));
        addedCount++;
      }
    }

    if (addedCount > 0) {
      await prefs.setStringList(_kCustomCitiesKey, currentCustomCitiesJson);
    }

    return addedCount;
  }

  /// Get the home location key from shared preferences
  Future<String?> getHomeLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kHomeLocationKey);
  }

  /// Set the home location key in shared preferences
  Future<void> setHomeLocation(String? cityKey) async {
    final prefs = await SharedPreferences.getInstance();
    if (cityKey == null) {
      await prefs.remove(_kHomeLocationKey);
    } else {
      await prefs.setString(_kHomeLocationKey, cityKey);
    }
  }
}
