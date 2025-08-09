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

  // Add to weather_service.dart
Future<DailyWeather> getDailyWeatherForecast({
  required double latitude,
  required double longitude,
  required String locationName,
}) async {
  const hourlyParameters = 
      'temperature_2m,weather_code,apparent_temperature,'
      'precipitation_probability,precipitation,rain,'
      'cloud_cover,wind_speed_10m,windgusts_10m';

  final url = Uri.parse(_baseUrl).replace(queryParameters: {
    'latitude': latitude.toString(),
    'longitude': longitude.toString(),
    'hourly': hourlyParameters,
    'timezone': 'auto',
    'forecast_days': '3', // Only fetch today's data
  });

  try {
    final response = await http.get(url).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return DailyWeather.fromJson(jsonData).copyWith(
        locationName: locationName,
      );
    } else {
      throw Exception(
          'API Error: ${response.statusCode} ${response.reasonPhrase}');
    }
  } on TimeoutException {
    throw Exception('Request timed out.');
  } catch (e) {
    throw Exception('Failed to get daily weather: $e');
  }
}

 }