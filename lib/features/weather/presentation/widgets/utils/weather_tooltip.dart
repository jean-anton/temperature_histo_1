import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aeroclim/features/climate/domain/climate_model.dart';
import 'package:aeroclim/features/weather/domain/weather_model.dart';
//import 'weather_deviation.dart';
import 'chart_helpers.dart';
import 'chart_theme.dart';

/// Widget for displaying weather tooltips
class WeatherTooltip {
  static OverlayEntry? _overlayEntry;
  static Timer? _tooltipTimer;
  static final GlobalKey tooltipKey = GlobalKey();

  static bool get isOpen => _overlayEntry != null;

  /// Show tooltip for daily weather data
  static void showDailyTooltip(
    BuildContext context,
    int touchedIndex,
    Offset position,
    DailyWeather forecast,
    List<WeatherDeviation?> deviations, {
    bool showExtendedWindInfo = false,
  }) {
    if (touchedIndex < 0 || touchedIndex >= forecast.dailyForecasts.length) {
      return;
    }

    final forecastData = forecast.dailyForecasts[touchedIndex];
    final deviation = touchedIndex < deviations.length
        ? deviations[touchedIndex]
        : null;

    final String formattedDate = DateFormat(
      'EEEE, d MMMM',
      'fr_FR',
    ).format(forecastData.date);

    _buildTooltip(
      context,
      position,
      formattedDate,
      forecastData,
      deviation: deviation,
      showExtendedWindInfo: showExtendedWindInfo,
    );
  }

  /// Show tooltip for hourly weather data
  static void showHourlyTooltip(
    BuildContext context,
    int touchedIndex,
    Offset position,
    HourlyWeather dailyWeather, {
    bool showExtendedWindInfo = false,
  }) {
    if (touchedIndex < 0 ||
        touchedIndex >= dailyWeather.hourlyForecasts.length) {
      return;
    }

    final hourly = dailyWeather.hourlyForecasts[touchedIndex];
    final String formattedDate = DateFormat(
      'EEEE, d MMMM HH:mm',
      'fr_FR',
    ).format(hourly.time);

    _buildTooltip(
      context,
      position,
      formattedDate,
      hourly,
      showExtendedWindInfo: showExtendedWindInfo,
    );
  }

  /// Show tooltip for period weather data
  static void showPeriodTooltip(
    BuildContext context,
    int touchedIndex,
    Offset position,
    PeriodForecast period, {
    bool showExtendedWindInfo = false,
  }) {
    final String formattedDate =
        '${DateFormat('EEEE, d MMMM', 'fr_FR').format(period.time)} - ${period.name}';

    _buildTooltip(
      context,
      position,
      formattedDate,
      period,
      showExtendedWindInfo: showExtendedWindInfo,
    );
  }

  /// Show tooltip for multi-model comparison
  static void showComparisonTooltip(
    BuildContext context,
    int touchedIndex,
    Offset position,
    String displayMode,
    MultiModelWeather? multiModelForecast,
    MultiModelHourlyWeather? multiModelHourlyForecast,
  ) {
    final bool isDaily = displayMode == 'daily';
    DateTime? date;
    final Map<String, Map<String, double>> modelData = {};

    if (isDaily && multiModelForecast != null) {
      for (final entry in multiModelForecast.models.entries) {
        if (touchedIndex >= 0 &&
            touchedIndex < entry.value.dailyForecasts.length) {
          final forecast = entry.value.dailyForecasts[touchedIndex];
          date ??= forecast.date;
          modelData[entry.key] = {'temp': forecast.temperatureMax};
        }
      }
    } else if (!isDaily && multiModelHourlyForecast != null) {
      for (final entry in multiModelHourlyForecast.models.entries) {
        if (touchedIndex >= 0 &&
            touchedIndex < entry.value.hourlyForecasts.length) {
          final forecast = entry.value.hourlyForecasts[touchedIndex];
          date ??= forecast.time;
          if (forecast.temperature != null) {
            modelData[entry.key] = {
              'temp': forecast.temperature!,
              'apparent': forecast.apparentTemperature ?? forecast.temperature!,
            };
          }
        }
      }
    }

    if (date == null) return;

    final String formattedDate = DateFormat(
      isDaily ? 'EEEE, d MMMM' : 'EEEE, d MMMM HH:mm',
      'fr_FR',
    ).format(date);

    _buildComparisonTooltip(
      context,
      position,
      formattedDate,
      modelData,
      isDaily,
    );
  }

  static void _buildComparisonTooltip(
    BuildContext context,
    Offset position,
    String formattedDate,
    Map<String, Map<String, double>> modelData,
    bool isDaily,
  ) {
    final modelNames = {
      'best_match': 'Best Match',
      'ecmwf_ifs': 'ECMWF IFS HRES 9km',
      'gfs_seamless': 'GFS',
      'meteofrance_seamless': 'ARPEGE',
    };

    final modelColors = {
      'best_match': Colors.orange,
      'ecmwf_ifs': Colors.blue,
      'gfs_seamless': Colors.red,
      'meteofrance_seamless': Colors.green,
    };

    final screenSize = MediaQuery.of(context).size;
    double tooltipLeft = position.dx - 110;
    double tooltipTop = position.dy - (isDaily ? 180 : 220);

    if (tooltipLeft < 10) tooltipLeft = 10;
    if (tooltipLeft + 220 > screenSize.width - 10)
      tooltipLeft = screenSize.width - 230;
    if (tooltipTop < 10) tooltipTop = position.dy + 20;

    removeTooltip();

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned(
            left: tooltipLeft,
            top: tooltipTop,
            child: Material(
              key: tooltipKey,
              color: Colors.transparent,
              child: Container(
                width: 220,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blueGrey.shade800.withValues(alpha: 0.95),
                      Colors.blueGrey.shade900.withValues(alpha: 0.95),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                    const Divider(color: Colors.white24, height: 16),
                    ...modelData.entries.map((e) {
                      final data = e.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: modelColors[e.key],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      modelNames[e.key] ?? e.key,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${data['temp']!.toStringAsFixed(1)}°C',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            if (data.containsKey('apparent'))
                              Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Text(
                                  'Ressenti: ${data['apparent']!.toStringAsFixed(1)}°C',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _tooltipTimer = Timer(const Duration(seconds: 10), removeTooltip);
  }

  /// Build the tooltip widget
  static void _buildTooltip(
    BuildContext context,
    Offset position,
    String formattedDate,
    dynamic data, {
    WeatherDeviation? deviation,
    bool showExtendedWindInfo = false,
  }) {
    Widget buildDetailRow(
      String label,
      String? value, {
      Color? valueColor,
      Widget? valueWidget,
    }) {
      if ((value == null || value.isEmpty) && valueWidget == null) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: ',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            if (valueWidget != null)
              valueWidget
            else
              Flexible(
                child: Text(
                  value!,
                  style: TextStyle(
                    color: valueColor ?? Colors.white,
                    fontSize: 13,
                    fontWeight: valueColor != null
                        ? FontWeight.bold
                        : FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    Widget buildDetailRowWind(
      String label,
      String? value, {
      Color? valueColor,
      Widget? valueWidget,
    }) {
      if ((value == null || value.isEmpty) && valueWidget == null) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 50, // pick the width you want
              child: Text(
                '$label:',
                textAlign: TextAlign.left,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            if (valueWidget != null)
              valueWidget
            else
              Flexible(
                child: Text(
                  value!,
                  style: TextStyle(
                    color: valueColor ?? Colors.white,
                    fontSize: 13,
                    // fontWeight: valueColor != null
                    //     ? FontWeight.bold
                    //     : FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    Widget? buildColorChar(double? value) {
      if (value == null) return null;
      final color = ChartTheme.windGustColor(value).withAlpha(255);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${value.toStringAsFixed(1)} km/h ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '███',
            style: TextStyle(color: color, fontSize: 13, letterSpacing: -1),
          ),
        ],
      );
    }

    Widget? buildOnlyColorBlock(double? value) {
      if (value == null) return null;
      final color = ChartTheme.windGustColor(value).withAlpha(255);
      return Text(
        '███',
        style: TextStyle(color: color, fontSize: 13, letterSpacing: -1),
      );
    }

    final screenSize = MediaQuery.of(context).size;
    double tooltipLeft = position.dx - 150;
    double tooltipTop = position.dy - 320;

    if (tooltipLeft < 10) {
      tooltipLeft = 10;
    } else if (tooltipLeft + 300 > screenSize.width - 10) {
      tooltipLeft = screenSize.width - 310;
    }

    if (tooltipTop < 10) {
      tooltipTop = position.dy + 20;
    }

    // Remove any existing tooltip before showing a new one
    removeTooltip();

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned(
            left: tooltipLeft,
            top: tooltipTop,
            child: Material(
              key: tooltipKey,
              color: Colors.transparent,
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(12),
                constraints: const BoxConstraints(maxHeight: 290),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blueGrey.shade800.withValues(alpha: 0.95),
                      Colors.blueGrey.shade900.withValues(alpha: 0.95),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Weather Description
                          // Weather Description
                          if (data is DailyForecast &&
                                  (data.weatherCodeDaytime != null ||
                                      data.weatherCode != null) ||
                              data is HourlyForecast &&
                                  data.weatherCode != null ||
                              data is PeriodForecast &&
                                  data.weatherCode != null)
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    data is DailyForecast
                                        ? ChartHelpers.getDescriptionFr(
                                                (data.weatherCodeDaytime ??
                                                        data.weatherCode)!
                                                    .toString(),
                                              ) ??
                                              ''
                                        : data is HourlyForecast &&
                                              data.weatherCode != null
                                        ? '${ChartHelpers.getDescriptionFr(data.weatherCode!.toString())}'
                                        : data is PeriodForecast &&
                                              data.weatherCode != null
                                        ? '${ChartHelpers.getDescriptionFr(data.weatherCode!.toString())}'
                                        : "",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                if (data is DailyForecast) ...[
                                  if (data.sunrise != null) ...[
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.wb_sunny_outlined,
                                      color: Colors.amberAccent,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('HH:mm').format(data.sunrise!),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                  if (data.sunset != null) ...[
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.nights_stay_outlined,
                                      color: Colors.orangeAccent,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('HH:mm').format(data.sunset!),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          // Temperature Details
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (data is DailyForecast) ...[
                                    buildDetailRow(
                                      'Temp. max.',
                                      '${data.temperatureMax.toStringAsFixed(1)}°C ${deviation != null ? '(${deviation.maxDeviationText})' : ''}',
                                      valueColor:
                                          (deviation?.maxDeviation ?? 0) > 0
                                          ? Colors.redAccent.shade100
                                          : Colors.lightBlueAccent.shade100,
                                    ),
                                    buildDetailRow(
                                      'Temp. min.',
                                      '${data.temperatureMin.toStringAsFixed(1)}°C ${deviation != null ? '(${deviation.minDeviationText})' : ''}',
                                      valueColor:
                                          (deviation?.minDeviation ?? 0) > 0
                                          ? Colors.redAccent.shade100
                                          : Colors.lightBlueAccent.shade100,
                                    ),
                                  ],
                                  if (data is HourlyForecast) ...[
                                    buildDetailRow(
                                      'Température',
                                      '${data.temperature?.toStringAsFixed(1)}°C',
                                    ),
                                    buildDetailRow(
                                      'Ressenti',
                                      '${data.apparentTemperature?.toStringAsFixed(1)}°C',
                                    ),
                                  ],
                                  if (data is PeriodForecast) ...[
                                    buildDetailRow(
                                      'Temp. moyenne',
                                      '${data.avgTemperature.toStringAsFixed(1)}°C',
                                    ),
                                    if (data.apparentTemperature != null)
                                      buildDetailRow(
                                        'Ressenti',
                                        '${data.apparentTemperature?.toStringAsFixed(1)}°C',
                                      ),
                                  ],
                                  // Precipitation Sum/Amount
                                  buildDetailRow(
                                    'Précipitations',
                                    data is DailyForecast
                                        ? data.precipitationSum != null
                                              ? '${data.precipitationSum?.toStringAsFixed(1)} mm'
                                              : null
                                        : data is HourlyForecast
                                        ? data.precipitation != null
                                              ? '${data.precipitation?.toStringAsFixed(1)} mm'
                                              : null
                                        : data is PeriodForecast
                                        ? data.precipitation != null
                                              ? '${data.precipitation?.toStringAsFixed(1)} mm'
                                              : null
                                        : null,
                                  ),
                                  // Precipitation Hours (DailyForecast only)
                                  if (data is DailyForecast)
                                    buildDetailRow(
                                      'Heures de précip.',
                                      data.precipitationHours != null
                                          ? '${data.precipitationHours?.toStringAsFixed(1)} h'
                                          : null,
                                    ),
                                  // Precipitation Probability
                                  buildDetailRow(
                                    'Chance de précip.',
                                    data is DailyForecast
                                        ? data.precipitationProbabilityMax !=
                                                  null
                                              ? '${data.precipitationProbabilityMax}%'
                                              : null
                                        : data is HourlyForecast
                                        ? data.precipitationProbability != null
                                              ? '${data.precipitationProbability}%'
                                              : null
                                        : data is PeriodForecast
                                        ? data.precipitationProbability != null
                                              ? '${data.precipitationProbability}%'
                                              : null
                                        : null,
                                  ),
                                  // Snowfall Sum (DailyForecast only)
                                  if (data is DailyForecast)
                                    buildDetailRow(
                                      'Chute de neige',
                                      data.snowfallSum != null &&
                                              data.snowfallSum! > 0
                                          ? '${data.snowfallSum?.toStringAsFixed(1)} cm'
                                          : null,
                                    ),
                                  // Cloud Cover
                                  buildDetailRow(
                                    'Couverture nuag.',
                                    data is DailyForecast
                                        ? data.cloudCoverMean != null
                                              ? '${data.cloudCoverMean}%'
                                              : null
                                        : data is HourlyForecast
                                        ? data.cloudCover != null
                                              ? '${data.cloudCover}%'
                                              : null
                                        : data is PeriodForecast
                                        ? data.cloudCover != null
                                              ? '${data.cloudCover}%'
                                              : null
                                        : null,
                                  ),

                                  buildDetailRow(
                                    'Vent',
                                    null,
                                    valueWidget: buildColorChar(
                                      data is DailyForecast
                                          ? data.windSpeedMax
                                          : data is HourlyForecast
                                          ? data.windSpeed
                                          : data is PeriodForecast
                                          ? data.maxWindSpeed
                                          : null,
                                    ),
                                  ),
                                  // Wind Gusts
                                  buildDetailRow(
                                    'Rafales',
                                    null,
                                    valueWidget: buildColorChar(
                                      data is DailyForecast
                                          ? data.windGustsMax
                                          : data is HourlyForecast
                                          ? data.windGusts
                                          : data is PeriodForecast
                                          ? data.maxWindGusts
                                          : null,
                                    ),
                                  ),
                                  // Wind Direction
                                  buildDetailRow(
                                    'Direction vent',
                                    data is DailyForecast
                                        ? data.windDirection10mDominant != null
                                              ? ChartHelpers.getWindDirectionAbbrev(
                                                  data.windDirection10mDominant,
                                                )
                                              : null
                                        : data is HourlyForecast
                                        ? data.windDirection10m != null
                                              ? ChartHelpers.getWindDirectionAbbrev(
                                                      data.windDirection10m,
                                                    ) +
                                                    ' (${data.windDirection10m}°)'
                                              : null
                                        : data is PeriodForecast
                                        ? data.windDirection != null
                                              ? ChartHelpers.getWindDirectionAbbrev(
                                                      data.windDirection,
                                                    ) +
                                                    ' (${data.windDirection}°)'
                                              : null
                                        : null,
                                  ),

                                  // Wind Speed
                                ],
                              ),
                              if (showExtendedWindInfo &&
                                  (data is HourlyForecast ||
                                      data is PeriodForecast ||
                                      data is DailyForecast)) ...[
                                const SizedBox(width: 24),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildDetailRowWind(
                                      '200m',
                                      null,
                                      valueWidget: buildOnlyColorBlock(
                                        data is HourlyForecast
                                            ? data.windSpeed200m
                                            : data is PeriodForecast
                                            ? data.windSpeed200m
                                            : (data as DailyForecast)
                                                  .windSpeed200m,
                                      ),
                                    ),
                                    buildDetailRowWind(
                                      '180m',
                                      null,
                                      valueWidget: buildOnlyColorBlock(
                                        data is HourlyForecast
                                            ? data.windSpeed180m
                                            : data is PeriodForecast
                                            ? data.windSpeed180m
                                            : (data as DailyForecast)
                                                  .windSpeed180m,
                                      ),
                                    ),
                                    buildDetailRowWind(
                                      '150m',
                                      null,
                                      valueWidget: buildOnlyColorBlock(
                                        data is HourlyForecast
                                            ? data.windSpeed150m
                                            : data is PeriodForecast
                                            ? data.windSpeed150m
                                            : (data as DailyForecast)
                                                  .windSpeed150m,
                                      ),
                                    ),
                                    buildDetailRowWind(
                                      '120m',
                                      null,
                                      valueWidget: buildOnlyColorBlock(
                                        data is HourlyForecast
                                            ? data.windSpeed120m
                                            : data is PeriodForecast
                                            ? data.windSpeed120m
                                            : (data as DailyForecast)
                                                  .windSpeed120m,
                                      ),
                                    ),
                                    buildDetailRowWind(
                                      '100m',
                                      null,
                                      valueWidget: buildOnlyColorBlock(
                                        data is HourlyForecast
                                            ? data.windSpeed100m
                                            : data is PeriodForecast
                                            ? data.windSpeed100m
                                            : (data as DailyForecast)
                                                  .windSpeed100m,
                                      ),
                                    ),
                                    buildDetailRowWind(
                                      '80m',
                                      null,
                                      valueWidget: buildOnlyColorBlock(
                                        data is HourlyForecast
                                            ? data.windSpeed80m
                                            : data is PeriodForecast
                                            ? data.windSpeed80m
                                            : (data as DailyForecast)
                                                  .windSpeed80m,
                                      ),
                                    ),
                                    buildDetailRowWind(
                                      '50m',
                                      null,
                                      valueWidget: buildOnlyColorBlock(
                                        data is HourlyForecast
                                            ? data.windSpeed50m
                                            : data is PeriodForecast
                                            ? data.windSpeed50m
                                            : (data as DailyForecast)
                                                  .windSpeed50m,
                                      ),
                                    ),
                                    buildDetailRowWind(
                                      '20m',
                                      null,
                                      valueWidget: buildOnlyColorBlock(
                                        data is HourlyForecast
                                            ? data.windSpeed20m
                                            : data is PeriodForecast
                                            ? data.windSpeed20m
                                            : (data as DailyForecast)
                                                  .windSpeed20m,
                                      ),
                                    ),

                                    buildDetailRowWind(
                                      '10m',
                                      null,
                                      valueWidget: buildOnlyColorBlock(
                                        data is HourlyForecast
                                            ? data.windSpeed
                                            : data is PeriodForecast
                                            ? data.maxWindSpeed
                                            : (data as DailyForecast)
                                                  .windSpeedMax,
                                      ),
                                    ),
                                    buildDetailRowWind(
                                      'Gusts',
                                      null,
                                      valueWidget: buildOnlyColorBlock(
                                        data is HourlyForecast
                                            ? data.windGusts
                                            : data is PeriodForecast
                                            ? data.maxWindGusts
                                            : (data as DailyForecast)
                                                  .windGustsMax,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: GestureDetector(
                        onTap: removeTooltip,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    scheduleTooltipRemoval(showExtendedWindInfo: showExtendedWindInfo);
  }

  /// Remove the current tooltip
  static void removeTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _tooltipTimer?.cancel();
  }

  /// Schedule tooltip removal after delay
  static void scheduleTooltipRemoval({bool showExtendedWindInfo = false}) {
    final duration = showExtendedWindInfo ? 60 * 5 : 10;
    _tooltipTimer = Timer(Duration(seconds: duration), () {
      removeTooltip();
    });
  }

  /// Cancel scheduled tooltip removal
  static void cancelTooltipRemoval() {
    _tooltipTimer?.cancel();
  }

  /// Show tooltip for a single daily forecast (for table view)
  static void showDailyForecastTooltip(
    BuildContext context,
    DailyForecast forecast,
    Offset position, {
    String? modelName,
    bool showExtendedWindInfo = false,
  }) {
    final String formattedDate = DateFormat(
      'EEEE, d MMMM',
      'fr_FR',
    ).format(forecast.date);

    final title = modelName != null
        ? '$formattedDate - $modelName'
        : formattedDate;

    _buildTooltipForSingleForecast(
      context,
      position,
      title,
      forecast,
      showExtendedWindInfo: showExtendedWindInfo,
    );
  }

  /// Show tooltip for a single hourly forecast (for table view)
  static void showHourlyForecastTooltip(
    BuildContext context,
    HourlyForecast forecast,
    Offset position, {
    String? modelName,
    bool showExtendedWindInfo = false,
  }) {
    final String formattedDate = DateFormat(
      'EEEE, d MMMM HH:mm',
      'fr_FR',
    ).format(forecast.time);

    final title = modelName != null
        ? '$formattedDate - $modelName'
        : formattedDate;

    _buildTooltipForSingleForecast(
      context,
      position,
      title,
      forecast,
      showExtendedWindInfo: showExtendedWindInfo,
    );
  }

  /// Show tooltip for a single period forecast (for table view)
  static void showPeriodForecastTooltip(
    BuildContext context,
    PeriodForecast forecast,
    Offset position, {
    String? modelName,
    bool showExtendedWindInfo = false,
  }) {
    final String formattedDate =
        '${DateFormat('EEEE, d MMMM', 'fr_FR').format(forecast.time)} - ${forecast.name}';

    final title = modelName != null
        ? '$formattedDate - $modelName'
        : formattedDate;

    _buildTooltipForSingleForecast(
      context,
      position,
      title,
      forecast,
      showExtendedWindInfo: showExtendedWindInfo,
    );
  }

  /// Build tooltip for a single forecast (used by table view)
  static void _buildTooltipForSingleForecast(
    BuildContext context,
    Offset position,
    String formattedDate,
    dynamic data, {
    bool showExtendedWindInfo = false,
  }) {
    Widget buildDetailRow(
      String label,
      String? value, {
      Color? valueColor,
      Widget? valueWidget,
    }) {
      if ((value == null || value.isEmpty) && valueWidget == null) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: ',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            if (valueWidget != null)
              valueWidget
            else
              Flexible(
                child: Text(
                  value!,
                  style: TextStyle(
                    color: valueColor ?? Colors.white,
                    fontSize: 13,
                    fontWeight: valueColor != null
                        ? FontWeight.bold
                        : FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    Widget buildDetailRowWind(
      String label,
      String? value, {
      Color? valueColor,
      Widget? valueWidget,
    }) {
      if ((value == null || value.isEmpty) && valueWidget == null) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 50,
              child: Text(
                '$label:',
                textAlign: TextAlign.left,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            if (valueWidget != null)
              valueWidget
            else
              Flexible(
                child: Text(
                  value!,
                  style: TextStyle(
                    color: valueColor ?? Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    Widget? buildColorChar(double? value) {
      if (value == null) return null;
      final color = ChartTheme.windGustColor(value).withAlpha(255);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${value.toStringAsFixed(1)} km/h ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '███',
            style: TextStyle(color: color, fontSize: 13, letterSpacing: -1),
          ),
        ],
      );
    }

    Widget? buildOnlyColorBlock(double? value) {
      if (value == null) return null;
      final color = ChartTheme.windGustColor(value).withAlpha(255);
      return Text(
        '███',
        style: TextStyle(color: color, fontSize: 13, letterSpacing: -1),
      );
    }

    final screenSize = MediaQuery.of(context).size;
    double tooltipLeft = position.dx - 150;
    double tooltipTop = position.dy - 320;

    if (tooltipLeft < 10) {
      tooltipLeft = 10;
    } else if (tooltipLeft + 300 > screenSize.width - 10) {
      tooltipLeft = screenSize.width - 310;
    }

    if (tooltipTop < 10) {
      tooltipTop = position.dy + 20;
    }

    removeTooltip();

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned(
            left: tooltipLeft,
            top: tooltipTop,
            child: Material(
              key: tooltipKey,
              color: Colors.transparent,
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(12),
                constraints: const BoxConstraints(maxHeight: 290),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blueGrey.shade800.withValues(alpha: 0.95),
                      Colors.blueGrey.shade900.withValues(alpha: 0.95),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Weather Description
                          if (data is DailyForecast &&
                                  (data.weatherCodeDaytime != null ||
                                      data.weatherCode != null) ||
                              data is HourlyForecast &&
                                  data.weatherCode != null ||
                              data is PeriodForecast &&
                                  data.weatherCode != null)
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    data is DailyForecast
                                        ? ChartHelpers.getDescriptionFr(
                                                (data.weatherCodeDaytime ??
                                                        data.weatherCode)!
                                                    .toString(),
                                              ) ??
                                              ''
                                        : data is HourlyForecast &&
                                              data.weatherCode != null
                                        ? '${ChartHelpers.getDescriptionFr(data.weatherCode!.toString())}'
                                        : data is PeriodForecast &&
                                              data.weatherCode != null
                                        ? '${ChartHelpers.getDescriptionFr(data.weatherCode!.toString())}'
                                        : "",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                if (data is DailyForecast) ...[
                                  if (data.sunrise != null) ...[
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.wb_sunny_outlined,
                                      color: Colors.amberAccent,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('HH:mm').format(data.sunrise!),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                  if (data.sunset != null) ...[
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.nights_stay_outlined,
                                      color: Colors.orangeAccent,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('HH:mm').format(data.sunset!),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          // Temperature Details
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (data is DailyForecast) ...[
                                    buildDetailRow(
                                      'Temp. max.',
                                      '${data.temperatureMax.toStringAsFixed(1)}°C',
                                      valueColor: Colors.redAccent.shade100,
                                    ),
                                    buildDetailRow(
                                      'Temp. min.',
                                      '${data.temperatureMin.toStringAsFixed(1)}°C',
                                      valueColor:
                                          Colors.lightBlueAccent.shade100,
                                    ),
                                  ],
                                  if (data is HourlyForecast) ...[
                                    buildDetailRow(
                                      'Température',
                                      '${data.temperature?.toStringAsFixed(1)}°C',
                                    ),
                                    buildDetailRow(
                                      'Ressenti',
                                      '${data.apparentTemperature?.toStringAsFixed(1)}°C',
                                    ),
                                  ],
                                  if (data is PeriodForecast) ...[
                                    buildDetailRow(
                                      'Temp. moyenne',
                                      '${data.avgTemperature.toStringAsFixed(1)}°C',
                                    ),
                                    if (data.apparentTemperature != null)
                                      buildDetailRow(
                                        'Ressenti',
                                        '${data.apparentTemperature?.toStringAsFixed(1)}°C',
                                      ),
                                  ],
                                  // Precipitation
                                  buildDetailRow(
                                    'Précipitations',
                                    data is DailyForecast
                                        ? data.precipitationSum != null
                                              ? '${data.precipitationSum?.toStringAsFixed(1)} mm'
                                              : null
                                        : data is HourlyForecast
                                        ? data.precipitation != null
                                              ? '${data.precipitation?.toStringAsFixed(1)} mm'
                                              : null
                                        : data is PeriodForecast
                                        ? data.precipitation != null
                                              ? '${data.precipitation?.toStringAsFixed(1)} mm'
                                              : null
                                        : null,
                                  ),
                                  // Precipitation Hours (DailyForecast only)
                                  if (data is DailyForecast)
                                    buildDetailRow(
                                      'Heures de précip.',
                                      data.precipitationHours != null
                                          ? '${data.precipitationHours?.toStringAsFixed(1)} h'
                                          : null,
                                    ),
                                  // Precipitation Probability
                                  buildDetailRow(
                                    'Chance de précip.',
                                    data is DailyForecast
                                        ? data.precipitationProbabilityMax !=
                                                  null
                                              ? '${data.precipitationProbabilityMax}%'
                                              : null
                                        : data is HourlyForecast
                                        ? data.precipitationProbability != null
                                              ? '${data.precipitationProbability}%'
                                              : null
                                        : data is PeriodForecast
                                        ? data.precipitationProbability != null
                                              ? '${data.precipitationProbability}%'
                                              : null
                                        : null,
                                  ),
                                  // Snowfall (DailyForecast only)
                                  if (data is DailyForecast)
                                    buildDetailRow(
                                      'Chute de neige',
                                      data.snowfallSum != null &&
                                              data.snowfallSum! > 0
                                          ? '${data.snowfallSum?.toStringAsFixed(1)} cm'
                                          : null,
                                    ),
                                  // Cloud Cover
                                  buildDetailRow(
                                    'Couverture nuag.',
                                    data is DailyForecast
                                        ? data.cloudCoverMean != null
                                              ? '${data.cloudCoverMean}%'
                                              : null
                                        : data is HourlyForecast
                                        ? data.cloudCover != null
                                              ? '${data.cloudCover}%'
                                              : null
                                        : data is PeriodForecast
                                        ? data.cloudCover != null
                                              ? '${data.cloudCover}%'
                                              : null
                                        : null,
                                  ),
                                  // Wind Speed
                                  buildDetailRow(
                                    'Vent',
                                    null,
                                    valueWidget: buildColorChar(
                                      data is DailyForecast
                                          ? data.windSpeedMax
                                          : data is HourlyForecast
                                          ? data.windSpeed
                                          : data is PeriodForecast
                                          ? data.maxWindSpeed
                                          : null,
                                    ),
                                  ),
                                  // Wind Gusts
                                  buildDetailRow(
                                    'Rafales',
                                    null,
                                    valueWidget: buildColorChar(
                                      data is DailyForecast
                                          ? data.windGustsMax
                                          : data is HourlyForecast
                                          ? data.windGusts
                                          : data is PeriodForecast
                                          ? data.maxWindGusts
                                          : null,
                                    ),
                                  ),
                                  // Wind Direction
                                  buildDetailRow(
                                    'Direction vent',
                                    data is DailyForecast
                                        ? data.windDirection10mDominant != null
                                              ? ChartHelpers.getWindDirectionAbbrev(
                                                  data.windDirection10mDominant,
                                                )
                                              : null
                                        : data is HourlyForecast
                                        ? data.windDirection10m != null
                                              ? ChartHelpers.getWindDirectionAbbrev(
                                                      data.windDirection10m,
                                                    ) +
                                                    ' (${data.windDirection10m}°)'
                                              : null
                                        : data is PeriodForecast
                                        ? data.windDirection != null
                                              ? ChartHelpers.getWindDirectionAbbrev(
                                                      data.windDirection,
                                                    ) +
                                                    ' (${data.windDirection}°)'
                                              : null
                                        : null,
                                  ),
                                ],
                              ),
                              if (showExtendedWindInfo &&
                                  (data is HourlyForecast ||
                                      data is PeriodForecast ||
                                      data is DailyForecast)) ...[
                                const SizedBox(width: 24),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildDetailRowWind(
                                      '200m',
                                      null,
                                      valueWidget: buildOnlyColorBlock(
                                        data is HourlyForecast
                                            ? data.windSpeed200m
                                            : data is PeriodForecast
                                            ? data.windSpeed200m
                                            : (data as DailyForecast)
                                                  .windSpeed200m,
                                      ),
                                    ),
                                    buildDetailRowWind(
                                      '180m',
                                      null,
                                      valueWidget: buildOnlyColorBlock(
                                        data is HourlyForecast
                                            ? data.windSpeed180m
                                            : data is PeriodForecast
                                            ? data.windSpeed180m
                                            : (data as DailyForecast)
                                                  .windSpeed180m,
                                      ),
                                    ),
                                    buildDetailRowWind(
                                      '150m',
                                      null,
                                      valueWidget: buildOnlyColorBlock(
                                        data is HourlyForecast
                                            ? data.windSpeed150m
                                            : data is PeriodForecast
                                            ? data.windSpeed150m
                                            : (data as DailyForecast)
                                                  .windSpeed150m,
                                      ),
                                    ),
                                    buildDetailRowWind(
                                      '120m',
                                      null,
                                      valueWidget: buildOnlyColorBlock(
                                        data is HourlyForecast
                                            ? data.windSpeed120m
                                            : data is PeriodForecast
                                            ? data.windSpeed120m
                                            : (data as DailyForecast)
                                                  .windSpeed120m,
                                      ),
                                    ),
                                    buildDetailRowWind(
                                      '100m',
                                      null,
                                      valueWidget: buildOnlyColorBlock(
                                        data is HourlyForecast
                                            ? data.windSpeed100m
                                            : data is PeriodForecast
                                            ? data.windSpeed100m
                                            : (data as DailyForecast)
                                                  .windSpeed100m,
                                      ),
                                    ),
                                    buildDetailRowWind(
                                      '80m',
                                      null,
                                      valueWidget: buildOnlyColorBlock(
                                        data is HourlyForecast
                                            ? data.windSpeed80m
                                            : data is PeriodForecast
                                            ? data.windSpeed80m
                                            : (data as DailyForecast)
                                                  .windSpeed80m,
                                      ),
                                    ),
                                    buildDetailRowWind(
                                      '50m',
                                      null,
                                      valueWidget: buildOnlyColorBlock(
                                        data is HourlyForecast
                                            ? data.windSpeed50m
                                            : data is PeriodForecast
                                            ? data.windSpeed50m
                                            : (data as DailyForecast)
                                                  .windSpeed50m,
                                      ),
                                    ),
                                    buildDetailRowWind(
                                      '20m',
                                      null,
                                      valueWidget: buildOnlyColorBlock(
                                        data is HourlyForecast
                                            ? data.windSpeed20m
                                            : data is PeriodForecast
                                            ? data.windSpeed20m
                                            : (data as DailyForecast)
                                                  .windSpeed20m,
                                      ),
                                    ),
                                    buildDetailRowWind(
                                      '10m',
                                      null,
                                      valueWidget: buildOnlyColorBlock(
                                        data is HourlyForecast
                                            ? data.windSpeed
                                            : data is PeriodForecast
                                            ? data.maxWindSpeed
                                            : (data as DailyForecast)
                                                  .windSpeedMax,
                                      ),
                                    ),
                                    buildDetailRowWind(
                                      'Gusts',
                                      null,
                                      valueWidget: buildOnlyColorBlock(
                                        data is HourlyForecast
                                            ? data.windGusts
                                            : data is PeriodForecast
                                            ? data.maxWindGusts
                                            : (data as DailyForecast)
                                                  .windGustsMax,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: GestureDetector(
                        onTap: removeTooltip,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    scheduleTooltipRemoval(showExtendedWindInfo: showExtendedWindInfo);
  }
}
