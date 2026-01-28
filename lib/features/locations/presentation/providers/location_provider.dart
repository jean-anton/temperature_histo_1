import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperature_histo_1/features/locations/domain/location_model.dart';
import 'package:temperature_histo_1/features/locations/data/location_repository.dart';

/// Provider for managing location state
class LocationProvider with ChangeNotifier {
  final LocationRepository _locationRepository;

  static const String _kSelectedClimateLocationKey = 'selectedClimateLocation';
  static const String _kSelectedWeatherLocationKey = 'selectedWeatherLocation';

  LocationProvider(this._locationRepository);

  // State
  Map<String, ClimateLocationInfo> _climateLocations = {};
  Map<String, WeatherLocationInfo> _weatherLocations = {};
  String _selectedClimateLocationKey = '04336_Saarbrücken-Ensheim_1961_1990';
  String _selectedWeatherLocationKey = '';
  bool _isLoading = false;

  // Getters
  Map<String, ClimateLocationInfo> get climateLocations => _climateLocations;
  Map<String, WeatherLocationInfo> get weatherLocations => _weatherLocations;
  String get selectedClimateLocationKey => _selectedClimateLocationKey;
  String get selectedWeatherLocationKey => _selectedWeatherLocationKey;
  bool get isLoading => _isLoading;

  ClimateLocationInfo? get selectedClimateLocation =>
      _climateLocations[_selectedClimateLocationKey];
  WeatherLocationInfo? get selectedWeatherLocation =>
      _weatherLocations[_selectedWeatherLocationKey];

  /// Initialize locations from repository and SharedPreferences
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load climate locations from repository
      _climateLocations = _locationRepository.climateLocationData;

      // Load weather locations (includes hardcoded + custom)
      _weatherLocations = await _locationRepository.loadWeatherLocations();

      // Load saved selections
      await _loadSelections();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load saved location selections from SharedPreferences
  Future<void> _loadSelections() async {
    final prefs = await SharedPreferences.getInstance();
    final savedClimateLocation = prefs.getString(_kSelectedClimateLocationKey);
    final savedWeatherLocation = prefs.getString(_kSelectedWeatherLocationKey);

    if (savedClimateLocation != null &&
        _climateLocations.containsKey(savedClimateLocation)) {
      _selectedClimateLocationKey = savedClimateLocation;
    }

    if (savedWeatherLocation != null &&
        _weatherLocations.containsKey(savedWeatherLocation)) {
      _selectedWeatherLocationKey = savedWeatherLocation;
    }
  }

  /// Set selected climate location
  Future<void> setClimateLocation(String key) async {
    if (_climateLocations.containsKey(key) &&
        _selectedClimateLocationKey != key) {
      _selectedClimateLocationKey = key;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kSelectedClimateLocationKey, key);
      notifyListeners();
    }
  }

  /// Set selected weather location
  Future<void> setWeatherLocation(String key) async {
    if (_weatherLocations.containsKey(key) &&
        _selectedWeatherLocationKey != key) {
      _selectedWeatherLocationKey = key;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kSelectedWeatherLocationKey, key);
      notifyListeners();
    }
  }

  /// Add a custom city
  Future<void> addCity(LocationSuggestion suggestion) async {
    await _locationRepository.addCity(suggestion);
    // Reload locations
    _weatherLocations = await _locationRepository.loadWeatherLocations();
    notifyListeners();
  }

  /// Delete a custom city
  Future<void> deleteCity(String key) async {
    await _locationRepository.deleteCity(key);
    // Reload locations
    _weatherLocations = await _locationRepository.loadWeatherLocations();

    // If deleted location was selected, switch to first available or reset
    if (_selectedWeatherLocationKey == key) {
      _selectedWeatherLocationKey = _weatherLocations.isNotEmpty
          ? _weatherLocations.keys.first
          : '';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kSelectedWeatherLocationKey,
        _selectedWeatherLocationKey,
      );
    }

    notifyListeners();
  }

  /// Refresh weather locations
  Future<void> refreshWeatherLocations() async {
    _weatherLocations = await _locationRepository.loadWeatherLocations();
    notifyListeners();
  }
}
