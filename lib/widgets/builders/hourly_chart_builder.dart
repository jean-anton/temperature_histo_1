import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/weather_forecast_model.dart';
import '../utils/chart_constants.dart';
import '../utils/chart_helpers.dart';
import '../utils/chart_data_provider.dart';

/// Builder for hourly weather chart
class HourlyChartBuilder {
  /// Build the hourly chart widget
  static Widget build({
    required HourlyWeather dailyWeather,
    required double minTemp,
    required double maxTemp,
    required List<String> hourLabels,
    required Size containerSize,
    bool showWindInfo = true,
  }) {
    
    return Stack(
      children: [
        // Background rectangles for day/night hours
        ..._buildBackgroundRectangles(dailyWeather, containerSize),
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
              maxX: (dailyWeather.hourlyForecasts.length - 1).toDouble(),
              minY: (minTemp - 2).floorToDouble(),
              maxY: (maxTemp + 2).ceilToDouble(),
              lineBarsData: [
                LineChartBarData(
                  spots: ChartDataProvider.getHourlyTempSpots(dailyWeather),
                  isCurved: true,
                  color: Colors.blue.shade700,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                          radius: 5,
                          color: Colors.blue.shade900,
                          strokeWidth: 3,
                          strokeColor: Colors.white,
                        ),
                  ),
                  belowBarData: BarAreaData(show: false),
                ),
                LineChartBarData(
                  spots: ChartDataProvider.getApparentTempSpots(dailyWeather),
                  isCurved: true,
                  color: Colors.purple.shade400,
                  barWidth: 2,
                  dashArray: [5, 5],
                  dotData: const FlDotData(show: false),
                ),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 2, // Display label every 2 hours
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= hourLabels.length) {
                        return const SizedBox.shrink();
                      }
                      return Transform.rotate(
                        angle: -0.0,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            hourLabels[index],
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
                    interval: 2,
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
                horizontalInterval: 2,
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
        ..._buildWeatherIcons(dailyWeather, minTemp, maxTemp, containerSize),
        ..._buildApparentTempLabels(
          dailyWeather,
          minTemp,
          maxTemp,
          containerSize,
        ),
        if (showWindInfo) ..._buildWindInfo(dailyWeather, minTemp, maxTemp, containerSize),
        _buildCurrentTimeLine(dailyWeather, minTemp, maxTemp, containerSize),
      ],
    );
  }

  /// Build background rectangles for day/night hours
  static List<Widget> _buildBackgroundRectangles(
    HourlyWeather dailyWeather,
    Size containerSize,
  ) {
    final List<Widget> rectangles = [];

    // Calculate the width of each hour column
    final double chartWidth = containerSize.width -
        ChartConstants.leftPadding -
        ChartConstants.rightPadding -
        ChartConstants.leftTitleReservedSize;
    final double hourWidth = chartWidth / dailyWeather.hourlyForecasts.length;

    // Calculate the height of the chart area
    final double chartHeight = containerSize.height -
        ChartConstants.topPadding -
        ChartConstants.bottomPadding -
        ChartConstants.bottomTitleReservedSize;

    for (int i = 0; i < dailyWeather.hourlyForecasts.length; i++) {
      final hourly = dailyWeather.hourlyForecasts[i];
      final bool isNight = hourly.isDay == 0;

      // Choose background color based on day/night
      final Color backgroundColor = isNight
          ? const Color.fromARGB(255, 104, 147, 168).withOpacity(0.3) // Light blue-grey for night
          : Colors.grey.shade50.withOpacity(0.5); // Light grey for day

      rectangles.add(
        Positioned(
          left: ChartConstants.leftPadding +
              ChartConstants.leftTitleReservedSize +
              (i * hourWidth),
          top: ChartConstants.topPadding,
          child: Container(
            width: hourWidth,
            height: chartHeight,
            color: backgroundColor,
          ),
        ),
      );
    }

    return rectangles;
  }

  /// Build a vertical line marking the current time
  static Widget _buildCurrentTimeLine(
    HourlyWeather dailyWeather,
    double minTemp,
    double maxTemp,
    Size containerSize,
  ) {
    // Find the index of the current time in the hourly forecasts
    final now = DateTime.now();
    int currentIndex = -1;
    Duration smallestDifference = Duration(days: 1);

    for (int i = 0; i < dailyWeather.hourlyForecasts.length; i++) {
      final forecastTime = dailyWeather.hourlyForecasts[i].time;
      final difference = forecastTime.difference(now).abs();

      if (difference < smallestDifference) {
        smallestDifference = difference;
        currentIndex = i;
      }
    }

    // If we couldn't find a current time index, don't show the line
    if (currentIndex == -1) {
      return const SizedBox.shrink();
    }

    // Calculate the position of the vertical line
    final screenPos = ChartHelpers.calculateScreenPosition(
      currentIndex.toDouble(),
      minTemp,
      containerSize,
      minTemp,
      maxTemp,
      dailyWeather.hourlyForecasts.length - 1,
      'hourly',
    );

    return Positioned(
      left: screenPos.dx,
      top: ChartConstants.topPadding,
      child: Container(
        width: 2,
        height:
            containerSize.height -
            ChartConstants.topPadding -
            ChartConstants.bottomPadding,
        color: Colors.red.withOpacity(0.7),
      ),
    );
  }

  /// Build weather icons for hourly chart
  static List<Widget> _buildWeatherIcons(
    HourlyWeather dailyWeather,
    double minTemp,
    double maxTemp,
    Size containerSize,
  ) {
    return dailyWeather.hourlyForecasts.asMap().entries.map((entry) {
      final int index = entry.key;
      final HourlyForecast hourly = entry.value;
      final String? iconPath = ChartHelpers.getIconPathForCode(
        hourly.weatherCode,
        isDay: hourly.isDay,
      );

      if (iconPath == null) return const SizedBox.shrink();

      final screenPos = ChartHelpers.calculateScreenPosition(
        index.toDouble(),
        hourly.temperature ?? 0,
        containerSize,
        minTemp,
        maxTemp,
        dailyWeather.hourlyForecasts.length - 1,
        'hourly',
      );
      //print("### CJG 291: iconPath: $iconPath, isDay: ${hourly.isDay}");

      return Positioned(
        left: screenPos.dx - 22.5,
        top: screenPos.dy - 65,
        child: SizedBox(
          width: 45,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(iconPath, width: 45, height: 45),
              const SizedBox(height: 4),
              Text(
                '${hourly.temperature!.round()}°',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }



  /// Build apparent temperature labels
  static List<Widget> _buildApparentTempLabels(
    HourlyWeather dailyWeather,
    double minTemp,
    double maxTemp,
    Size containerSize,
  ) {
    return dailyWeather.hourlyForecasts.asMap().entries.map((entry) {
      final int index = entry.key;
      final HourlyForecast hourly = entry.value;

      if (hourly.apparentTemperature == null) return const SizedBox.shrink();

      final screenPos = ChartHelpers.calculateScreenPosition(
        index.toDouble(),
        hourly.apparentTemperature!,
        containerSize,
        minTemp,
        maxTemp,
        dailyWeather.hourlyForecasts.length - 1,
        'hourly',
      );

      return Positioned(
        left: screenPos.dx - 25,
        top: screenPos.dy + 15,
        child: SizedBox(
          width: 50,
          child: Text(
            '${hourly.apparentTemperature!.round()}°',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.purple,
            ),
          ),
        ),
      );
    }).toList();
  }

  /// Build wind direction icons and speed/gusts labels for hourly chart
  static List<Widget> _buildWindInfo(
    HourlyWeather dailyWeather,
    double minTemp,
    double maxTemp,
    Size containerSize,
  ) {
    return dailyWeather.hourlyForecasts.asMap().entries.map((entry) {
      final int index = entry.key;
      final HourlyForecast hourly = entry.value;

      if (hourly.windSpeed == null) return const SizedBox.shrink();

      final screenPos = ChartHelpers.calculateScreenPosition(
        index.toDouble(),
        hourly.temperature ?? 0,
        containerSize,
        minTemp,
        maxTemp,
        dailyWeather.hourlyForecasts.length - 1,
        'hourly',
      );

      //final windIconPath = ChartHelpers.getWindDirectionIconPath(hourly.windDirection10m);
      final windIconPath = "assets/google_weather_icons/v3/arrow.svg";
      //final windIconPath = "assets/google_weather_icons/v3/arrow_centered_jg.svg";
      final windDirectionDegrees = hourly.windDirection10m ?? 0;

      return Positioned(
        left: screenPos.dx - 30,
        top: screenPos.dy + 45, // Position below temperature
        child: SizedBox(
          width: 60,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Wind direction icon with rotation
              // Arrow SVG points east (90°) by default, so rotate relative to that
              Transform.rotate(
                //angle: (windDirectionDegrees - 90) * (3.14159 / 180), // Convert degrees to radians
                angle: (135 + windDirectionDegrees) * (3.14159 / 180), // Convert degrees to radians
                child: SvgPicture.asset(
                  windIconPath,
                  width: 50 * (hourly.windGusts ?? 0.0) / 20, // Scale size by wind speed (max 20 m/s)
                  height: 50 * (hourly.windGusts ?? 0.0) / 20,
                  colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
