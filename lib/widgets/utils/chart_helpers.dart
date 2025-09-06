import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import '../../data/weather_icon_data.dart';
import '../../models/climate_normal_model.dart';
import '../../models/weather_forecast_model.dart';
import '../../models/weather_icon.dart';
//import 'weather_deviation.dart';
import 'chart_constants.dart';

/// Helper class containing chart-related utility methods
class ChartHelpers {
  /// Get weather description in French
  static String? getDescriptionFr(String code) {
    final match = weatherIcons.firstWhere(
      (icon) => icon.code == code,
      orElse: () => WeatherIcon(
        code: '',
        iconPath: '',
        descriptionEn: '',
        descriptionFr: '',
      ),
    );

    return match.code.isEmpty ? null : match.descriptionFr;
  }

  /// Get weather icon path for a given weather code
  static String? getIconPathForCode(int? code, {int? isDay}) {
    if (code == null) return null;
    try {
      final iconData = weatherIcons.firstWhere(
        (icon) => icon.code == code.toString(),
      );
      return getIconPathForCodeWithDayNight(iconData.iconPath, isDay);
    } catch (e) {
      return null;
    }
  }

  /// Get weather icon path considering day/night variants
  static String? getIconPathForCodeWithDayNight(String baseIconPath, int? isDay) {
    if (isDay == null) return baseIconPath;

    // If it's night (isDay == 0), try to find night variant
    if (isDay == 0) {
      final nightIconPath = baseIconPath.replaceAll('_day.svg', '_night.svg');
      // Check if night variant exists by trying to load it
      // For now, we'll assume the file exists if it's a known day/night pair
      if (_hasNightVariant(baseIconPath)) {
        return nightIconPath;
      }
    }

    // Return the base icon path (day variant or non-day/night specific)
    return baseIconPath;
  }

  /// Check if an icon has a night variant available
  static bool _hasNightVariant(String iconPath) {
    final dayNightIcons = [
      'clear_day.svg',
      'mostly_clear_day.svg',
      'partly_cloudy_day.svg',
      'scattered_showers_day.svg',
      'scattered_snow_showers_day.svg',
      'isolated_scattered_thunderstorms_day.svg',
    ];

    return dayNightIcons.any((icon) => iconPath.contains(icon));
  }

  /// Calculate weather deviation for a daily forecast
  static WeatherDeviation? getDeviationForDay(
    DailyForecast dailyForecast,
    List<ClimateNormal> climateNormals,
  ) {
    final normal = ClimateNormal.findByDayOfYear(
      climateNormals,
      dailyForecast.dayOfYear,
    );
    if (normal == null) {
      return null;
    }
    return WeatherDeviation(
      maxDeviation: dailyForecast.temperatureMax - normal.temperatureMax,
      minDeviation: dailyForecast.temperatureMin - normal.temperatureMin,
      avgDeviation:
          ((dailyForecast.temperatureMax + dailyForecast.temperatureMin) / 2) -
          ((normal.temperatureMax + normal.temperatureMin) / 2),
      normal: normal,
    );
  }

  /// Generate hour labels for hourly chart
  static List<String> generateHourLabels(HourlyWeather? dailyWeather) {
    if (dailyWeather != null && dailyWeather.hourlyForecasts.isNotEmpty) {
      return dailyWeather.hourlyForecasts.map((hourly) {
        return DateFormat('HH:mm EEE', 'fr_FR').format(hourly.time);
      }).toList();
    } else {
      return [];
    }
  }

  /// Generate date labels for daily chart
  static List<String> generateDateLabels(DailyWeather? forecast) {
    if (forecast == null) return [];
    return forecast.dailyForecasts
        .map((daily) => DateFormat('E, d MMM', 'fr_FR').format(daily.date))
        .toList();
  }

  /// Calculate temperature range for chart
  static Map<String, double> calculateTempRange(
    DailyWeather? forecast,
    HourlyWeather? dailyWeather,
    String displayMode,
  ) {
    late List<double> allTemps;
    
    if (displayMode == 'daily' && forecast != null) {
      allTemps = forecast.dailyForecasts
          .expand((d) => [d.temperatureMax, d.temperatureMin])
          .toList();
    } else if (displayMode == 'hourly' && dailyWeather != null) {
      allTemps = dailyWeather.hourlyForecasts
          .where((h) => h.temperature != null)
          .map((h) => h.temperature!)
          .toList();
    } else {
      return {'min': 0, 'max': 20};
    }

    return {
      'min': allTemps.isNotEmpty ? allTemps.reduce(min) : 0,
      'max': allTemps.isNotEmpty ? allTemps.reduce(max) : 20,
    };
  }

  /// Calculate screen position from chart coordinates
  static Offset calculateScreenPosition(
    double chartX,
    double chartY,
    Size containerSize,
    double minTemp,
    double maxTemp,
    int maxIndex,
    String displayMode,
  ) {
    final double gridLeft = ChartConstants.leftPadding +
        ChartConstants.leftTitleReservedSize;
    final double gridTop = ChartConstants.topPadding;

    final double gridWidth = containerSize.width -
        ChartConstants.leftPadding -
        ChartConstants.rightPadding -
        ChartConstants.leftTitleReservedSize;
    final double gridHeight = containerSize.height -
        ChartConstants.topPadding -
        ChartConstants.bottomPadding -
        ChartConstants.bottomTitleReservedSize;

    final double minX = 0;
    final double maxX = maxIndex.toDouble();

    // Use different Y-axis ranges based on display mode
    final double minY = displayMode == 'daily'
        ? (minTemp - 6).floorToDouble()
        : (minTemp - 2).floorToDouble();
    final double maxY = displayMode == 'daily'
        ? (maxTemp + 6).ceilToDouble()
        : (maxTemp + 2).ceilToDouble();

    final double normalizedX = (maxX > minX) ? (chartX - minX) / (maxX - minX) : 0.0;
    final double normalizedY = (maxY > minY) ? (chartY - minY) / (maxY - minY) : 0.0;

    final double screenX = gridLeft + (normalizedX * gridWidth);
    final double screenY = gridTop + ((1.0 - normalizedY) * gridHeight);

    return Offset(screenX, screenY);
  }

  /// Calculate screen X position for a given chart X coordinate (for vertical alignment)
  static double calculateScreenXPosition(
    double chartX,
    Size containerSize,
    int maxIndex,
  ) {
    // Calculate the grid dimensions
    final double gridLeft = ChartConstants.leftPadding + 
        ChartConstants.leftTitleReservedSize;
    final double gridWidth = containerSize.width -
        ChartConstants.leftPadding -
        ChartConstants.rightPadding -
        ChartConstants.leftTitleReservedSize;

    // If there's only one data point, center it
    if (maxIndex <= 0) {
      return gridLeft + gridWidth / 2;
    }

    // Calculate position proportionally
    final double step = gridWidth / maxIndex;
    return gridLeft + (chartX * step);
  }

  /// Get tapped index from local position
  static int? getTappedIndex(
    Offset localPosition,
    Size containerSize,
    int maxIndex,
  ) {
    final double gridLeft = ChartConstants.leftPadding + 
        ChartConstants.leftTitleReservedSize;
    final double gridTop = ChartConstants.topPadding;
    final double gridRight = containerSize.width - ChartConstants.rightPadding;
    final double gridBottom = containerSize.height - 
        ChartConstants.bottomPadding - 
        ChartConstants.bottomTitleReservedSize;
    final double gridWidth = gridRight - gridLeft;

    if (localPosition.dx < gridLeft ||
        localPosition.dx > gridRight ||
        localPosition.dy < gridTop ||
        localPosition.dy > gridBottom) {
      return null;
    }

    final double relativeX = localPosition.dx - gridLeft;
    if (gridWidth <= 0) return null;
    final double normalizedX = relativeX / gridWidth;

    if (maxIndex < 0) return null;
    final int index = (normalizedX * maxIndex).round().clamp(0, maxIndex);

    return index;
  }
}
