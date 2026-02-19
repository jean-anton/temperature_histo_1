import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math';
import 'package:aeroclim/core/config/app_config.dart';
//import 'package:aptabase_flutter/aptabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:aeroclim/core/constants/app_constants.dart';
import 'package:aeroclim/features/weather/domain/weather_model.dart';

class WeatherRepository {
  /// Fetches a weather forecast for a single model from the Open-Meteo API.
  Future<DailyWeather> getWeatherForecast({
    required double latitude,
    required double longitude,
    required String model,
    required String locationName,
  }) async {
    final url = Uri.parse(AppConstants.weatherApiBaseUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'daily': AppConstants.defaultDailyParameters,
        'timezone': 'auto',
        'forecast_days': '16',
        'models': model,
      },
    );

    // Aptabase.instance.trackEvent("getWeatherForecast ${model}").catchError((e) {
    //   debugPrint(
    //     "Aptabase trackEvent failed (likely blocked by extension): $e",
    //   );
    // });
    print("###### CJG 193: getWeatherForecast called ${model}");

    try {
      final response = await _getWithRetry(url);
      print("### CJG 192: getWeatherForecast URL: $url");
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
    final hourlyParameters = AppConstants.getHourlyParameters(model);

    print("### CJG 192: hourlyParameters: $hourlyParameters");
    print("### CJG 192: latitude: $latitude longitude: $longitude");
    print("### CJG 192: locationName: $locationName");
    print("### CJG 192: model: $model");

    final url = Uri.parse(AppConstants.weatherApiBaseUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'hourly': hourlyParameters,
        'timezone': 'auto',
        'forecast_days': '16',
        'models': model,
      },
    );
    print("### CJG getHourlyWeatherForecast: URL: $url");
    try {
      final response = await _getWithRetry(url);

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
      throw Exception('Failed to get hourly weather: $e');
    }
  }

  /// Helper to perform GET requests with retry logic for 429 errors.
  Future<http.Response> _getWithRetry(Uri url, {int maxRetries = 3}) async {
    int retryCount = 0;
    while (retryCount < maxRetries) {
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 429) {
        retryCount++;
        final delay = pow(2, retryCount) * 1000 + Random().nextInt(1000);
        print(
          '### CJG: Received 429. Retrying in ${delay / 1000}s (attempt $retryCount/$maxRetries)',
        );
        await Future.delayed(Duration(milliseconds: delay.toInt()));
      } else {
        return response;
      }
    }
    // Final attempt if all retries failed with 429
    return await http.get(url).timeout(const Duration(seconds: 15));
  }
}
