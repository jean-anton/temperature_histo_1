// lib/services/weather_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
// Add this import for the Random class
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:temperature_histo_1/features/weather/domain/weather_model.dart';
import 'package:temperature_histo_1/features/weather/domain/meteo_france_model.dart';

class WeatherRepository {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  static const String _dailyParameters =
      'temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_hours,snowfall_sum,precipitation_probability_max,weathercode,cloudcover_mean,windspeed_10m_max,windgusts_10m_max,wind_direction_10m_dominant,sunrise,sunset';

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
    String hourlyParameters = '';
    if (model == 'ecmwf_ifs025') {
      hourlyParameters =
          'temperature_2m,weather_code,apparent_temperature,'
          'precipitation_probability,precipitation,rain,'
          'cloud_cover,wind_speed_10m,wind_gusts_10m,'
          'is_day,sunshine_duration,wind_direction_10m';
    } else if (model == 'meteofrance_arome_seamless' ||
        model == 'meteofrance_seamless') {
      hourlyParameters =
          'temperature_2m,weather_code,apparent_temperature,'
          'precipitation_probability,precipitation,rain,'
          'cloud_cover,wind_speed_10m,windgusts_10m,'
          'is_day,sunshine_duration,wind_direction_10m,'
          'windspeed_20m,windspeed_50m,windspeed_80m,windspeed_100m,windspeed_120m,windspeed_150m,windspeed_180m,windspeed_200m';
    } else if (model == 'icon_seamless') {
      hourlyParameters =
          'temperature_2m,weather_code,apparent_temperature,'
          'precipitation_probability,precipitation,rain,'
          'cloud_cover,wind_speed_10m,windgusts_10m,'
          'is_day,sunshine_duration,wind_direction_10m,'
          'windspeed_80m,windspeed_120m,windspeed_180m';
    } else {
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
        'forecast_days': '7',
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

  /// Fetches weather forecast from MeteoFrance.
  Future<MeteoFranceForecast> getMeteoFranceForecast({
    required double latitude,
    required double longitude,
  }) async {
    const String token = '__Wj7dVSTjV9YGu1guveLyDq0g7S7TfTjaHBTPTpO0kj8__';
    final url = Uri.parse('https://webservice.meteofrance.com/forecast')
        .replace(
          queryParameters: {
            'token': token,
            'lat': latitude.toString(),
            'lon': longitude.toString(),
            'lang': 'fr',
          },
        );

    print("### CJG getMeteoFranceForecast URL: $url");

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        //print("### CJG getMeteoFranceForecast response: ${jsonData}");
        try {
          final forecast = MeteoFranceForecast.fromJson(jsonData);

          return forecast;
        } catch (e) {
          throw Exception('Failed to parse MeteoFrance weather: $e');
        }
      } else {
        throw Exception(
          'API Error MeteoFrance: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } on TimeoutException {
      throw Exception('Request to MeteoFrance timed out.');
    } catch (e) {
      throw Exception('Failed to get MeteoFrance weather: $e');
    }
  }
}
