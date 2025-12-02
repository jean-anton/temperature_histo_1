import 'dart:async';
import 'package:flutter/material.dart';
import 'package:temperature_histo_1/features/locations/domain/location_model.dart';
import 'package:temperature_histo_1/features/locations/data/location_repository.dart';

class CityManagementDialog extends StatefulWidget {
  final Map<String, WeatherLocationInfo> weatherLocations;
  final LocationRepository locationService;
  final String selectedWeatherLocation;
  final Function(String) onLocationChanged;
  final Function() onLocationsUpdated;

  const CityManagementDialog({
    super.key,
    required this.weatherLocations,
    required this.locationService,
    required this.selectedWeatherLocation,
    required this.onLocationChanged,
    required this.onLocationsUpdated,
  });

  @override
  State<CityManagementDialog> createState() => _CityManagementDialogState();
}

class _CityManagementDialogState extends State<CityManagementDialog> {
  late Map<String, WeatherLocationInfo> _currentLocations;
  final TextEditingController _searchController = TextEditingController();
  List<LocationSuggestion> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounceTimer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentLocations = Map.from(widget.weatherLocations);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Cancel previous timer
    _debounceTimer?.cancel();

    if (_searchController.text.isEmpty) {
      setState(() {
        _suggestions = [];
        _errorMessage = null;
      });
      return;
    }

    if (_searchController.text.length >= 2) {
      // Start new timer for debouncing
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        _searchCities();
      });
    }
  }

  Future<void> _searchCities() async {
    if (_searchController.text.isEmpty) {
      setState(() {
        _suggestions = [];
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final suggestions = await widget.locationService.fetchSuggestions(_searchController.text);
      setState(() {
        _suggestions = suggestions;
        _errorMessage = suggestions.isEmpty ? 'Aucune ville trouvée' : null;
      });
    } catch (e) {
      print('Error searching cities: $e');
      setState(() {
        _suggestions = [];
        _errorMessage = 'Erreur lors de la recherche: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addCity(LocationSuggestion suggestion) async {
    await widget.locationService.addCity(suggestion);

    // Reload locations
    final weatherLocations = await widget.locationService.loadWeatherLocations();
    setState(() {
      _currentLocations = weatherLocations;
      _searchController.clear();
      _suggestions = [];
    });
    widget.onLocationsUpdated();

    // If this is the first custom city, select it
    if (_currentLocations.length == 4) { // 3 hard-coded + 1 new
      final newKey = _currentLocations.keys.last;
      widget.onLocationChanged(newKey);
    }
  }

  Future<void> _deleteCity(String cityKey) async {
    await widget.locationService.deleteCity(cityKey);

    // Reload locations
    final weatherLocations = await widget.locationService.loadWeatherLocations();
    setState(() {
      _currentLocations = weatherLocations;
    });
    widget.onLocationsUpdated();

    // If the deleted city was selected, switch to the first available city
    if (widget.selectedWeatherLocation == cityKey && _currentLocations.isNotEmpty) {
      final firstKey = _currentLocations.keys.first;
      widget.onLocationChanged(firstKey);
    }
  }

  bool _isCustomCity(String cityKey) {
    return widget.locationService.isCustomCity(cityKey);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Gestion des villes'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add new city section
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Ajouter une ville',
                      hintText: 'Tapez le nom d\'une ville...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchCities,
                ),
              ],
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (_suggestions.isNotEmpty)
              SizedBox(
                height: 150,
                child: ListView.builder(
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    return ListTile(
                      title: Text(suggestion.name),
                      subtitle: Text(suggestion.formattedLocation),
                      onTap: () => _addCity(suggestion),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            // List of cities
            const Text(
              'Villes enregistrées:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _currentLocations.length,
                itemBuilder: (context, index) {
                  final cityKey = _currentLocations.keys.elementAt(index);
                  final cityInfo = _currentLocations[cityKey]!;
                  final isCustom = _isCustomCity(cityKey);

                  return ListTile(
                    title: Text(cityInfo.formattedLocation),
                    subtitle: Text(
                      'Lat: ${cityInfo.lat.toStringAsFixed(4)}, Lon: ${cityInfo.lon.toStringAsFixed(4)}',
                    ),
                    trailing: isCustom
                        ? IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteCity(cityKey),
                          )
                        : null, // No delete button for hard-coded cities
                    tileColor: widget.selectedWeatherLocation == cityKey
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : null,
                    onTap: () {
                      widget.onLocationChanged(cityKey);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}
