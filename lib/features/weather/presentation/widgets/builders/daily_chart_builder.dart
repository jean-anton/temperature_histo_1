import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:temperature_histo_1/features/climate/domain/climate_model.dart';
import 'package:temperature_histo_1/features/weather/domain/weather_model.dart';
import '../utils/chart_constants.dart';
import '../utils/chart_helpers.dart';
import '../utils/chart_data_provider.dart';
import '../utils/chart_theme.dart';
import '../utils/chart_positioning.dart';
import '../common/wind_indicator.dart';

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

    final minX = startTime.millisecondsSinceEpoch.toDouble();
    final maxX = forecast.dailyForecasts.last.date
      //  .add(const Duration(days: 1))
        .millisecondsSinceEpoch
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
                color: ChartTheme.borderColor,
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
                return FlLine(color: ChartTheme.gridLineColor, strokeWidth: 1);
              },
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: ChartTheme.gridLineColorLight,
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                axisNameSize: ChartConstants.bottomAxisNameSize,
                //axisNameWidget: const Text('Date'),
                axisNameWidget: Container(),
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
                  style: ChartTheme.axisTitleStyle,
                ),
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: ChartConstants.leftAxisTitleSize,
                  interval: 5,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.round()}°',
                      style: ChartTheme.axisLabelStyle,
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
                color: ChartTheme.temperatureMaxLineColor,
                barWidth: ChartTheme.chartLineWidth,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: true),
              ),

              LineChartBarData(
                spots: ChartDataProvider.getMinTempSpots(forecast),
                isCurved: true,
                color: ChartTheme.temperatureMinLineColor,
                barWidth: ChartTheme.chartLineWidth,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                        radius: ChartTheme.chartDotRadius,
                        color: ChartTheme.temperatureMinDotColor,
                        strokeWidth: ChartTheme.chartDotStrokeWidth,
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
                color: ChartTheme.normalMaxLineColor,
                barWidth: ChartTheme.normalLineWidth,
                dashArray: [
                  ChartTheme.normalLineDashPattern,
                  ChartTheme.normalLineDashPattern,
                ],
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
              ),
              LineChartBarData(
                spots: ChartDataProvider.getNormalMinSpots(
                  forecast,
                  deviations,
                ),
                isCurved: true,
                color: ChartTheme.normalMinLineColor,
                barWidth: ChartTheme.normalLineWidth,
                dashArray: [
                  ChartTheme.normalLineDashPattern,
                  ChartTheme.normalLineDashPattern,
                ],
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
        ..._buildWeekendBackgroundRectangles(forecast, containerSize),
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

          final screenPos = ChartPositioning.calculatePosition(
            timeMs: hourly.date.millisecondsSinceEpoch.toDouble(),
            value: 10,
            containerSize: containerSize,
            minValue: minTemp,
            maxValue: maxTemp,
            startTime: forecast.dailyForecasts.first.date,
            endTime: forecast.dailyForecasts.last.date,
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
                style: ChartTheme.dateLabelStyle,
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

    // Get the first and last dates for proper positioning
    final DateTime firstDate = forecast.dailyForecasts.first.date;
    final DateTime lastDate = forecast.dailyForecasts.last.date;

    for (int i = 0; i < forecast.dailyForecasts.length; i++) {
      final daily = forecast.dailyForecasts[i];
      final bool isWeekend =
          daily.date.weekday == DateTime.saturday ||
          daily.date.weekday == DateTime.sunday;

      if (isWeekend) {
        // Use calculateScreenPosition2 to get accurate positioning
        // We'll position at minY and maxY to span the full height
        final screenPosLeft = ChartPositioning.calculatePosition(
          timeMs: daily.date
              .subtract(Duration(hours: 12))
              .millisecondsSinceEpoch
              .toDouble(),
          value: 0,
          containerSize: containerSize,
          minValue: 0,
          maxValue: 100,
          startTime: firstDate,
          endTime: lastDate,
        );

        // Calculate the position for the next day to determine width
        final DateTime nextDate = i < forecast.dailyForecasts.length - 1
            ? forecast.dailyForecasts[i + 1].date
            : daily.date.add(const Duration(days: 1));

        final screenPosRight = ChartPositioning.calculatePosition(
          timeMs: nextDate
              .subtract(Duration(hours: 12))
              .millisecondsSinceEpoch
              .toDouble(),
          value: 0,
          containerSize: containerSize,
          minValue: 0,
          maxValue: 100,
          startTime: firstDate,
          endTime: lastDate,
        );

        // Calculate width based on the difference between positions
        final double dayWidth = screenPosRight.dx - screenPosLeft.dx;

        rectangles.add(
          Positioned(
            left: screenPosLeft.dx,
            top: ChartConstants.topPadding,
            child: Container(
              width: dayWidth,
              height:
                  containerSize.height -
                  ChartConstants.topPadding -
                  ChartConstants.bottomPadding,
              color: ChartTheme.weekendBackgroundColor,
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
      // Use daytime weathercode if available, fallback to original
      final weatherCodeToUse = daily.weatherCodeDaytime ?? daily.weatherCode;
      final String? iconPath = ChartHelpers.getIconPath(
        code: weatherCodeToUse,
        iconName: daily.weatherIcon,
      );
      final WeatherDeviation? deviation = index < deviations.length
          ? deviations[index]
          : null;

      if (iconPath == null) return const SizedBox.shrink();

      final screenPos = ChartPositioning.calculatePosition(
        timeMs: daily.date.millisecondsSinceEpoch.toDouble(),
        value: daily.temperatureMax,
        containerSize: containerSize,
        minValue: minTemp,
        maxValue: maxTemp,
        startTime: forecast.dailyForecasts.first.date,
        endTime: forecast.dailyForecasts.last.date,
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
                style: ChartTheme.temperatureMaxLabelStyle,
              ),
              if (deviation != null)
                Container(
                  margin: const EdgeInsets.only(
                    top: ChartTheme.deviationTopMargin,
                    left: ChartTheme.deviationLeftMargin,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: ChartTheme.deviationPaddingHorizontal,
                    vertical: ChartTheme.deviationPaddingVertical,
                  ),
                  decoration: BoxDecoration(
                    color: deviation.maxDeviation > 0
                        ? ChartTheme.deviationWarmBackground
                        : ChartTheme.deviationCoolBackground,
                    borderRadius: BorderRadius.circular(
                      ChartTheme.deviationBorderRadius,
                    ),
                  ),
                  child: Text(
                    deviation.maxDeviationText,
                    style: ChartTheme.deviationLabelStyle.copyWith(
                      color: deviation.maxDeviation > 0
                          ? ChartTheme.deviationWarmText
                          : ChartTheme.deviationCoolText,
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

      final screenPos = ChartPositioning.calculatePosition(
        timeMs: daily.date.millisecondsSinceEpoch.toDouble(),
        value: daily.temperatureMin,
        containerSize: containerSize,
        minValue: minTemp,
        maxValue: maxTemp,
        startTime: forecast.dailyForecasts.first.date,
        endTime: forecast.dailyForecasts.last.date,
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
                style: ChartTheme.temperatureMinLabelStyle,
              ),
              if (deviation != null) SizedBox(height: 4),
              if (deviation != null)
                Container(
                  margin: const EdgeInsets.only(top: 0, left: 20),
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

      if (daily.windSpeedMax == null || daily.windGustsMax == null) {
        return const SizedBox.shrink();
      }

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
        left: screenPos.dx - ChartTheme.windInfoContainerOffset,
        top: screenPos.dy + 5,
        child: WindIndicator(
          windSpeed: daily.windSpeedMax!,
          windGusts: daily.windGustsMax,
          windDirection: daily.windDirection10mDominant ?? 0,
        ),
      );
    }).toList();
  }
}
