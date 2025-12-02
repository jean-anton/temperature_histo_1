import 'package:flutter/foundation.dart';
import 'package:temperature_histo_1/features/weather/domain/weather_model.dart';
import 'package:temperature_histo_1/features/weather/data/weather_repository.dart';
import 'package:temperature_histo_1/features/locations/domain/location_model.dart';

/// Provider for managing weather data state
class WeatherProvider with ChangeNotifier {
  final WeatherRepository _weatherRepository;

  WeatherProvider(this._weatherRepository);

  // State
  DailyWeather? _dailyForecast;
  HourlyWeather? _hourlyForecast;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedModel = 'best_match';

  // Getters
  DailyWeather? get dailyForecast => _dailyForecast;
  HourlyWeather? get hourlyForecast => _hourlyForecast;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedModel => _selectedModel;

  /// Set the selected model
  void setSelectedModel(String model) {
    if (_selectedModel != model) {
      _selectedModel = model;
      notifyListeners();
    }
  }

  /// Fetch daily weather forecast for a location
  Future<void> fetchDailyWeather(WeatherLocationInfo location) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dailyForecast = await _weatherRepository.getWeatherForecast(
        latitude: location.lat,
        longitude: location.lon,
        model: _selectedModel,
        locationName: location.displayName,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load daily weather: $e';
      _dailyForecast = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch hourly weather forecast for a location
  Future<void> fetchHourlyWeather(WeatherLocationInfo location) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _hourlyForecast = await _weatherRepository.getHourlyWeatherForecast(
        latitude: location.lat,
        longitude: location.lon,
        model: _selectedModel,
        locationName: location.displayName,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load hourly weather: $e';
      _hourlyForecast = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear current forecasts and error
  void clear() {
    _dailyForecast = null;
    _hourlyForecast = null;
    _errorMessage = null;
    notifyListeners();
  }
}
