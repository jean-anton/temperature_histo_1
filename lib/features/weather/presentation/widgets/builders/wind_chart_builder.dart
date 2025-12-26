import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:temperature_histo_1/features/weather/domain/weather_model.dart';
import 'package:temperature_histo_1/features/weather/presentation/widgets/utils/chart_positioning.dart';
import 'package:temperature_histo_1/features/weather/presentation/widgets/utils/chart_constants.dart';
import 'package:temperature_histo_1/features/weather/presentation/widgets/utils/chart_theme.dart';

class WindChartBuilder {
  static Widget build({
    required HourlyWeather hourlyWeather,
    required DailyWeather forecast,
    required Size containerSize,
    required String displayMode, // 'daily' or 'hourly'
    required DateTime startTime,
    required DateTime endTime,
    required List<String> labels,
    required double minY,
    required double maxY,
  }) {
    return Stack(
      children: [
        _buildBackgroundGrid(
          containerSize,
          hourlyWeather,
          forecast,
          startTime,
          endTime,
          displayMode,
          minY,
          maxY,
        ),
        ..._buildNight(hourlyWeather, forecast, minY, maxY, containerSize),
        _buildHeatmap(
          containerSize,
          hourlyWeather,
          startTime,
          endTime,
          minY,
          maxY,
        ),
        _buildSeparationLine(containerSize, startTime, endTime, minY, maxY),
        _buildXAxisLabels(
          containerSize,
          hourlyWeather,
          startTime,
          endTime,
          labels,
          displayMode,
          minY,
          maxY,
        ),
        _buildAltitudes(containerSize, startTime, endTime, minY, maxY),
        _buildLegend(containerSize),
      ],
    );
  }

  static Widget _buildBackgroundGrid(
    Size containerSize,
    HourlyWeather hourlyWeather,
    DailyWeather forecast,
    DateTime chartStartTime,
    DateTime chartEndTime,
    String displayMode,
    double minY,
    double maxY,
  ) {
    return
    // LineChart(
    //   LineChartData(
    //     minX: chartStartTime.millisecondsSinceEpoch.toDouble(),
    //     maxX: chartEndTime.millisecondsSinceEpoch.toDouble(),
    //     minY: minY,
    //     maxY: maxY,
    //     borderData: FlBorderData(
    //       border: Border.all(
    //         color: ChartTheme.borderColor,
    //         width: ChartConstants.borderWidth,
    //       ),
    //     ),
    //     gridData: FlGridData(
    //       show: true,
    //       drawVerticalLine: true,
    //       verticalInterval: displayMode == 'daily'
    //           ? const Duration(days: 1).inMilliseconds.toDouble()
    //           : const Duration(hours: 1).inMilliseconds.toDouble(),
    //       getDrawingVerticalLine: (value) {
    //         final dateTime = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    //         final isMidnight = dateTime.hour == 0 && dateTime.minute == 0;
    //         return FlLine(
    //           color: isMidnight
    //               ? Colors.grey.shade500
    //               : ChartTheme.gridLineColorLight,
    //           strokeWidth: isMidnight ? 1.0 : 0.5,
    //         );
    //       },
    //       drawHorizontalLine: false,
    //     ),
    //     titlesData: const FlTitlesData(
    //       leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    //       bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    //       topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    //       rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    //     ),
    //     lineBarsData: [],
    //   ),
    // );
    LineChart(
      LineChartData(
        minX: chartStartTime.millisecondsSinceEpoch.toDouble(),
        maxX: chartEndTime.millisecondsSinceEpoch.toDouble(),
        minY: minY,
        maxY: maxY,
        borderData: FlBorderData(
          border: Border.all(
            color: ChartTheme.borderColor,
            width: ChartConstants.borderWidth,
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          verticalInterval: const Duration(hours: 1).inMilliseconds.toDouble(),
          getDrawingVerticalLine: (value) =>
              FlLine(color: ChartTheme.gridLineColor, strokeWidth: 0.5),
          drawHorizontalLine: true,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: ChartTheme.gridLineColorLight, strokeWidth: 0.5),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            axisNameSize: ChartConstants.bottomAxisNameSize,
            //axisNameWidget: const Text('Hour'),
            axisNameWidget: Container(),
            sideTitles: SideTitles(
              showTitles:
                  true, // Hide default fl_chart labels - using custom labels instead
              interval: const Duration(hours: 2).inMilliseconds.toDouble(),
              reservedSize: ChartConstants.bottomAxisTitleSize,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            axisNameSize: ChartConstants.leftAxisNameSize,
            axisNameWidget: const Text('°C'),
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20,
              reservedSize: ChartConstants.leftAxisTitleSize,
              getTitlesWidget: (value, meta) => const SizedBox.shrink(),
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        lineBarsData: [],
        backgroundColor: Colors.transparent,
        lineTouchData: const LineTouchData(enabled: false),
      ),
    );
  }

  static Widget _buildSeparationLine(
    Size containerSize,
    DateTime startTime,
    DateTime endTime,
    double minY,
    double maxY,
  ) {
    final pos = ChartPositioning.calculatePosition(
      timeMs: startTime.millisecondsSinceEpoch.toDouble(),
      value: 10.0,
      containerSize: containerSize,
      minValue: minY,
      maxValue: maxY,
      startTime: startTime,
      endTime: endTime,
    );

    return Positioned(
      left: ChartConstants.leftPadding + ChartConstants.leftTitleReservedSize,
      right: ChartConstants.rightPadding,
      top: pos.dy - 1.0,
      child: Container(height: 2.0, color: Colors.black),
    );
  }

  static List<Widget> _buildNight(
    HourlyWeather hourlyWeather,
    DailyWeather forecast,
    double minY,
    double maxY,
    Size containerSize,
  ) {
    List<Widget> nightWidgets = [];
    final startTime = hourlyWeather.hourlyForecasts.first.time;
    final endTime = hourlyWeather.hourlyForecasts.last.time;

    for (var daily in forecast.dailyForecasts) {
      if (daily.sunset != null && daily.sunrise != null) {
        DateTime sunset = daily.sunset!;
        DateTime nextSunrise = daily.sunrise!.add(const Duration(days: 1));

        if (sunset.isBefore(endTime) && nextSunrise.isAfter(startTime)) {
          final posStart = ChartPositioning.calculatePosition(
            timeMs: sunset.millisecondsSinceEpoch.toDouble(),
            value: maxY,
            containerSize: containerSize,
            minValue: minY,
            maxValue: maxY,
            startTime: startTime,
            endTime: endTime,
          );
          final posEnd = ChartPositioning.calculatePosition(
            timeMs: nextSunrise.millisecondsSinceEpoch.toDouble(),
            value: maxY,
            containerSize: containerSize,
            minValue: minY,
            maxValue: maxY,
            startTime: startTime,
            endTime: endTime,
          );

          final left = posStart.dx;
          final width = (posEnd.dx - posStart.dx)
              .clamp(0.0, containerSize.width)
              .toDouble();

          if (width > 0) {
            nightWidgets.add(
              Positioned(
                left: left,
                top: ChartConstants.topPadding,
                width: width,
                height:
                    containerSize.height -
                    ChartConstants.topPadding -
                    ChartConstants.bottomPadding,
                child: Container(color: ChartTheme.nightBackgroundColor),
              ),
            );
          }
        }
      }
    }
    return nightWidgets;
  }

  static Widget _buildHeatmap(
    Size containerSize,
    HourlyWeather hourlyWeather,
    DateTime chartStartTime,
    DateTime chartEndTime,
    double minY,
    double maxY,
  ) {
    final List<Widget> segments = [];
    final List<double> altitudes = [
      -20.0,
      10.0,
      20.0,
      50.0,
      80.0,
      100.0,
      120.0,
      150.0,
      180.0,
      200.0,
    ];

    final forecasts = hourlyWeather.hourlyForecasts;

    final posT0 = ChartPositioning.calculatePosition(
      timeMs: forecasts.first.time.millisecondsSinceEpoch.toDouble(),
      value: 0.0,
      containerSize: containerSize,
      minValue: minY,
      maxValue: maxY,
      startTime: chartStartTime,
      endTime: chartEndTime,
    );
    final posT1 = ChartPositioning.calculatePosition(
      timeMs: forecasts.first.time
          .add(const Duration(hours: 1))
          .millisecondsSinceEpoch
          .toDouble(),
      value: 0.0,
      containerSize: containerSize,
      minValue: minY,
      maxValue: maxY,
      startTime: chartStartTime,
      endTime: chartEndTime,
    );
    final double hourWidth = posT1.dx - posT0.dx;

    for (int i = 0; i < forecasts.length; i++) {
      final f = forecasts[i];
      final tPos = ChartPositioning.calculatePosition(
        timeMs: f.time.millisecondsSinceEpoch.toDouble(),
        value: 0.0,
        containerSize: containerSize,
        minValue: minY,
        maxValue: maxY,
        startTime: chartStartTime,
        endTime: chartEndTime,
      );

      for (int j = 0; j < altitudes.length - 1; j++) {
        final altBottom = altitudes[j];
        final altTop = altitudes[j + 1];

        final windSpeed = _getWindSpeedForRange(f, altBottom, altTop);
        if (windSpeed == null) continue;

        final posBottom = ChartPositioning.calculatePosition(
          timeMs: f.time.millisecondsSinceEpoch.toDouble(),
          value: altBottom,
          containerSize: containerSize,
          minValue: minY,
          maxValue: maxY,
          startTime: chartStartTime,
          endTime: chartEndTime,
        );
        final posTop = ChartPositioning.calculatePosition(
          timeMs: f.time.millisecondsSinceEpoch.toDouble(),
          value: altTop,
          containerSize: containerSize,
          minValue: minY,
          maxValue: maxY,
          startTime: chartStartTime,
          endTime: chartEndTime,
        );

        final segmentHeight = (posBottom.dy - posTop.dy).abs();

        segments.add(
          Positioned(
            left: tPos.dx,
            top: posTop.dy,
            width: hourWidth,
            height: segmentHeight,
            child: Stack(
              children: [
                Text(
                  //'x',
                  f.time.hour.toString(),
                  style: ChartTheme.hourLabelStyle,
                  //textAlign: TextAlign.center,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: ChartTheme.windGustColor(windSpeed),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                      width: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return Stack(children: segments);
  }

  static double? _getWindSpeedForRange(
    HourlyForecast forecast,
    double bottom,
    double top,
  ) {
    if (bottom == -20.0 && top == 10.0) {
      return forecast.windGusts ?? forecast.windSpeed;
    }

    // Try to get exactly the top altitude
    double? speed = _getWindSpeedAtAltitude(forecast, top);
    if (speed != null) return speed;

    // Fallback: Find the nearest available altitude data to fill the gap
    final alts = [200.0, 180.0, 150.0, 120.0, 100.0, 80.0, 50.0, 20.0, 10.0];
    double minDiff = double.infinity;
    double? bestVal;

    for (var alt in alts) {
      double? val = _getWindSpeedAtAltitude(forecast, alt);
      if (val != null) {
        double diff = (alt - top).abs();
        if (diff < minDiff) {
          minDiff = diff;
          bestVal = val;
        }
      }
    }
    return bestVal;
  }

  static double? _getWindSpeedAtAltitude(
    HourlyForecast forecast,
    double altitude,
  ) {
    if (altitude == 10.0) return forecast.windSpeed;
    if (altitude == 20.0) return forecast.windSpeed20m;
    if (altitude == 50.0) return forecast.windSpeed50m;
    if (altitude == 80.0) return forecast.windSpeed80m;
    if (altitude == 100.0) return forecast.windSpeed100m;
    if (altitude == 120.0) return forecast.windSpeed120m;
    if (altitude == 150.0) return forecast.windSpeed150m;
    if (altitude == 180.0) return forecast.windSpeed180m;
    if (altitude == 200.0) return forecast.windSpeed200m;
    return null;
  }

  static Widget _buildXAxisLabels(
    Size containerSize,
    HourlyWeather hourlyWeather,
    DateTime chartStartTime,
    DateTime chartEndTime,
    List<String> labels,
    String displayMode,
    double minY,
    double maxY,
  ) {
    final forecasts = hourlyWeather.hourlyForecasts;

    if (displayMode == 'daily') {
      final List<Widget> dailyLabels = [];
      int labelIndex = 0;
      for (int i = 0; i < forecasts.length; i++) {
        final f = forecasts[i];
        if ((f.time.hour == 0 && f.time.minute == 0) || i == 0) {
          if (labelIndex < labels.length) {
            final pos = ChartPositioning.calculatePosition(
              timeMs: f.time.millisecondsSinceEpoch.toDouble(),
              value: 0,
              containerSize: containerSize,
              minValue: minY,
              maxValue: maxY,
              startTime: chartStartTime,
              endTime: chartEndTime,
            );

            dailyLabels.add(
              Positioned(
                left: pos.dx - 40,
                top:
                    containerSize.height -
                    ChartConstants.bottomTitleReservedSize +
                    30,
                child: SizedBox(
                  width: 80,
                  child: Text(
                    labels[labelIndex],
                    textAlign: TextAlign.center,
                    style: ChartTheme.dateLabelStyle,
                  ),
                ),
              ),
            );
            labelIndex++;
          }
        }
      }
      return Stack(children: dailyLabels);
    } else {
      final int step = (forecasts.length > 24) ? 2 : 2;
      return Stack(
        children: forecasts
            .asMap()
            .entries
            .where((entry) => entry.key % step == 0)
            .map((entry) {
              final int index = entry.key;
              final f = entry.value;
              final String label = (index < labels.length) ? labels[index] : '';

              final pos = ChartPositioning.calculatePosition(
                timeMs: f.time.millisecondsSinceEpoch.toDouble(),
                value: 0,
                containerSize: containerSize,
                minValue: minY,
                maxValue: maxY,
                startTime: chartStartTime,
                endTime: chartEndTime,
              );

              return Positioned(
                left: pos.dx - 40,
                top:
                    containerSize.height -
                    ChartConstants.bottomTitleReservedSize +
                    30,
                child: SizedBox(
                  width: 80,
                  child: Column(
                    children: [
                      Text(
                        'x',
                        textAlign: TextAlign.center,
                        style: ChartTheme.hourLabelStyle,
                      ),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: ChartTheme.hourLabelStyle,
                      ),
                    ],
                  ),
                ),
              );
            })
            .toList(),
      );
    }
  }

  static Widget _buildAltitudes(
    Size containerSize,
    DateTime chartStartTime,
    DateTime chartEndTime,
    double minY,
    double maxY,
  ) {
    final List<double> altitudes = [
      10.0,
      20.0,
      50.0,
      80.0,
      100.0,
      120.0,
      150.0,
      180.0,
      200.0,
    ];

    return Stack(
      children: altitudes.where((alt) => alt >= 10.0).map((alt) {
        final pos = ChartPositioning.calculatePosition(
          timeMs: chartStartTime.millisecondsSinceEpoch.toDouble(),
          value: alt,
          containerSize: containerSize,
          minValue: minY,
          maxValue: maxY,
          startTime: chartStartTime,
          endTime: chartEndTime,
        );
        return Positioned(
          left: 5,
          top: pos.dy - 8,
          child: Text(
            '${alt.toInt()}m',
            style: ChartTheme.axisLabelStyle.copyWith(fontSize: 12),
          ),
        );
      }).toList(),
    );
  }

  static Widget _buildLegend(Size containerSize) {
    return Positioned(
      bottom: 5,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            const Text('Vitesse: ', style: TextStyle(fontSize: 10)),
            _legendBox(Colors.blue.withValues(alpha: 0.3), '<5'),
            _legendBox(Colors.green.withValues(alpha: 0.5), '10'),
            _legendBox(Colors.yellow.withValues(alpha: 0.7), '20'),
            _legendBox(Colors.orange.withValues(alpha: 0.8), '30'),
            _legendBox(Colors.red.withValues(alpha: 0.9), '50'),
            _legendBox(Colors.purple, '>70'),
          ],
        ),
      ),
    );
  }

  static Widget _legendBox(Color color, String label) {
    return Row(
      children: [
        Container(width: 10, height: 10, color: color),
        const SizedBox(width: 2),
        Text(label, style: const TextStyle(fontSize: 8)),
        const SizedBox(width: 1),
      ],
    );
  }
}
