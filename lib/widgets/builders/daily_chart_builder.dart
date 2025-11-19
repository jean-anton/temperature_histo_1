import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:temperature_histo_1/models/climate_normal_model.dart';

import '../../models/weather_forecast_model.dart';
import '../utils/chart_constants.dart';
import '../utils/chart_helpers.dart';
import '../utils/chart_data_provider.dart';

/// Builder for daily weather chart
class DailyChartBuilder {
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
    final List<FlSpot> spotsMAxTemp = ChartDataProvider.getMaxTempSpots(
      forecast,
    );

    final startTime = forecast.dailyForecasts.first.date;
    print(
      "### CJG 192: startTime: $startTime minTemp: $minTemp maxTemp: $maxTemp,${forecast.dailyForecasts.first.temperatureMax} ",
    );
    final minX = startTime.millisecondsSinceEpoch.toDouble();
    final maxX = forecast.dailyForecasts.last.date.millisecondsSinceEpoch
        .toDouble();
    final minY = minTemp - 5;
    final maxY = maxTemp + 5;

    return Stack(
      children: [
        LineChart(
          LineChartData(
            minX: minX,
            maxX: maxX,
            minY: minY,
            maxY: maxY,
            borderData: FlBorderData(
              //show: true,
              border: Border.all(
                color: Colors.grey.shade300,
                width: ChartConstants.borderWidth,
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              verticalInterval: const Duration(
                hours: 1,
              ).inMilliseconds.toDouble(),
              horizontalInterval: 5,
              checkToShowVerticalLine: (value) {
                // Convert the proposed grid line value to DateTime
                final dateTime = DateTime.fromMillisecondsSinceEpoch(
                  value.toInt(),
                );

                // Only show lines at midnight (00:00)
                return dateTime.hour == 0 &&
                    dateTime.minute == 0 &&
                    dateTime.second == 0 &&
                    dateTime.millisecond == 0;
              },

              getDrawingVerticalLine: (value) {
                return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
              },
              getDrawingHorizontalLine: (value) {
                return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
              },
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                axisNameSize: ChartConstants.bottomAxisNameSize,
                //axisNameWidget: const Text('Date'),
                axisNameWidget:  Container(),
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: const Duration(days: 1).inMilliseconds.toDouble(),
                  reservedSize: ChartConstants.bottomAxisTitleSize,
                  getTitlesWidget: (value, meta) {
                    //final dateLabelsIndex = meta.;
                    return Container();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                axisNameSize: ChartConstants.leftAxisNameSize,
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
                  reservedSize: ChartConstants.leftAxisTitleSize,
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
            lineBarsData: [
              LineChartBarData(
                spots: spotsMAxTemp,
                isCurved: true,
                color: Colors.red.shade400, 
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: true),
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
                spots: ChartDataProvider.getNormalMaxSpots(
                  forecast,
                  deviations,
                ),
                isCurved: true,
                color: Colors.red.shade300,
                barWidth: 2,
                dashArray: [5, 5],
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
              ),
              LineChartBarData(
                spots: ChartDataProvider.getNormalMinSpots(
                  forecast,
                  deviations,
                ),
                isCurved: true,
                color: Colors.blue.shade300,
                barWidth: 2,
                dashArray: [5, 5],
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
              ),
            ],
            backgroundColor: Colors
                .transparent, // Make background transparent so our rectangles show through
            lineTouchData: const LineTouchData(enabled: false),
          ),
        ),
        ..._buildWeatherIcons(
          forecast,
          deviations,
          minTemp,
          maxTemp,
          containerSize,
        ),
        ..._buildMinTempLabels(
          forecast,
          deviations,
          minTemp,
          maxTemp,
          containerSize,
        ),
        ..._buildDayLabels(
          forecast,
          minTemp,
          maxTemp,
          containerSize,
          dateLabels,
        ),
        ..._buildWeekendBackgroundRectangles(
          forecast,
          containerSize,
        ),
        if (showWindInfo)
          ..._buildWindInfo(forecast, minTemp, maxTemp, containerSize),
      ],
    );
  }
 static List<Widget> _buildDayLabels(
    DailyWeather forecast,
    double minTemp,
    double maxTemp,
    Size containerSize,
    List<String> hourLabels,
  ) {
    return forecast.dailyForecasts
        .asMap()
        .entries
        .where((entry) => entry.key % 1 == 0) // keep only every 3rd
        .map((entry) {
          final int index = entry.key;
          final DailyForecast hourly = entry.value;
          final String? label =
              hourLabels.isNotEmpty && index < hourLabels.length
              ? hourLabels[index]
              : null;

          if (label == null) return const SizedBox.shrink();

          final screenPos = ChartHelpers.calculateScreenPosition2(
            hourly.date.millisecondsSinceEpoch.toDouble(),
            10,
            containerSize,
            minTemp,
            maxTemp,
            forecast.dailyForecasts.first.date,
            forecast.dailyForecasts.last.date,
          );

          return Positioned(
            left: screenPos.dx - 40, // Center the label
            top:
                containerSize.height -
                ChartConstants.bottomTitleReservedSize +
                30, // Position at bottom
            child: SizedBox(
              width: 80,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
            ),
          );
        })
        .toList();
  }

  /// Build background rectangles for weekend days (Saturday and Sunday)
  static List<Widget> _buildWeekendBackgroundRectangles(
    DailyWeather forecast,
    Size containerSize,
  ) {
    final List<Widget> rectangles = [];

    // Calculate the width of each day column
    final double chartWidth =
        containerSize.width -
        ChartConstants.leftPadding -
        ChartConstants.rightPadding -
        ChartConstants.leftTitleReservedSize;
    final double dayWidth = chartWidth / forecast.dailyForecasts.length;

    // Calculate the height of the chart area
    final double chartHeight =
        containerSize.height -
        ChartConstants.topPadding -
        ChartConstants.bottomPadding -
        ChartConstants.bottomTitleReservedSize;

    for (int i = 0; i < forecast.dailyForecasts.length; i++) {
      final daily = forecast.dailyForecasts[i];
      final bool isWeekend =
          daily.date.weekday == DateTime.saturday ||
          daily.date.weekday == DateTime.sunday;

      if (isWeekend) {
        rectangles.add(
          Positioned(
            left:
                ChartConstants.leftPadding +
                ChartConstants.leftTitleReservedSize +
                (i * dayWidth),
            top: ChartConstants.topPadding,
            child: Container(
              width: dayWidth,
              height: chartHeight,
              color: Colors.lightBlue.shade300.withOpacity(
                0.3,
              ), // Light blue background for weekends
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
      final String? iconPath = ChartHelpers.getIconPathForCode(
        daily.weatherCode,
      );
      final WeatherDeviation? deviation = index < deviations.length
          ? deviations[index]
          : null;

      if (iconPath == null) return const SizedBox.shrink();

      final screenPos = ChartHelpers.calculateScreenPosition2(
        daily.date.millisecondsSinceEpoch.toDouble(),
        daily.temperatureMax,
        containerSize,
        minTemp,
        maxTemp,
        forecast.dailyForecasts.first.date,
        forecast.dailyForecasts.last.date,
      );

      return Positioned(
        left: screenPos.dx - 22.5,
        top: screenPos.dy - 50,
        child: SizedBox(
          width: 55,
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
                  margin: const EdgeInsets.only(top: 0,left: 20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 0,
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
      // final screenPos = ChartHelpers.calculateScreenPosition(
      //   index.toDouble(),
      //   daily.temperatureMax,
      //   containerSize,
      //   minTemp,
      //   maxTemp,
      //   forecast.dailyForecasts.length - 1,
      //   'daily',
      // );

      final screenPos = ChartHelpers.calculateScreenPosition2(
        daily.date.millisecondsSinceEpoch.toDouble(),
        daily.temperatureMin,
        containerSize,
        minTemp,
        maxTemp,
        forecast.dailyForecasts.first.date,
        forecast.dailyForecasts.last.date,
      );

      return Positioned(
        left: screenPos.dx - 25,
        top: screenPos.dy - 25,
        child: SizedBox(
          width: 50,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${daily.temperatureMin.round()}°',
                //'x',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              if (deviation != null)
                SizedBox(height: 4),
              if (deviation != null)
                Container(
                  margin: const EdgeInsets.only(top: 0,left: 20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 0,
                  ),
                  decoration: BoxDecoration(
                    color: deviation.maxDeviation > 0
                        ? Colors.red.shade50
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    deviation.minDeviationText,
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

      if (daily.windSpeedMax == null || daily.windGustsMax == null)
        return const SizedBox.shrink();

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
                angle:
                    (135 + windDirectionDegrees) *
                    (3.14159 / 180), // Convert degrees to radians
                //angle: (0) * (3.14159 / 180), // Convert degrees to radians
                child: SvgPicture.asset(
                  windIconPath,
                  // width: 50 * daily.windGustsMax! / 20, // Scale size by wind speed (max 20 m/s)
                  // height: 50 * daily.windGustsMax! / 20,
                  width:
                      (daily.windGustsMax ?? 0.0) *
                      2, // Scale size by wind speed (max 20 m/s)
                  height: (daily.windGustsMax ?? 0.0) * 2,
                  colorFilter: ColorFilter.mode(
                    gustColor(daily.windGustsMax ?? 0.0),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
