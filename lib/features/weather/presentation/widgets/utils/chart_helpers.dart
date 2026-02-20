import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import 'package:aeroclim/l10n/app_localizations.dart';
import 'package:aeroclim/features/weather/data/weather_icon_data.dart';
import 'package:aeroclim/features/climate/domain/climate_model.dart';
import 'package:aeroclim/features/weather/domain/weather_model.dart';
//import 'weather_deviation.dart';
import 'chart_constants.dart';
import 'chart_theme.dart';

/// Helper class containing chart-related utility methods
class ChartHelpers {
  /// Formats a date according to specific localized rules
  static String formatLocalizedDate(
    DateTime date,
    String locale, {
    bool includeYear = true,
    bool includeTime = false,
  }) {
    String formatted;
    if (includeYear) {
      if (includeTime) {
        final dFormat = DateFormat.yMMMMEEEEd(locale).format(date);
        final tFormat = DateFormat('HH:mm').format(date);
        formatted = '$dFormat $tFormat';
      } else {
        formatted = DateFormat.yMMMMEEEEd(locale).format(date);
      }
    } else {
      if (includeTime) {
        final dFormat = DateFormat.MMMMEEEEd(locale).format(date);
        final tFormat = DateFormat('HH:mm').format(date);
        formatted = '$dFormat $tFormat';
      } else {
        formatted = DateFormat.MMMMEEEEd(locale).format(date);
      }
    }

    if (locale.startsWith('fr') && date.day == 1) {
      // Replaces "1" with "1er" in patterns like "dimanche 1 mars" or "lundi 1 avril"
      formatted = formatted.replaceFirst(' 1 ', ' 1er ');
    }

    return formatted.isNotEmpty
        ? formatted[0].toUpperCase() + formatted.substring(1)
        : formatted;
  }

  /// Get localized weather description
  static String? getDescription(BuildContext context, String code) {
    if (code.isEmpty) return null;
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return null;

    switch (code) {
      case '0':
        return l10n.weatherDesc0;
      case '1':
        return l10n.weatherDesc1;
      case '2':
        return l10n.weatherDesc2;
      case '3':
        return l10n.weatherDesc3;
      case '45':
        return l10n.weatherDesc45;
      case '48':
        return l10n.weatherDesc48;
      case '51':
        return l10n.weatherDesc51;
      case '53':
        return l10n.weatherDesc53;
      case '55':
        return l10n.weatherDesc55;
      case '56':
        return l10n.weatherDesc56;
      case '57':
        return l10n.weatherDesc57;
      case '61':
        return l10n.weatherDesc61;
      case '63':
        return l10n.weatherDesc63;
      case '65':
        return l10n.weatherDesc65;
      case '66':
        return l10n.weatherDesc66;
      case '67':
        return l10n.weatherDesc67;
      case '71':
        return l10n.weatherDesc71;
      case '73':
        return l10n.weatherDesc73;
      case '75':
        return l10n.weatherDesc75;
      case '77':
        return l10n.weatherDesc77;
      case '80':
        return l10n.weatherDesc80;
      case '81':
        return l10n.weatherDesc81;
      case '82':
        return l10n.weatherDesc82;
      case '85':
        return l10n.weatherDesc85;
      case '86':
        return l10n.weatherDesc86;
      case '95':
        return l10n.weatherDesc95;
      case '96':
        return l10n.weatherDesc96;
      case '99':
        return l10n.weatherDesc99;
      default:
        return null;
    }
  }

  /// Get weather icon path for a given weather code or icon name
  static String? getIconPath({int? code, String? iconName, int? isDay}) {
    // if (iconName != null) {
    //   return _getMeteoFranceIconPath(iconName);
    // }
    return getIconPathForCode(code, isDay: isDay);
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

  static String? _getMeteoFranceIconPath1(String icon) {
    const basePath = 'assets/google_weather_icons/v4/';
    if (icon.contains('p1j') || icon.contains('p1n') || icon.contains('p4j'))
      return '${basePath}clear_day.svg';
    if (icon.contains('p2j') || icon.contains('p2n'))
      return '${basePath}partly_cloudy_day.svg';
    if (icon.contains('p3')) return '${basePath}cloudy.svg'; // p3j, p3bisj
    if (icon.contains('p6')) return '${basePath}haze_fog_dust_smoke.svg';
    if (icon.contains('p13')) return '${basePath}slight_rain.svg';
    if (icon.contains('p14'))
      return '${basePath}showers_rain.svg'; // p14j, p14bisj
    if (icon.contains('p24')) return '${basePath}isolated_thunderstorms.svg';
    // Default fallback
    return '${basePath}cloudy.svg';
  }

  static String _getMeteoFranceIconPath(String icon) {
    const basePath = 'assets/google_weather_icons/v4/';

    // Check suffix for day/night
    final isDay = icon.endsWith('j');
    final isNight = icon.endsWith('n');

    // Normalize base code (strip j/n)
    final normalized = icon.replaceAll(RegExp(r'[jn]$'), '');

    switch (normalized) {
      case 'p1': // Clear sky
        return basePath + (isDay ? 'clear_day.svg' : 'clear_night.svg');

      case 'p1bis': // Mostly clear
        return basePath +
            (isDay ? 'mostly_clear_day.svg' : 'mostly_clear_night.svg');

      case 'p2': // Partly cloudy
        return basePath +
            (isDay ? 'partly_cloudy_day.svg' : 'partly_cloudy_night.svg');

      case 'p3': // Cloudy
        return basePath + 'cloudy.svg';
      case 'p3bis': // Overcast
        return basePath +
            (isDay ? 'mostly_cloudy_day.svg' : 'mostly_cloudy_night.svg');

      case 'p4': // Ciel voilé
        return basePath +
            (isDay
                ? 'cloudy_with_sunny_light.svg'
                : 'cloudy_with_snow_light.svg');

      case 'p5': // Drizzle
        return basePath + 'drizzle.svg';

      case 'p6': // Brume
        return basePath + 'haze_fog_dust_smoke.svg';

      case 'p7': // Brouillard
        return basePath + 'haze_fog_dust_smoke.svg';

      case 'p11': // Fog
        return basePath + 'haze_fog_dust_smoke.svg';

      case 'p13': // Light rain
        return basePath + 'slight_rain.svg';

      case 'p14': // Rain
        return basePath + 'showers_rain.svg';
      case 'p14bis': // Showers
        return basePath +
            (isDay
                ? 'scattered_showers_day.svg'
                : 'scattered_showers_night.svg');

      case 'p8': // Light snow
        return basePath + 'slight_snow.svg';
      case 'p9': // Heavy snow
        return basePath + 'heavy_snow.svg';
      case 'p10': // Rain + snow
        return basePath + 'mixed_rain_snow.svg';
      case 'p12': // Flurries
        return basePath + 'flurries.svg';

      case 'p24': // Isolated thunderstorms
        return basePath +
            (isDay
                ? 'isolated_scattered_thunderstorms_day.svg'
                : 'isolated_scattered_thunderstorms_night.svg');

      case 'p25': // Strong thunderstorms
        return basePath + 'strong_thunderstorms.svg';

      case 'p26': // Tornado
        return basePath + 'tornado.svg';

      case 'p27': // Tropical storm
        return basePath + 'tropical_storm_hurricane.svg';

      default:
        return basePath + 'cloudy.svg'; // Fallback
    }
  }

  /// Get weather icon path considering day/night variants
  static String? getIconPathForCodeWithDayNight(
    String baseIconPath,
    int? isDay,
  ) {
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
  static List<String> generateHourLabels(
    HourlyWeather? dailyWeather,
    String locale,
  ) {
    if (dailyWeather != null && dailyWeather.hourlyForecasts.isNotEmpty) {
      return dailyWeather.hourlyForecasts.map((hourly) {
        final hour = DateFormat('HH', locale).format(hourly.time);
        final dayAbbrev = DateFormat('EEE', locale).format(hourly.time);
        return '${hour}h $dayAbbrev';
      }).toList();
    } else {
      return [];
    }
  }

  /// Generate date labels for daily chart
  static List<String> generateDateLabels(
    DailyWeather? forecast,
    String locale,
  ) {
    if (forecast == null) return [];
    return forecast.dailyForecasts
        .map((daily) => DateFormat('E, d', locale).format(daily.date))
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
    } else if ((displayMode == 'hourly' || displayMode == 'periodes') &&
        dailyWeather != null) {
      allTemps = dailyWeather.hourlyForecasts
          .expand(
            (h) => [
              if (h.temperature != null) h.temperature!,
              if (h.apparentTemperature != null) h.apparentTemperature!,
            ],
          )
          .toList();
    } else {
      return {'min': 0, 'max': 20};
    }

    if (allTemps.isEmpty) {
      return {'min': 0, 'max': 20};
    }

    return {'min': allTemps.reduce(min), 'max': allTemps.reduce(max)};
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
    final double gridLeft =
        ChartConstants.leftPadding + ChartConstants.leftTitleReservedSize;
    final double gridTop = ChartConstants.topPadding;

    final double gridWidth =
        containerSize.width -
        ChartConstants.leftPadding -
        ChartConstants.rightPadding -
        ChartConstants.leftTitleReservedSize;
    final double gridHeight =
        containerSize.height -
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

    final double normalizedX = (maxX > minX)
        ? (chartX - minX) / (maxX - minX)
        : 0.0;
    final double normalizedY = (maxY > minY)
        ? (chartY - minY) / (maxY - minY)
        : 0.0;

    final double screenX = gridLeft + (normalizedX * gridWidth);
    final double screenY = gridTop + ((1.0 - normalizedY) * gridHeight);

    return Offset(screenX, screenY);
  }

  /// Calculate screen position from chart coordinates
  static Offset calculateScreenPosition2(
    double chartX,
    double chartY,
    Size containerSize,
    double minTemp,
    double maxTemp,
    //HourlyWeather dailyWeather,
    DateTime startTime,
    DateTime endTime,
  ) {
    final chartWidth =
        //constraints.maxWidth -
        containerSize.width -
        ChartConstants.leftAxisTitleSize -
        ChartConstants.leftAxisNameSize -
        2 * ChartConstants.borderWidth;
    final chartHeight =
        //constraints.maxHeight -
        containerSize.height -
        ChartConstants.bottomAxisTitleSize -
        ChartConstants.bottomAxisNameSize -
        2 * ChartConstants.borderWidth;

    //final List<FlSpot> spots = ChartDataProvider.getHourlyTempSpots(dailyWeather);

    //final startTime = dailyWeather.hourlyForecasts.first.time;
    //print("### CJG 192: startTime: $startTime minTemp: $minTemp maxTemp: $maxTemp,${dailyWeather.hourlyForecasts.first.temperature} ");
    final minX = startTime.millisecondsSinceEpoch.toDouble();
    // final maxX = startTime
    //     .add(const Duration(hours: 44))
    //     .millisecondsSinceEpoch
    //     .toDouble();
    final maxX = endTime.millisecondsSinceEpoch.toDouble();
    final minY = minTemp - 5;
    final maxY = maxTemp + 5;

    final x =
        ChartConstants.leftAxisTitleSize +
        ChartConstants.leftAxisNameSize +
        (chartX - minX) / (maxX - minX) * chartWidth +
        ChartConstants.borderWidth;
    final y =
        chartHeight -
        ((chartY - minY) / (maxY - minY)) * chartHeight +
        ChartConstants.borderWidth;

    return Offset(x, y);
  }

  /// Calculate screen X position for a given chart X coordinate (for vertical alignment)
  static double calculateScreenXPosition(
    double chartX,
    Size containerSize,
    int maxIndex,
  ) {
    // Calculate the grid dimensions
    final double gridLeft =
        ChartConstants.leftPadding + ChartConstants.leftTitleReservedSize;
    final double gridWidth =
        containerSize.width -
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

  /// Get tapped index from local position (for daily charts)
  static int? getTappedIndex(
    Offset localPosition,
    Size containerSize,
    int maxIndex,
  ) {
    final double gridLeft =
        ChartConstants.leftPadding + ChartConstants.leftTitleReservedSize;
    final double gridRight = containerSize.width - ChartConstants.rightPadding;
    final double gridWidth = gridRight - gridLeft;

    if (localPosition.dx < gridLeft ||
        localPosition.dx > gridRight ||
        localPosition.dy < 0 ||
        localPosition.dy > containerSize.height) {
      return null;
    }

    final double relativeX = localPosition.dx - gridLeft;
    if (gridWidth <= 0) return null;
    final double normalizedX = relativeX / gridWidth;

    if (maxIndex < 0) return null;
    final int index = (normalizedX * maxIndex).round().clamp(0, maxIndex);

    return index;
  }

  /// Get tapped index for hourly chart using time-based positioning
  /// This ensures tooltips align correctly with chart points even when forecasts are filtered
  static int? getTappedIndexForHourly(
    Offset localPosition,
    Size containerSize,
    HourlyWeather hourlyWeather,
  ) {
    final double gridLeft =
        ChartConstants.leftPadding + ChartConstants.leftTitleReservedSize;
    //final double gridTop = ChartConstants.topPadding;
    final double gridRight = containerSize.width - ChartConstants.rightPadding;
    //final double gridBottom =
    //    containerSize.height -
    //    ChartConstants.bottomPadding -
    //    ChartConstants.bottomTitleReservedSize;
    final double gridWidth = gridRight - gridLeft;

    // Check if tap is within chart bounds (horizontally strict, vertically permissive within container)
    if (localPosition.dx < gridLeft ||
        localPosition.dx > gridRight ||
        localPosition.dy < 0 ||
        localPosition.dy > containerSize.height) {
      return null;
    }

    // Calculate the time at the tapped position
    final double relativeX = localPosition.dx - gridLeft;
    if (gridWidth <= 0) return null;
    final double normalizedX = relativeX / gridWidth;

    final startTime = hourlyWeather.hourlyForecasts.first.time;
    final endTime = hourlyWeather.hourlyForecasts.last.time;
    final totalDuration = endTime.difference(startTime).inMilliseconds;

    final tappedTimeMs =
        startTime.millisecondsSinceEpoch + (normalizedX * totalDuration);
    final tappedTime = DateTime.fromMillisecondsSinceEpoch(
      tappedTimeMs.round(),
    );

    // Find the nearest forecast to the tapped time
    int nearestIndex = 0;
    int minDifference =
        (hourlyWeather.hourlyForecasts[0].time
                .difference(tappedTime)
                .inMilliseconds)
            .abs();

    for (int i = 1; i < hourlyWeather.hourlyForecasts.length; i++) {
      final difference =
          (hourlyWeather.hourlyForecasts[i].time
                  .difference(tappedTime)
                  .inMilliseconds)
              .abs();
      if (difference < minDifference) {
        minDifference = difference;
        nearestIndex = i;
      }
    }

    return nearestIndex;
  }

  /// Get tapped index from local position
  static int? getTappedIndex_old(
    Offset localPosition,
    Size containerSize,
    int maxIndex,
  ) {
    final double gridLeft =
        ChartConstants.leftPadding + ChartConstants.leftTitleReservedSize;
    final double gridTop = ChartConstants.topPadding;
    final double gridRight = containerSize.width - ChartConstants.rightPadding;
    final double gridBottom =
        containerSize.height -
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

  /// Get wind direction icon path based on degrees
  // static String getWindDirectionIconPath(int? degrees) {
  //   if (degrees == null) return 'assets/google_weather_icons/v4/arrow.svg';

  //   // Normalize degrees to 0-360
  //   final normalizedDegrees = degrees % 360;

  //   // Map degrees to arrow directions (8 cardinal directions)
  //   if (normalizedDegrees >= 337.5 || normalizedDegrees < 22.5) {
  //     return 'assets/google_weather_icons/v4/arrow.svg'; // North
  //   } else if (normalizedDegrees >= 22.5 && normalizedDegrees < 67.5) {
  //     return 'assets/google_weather_icons/v3/arrow_2.svg'; // Northeast
  //   } else if (normalizedDegrees >= 67.5 && normalizedDegrees < 112.5) {
  //     return 'assets/google_weather_icons/v3/arrow_3.svg'; // East
  //   } else if (normalizedDegrees >= 112.5 && normalizedDegrees < 157.5) {
  //     return 'assets/google_weather_icons/v3/arrow_4.svg'; // Southeast
  //   } else if (normalizedDegrees >= 157.5 && normalizedDegrees < 202.5) {
  //     return 'assets/google_weather_icons/v3/arrow_5.svg'; // South
  //   } else if (normalizedDegrees >= 202.5 && normalizedDegrees < 247.5) {
  //     return 'assets/google_weather_icons/v3/arrow_4.svg'; // Southwest (reuse arrow_4 rotated)
  //   } else if (normalizedDegrees >= 247.5 && normalizedDegrees < 292.5) {
  //     return 'assets/google_weather_icons/v3/arrow_3.svg'; // West (reuse arrow_3 rotated)
  //   } else {
  //     return 'assets/google_weather_icons/v3/arrow_2.svg'; // Northwest (reuse arrow_2 rotated)
  //   }
  // }

  /// Get wind direction abbreviation
  static String getWindDirectionAbbrev(int? degrees) {
    if (degrees == null) return 'N';

    final normalizedDegrees = degrees % 360;

    if (normalizedDegrees >= 337.5 || normalizedDegrees < 22.5) {
      return 'N';
    } else if (normalizedDegrees >= 22.5 && normalizedDegrees < 67.5) {
      return 'NE';
    } else if (normalizedDegrees >= 67.5 && normalizedDegrees < 112.5) {
      return 'E';
    } else if (normalizedDegrees >= 112.5 && normalizedDegrees < 157.5) {
      return 'SE';
    } else if (normalizedDegrees >= 157.5 && normalizedDegrees < 202.5) {
      return 'S';
    } else if (normalizedDegrees >= 202.5 && normalizedDegrees < 247.5) {
      return 'SW';
    } else if (normalizedDegrees >= 247.5 && normalizedDegrees < 292.5) {
      return 'W';
    } else {
      return 'NW';
    }
  }
}

Color gustColor(double speed) => ChartTheme.windGustColor(speed);
