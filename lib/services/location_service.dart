import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_models.dart';
import '../api_keys.dart';
import 'geolocation_service.dart';

class LocationService {
  final GeolocationService _geolocationService;

  LocationService(this._geolocationService);
  static const String _kCustomCitiesKey = 'custom_weather_cities';

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
      displayName: 'Bad Dürkheim',
      assetPath: 'assets/data/climatologie_01072_Bad-Dürkheim_1961_1990.csv',
      lat: 49.4719,
      lon: 8.1929,
      startYear: 1961,
      endYear: 1990,
    ),
  };

  // Hard-coded weather locations
  // ROSBRUCK 49.159634, 6.850805
  static const Map<String, WeatherLocationInfo> _hardcodedWeatherLocations = {
    'rosbruck_fr': WeatherLocationInfo(
      displayName: 'Rosbruck',
      lat: 49.159634,
      lon: 6.850805,
      country: 'France',
    ),
    'lachambre_fr': WeatherLocationInfo(
      displayName: 'Lachambre',
      lat: 49.13,
      lon: 6.78,
      country: 'France',
    ),
    'bad_duerkheim_de': WeatherLocationInfo(
      displayName: 'Bad Dürkheim',
      lat: 49.4719,
      lon: 8.1929,
      country: 'Germany',
    ),
  };

  Future<Map<String, WeatherLocationInfo>> loadWeatherLocations() async {
    final prefs = await SharedPreferences.getInstance();

    // Start with hard-coded locations
    final weatherLocations = Map<String, WeatherLocationInfo>.from(_hardcodedWeatherLocations);

    // Load custom cities from shared_preferences
    final customCitiesJson = prefs.getStringList(_kCustomCitiesKey) ?? [];
    for (final cityJson in customCitiesJson) {
      try {
        final cityData = jsonDecode(cityJson);
        final key = cityData['key'] as String;
        weatherLocations[key] = WeatherLocationInfo(
          displayName: cityData['displayName'] as String,
          lat: cityData['lat'] as double,
          lon: cityData['lon'] as double,
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
    const double lon = 7.951;  // Bischwiller longitude

    return await _geolocationService.fetchSuggestions(query, lat: lat, lon: lon);
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
    // Hard-coded cities are not custom
    return !_hardcodedWeatherLocations.containsKey(cityKey);
  }
}
