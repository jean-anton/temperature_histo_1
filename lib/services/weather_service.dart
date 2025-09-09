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
      'temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_hours,snowfall_sum,precipitation_probability_max,weathercode,cloudcover_mean,windspeed_10m_max,windgusts_10m_max,wind_direction_10m_dominant';

  /// Fetches a weather forecast for a single model from the Open-Meteo API.
  Future<DailyWeather> getWeatherForecast({
    required double latitude,
    required double longitude,
    required String model,
    required String locationName,
  }) async {
    final url = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'daily': _dailyParameters,
        'timezone': 'auto',
        'forecast_days': '16',
        'models': model,
      },
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final forecast = DailyWeather.fromJson(
          jsonData,
        ).copyWith(locationName: locationName, model: model);
        return forecast;
      } else {
        throw Exception(
          'API Error for model $model: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } on TimeoutException {
      throw Exception('Request for model $model timed out.');
    } catch (e) {
      throw Exception('Failed to get weather for model $model: $e');
    }
  }

  // Add to weather_service.dart
  Future<HourlyWeather> getHourlyWeatherForecast({
    required double latitude,
    required double longitude,
    required String model,
    required String locationName,
  }) async {
    String hourlyParameters = '';
    if(model == 'ecmwf_ifs025') {
      hourlyParameters =
        'temperature_2m,weather_code,apparent_temperature,'
        'precipitation_probability,precipitation,rain,'
        'cloud_cover,wind_speed_10m,wind_gusts_10m,'
        'is_day,sunshine_duration,wind_direction_10m';
    }else{
      hourlyParameters =
        'temperature_2m,weather_code,apparent_temperature,'
        'precipitation_probability,precipitation,rain,'
        'cloud_cover,wind_speed_10m,windgusts_10m,'
        'is_day,sunshine_duration,wind_direction_10m';
    }
    

    print("### CJG 192: hourlyParameters: $hourlyParameters");
    print("### CJG 192: latitude: $latitude longitude: $longitude");
    print("### CJG 192: locationName: $locationName");
    print("### CJG 192: model: $model");


    final url = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'hourly': hourlyParameters,
        'timezone': 'auto',
        'forecast_days': '3', 
        'models': model, // Only fetch today's data
      },
    );
    print("### CJG getDailyWeatherForecast: URL: $url");
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return HourlyWeather.fromJson(
          jsonData,
        ).copyWith(locationName: locationName);
      } else {
        throw Exception(
          'API Error: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } on TimeoutException {
      throw Exception('Request timed out.');
    } catch (e) {
      throw Exception('Failed to get daily weather: $e');
    }
  }
}
