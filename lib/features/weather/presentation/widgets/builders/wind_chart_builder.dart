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
    required DisplayType displayType,
    required DateTime startTime,
    required DateTime endTime,
    required List<String> labels,
    required double minY,
    required double maxY,
  }) {
    final bool isVentDay = displayType == DisplayType.ventDay;

    // Filter forecasts for ventDay mode using sunrise/sunset times
    final displayForecasts = isVentDay
        ? hourlyWeather.hourlyForecasts.where((f) {
            // Find the corresponding day in the daily forecast
            final forecastDay = forecast.dailyForecasts.firstWhere(
              (day) =>
                  day.date.year == f.time.year &&
                  day.date.month == f.time.month &&
                  day.date.day == f.time.day,
              orElse: () => forecast.dailyForecasts.first,
            );

            // Check if this hour falls within daylight (between sunrise and sunset)
            if (forecastDay.sunrise != null && forecastDay.sunset != null) {
              return f.time.isAfter(forecastDay.sunrise!) &&
                  f.time.isBefore(forecastDay.sunset!);
            }

            // Fallback to isDay flag if sunrise/sunset not available
            return f.isDay == 1;
          }).toList()
        : hourlyWeather.hourlyForecasts;

    if (displayForecasts.isEmpty) return Container();

    return Stack(
      key: ValueKey(displayType),
      children: [
        _buildBackgroundGrid(
          containerSize,
          displayForecasts,
          forecast,
          startTime,
          endTime,
          displayMode,
          minY,
          maxY,
          isVentDay,
        ),
        if (!isVentDay)
          ..._buildNight(hourlyWeather, forecast, minY, maxY, containerSize),
        _buildHeatmap(
          containerSize,
          displayForecasts,
          forecast,
          startTime,
          endTime,
          minY,
          maxY,
          displayType,
        ),
        if (isVentDay) ..._buildDaySeparators(containerSize, displayForecasts),
        _buildSeparationLine(containerSize, startTime, endTime, minY, maxY, 10.0, 3.0),
        _buildSeparationLine(containerSize, startTime, endTime, minY, maxY, -20.0, 3.0),
        _buildSeparationLine(containerSize, startTime, endTime, minY, maxY, 50.0, 1.0),
        _buildSeparationLine(containerSize, startTime, endTime, minY, maxY, 100.0, 1.0),
        _buildSeparationLine(containerSize, startTime, endTime, minY, maxY, 150.0, 1.0),
        _buildXAxisLabels(
          containerSize,
          displayForecasts,
          startTime,
          endTime,
          labels,
          displayMode,
          minY,
          maxY,
          isVentDay,
          hourlyWeather.hourlyForecasts, // Pass original for date logic
        ),
        _buildAltitudes(containerSize, startTime, endTime, minY, maxY),
        //_buildLegend(containerSize),
      ],
    );
  }

  static Widget _buildBackgroundGrid(
    Size containerSize,
    List<HourlyForecast> displayForecasts,
    DailyWeather forecast,
    DateTime chartStartTime,
    DateTime chartEndTime,
    String displayMode,
    double minY,
    double maxY,
    bool isVentDay,
  ) {
    if (displayForecasts.isEmpty) return Container();

    final double minX = isVentDay
        ? 0
        : chartStartTime.millisecondsSinceEpoch.toDouble();
    final double maxX = isVentDay
        ? (displayForecasts.length - 1).toDouble()
        : chartEndTime.millisecondsSinceEpoch.toDouble();

    return LineChart(
      LineChartData(
        minX: minX,
        maxX: maxX,
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
          verticalInterval: isVentDay
              ? 2.0 // Show line every 2 hours in VentDay mode
              : const Duration(hours: 1).inMilliseconds.toDouble(),
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
            axisNameWidget: Container(),
            sideTitles: SideTitles(
              showTitles: true,
              interval: isVentDay
                  ? 2.0
                  : const Duration(hours: 2).inMilliseconds.toDouble(),
              reservedSize: ChartConstants.bottomAxisTitleSize,
              getTitlesWidget: (value, meta) => Container(),
            ),
          ),
          leftTitles: AxisTitles(
            axisNameSize: ChartConstants.leftAxisNameSize,
            axisNameWidget: const SizedBox.shrink(),
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
    double value,
    double height,
  ) {
    final pos = ChartPositioning.calculatePosition(
      timeMs: startTime.millisecondsSinceEpoch.toDouble(),
      value: value,
      containerSize: containerSize,
      minValue: minY,
      maxValue: maxY,
      startTime: startTime,
      endTime: endTime,
    );
    
    return 
        Positioned(
          left: ChartConstants.leftPadding + ChartConstants.leftTitleReservedSize,
          right: ChartConstants.rightPadding,
          top: pos.dy - 1.0,
          child: Container(
            height: height,
            color: const Color.fromARGB(255, 10, 10, 10).withValues(alpha: 0.6),
          ),
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

    // Handle the night rectangle for the period ending at the first day's sunrise
    if (forecast.dailyForecasts.isNotEmpty) {
      final firstDay = forecast.dailyForecasts.first;
      if (firstDay.sunrise != null && firstDay.sunrise!.isAfter(startTime)) {
        final posStart = ChartPositioning.calculatePosition(
          timeMs: startTime.millisecondsSinceEpoch.toDouble(),
          value: maxY,
          containerSize: containerSize,
          minValue: minY,
          maxValue: maxY,
          startTime: startTime,
          endTime: endTime,
        );
        final posEnd = ChartPositioning.calculatePosition(
          timeMs: firstDay.sunrise!.millisecondsSinceEpoch.toDouble(),
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

    // Handle night rectangles for sunset to next sunrise
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
    List<HourlyForecast> displayForecasts,
    DailyWeather forecast,
    DateTime chartStartTime,
    DateTime chartEndTime,
    double minY,
    double maxY,
    DisplayType displayType,
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

    final bool isVentDay = displayType == DisplayType.ventDay;
    final double chartWidthForX =
        containerSize.width -
        ChartConstants.leftPadding -
        ChartConstants.rightPadding -
        ChartConstants.leftTitleReservedSize;

    double getX(int index, DateTime time) {
      if (isVentDay) {
        final double slotWidth = chartWidthForX / displayForecasts.length;
        return ChartConstants.leftPadding +
            ChartConstants.leftTitleReservedSize +
            (index * slotWidth);
      } else {
        return ChartPositioning.calculatePosition(
          timeMs: time.millisecondsSinceEpoch.toDouble(),
          value: 0.0,
          containerSize: containerSize,
          minValue: minY,
          maxValue: maxY,
          startTime: chartStartTime,
          endTime: chartEndTime,
        ).dx;
      }
    }

    final double hourWidth = isVentDay
        ? chartWidthForX / displayForecasts.length
        : (ChartPositioning.calculatePosition(
                timeMs: displayForecasts.first.time
                    .add(const Duration(hours: 1))
                    .millisecondsSinceEpoch
                    .toDouble(),
                value: 0.0,
                containerSize: containerSize,
                minValue: minY,
                maxValue: maxY,
                startTime: chartStartTime,
                endTime: chartEndTime,
              ).dx -
              ChartPositioning.calculatePosition(
                timeMs: displayForecasts.first.time.millisecondsSinceEpoch
                    .toDouble(),
                value: 0.0,
                containerSize: containerSize,
                minValue: minY,
                maxValue: maxY,
                startTime: chartStartTime,
                endTime: chartEndTime,
              ).dx);

    for (int i = 0; i < displayForecasts.length; i++) {
      final f = displayForecasts[i];
      final double xPos = getX(i, f.time);

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
            left: xPos,
            top: posTop.dy,
            width: hourWidth,
            height: segmentHeight,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: ChartTheme.windGustColor(windSpeed),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                      width: 0.2,
                    ),
                  ),
                ),
                Text('s${windSpeed.round().toString()}\n${f.time.hour} ${f.time.day}'),

              ],
            ),
          ),
        );
      }
    }

    return Stack(children: segments);
  }

  static List<Widget> _buildDaySeparators(
    Size containerSize,
    List<HourlyForecast> displayForecasts,
  ) {
    final List<Widget> separators = [];
    if (displayForecasts.isEmpty) return separators;

    final double chartWidthForX =
        containerSize.width -
        ChartConstants.leftPadding -
        ChartConstants.rightPadding -
        ChartConstants.leftTitleReservedSize;
    final double slotWidth = chartWidthForX / displayForecasts.length;

    for (int i = 1; i < displayForecasts.length; i++) {
      if (displayForecasts[i].time.day != displayForecasts[i - 1].time.day) {
        final double x =
            ChartConstants.leftPadding +
            ChartConstants.leftTitleReservedSize +
            (i * slotWidth);
        separators.add(
          Positioned(
            left: x - 1.0,
            top: ChartConstants.topPadding,
            height:
                containerSize.height -
                ChartConstants.topPadding -
                ChartConstants.bottomPadding -
                50,
            child: Container(
              width: 2.0,
              color: const Color.fromARGB(
                255,
                10,
                10,
                10,
              ).withValues(alpha: 0.3),
            ),
          ),
        );
      }
    }
    return separators;
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
    List<HourlyForecast> displayForecasts,
    DateTime chartStartTime,
    DateTime chartEndTime,
    List<String> labels,
    String displayMode,
    double minY,
    double maxY,
    bool isVentDay,
    List<HourlyForecast> allForecasts,
  ) {
    final double chartWidthForX =
        containerSize.width -
        ChartConstants.leftPadding -
        ChartConstants.rightPadding -
        ChartConstants.leftTitleReservedSize;

    double getX(int index, DateTime time) {
      if (isVentDay) {
        final double slotWidth = chartWidthForX / displayForecasts.length;
        return ChartConstants.leftPadding +
            ChartConstants.leftTitleReservedSize +
            (index * slotWidth);
      } else {
        return ChartPositioning.calculatePosition(
          timeMs: time.millisecondsSinceEpoch.toDouble(),
          value: 0.0,
          containerSize: containerSize,
          minValue: minY,
          maxValue: maxY,
          startTime: chartStartTime,
          endTime: chartEndTime,
        ).dx;
      }
    }

    if (displayMode == 'daily') {
      final List<Widget> dailyLabels = [];
      int labelIndex = 0;
      int? lastDay;

      for (int i = 0; i < displayForecasts.length; i++) {
        final f = displayForecasts[i];
        bool isNewDay = false;

        if (isVentDay) {
          if (lastDay == null || f.time.day != lastDay) {
            isNewDay = true;
            lastDay = f.time.day;
          }
        } else {
          if ((f.time.hour == 0 && f.time.minute == 0) || i == 0) {
            isNewDay = true;
          }
        }

        if (isNewDay) {
          if (labelIndex < labels.length) {
            final double xPos = getX(i, f.time);
            final double slotWidth = chartWidthForX / displayForecasts.length;
            final double centerX = isVentDay ? xPos + slotWidth / 2 : xPos;

            dailyLabels.add(
              Positioned(
                left: centerX - 40,
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
      final int step = (displayForecasts.length > 24) ? 2 : 2;
      return Stack(
        children: displayForecasts
            .asMap()
            .entries
            .where((entry) => entry.key % step == 0)
            .map((entry) {
              final int index = entry.key;
              final f = entry.value;
              final String label = (index < labels.length) ? labels[index] : '';

              final double xPos = getX(index, f.time);
              final double slotWidth = chartWidthForX / displayForecasts.length;
              final double centerX = isVentDay ? xPos + slotWidth / 2 : xPos;

              return Positioned(
                left: centerX - 40,
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
    final posGusts = ChartPositioning.calculatePosition(
      timeMs: chartStartTime.millisecondsSinceEpoch.toDouble(),
      value: -10,
      containerSize: containerSize,
      minValue: minY,
      maxValue: maxY,
      startTime: chartStartTime,
      endTime: chartEndTime,
    );
    return Stack(
      children:
          altitudes.where((alt) => alt >= 10.0).map((alt) {
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
          }).toList() +
          [
            Positioned(
              left: 5,
              top: posGusts.dy - 8,
              child: Text(
                'Gusts',
                style: ChartTheme.axisLabelStyle.copyWith(fontSize: 14),
              ),
            ),
          ],
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
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 2),
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 1),
      ],
    );
  }
}
