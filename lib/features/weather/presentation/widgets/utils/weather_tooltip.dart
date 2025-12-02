import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:temperature_histo_1/features/climate/domain/climate_model.dart';
import 'package:temperature_histo_1/features/weather/domain/weather_model.dart';
//import 'weather_deviation.dart';
import 'chart_helpers.dart';

/// Widget for displaying weather tooltips
class WeatherTooltip {
  static OverlayEntry? _overlayEntry;
  static Timer? _tooltipTimer;

  /// Show tooltip for daily weather data
  static void showDailyTooltip(
    BuildContext context,
    int touchedIndex,
    Offset position,
    DailyWeather forecast,
    List<WeatherDeviation?> deviations,
  ) {
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

    _buildTooltip(context, position, formattedDate, forecastData, deviation);
  }

  /// Show tooltip for hourly weather data
  static void showHourlyTooltip(
    BuildContext context,
    int touchedIndex,
    Offset position,
    HourlyWeather dailyWeather,
  ) {
    if (touchedIndex < 0 || touchedIndex >= dailyWeather.hourlyForecasts.length) {
      return;
    }

    final hourly = dailyWeather.hourlyForecasts[touchedIndex];
    final String formattedDate = DateFormat(
      'EEEE, d MMMM HH:mm',
      'fr_FR',
    ).format(hourly.time);

    _buildTooltip(context, position, formattedDate, hourly);
  }

  /// Build the tooltip widget
  static void _buildTooltip(
    BuildContext context,
    Offset position,
    String formattedDate,
    dynamic data, // DailyForecast or HourlyForecast
    [WeatherDeviation? deviation,]
  ) {
    Widget buildDetailRow(String label, String? value, {Color? valueColor}) {
      if (value == null || value.isEmpty) {
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
            Flexible(
              child: Text(
                value,
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
      builder: (context) => Positioned(
        left: tooltipLeft,
        top: tooltipTop,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(maxHeight: 290),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blueGrey.shade800.withOpacity(0.95),
                  Colors.blueGrey.shade900.withOpacity(0.95),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
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
                      if (data is DailyForecast && data.weatherCode != null ||
                          data is HourlyForecast && data.weatherCode != null)
                        Text(
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
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        height: 1,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      // Temperature Details
                      if (data is DailyForecast) ...[
                        buildDetailRow(
                          'Temp. max.',
                          '${data.temperatureMax?.toStringAsFixed(1)}°C ${deviation != null ? '(${deviation.maxDeviationText ?? ''})' : ''}',
                          valueColor: (deviation?.maxDeviation ?? 0) > 0
                              ? Colors.redAccent.shade100
                              : Colors.lightBlueAccent.shade100,
                        ),
                        buildDetailRow(
                          'Temp. min.',
                          '${data.temperatureMin?.toStringAsFixed(1)}°C ${deviation != null ? '(${deviation.minDeviationText ?? ''})' : ''}',
                          valueColor: (deviation?.minDeviation ?? 0) > 0
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
                            ? data.precipitationProbabilityMax != null
                                  ? '${data.precipitationProbabilityMax}%'
                                  : null
                            : data is HourlyForecast
                            ? data.precipitationProbability != null
                                  ? '${data.precipitationProbability}%'
                                  : null
                            : null,
                      ),
                      // Snowfall Sum (DailyForecast only)
                      if (data is DailyForecast)
                        buildDetailRow(
                          'Chute de neige',
                          data.snowfallSum != null && data.snowfallSum! > 0
                              ? '${data.snowfallSum?.toStringAsFixed(1)} cm'
                              : null,
                        ),
                      // Cloud Cover
                      buildDetailRow(
                        'Couverture nuageuse',
                        data is DailyForecast
                            ? data.cloudCoverMean != null
                                  ? '${data.cloudCoverMean}%'
                                  : null
                            : data is HourlyForecast
                            ? data.cloudCover != null
                                  ? '${data.cloudCover}%'
                                  : null
                            : null,
                      ),
                      // Wind Speed
                      buildDetailRow(
                        'Vent',
                        data is DailyForecast
                            ? data.windSpeedMax != null
                                  ? '${data.windSpeedMax?.toStringAsFixed(1)} km/h'
                                  : null
                            : data is HourlyForecast
                            ? data.windSpeed != null
                                  ? '${data.windSpeed?.toStringAsFixed(1)} km/h'
                                  : null
                            : null,
                      ),
                      // Wind Gusts
                      buildDetailRow(
                        'Rafales',
                        data is DailyForecast
                            ? data.windGustsMax != null
                                  ? '${data.windGustsMax?.toStringAsFixed(1)} km/h'
                                  : null
                            : data is HourlyForecast
                            ? data.windGusts != null
                                  ? '${data.windGusts?.toStringAsFixed(1)} km/h'
                                  : null
                            : null,
                      ),
                      // Wind Direction
                      buildDetailRow(
                        'Direction vent',
                        data is DailyForecast
                            ? data.windDirection10mDominant != null
                                  ? ChartHelpers.getWindDirectionAbbrev(data.windDirection10mDominant)
                                  : null
                            : data is HourlyForecast
                            ? data.windDirection10m != null
                                  ? ChartHelpers.getWindDirectionAbbrev(data.windDirection10m) + ' (${data.windDirection10m}°)'
                                  : null
                            : null,
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
                        color: Colors.white.withOpacity(0.2),
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
    );

    Overlay.of(context).insert(_overlayEntry!);
    scheduleTooltipRemoval();
  }

  /// Remove the current tooltip
  static void removeTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _tooltipTimer?.cancel();
  }

  /// Schedule tooltip removal after delay
  static void scheduleTooltipRemoval() {
    _tooltipTimer = Timer(const Duration(seconds: 10), () {
      removeTooltip();
    });
  }

  /// Cancel scheduled tooltip removal
  static void cancelTooltipRemoval() {
    _tooltipTimer?.cancel();
  }
}
