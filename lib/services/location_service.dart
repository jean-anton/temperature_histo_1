import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_models.dart';
import '../api_keys.dart';

class LocationService {
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
  static const Map<String, WeatherLocationInfo> _hardcodedWeatherLocations = {
    'rosbruck_fr': WeatherLocationInfo(
      displayName: 'Rosbruck',
      lat: 49.15,
      lon: 6.85,
    ),
    'lachambre_fr': WeatherLocationInfo(
      displayName: 'Lachambre',
      lat: 49.13,
      lon: 6.78,
    ),
    'bad_duerkheim_de': WeatherLocationInfo(
      displayName: 'Bad Dürkheim',
      lat: 49.4719,
      lon: 8.1929,
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
        );
      } catch (e) {
        // Skip invalid entries
        continue;
      }
    }

    return weatherLocations;
  }

  Future<List<LocationSuggestion>> fetchSuggestions(String query) async {
    const String apiKey = geoapifyApiKey;
    const double lat = 48.821; // Bischwiller latitude
    const double lon = 7.951;  // Bischwiller longitude

    final url = Uri.parse(
      'https://api.geoapify.com/v1/geocode/autocomplete'
      '?text=$query'
      '&bias=proximity:$lon,$lat'
      '&limit=5'
      '&apiKey=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final features = data['features'] as List;
      return features.map((item) {
        final props = item['properties'];
        return LocationSuggestion(
          name: props['formatted'],
          lat: props['lat'],
          lon: props['lon'],
        );
      }).toList();
    } else {
      throw Exception('Failed to fetch suggestions: ${response.statusCode}');
    }
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
