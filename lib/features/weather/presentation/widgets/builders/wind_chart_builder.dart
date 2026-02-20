import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:aeroclim/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:aeroclim/features/weather/domain/weather_model.dart';
import 'package:aeroclim/flchart_positioned/flchart_positioned.dart';
import '../utils/chart_constants.dart';
import '../utils/chart_theme.dart';

class WindChartBuilder {
  static Widget build({
    required HourlyWeather hourlyWeather,
    required DailyWeather forecast,
    required Size containerSize,
    required String displayMode,
    required DisplayType displayType,
    required DateTime startTime,
    required DateTime endTime,
    required List<String> labels,
    required double minY,
    required double maxY,
    required BuildContext context,
    required String locale,
  }) {
    final bool isVentDay = displayType == DisplayType.ventDay;

    // Filter forecasts for ventDay mode using sunrise/sunset times
    final displayForecasts = isVentDay
        ? hourlyWeather.hourlyForecasts.where((f) {
            final forecastDay = forecast.dailyForecasts.firstWhere(
              (day) =>
                  day.date.year == f.time.year &&
                  day.date.month == f.time.month &&
                  day.date.day == f.time.day,
              orElse: () => forecast.dailyForecasts.first,
            );
            if (forecastDay.sunrise != null && forecastDay.sunset != null) {
              return f.time.isAfter(forecastDay.sunrise!) &&
                  f.time.isBefore(forecastDay.sunset!);
            }
            return f.isDay == 1;
          }).toList()
        : hourlyWeather.hourlyForecasts;

    if (displayForecasts.isEmpty) return Container();

    // Create ChartConfig and ChartPositioner for consistent positioning
    final config = ChartConfig(
      leftReservedSize: ChartConstants.leftAxisTitleSize,
      bottomReservedSize: ChartConstants.bottomAxisTitleSize,
      borderWidth: ChartConstants.borderWidth,
      leftAxisNameSize: ChartConstants.leftAxisNameSize,
      bottomAxisNameSize: ChartConstants.bottomAxisNameSize,
    );

    final positioner = ChartPositioner(
      config: config,
      containerSize: containerSize,
      minX: isVentDay ? 0 : startTime.millisecondsSinceEpoch.toDouble(),
      maxX: isVentDay
          ? (displayForecasts.length - 1).toDouble()
          : endTime.millisecondsSinceEpoch.toDouble(),
      minY: minY,
      maxY: maxY,
    );

    return Stack(
      key: ValueKey(displayType),
      children: [
        _buildBackgroundGrid(
          containerSize,
          displayForecasts,
          startTime,
          endTime,
          displayMode,
          minY,
          maxY,
          isVentDay,
        ),
        if (!isVentDay) _buildNight(hourlyWeather, forecast, positioner),
        _buildHeatmap(
          containerSize,
          displayForecasts,
          forecast,
          startTime,
          endTime,
          minY,
          maxY,
          displayType,
          positioner,
        ),
        _buildSeparationLine(positioner, 10.0, 3.0),
        _buildSeparationLine(positioner, -20.0, 3.0),
        _buildSeparationLine(positioner, 50.0, 1.0),
        _buildSeparationLine(positioner, 100.0, 1.0),
        _buildSeparationLine(positioner, 150.0, 1.0),
        _buildDaySeparators(displayForecasts, positioner, isVentDay),
        _buildCurrentTimeLine(hourlyWeather, positioner),
        _buildXAxisLabels(
          displayForecasts,
          labels,
          displayMode,
          positioner,
          isVentDay,
          hourlyWeather.hourlyForecasts,
          locale,
        ),
        _buildAltitudes(positioner, context),
        _buildLegend(containerSize, context),
      ],
    );
  }

  static Widget _buildBackgroundGrid(
    Size containerSize,
    List<HourlyForecast> displayForecasts,
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
              ? 2.0
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

  /// Build a vertical line marking the current time
  static Widget _buildCurrentTimeLine(
    HourlyWeather hourlyWeather,
    ChartPositioner positioner,
  ) {
    final now = DateTime.now();
    final pos = positioner.calculateFromTime(now, positioner.minY);
    final chartArea = positioner.getChartArea();

    return Positioned(
      left: pos.dx,
      top: chartArea.top,
      child: Container(
        width: 2,
        height: chartArea.height,
        color: ChartTheme.currentTimeLineColor,
      ),
    );
  }

  static Widget _buildSeparationLine(
    ChartPositioner positioner,
    double value,
    double height,
  ) {
    final pos = positioner.calculate(positioner.minX, value);
    final chartArea = positioner.getChartArea();

    return Positioned(
      left: chartArea.left,
      right: ChartConstants.rightPadding,
      top: pos.dy - 1.0,
      child: Container(
        height: height,
        color: const Color.fromARGB(255, 10, 10, 10).withValues(alpha: 0.6),
      ),
    );
  }

  static Widget _buildNight(
    HourlyWeather hourlyWeather,
    DailyWeather forecast,
    ChartPositioner positioner,
  ) {
    List<Widget> nightWidgets = [];
    final startTime = hourlyWeather.hourlyForecasts.first.time;
    final endTime = hourlyWeather.hourlyForecasts.last.time;
    final chartArea = positioner.getChartArea();

    // Handle night rectangle for period ending at first day's sunrise
    if (forecast.dailyForecasts.isNotEmpty) {
      final firstDay = forecast.dailyForecasts.first;
      if (firstDay.sunrise != null && firstDay.sunrise!.isAfter(startTime)) {
        final posStart = positioner.calculateFromTime(
          startTime,
          positioner.maxY,
        );
        final posEnd = positioner.calculateFromTime(
          firstDay.sunrise!,
          positioner.maxY,
        );

        final width = (posEnd.dx - posStart.dx)
            .clamp(0.0, positioner.containerSize.width)
            .toDouble();

        if (width > 0) {
          nightWidgets.add(
            Positioned(
              left: posStart.dx,
              top: chartArea.top,
              width: width,
              height: chartArea.height,
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
          final posStart = positioner.calculateFromTime(
            sunset,
            positioner.maxY,
          );
          final posEnd = positioner.calculateFromTime(
            nextSunrise,
            positioner.maxY,
          );

          final width = (posEnd.dx - posStart.dx)
              .clamp(0.0, positioner.containerSize.width)
              .toDouble();

          if (width > 0) {
            nightWidgets.add(
              Positioned(
                left: posStart.dx,
                top: chartArea.top,
                width: width,
                height: chartArea.height,
                child: Container(color: ChartTheme.nightBackgroundColor),
              ),
            );
          }
        }
      }
    }
    return Stack(children: nightWidgets);
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
    ChartPositioner positioner,
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
    final chartArea = positioner.getChartArea();

    double getX(int index, DateTime time) {
      if (isVentDay) {
        final double slotWidth = chartArea.width / displayForecasts.length;
        return chartArea.left + (index * slotWidth);
      } else {
        return positioner.calculateFromTime(time, 0.0).dx;
      }
    }

    final double hourWidth = isVentDay
        ? chartArea.width / displayForecasts.length
        : (positioner
                  .calculateFromTime(
                    displayForecasts.first.time.add(const Duration(hours: 1)),
                    0.0,
                  )
                  .dx -
              positioner
                  .calculateFromTime(displayForecasts.first.time, 0.0)
                  .dx);

    for (int i = 0; i < displayForecasts.length; i++) {
      final f = displayForecasts[i];
      final double xPos = getX(i, f.time);

      for (int j = 0; j < altitudes.length - 1; j++) {
        final altBottom = altitudes[j];
        final altTop = altitudes[j + 1];

        final windSpeed = _getWindSpeedForRange(f, altBottom, altTop);
        if (windSpeed == null) continue;

        final posBottom = positioner.calculate(positioner.minX, altBottom);
        final posTop = positioner.calculate(positioner.minX, altTop);

        final segmentHeight = (posBottom.dy - posTop.dy).abs();

        segments.add(
          Positioned(
            left: xPos,
            top: posTop.dy,
            width: hourWidth,
            height: segmentHeight,
            child: Container(
              decoration: BoxDecoration(
                color: ChartTheme.windGustColor(windSpeed),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                  width: 0.2,
                ),
              ),
            ),
          ),
        );
      }
    }

    return Stack(children: segments);
  }

  static Widget _buildDaySeparators(
    List<HourlyForecast> displayForecasts,
    ChartPositioner positioner,
    bool isVentDay,
  ) {
    final List<Widget> separators = [];
    if (displayForecasts.isEmpty) return Stack(children: separators);

    final chartArea = positioner.getChartArea();

    for (int i = 1; i < displayForecasts.length; i++) {
      final f = displayForecasts[i];
      if (f.time.hour == 0 && f.time.minute == 0) {
        double x;
        if (isVentDay) {
          final double slotWidth = chartArea.width / displayForecasts.length;
          x = chartArea.left + (i * slotWidth);
        } else {
          x = positioner.calculateFromTime(f.time, 0.0).dx;
        }
        separators.add(
          Positioned(
            left: x - 1.0,
            top: chartArea.top,
            height: chartArea.height - 50,
            child: Container(
              width: 5.0,
              color: const Color.fromARGB(
                255,
                10,
                10,
                10,
              ).withValues(alpha: 0.1),
            ),
          ),
        );
      }
    }
    return Stack(children: separators);
  }

  static double? _getWindSpeedForRange(
    HourlyForecast forecast,
    double bottom,
    double top,
  ) {
    if (bottom == -20.0 && top == 10.0) {
      return forecast.windGusts ?? forecast.windSpeed;
    }

    double? speed = _getWindSpeedAtAltitude(forecast, top);
    if (speed != null) return speed;

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
    List<HourlyForecast> displayForecasts,
    List<String> labels,
    String displayMode,
    ChartPositioner positioner,
    bool isVentDay,
    List<HourlyForecast> allForecasts,
    String locale,
  ) {
    final chartArea = positioner.getChartArea();

    double getX(int index, DateTime time) {
      if (isVentDay) {
        final double slotWidth = chartArea.width / displayForecasts.length;
        return chartArea.left + (index * slotWidth);
      } else {
        return positioner.calculateFromTime(time, 0.0).dx;
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
            final double slotWidth = chartArea.width / displayForecasts.length;
            final double centerX = isVentDay ? xPos + slotWidth / 2 : xPos;

            dailyLabels.add(
              Positioned(
                left: centerX - 40,
                top:
                    positioner.containerSize.height -
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
      final int step = 2;
      final widgets = displayForecasts
          .asMap()
          .entries
          .where((entry) => entry.key % step == 0)
          .map((entry) {
            final int index = entry.key;
            final f = entry.value;
            final String hourLabel = (index < labels.length)
                ? labels[index]
                : '';

            final date = f.time;
            TextStyle? style;
            String day = "";
            if (date.hour == 0) {
              style = ChartTheme.hour00LabelStyle;
              final monthFormat = DateFormat.MMM(locale);
              day = '${date.day} ${monthFormat.format(date)}';
            } else {
              style = ChartTheme.hourLabelStyle;
            }
            final String displayLabel =
                hourLabel + (day.isNotEmpty ? "\n$day" : "");

            final double xPos = getX(index, f.time);
            final double slotWidth = chartArea.width / displayForecasts.length;
            final double centerX = isVentDay ? xPos + slotWidth / 2 : xPos;

            return Positioned(
              left: centerX - 40,
              top:
                  positioner.containerSize.height -
                  ChartConstants.bottomTitleReservedSize +
                  30,
              child: SizedBox(
                width: 80,
                child: Text(
                  displayLabel,
                  textAlign: TextAlign.center,
                  style: style,
                ),
              ),
            );
          })
          .toList();
      return Stack(children: widgets);
    }
  }

  static Widget _buildAltitudes(
    ChartPositioner positioner,
    BuildContext context,
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
    final posGusts = positioner.calculate(positioner.minX, -10);

    final widgets = altitudes.where((alt) => alt >= 10.0).map((alt) {
      final pos = positioner.calculate(positioner.minX, alt);
      return Positioned(
        left: 5,
        top: pos.dy - 8,
        child: Text(
          '${alt.toInt()}m',
          style: ChartTheme.axisLabelStyle.copyWith(fontSize: 12),
        ),
      );
    }).toList();

    widgets.add(
      Positioned(
        left: 5,
        top: posGusts.dy - 8,
        child: Text(
          AppLocalizations.of(context)!.gusts,
          style: ChartTheme.axisLabelStyle.copyWith(fontSize: 14),
        ),
      ),
    );

    return Stack(children: widgets);
  }

  static Widget _buildLegend(Size containerSize, BuildContext context) {
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
            Text(
              '${AppLocalizations.of(context)!.speed}: ',
              style: const TextStyle(fontSize: 10),
            ),
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
