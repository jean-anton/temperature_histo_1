import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geoapify Proximity Demo',
      home: Scaffold(
        appBar: AppBar(title: const Text('Geoapify Search')),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: LocationSearchField(),
        ),
      ),
    );
  }
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

Future<List<LocationSuggestion>> fetchSuggestions(String query) async {
  const String apiKey = '4195cd5c8bc54697a4a2bba4e9f2aa36'; // ← Replace with your Geoapify API key
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

class LocationSearchField extends StatefulWidget {
  const LocationSearchField({super.key});

  @override
  State<LocationSearchField> createState() => _LocationSearchFieldState();
}

class _LocationSearchFieldState extends State<LocationSearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<LocationSuggestion>(
      textFieldConfiguration: TextFieldConfiguration(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Search location',
          border: OutlineInputBorder(),
        ),
      ),
      suggestionsCallback: (pattern) =>
          pattern.isEmpty ? Future.value([]) : fetchSuggestions(pattern),
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion.name),
          subtitle: Text(
              'Lat: ${suggestion.lat.toStringAsFixed(4)}, Lon: ${suggestion.lon.toStringAsFixed(4)}'),
        );
      },
      onSuggestionSelected: (suggestion) {
        _controller.text = suggestion.name;
        // You can add your map update or navigation logic here
      },
    );
  }
}
