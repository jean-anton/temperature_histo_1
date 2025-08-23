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
    required DailyWeather dailyWeather,
    required double minTemp,
    required double maxTemp,
    required List<String> hourLabels,
    required Size containerSize,
  }) {
    return Stack(
      children: [
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
                          radius: 4,
                          color: Colors.blue.shade900,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.shade50,
                  ),
                ),
                LineChartBarData(
                  spots: ChartDataProvider.getApparentTempSpots(dailyWeather),
                  isCurved: true,
                  color: Colors.purple.shade400,
                  barWidth: 2,
                  dashArray: [5, 5],
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                          radius: 3,
                          color: Colors.purple.shade800,
                        ),
                  ),
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
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
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
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
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
                  return FlLine(
                    color: Colors.grey.shade300,
                    strokeWidth: 1,
                  );
                },
                getDrawingHorizontalLine: (value) {
                  return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
                },
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              backgroundColor: Colors.grey.shade50,
              lineTouchData: LineTouchData(enabled: false),
            ),
          ),
        ),
        ..._buildWeatherIcons(dailyWeather, minTemp, maxTemp, containerSize),
        ..._buildTemperatureLabels(dailyWeather, minTemp, maxTemp, containerSize),
        ..._buildApparentTempLabels(dailyWeather, minTemp, maxTemp, containerSize),
        _buildCurrentTimeLine(dailyWeather, minTemp, maxTemp, containerSize),
      ],
    );
  }

  /// Build a vertical line marking the current time
  static Widget _buildCurrentTimeLine(
    DailyWeather dailyWeather,
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
    );
    
    return Positioned(
      left: screenPos.dx,
      top: ChartConstants.topPadding,
      child: Container(
        width: 2,
        height: containerSize.height - 
            ChartConstants.topPadding - 
            ChartConstants.bottomPadding,
        color: Colors.red.withOpacity(0.7),
      ),
    );
  }

  /// Build weather icons for hourly chart
  static List<Widget> _buildWeatherIcons(
    DailyWeather dailyWeather,
    double minTemp,
    double maxTemp,
    Size containerSize,
  ) {
    return dailyWeather.hourlyForecasts.asMap().entries.map((entry) {
      final int index = entry.key;
      final HourlyForecast hourly = entry.value;
      final String? iconPath = ChartHelpers.getIconPathForCode(hourly.weatherCode);

      if (iconPath == null) return const SizedBox.shrink();

      final screenPos = ChartHelpers.calculateScreenPosition(
        index.toDouble(),
        hourly.temperature ?? 0,
        containerSize,
        minTemp,
        maxTemp,
        dailyWeather.hourlyForecasts.length - 1,
      );

      return Positioned(
        left: screenPos.dx - 15,
        top: screenPos.dy - 45,
        child: SvgPicture.asset(iconPath, width: 30, height: 30),
      );
    }).toList();
  }

  /// Build actual temperature labels
  static List<Widget> _buildTemperatureLabels(
    DailyWeather dailyWeather,
    double minTemp,
    double maxTemp,
    Size containerSize,
  ) {
    return dailyWeather.hourlyForecasts.asMap().entries.map((entry) {
      final int index = entry.key;
      final HourlyForecast hourly = entry.value;

      if (hourly.temperature == null) return const SizedBox.shrink();

      final screenPos = ChartHelpers.calculateScreenPosition(
        index.toDouble(),
        hourly.temperature!,
        containerSize,
        minTemp,
        maxTemp,
        dailyWeather.hourlyForecasts.length - 1,
      );

      return Positioned(
        left: screenPos.dx - 15,
        top: screenPos.dy - 25,
        child: SizedBox(
          width: 30,
          child: Text(
            '${hourly.temperature!.round()}°',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
      );
    }).toList();
  }

  /// Build apparent temperature labels
  static List<Widget> _buildApparentTempLabels(
    DailyWeather dailyWeather,
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
      );

      return Positioned(
        left: screenPos.dx - 15,
        top: screenPos.dy + 5,
        child: SizedBox(
          width: 30,
          child: Text(
            '${hourly.apparentTemperature!.round()}°',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.normal,
              color: Colors.purple,
            ),
          ),
        ),
      );
    }).toList();
  }
}
