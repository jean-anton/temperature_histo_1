import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:temperature_histo_1/features/climate/domain/climate_model.dart';
import 'package:temperature_histo_1/features/weather/domain/weather_model.dart';
//import 'weather_deviation.dart';
import 'chart_helpers.dart';
import 'chart_theme.dart';

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

    _buildTooltip(
      context,
      position,
      formattedDate,
      forecastData,
      deviation: deviation,
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

    Widget? buildColorChar(double? value) {
      if (value == null) return null;
      final color = ChartTheme.windGustColor(value);
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
      final color = ChartTheme.windGustColor(value);
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
                      // Weather Description
                      if (data is DailyForecast && data.weatherCode != null ||
                          data is HourlyForecast && data.weatherCode != null)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
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
                        color: Colors.white.withOpacity(0.3),
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
                                  data.snowfallSum != null &&
                                          data.snowfallSum! > 0
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

                              buildDetailRow(
                                'Vent',
                                null,
                                valueWidget: buildColorChar(
                                  data is DailyForecast
                                      ? data.windSpeedMax
                                      : data is HourlyForecast
                                      ? data.windSpeed
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
                                    : null,
                              ),

                              // Wind Speed
                            ],
                          ),
                          if (showExtendedWindInfo &&
                              data is HourlyForecast) ...[
                            const SizedBox(width: 24),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildDetailRow(
                                  '200m',
                                  null,
                                  valueWidget: buildOnlyColorBlock(
                                    data.windSpeed200m,
                                  ),
                                ),
                                buildDetailRow(
                                  '180m',
                                  null,
                                  valueWidget: buildOnlyColorBlock(
                                    data.windSpeed180m,
                                  ),
                                ),
                                buildDetailRow(
                                  '150m',
                                  null,
                                  valueWidget: buildOnlyColorBlock(
                                    data.windSpeed150m,
                                  ),
                                ),
                                buildDetailRow(
                                  '120m',
                                  null,
                                  valueWidget: buildOnlyColorBlock(
                                    data.windSpeed120m,
                                  ),
                                ),
                                buildDetailRow(
                                  '100m',
                                  null,
                                  valueWidget: buildOnlyColorBlock(
                                    data.windSpeed100m,
                                  ),
                                ),
                                buildDetailRow(
                                  '80m',
                                  null,
                                  valueWidget: buildOnlyColorBlock(
                                    data.windSpeed80m,
                                  ),
                                ),
                                buildDetailRow(
                                  '50m',
                                  null,
                                  valueWidget: buildOnlyColorBlock(
                                    data.windSpeed50m,
                                  ),
                                ),
                                buildDetailRow(
                                  '20m',
                                  null,
                                  valueWidget: buildOnlyColorBlock(
                                    data.windSpeed20m,
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
}
