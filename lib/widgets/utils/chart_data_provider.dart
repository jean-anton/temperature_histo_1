import 'package:fl_chart/fl_chart.dart';
import 'package:temperature_histo_1/models/climate_normal_model.dart';

import '../../models/weather_forecast_model.dart';
//import 'weather_deviation.dart';

/// Provides chart data for different chart types
class ChartDataProvider {
  /// Get maximum temperature spots for daily chart
  static List<FlSpot> getMaxTempSpots(WeatherForecast forecast) {
    return forecast.dailyForecasts.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.temperatureMax);
    }).toList();
  }

  /// Get minimum temperature spots for daily chart
  static List<FlSpot> getMinTempSpots(WeatherForecast forecast) {
    return forecast.dailyForecasts.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.temperatureMin);
    }).toList();
  }

  /// Get normal maximum temperature spots for daily chart
  static List<FlSpot> getNormalMaxSpots(
    WeatherForecast forecast,
    List<WeatherDeviation?> deviations,
  ) {
    return forecast.dailyForecasts
        .asMap()
        .entries
        .map((entry) {
          final normal = entry.key < deviations.length
              ? deviations[entry.key]?.normal
              : null;
          return FlSpot(entry.key.toDouble(), normal?.temperatureMax ?? 0);
        })
        .where((spot) => spot.y != 0)
        .toList();
  }

  /// Get normal minimum temperature spots for daily chart
  static List<FlSpot> getNormalMinSpots(
    WeatherForecast forecast,
    List<WeatherDeviation?> deviations,
  ) {
    return forecast.dailyForecasts
        .asMap()
        .entries
        .map((entry) {
          final normal = entry.key < deviations.length
              ? deviations[entry.key]?.normal
              : null;
          return FlSpot(entry.key.toDouble(), normal?.temperatureMin ?? 0);
        })
        .where((spot) => spot.y != 0)
        .toList();
  }

  /// Get hourly temperature spots for hourly chart
  static List<FlSpot> getHourlyTempSpots(DailyWeather dailyWeather) {
    return dailyWeather.hourlyForecasts.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.temperature ?? 0);
    }).toList();
  }

  /// Get apparent temperature spots for hourly chart
  static List<FlSpot> getApparentTempSpots(DailyWeather dailyWeather) {
    return dailyWeather.hourlyForecasts.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.apparentTemperature ?? 0);
    }).toList();
  }
}