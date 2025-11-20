import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:temperature_histo_1/models/climate_normal_model.dart';

import '../../models/weather_forecast_model.dart';
import '../utils/chart_constants.dart';
import '../utils/chart_helpers.dart';
import '../utils/chart_data_provider.dart';

/// Builder for daily weather chart
class DailyChartBuilder2 {
  /// Build the daily chart widget
  static Widget build({
    required DailyWeather forecast,
    required List<WeatherDeviation?> deviations,
    required double minTemp,
    required double maxTemp,
    required List<String> dateLabels,
    required Size containerSize,
    bool showWindInfo = true,
  }) {
    return Stack(
      children: [
        // Background rectangles for weekend days
        ..._buildWeekendBackgroundRectangles(forecast, containerSize),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            ChartConstants.leftPadding,
            ChartConstants.topPadding,
            ChartConstants.rightPadding,
            ChartConstants.bottomPadding,
          ),
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (forecast.dailyForecasts.length - 1).toDouble(),
              minY: (minTemp - 6).floorToDouble(),
              maxY: (maxTemp + 6).ceilToDouble(),
              lineBarsData: [
                LineChartBarData(
                  spots: ChartDataProvider.getMaxTempSpots(forecast),
                  isCurved: true,
                  color: Colors.red.shade300,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                          radius: 5,
                          color: Colors.red.shade600,
                          strokeWidth: 3,
                          strokeColor: Colors.white,
                        ),
                  ),
                  belowBarData: BarAreaData(show: false),
                ),
                LineChartBarData(
                  spots: ChartDataProvider.getMinTempSpots(forecast),
                  isCurved: true,
                  color: Colors.blue.shade300,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                          radius: 5,
                          color: Colors.blue.shade600,
                          strokeWidth: 1,
                          strokeColor: Colors.white,
                        ),
                  ),
                  belowBarData: BarAreaData(show: false),
                ),
                LineChartBarData(
                  spots: ChartDataProvider.getNormalMaxSpots(forecast, deviations),
                  isCurved: true,
                  color: Colors.red.shade300,
                  barWidth: 2,
                  dashArray: [5, 5],
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
                LineChartBarData(
                  spots: ChartDataProvider.getNormalMinSpots(forecast, deviations),
                  isCurved: true,
                  color: Colors.blue.shade300,
                  barWidth: 2,
                  dashArray: [5, 5],
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 80,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= dateLabels.length) {
                        return const SizedBox.shrink();
                      }
                      return Transform.rotate(
                        angle: -0.785,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Text(
                            dateLabels[index],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: const Text(
                    'Température (°C)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 5,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.round()}°',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                verticalInterval: 1,
                horizontalInterval: 5,
                getDrawingVerticalLine: (value) {
                  return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
                },
                getDrawingHorizontalLine: (value) {
                  return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
                },
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              backgroundColor: Colors.transparent, // Make background transparent so our rectangles show through
              lineTouchData: LineTouchData(enabled: false),
            ),
          ),
        ),
        ..._buildWeatherIcons(forecast, deviations, minTemp, maxTemp, containerSize),
        ..._buildMinTempLabels(forecast, deviations, minTemp, maxTemp, containerSize),
        if (showWindInfo) ..._buildWindInfo(forecast, minTemp, maxTemp, containerSize),
      ],
    );
  }

  /// Build background rectangles for weekend days (Saturday and Sunday)
  static List<Widget> _buildWeekendBackgroundRectangles(
    DailyWeather forecast,
    Size containerSize,
  ) {
    final List<Widget> rectangles = [];

    // Calculate the width of each day column
    final double chartWidth = containerSize.width -
        ChartConstants.leftPadding -
        ChartConstants.rightPadding -
        ChartConstants.leftTitleReservedSize;
    final double dayWidth = chartWidth / forecast.dailyForecasts.length;

    // Calculate the height of the chart area
    final double chartHeight = containerSize.height -
        ChartConstants.topPadding -
        ChartConstants.bottomPadding -
        ChartConstants.bottomTitleReservedSize;

    for (int i = 0; i < forecast.dailyForecasts.length; i++) {
      final daily = forecast.dailyForecasts[i];
      final bool isWeekend = daily.date.weekday == DateTime.saturday ||
                             daily.date.weekday == DateTime.sunday;

      if (isWeekend) {
        rectangles.add(
          Positioned(
            left: ChartConstants.leftPadding +
                ChartConstants.leftTitleReservedSize +
                (i * dayWidth),
            top: ChartConstants.topPadding,
            child: Container(
              width: dayWidth,
              height: chartHeight,
              color: Colors.lightBlue.shade300.withOpacity(0.3), // Light blue background for weekends
            ),
          ),
        );
      }
    }

    return rectangles;
  }

  /// Build weather icons and max temperature labels
  static List<Widget> _buildWeatherIcons(
    DailyWeather forecast,
    List<WeatherDeviation?> deviations,
    double minTemp,
    double maxTemp,
    Size containerSize,
  ) {
    return forecast.dailyForecasts.asMap().entries.map((entry) {
      final int index = entry.key;
      final DailyForecast daily = entry.value;
      final String? iconPath = ChartHelpers.getIconPathForCode(daily.weatherCode);
      final WeatherDeviation? deviation = index < deviations.length
          ? deviations[index]
          : null;

      if (iconPath == null) return const SizedBox.shrink();

      final screenPos = ChartHelpers.calculateScreenPosition(
        index.toDouble(),
        daily.temperatureMax,
        containerSize,
        minTemp,
        maxTemp,
        forecast.dailyForecasts.length - 1,
        'daily',
      );

      return Positioned(
        left: screenPos.dx - 22.5,
        top: screenPos.dy - 85,
        child: SizedBox(
          width: 45,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(iconPath, width: 45, height: 45),
              const SizedBox(height: 8),
              Text(
                '${daily.temperatureMax.round()}°',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.black87,
                ),
              ),
              if (deviation != null)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: deviation.maxDeviation > 0
                        ? Colors.red.shade50
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    deviation.maxDeviationText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: deviation.maxDeviation > 0
                          ? Colors.red.shade900
                          : Colors.blue.shade900,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  /// Build minimum temperature labels
  static List<Widget> _buildMinTempLabels(
    DailyWeather forecast,
    List<WeatherDeviation?> deviations,
    double minTemp,
    double maxTemp,
    Size containerSize,
  ) {
    return forecast.dailyForecasts.asMap().entries.map((entry) {
      final int index = entry.key;
      final DailyForecast daily = entry.value;
      final WeatherDeviation? deviation = index < deviations.length
          ? deviations[index]
          : null;
      //print("#### CJG index: $index");
      final screenPos = ChartHelpers.calculateScreenPosition(
        index.toDouble(),
        daily.temperatureMin,
        containerSize,
        minTemp,
        maxTemp,
        forecast.dailyForecasts.length - 1,
        'daily',
      );

      return Positioned(
        left: screenPos.dx - 25,
        top: screenPos.dy + 15,
        child: SizedBox(
          width: 50,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${daily.temperatureMin.round()}°',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              if (deviation != null)
                Text(
                  deviation.minDeviationText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: deviation.minDeviation > 0
                        ? Colors.red.shade600
                        : Colors.blue.shade600,
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  /// Build wind direction icons and speed/gusts labels for daily chart
  static List<Widget> _buildWindInfo(
    DailyWeather forecast,
    double minTemp,
    double maxTemp,
    Size containerSize,
  ) {
    return forecast.dailyForecasts.asMap().entries.map((entry) {
      final int index = entry.key;
      final DailyForecast daily = entry.value;

      if (daily.windSpeedMax == null || daily.windGustsMax == null) return const SizedBox.shrink();

      final screenPos = ChartHelpers.calculateScreenPosition(
        index.toDouble(),
        daily.temperatureMax,
        containerSize,
        minTemp,
        maxTemp,
        forecast.dailyForecasts.length - 1,
        'daily',
      );
      final windIconPath = "assets/google_weather_icons/v3/arrow.svg";
      //final windIconPath = "assets/google_weather_icons/v3/arrow_centered_jg.svg";
      final windDirectionDegrees = daily.windDirection10mDominant ?? 0;
      //print("### CJG daily.windGustsMax: ${daily.windGustsMax}");
      print("### CJG windDirectionDegrees: $windDirectionDegrees");


      return Positioned(
        left: screenPos.dx - 100,
        top: screenPos.dy + 5, // Position below temperature
        child: SizedBox(
          width: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Wind direction icon with rotation
              // Arrow SVG points east (90°) by default, so rotate relative to that
              Transform.rotate(
                //angle: (windDirectionDegrees - 90) * (3.14159 / 180), // Convert degrees to radians
                angle: (135 + windDirectionDegrees) * (3.14159 / 180), // Convert degrees to radians
                //angle: (0) * (3.14159 / 180), // Convert degrees to radians
                child: SvgPicture.asset(
                  windIconPath,
                  // width: 50 * daily.windGustsMax! / 20, // Scale size by wind speed (max 20 m/s)
                  // height: 50 * daily.windGustsMax! / 20,
                  width: (daily.windGustsMax ?? 0.0) *2, // Scale size by wind speed (max 20 m/s)
                  height: (daily.windGustsMax ?? 0.0) *2,
                  colorFilter:  ColorFilter.mode(gustColor(daily.windGustsMax ?? 0.0), BlendMode.srcIn),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
