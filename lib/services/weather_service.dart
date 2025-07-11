// lib/services/weather_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
// Add this import for the Random class
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/weather_forecast_model.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  static const String _dailyParameters =
      'temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_hours,snowfall_sum,precipitation_probability_max,weathercode,cloudcover_mean,windspeed_10m_max,windgusts_10m_max';

  /// Fetches a weather forecast for a single model from the Open-Meteo API.
  Future<WeatherForecast> getWeatherForecast({
    required double latitude,
    required double longitude,
    required String model,
    required String locationName,
  }) async {
    final url = Uri.parse(_baseUrl).replace(queryParameters: {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'daily': _dailyParameters,
      'timezone': 'auto',
      'forecast_days': '16',
      'models': model,
    });

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final forecast = WeatherForecast.fromJson(jsonData).copyWith(
          locationName: locationName,
          model: model,
        );
        return forecast;
      } else {
        throw Exception(
            'API Error for model $model: ${response.statusCode} ${response.reasonPhrase}');
      }
    } on TimeoutException {
      throw Exception('Request for model $model timed out.');
    } catch (e) {
      throw Exception('Failed to get weather for model $model: $e');
    }
  }

  /// **NEW STUB FUNCTION**
  ///
  /// Returns a mock WeatherForecast with 10 days of sample data without an HTTP call.
  /// Useful for UI development and testing without network dependency.
  Future<WeatherForecast> getWeatherForecast_stub({
    required double latitude,
    required double longitude,
    required String model,
    required String locationName,
  }) async {
    final random = Random();
    final dailyForecasts = <DailyForecast>[];
    final startDate = DateTime.now();

    // A list of common weather codes to randomly choose from.
    final weatherCodes = [0, 1, 2, 3, 45, 61, 80, 95];

    // Generate 10 days of sample forecast data.
    for (int i = 0; i < 10; i++) {
      final date = startDate.add(Duration(days: i));
      // Generate a plausible max temperature (e.g., between 15°C and 25°C).
      final maxTemp = 15.0 + random.nextDouble() * 10;
      // Ensure min temperature is realistically lower than max.
      final minTemp = maxTemp - (5.0 + random.nextDouble() * 5);

      dailyForecasts.add(DailyForecast(
        date: date,
        temperatureMax: double.parse(maxTemp.toStringAsFixed(1)),
        temperatureMin: double.parse(minTemp.toStringAsFixed(1)),
        precipitationSum: random.nextDouble() * 15, // 0-15mm
        precipitationHours: random.nextDouble() * 10, // 0-10 hours
        snowfallSum: 0.0, // Assuming no snow for this stub
        precipitationProbabilityMax: random.nextInt(101), // 0-100%
        weatherCode: weatherCodes[random.nextInt(weatherCodes.length)],
        cloudCoverMean: random.nextInt(101), // 0-100%
        windSpeedMax: random.nextDouble() * 40, // 0-40 km/h
        windGustsMax: random.nextDouble() * 60, // 0-60 km/h
      ));
    }

    // Create the final WeatherForecast object with the generated data.
    final forecast = WeatherForecast(
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      model: '$model (Stub)', // Suffix helps identify stub data in the UI
      timezone: 'Europe/Berlin',
      dailyForecasts: dailyForecasts,
    );

    // Simulate a short network delay to mimic a real API call.
    return Future.delayed(const Duration(milliseconds: 400), () => forecast);
  }

  /// Fetches forecasts from multiple models in PARALLEL for much faster execution.
  Future<Map<String, WeatherForecast>> getMultiModelForecast({
    required double latitude,
    required double longitude,
    required String locationName,
    required List<String> models,
    bool useStub = false, // Add a flag to easily switch to the stub
  }) async {
    // Decide which function to call based on the `useStub` flag.
    final fetchFunction = useStub ? getWeatherForecast_stub : getWeatherForecast;

    final futures = models.map((model) {
      return fetchFunction(
        latitude: latitude,
        longitude: longitude,
        model: model,
        locationName: locationName,
      ).catchError((e) {
        print('Failed to fetch forecast for model $model  $e  $WeatherService');
        return null;
      });
    }).toList();

    final results = await Future.wait(futures);

    final forecasts = <String, WeatherForecast>{};
    for (int i = 0; i < models.length; i++) {
      final forecast = results[i];
      if (forecast != null) {
        forecasts[models[i]] = forecast;
      }
    }

    return forecasts;
  }
}