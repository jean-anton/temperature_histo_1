import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_models.dart';

abstract class GeolocationService {
  Future<List<LocationSuggestion>> fetchSuggestions(String query, {double? lat, double? lon});
}

class GeoapifyGeolocationService implements GeolocationService {
  final String apiKey;

  GeoapifyGeolocationService(this.apiKey);

  @override
  Future<List<LocationSuggestion>> fetchSuggestions(String query, {double? lat, double? lon}) async {
    final bias = lat != null && lon != null ? '&bias=proximity:$lon,$lat' : '';
    final url = Uri.parse(
      'https://api.geoapify.com/v1/geocode/autocomplete'
      '?text=$query'
      '$bias'
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
          country: props['country'],
          state: props['state'],
          county: props['county'] ?? props['region'],
        );
      }).toList();
    } else {
      throw Exception('Failed to fetch suggestions: ${response.statusCode}');
    }
  }
}

class PhotonGeolocationService implements GeolocationService {
  @override
  Future<List<LocationSuggestion>> fetchSuggestions(String query, {double? lat, double? lon}) async {
    final bias = lat != null && lon != null ? '&lat=$lat&lon=$lon' : '';
    final url = Uri.parse(
      'https://photon.komoot.io/api/?q=$query&layer=city$bias&limit=5',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final features = data['features'] as List;
      return features.map((item) {
        final props = item['properties'];
        final geometry = item['geometry'];
        return LocationSuggestion(
          name: props['name'] ?? props['formatted'] ?? 'Unknown',
          lat: geometry['coordinates'][1],
          lon: geometry['coordinates'][0],
          country: props['country'],
          state: props['state'],
          county: props['county'],
        );
      }).toList();
    } else {
      throw Exception('Failed to fetch suggestions: ${response.statusCode}');
    }
  }
}

enum GeolocationProvider {
  geoapify,
  photon,
}

class GeolocationServiceFactory {
  static GeolocationService create(GeolocationProvider provider, String apiKey) {
    switch (provider) {
      case GeolocationProvider.geoapify:
        return GeoapifyGeolocationService(apiKey);
      case GeolocationProvider.photon:
        return PhotonGeolocationService();
    }
  }
}
