import 'package:flutter/foundation.dart';
import 'package:temperature_histo_1/features/weather/domain/weather_model.dart';
import 'package:temperature_histo_1/features/weather/data/weather_repository.dart';
import 'package:temperature_histo_1/features/locations/domain/location_model.dart';
import 'package:temperature_histo_1/features/weather/domain/weathercode_calculator.dart';

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

  /// Fetch weather forecast with daytime weathercode calculation
  /// This method fetches both daily and hourly forecasts, then calculates
  /// the daytime-representative weathercode for each day
  Future<void> fetchWeatherWithDaytimeCalculation(
    WeatherLocationInfo location,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch both daily and hourly forecasts in parallel
      final results = await Future.wait([
        _weatherRepository.getWeatherForecast(
          latitude: location.lat,
          longitude: location.lon,
          model: _selectedModel,
          locationName: location.displayName,
        ),
        _weatherRepository.getHourlyWeatherForecast(
          latitude: location.lat,
          longitude: location.lon,
          model: _selectedModel,
          locationName: location.displayName,
        ),
      ]);

      final dailyWeather = results[0] as DailyWeather;
      final hourlyWeather = results[1] as HourlyWeather;

      // Calculate daytime weathercodes for each daily forecast
      final enhancedForecasts = dailyWeather.dailyForecasts.map((daily) {
        // Calculate daytime weathercode using hourly data
        final result = WeathercodeCalculator.calculateDaytimeWeathercode(
          hourlyForecasts: hourlyWeather.hourlyForecasts,
          targetDate: daily.date,
        );

        // Create new DailyForecast with calculated weathercode
        return DailyForecast(
          date: daily.date,
          temperatureMax: daily.temperatureMax,
          temperatureMin: daily.temperatureMin,
          precipitationSum: daily.precipitationSum,
          precipitationHours: daily.precipitationHours,
          snowfallSum: daily.snowfallSum,
          precipitationProbabilityMax: daily.precipitationProbabilityMax,
          weatherCode: daily.weatherCode,
          weatherCodeDaytime: result.calculatedCode,
          daytimeHoursAnalyzed: result.hoursAnalyzed,
          cloudCoverMean: daily.cloudCoverMean,
          windSpeedMax: daily.windSpeedMax,
          windGustsMax: daily.windGustsMax,
          windDirection10mDominant: daily.windDirection10mDominant,
          sunrise: daily.sunrise,
          sunset: daily.sunset,
          weatherIcon: daily.weatherIcon,
        );
      }).toList();

      // Update state with enhanced forecasts
      _dailyForecast = DailyWeather(
        locationName: dailyWeather.locationName,
        model: dailyWeather.model,
        dailyForecasts: enhancedForecasts,
        latitude: dailyWeather.latitude,
        longitude: dailyWeather.longitude,
        timezone: dailyWeather.timezone,
      );

      _hourlyForecast = hourlyWeather;
      _errorMessage = null;

      print('### Daytime weathercode calculation completed:');
      for (final forecast in enhancedForecasts) {
        print(
          '  ${forecast.formattedDate}: Original=${forecast.weatherCode}, Daytime=${forecast.weatherCodeDaytime} (${forecast.daytimeHoursAnalyzed}h)',
        );
      }
    } catch (e) {
      _errorMessage = 'Failed to load weather with daytime calculation: $e';
      _dailyForecast = null;
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
