import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../features/locations/domain/location_model.dart';

abstract class GeolocationService {
  Future<List<LocationSuggestion>> fetchSuggestions(
    String query, {
    double? lat,
    double? lon,
  });
  Future<LocationSuggestion?> reverseGeocode(double lat, double lon);
}

// class GeoapifyGeolocationService implements GeolocationService {
//   final String apiKey;

//   GeoapifyGeolocationService(this.apiKey);

//   @override
//   Future<List<LocationSuggestion>> fetchSuggestions(String query, {double? lat, double? lon}) async {
//     final bias = lat != null && lon != null ? '&bias=proximity:$lon,$lat' : '';
//     final url = Uri.parse(
//       'https://api.geoapify.com/v1/geocode/autocomplete'
//       '?text=$query'
//       '$bias'
//       '&limit=5'
//       '&apiKey=$apiKey',
//     );

//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       final features = data['features'] as List;
//       return features.map((item) {
//         final props = item['properties'];
//         return LocationSuggestion(
//           name: props['formatted'],
//           lat: props['lat'],
//           lon: props['lon'],
//           country: props['country'],
//           state: props['state'],
//           county: props['county'] ?? props['region'],
//         );
//       }).toList();
//     } else {
//       throw Exception('Failed to fetch suggestions: ${response.statusCode}');
//     }
//   }
// }

class PhotonGeolocationService implements GeolocationService {
  @override
  Future<List<LocationSuggestion>> fetchSuggestions(
    String query, {
    double? lat,
    double? lon,
  }) async {
    final bias = lat != null && lon != null ? '&lat=$lat&lon=$lon' : '';
    final url = Uri.parse(
      'https://photon.komoot.io/api/?q=$query&layer=city$bias&limit=5',
    );

    final response = await http.get(url);
    print(
      "####### CJG PhotonGeolocationService: URL: $url, Status: ${response.statusCode}",
    );
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

  @override
  Future<LocationSuggestion?> reverseGeocode(double lat, double lon) async {
    final url = Uri.parse('https://photon.komoot.io/reverse?lat=$lat&lon=$lon');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final features = data['features'] as List;
      if (features.isEmpty) return null;

      final props = features[0]['properties'];
      final geometry = features[0]['geometry'];
      return LocationSuggestion(
        name:
            props['name'] ??
            props['formatted'] ??
            '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}',
        lat: geometry['coordinates'][1],
        lon: geometry['coordinates'][0],
        country: props['country'],
        state: props['state'],
        county: props['county'],
      );
    }
    return null;
  }
}

class OpenMeteoGeolocationService implements GeolocationService {
  @override
  Future<List<LocationSuggestion>> fetchSuggestions(
    String query, {
    double? lat,
    double? lon,
  }) async {
    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=$query&count=10&language=en&format=json',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List? ?? [];
      return results.map((item) {
        return LocationSuggestion(
          name: item['name'] ?? 'Unknown',
          lat: item['latitude'] ?? 0.0,
          lon: item['longitude'] ?? 0.0,
          country: item['country'],
          state: item['admin1'],
          county: item['admin3'],
        );
      }).toList();
    } else {
      throw Exception('Failed to fetch suggestions: ${response.statusCode}');
    }
  }

  @override
  Future<LocationSuggestion?> reverseGeocode(double lat, double lon) async {
    // Open-Meteo doesn't seem to have a straightforward reverse geocoding API in their free geocoding service
    return null;
  }
}

enum GeolocationProvider {
  //geoapify,
  photon,
  openMeteo,
}

class GeolocationServiceFactory {
  static GeolocationService create(
    GeolocationProvider provider,
    String apiKey,
  ) {
    switch (provider) {
      // case GeolocationProvider.geoapify:
      //   return PhotonGeolocationService();
      // return GeoapifyGeolocationService(apiKey);
      case GeolocationProvider.photon:
        return PhotonGeolocationService();
      case GeolocationProvider.openMeteo:
        return OpenMeteoGeolocationService();
    }
  }
}

class FallbackGeolocationService implements GeolocationService {
  final List<GeolocationService> _services;

  FallbackGeolocationService(this._services);

  @override
  Future<List<LocationSuggestion>> fetchSuggestions(
    String query, {
    double? lat,
    double? lon,
  }) async {
    for (final service in _services) {
      try {
        final suggestions = await service.fetchSuggestions(
          query,
          lat: lat,
          lon: lon,
        );
        if (suggestions.isNotEmpty) {
          return suggestions;
        }
      } catch (e) {
        // Continue to next service if this one fails
        continue;
      }
    }
    // If all services fail, return empty list
    return [];
  }

  @override
  Future<LocationSuggestion?> reverseGeocode(double lat, double lon) async {
    for (final service in _services) {
      try {
        final suggestion = await service.reverseGeocode(lat, lon);
        if (suggestion != null) {
          return suggestion;
        }
      } catch (e) {
        continue;
      }
    }
    return null;
  }
}
