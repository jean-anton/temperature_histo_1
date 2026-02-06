import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aeroclim/features/weather/domain/weather_model.dart';
import 'package:aeroclim/flchart_positioned/flchart_positioned.dart';
import '../utils/chart_constants.dart';
import '../utils/chart_helpers.dart';
import '../utils/chart_data_provider.dart';
import '../utils/chart_theme.dart';
import '../common/wind_indicator.dart';

/// Builder for period-based weather chart (Aperçu)
class PeriodChartBuilder {
  /// Build the period chart widget
  static Widget build({
    required HourlyWeather hourlyWeather,
    required double minTemp,
    required double maxTemp,
    required List<String> hourLabels,
    required BoxConstraints constraints,
    bool showWindInfo = true,
    required Size containerSize,
    required DailyWeather forecast,
  }) {
    final List<PeriodForecast> periodForecasts =
        ChartDataProvider.getPeriodForecasts(hourlyWeather);

    final List<FlSpot> spots = ChartDataProvider.getPeriodTempSpots(
      periodForecasts,
    );

    if (periodForecasts.isEmpty) {
      return const Center(child: Text('Aucune donnée de période'));
    }

    final startTime = periodForecasts.first.time;
    final endTime = periodForecasts.last.time.add(const Duration(hours: 6));

    final minX = startTime.millisecondsSinceEpoch.toDouble();
    final maxX = endTime.millisecondsSinceEpoch.toDouble();
    final minY = minTemp - 5;
    final maxY = maxTemp + 5;

    // Chart configuration matching ChartConstants
    final config = ChartConfig(
      leftReservedSize: ChartConstants.leftAxisTitleSize,
      bottomReservedSize: ChartConstants.bottomAxisTitleSize,
      borderWidth: ChartConstants.borderWidth,
      leftAxisNameSize: ChartConstants.leftAxisNameSize,
      bottomAxisNameSize: ChartConstants.bottomAxisNameSize,
    );

    final chartData = LineChartData(
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
        verticalInterval: const Duration(hours: 6).inMilliseconds.toDouble(),
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
          sideTitles: SideTitles(
            showTitles: true,
            interval: const Duration(hours: 6).inMilliseconds.toDouble(),
            reservedSize: ChartConstants.bottomAxisTitleSize,
            getTitlesWidget: (value, meta) => const SizedBox.shrink(),
          ),
        ),
        leftTitles: AxisTitles(
          axisNameSize: ChartConstants.leftAxisNameSize,
          axisNameWidget: const Text('°C', style: ChartTheme.axisTitleStyle),
          sideTitles: SideTitles(
            showTitles: true,
            interval: 5,
            reservedSize: ChartConstants.leftAxisTitleSize,
            getTitlesWidget: (value, meta) =>
                Text('${value.toInt()}°', style: ChartTheme.axisLabelStyle),
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      lineBarsData: [
        // Main temperature line
        LineChartBarData(
          isCurved: true,
          spots: spots,
          color: ChartTheme.temperatureMaxLineColor,
          barWidth: ChartTheme.chartLineWidth,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
                  radius: ChartTheme.chartDotRadius,
                  color: ChartTheme.temperatureMaxDotColor,
                  strokeWidth: ChartTheme.chartDotStrokeWidth,
                  strokeColor: Colors.white,
                ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ChartTheme.temperatureMaxLineColor.withValues(alpha: 0.2),
                ChartTheme.temperatureMaxLineColor.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
        // Apparent temperature dotted line
        LineChartBarData(
          isCurved: true,
          spots: ChartDataProvider.getPeriodApparentTempSpots(periodForecasts),
          color: ChartTheme.apparentTempLineColor,
          barWidth: 2,
          isStrokeCapRound: true,
          dashArray: ChartTheme.apparentTempDashPattern,
          dotData: const FlDotData(show: false),
        ),
      ],
      backgroundColor: Colors.transparent,
      lineTouchData: const LineTouchData(enabled: false),
    );

    return PositionedLineChart(
      config: config,
      data: chartData,
      layers: [
        // Weekend background
        (context, positioner) => _buildWeekends(forecast, positioner),
        // Night background
        (context, positioner) =>
            _buildNight(periodForecasts, forecast, positioner),
        // Day separators
        (context, positioner) =>
            _buildDaySeparators(periodForecasts, positioner),
        // Wind info if enabled
        if (showWindInfo)
          (context, positioner) => _buildWindInfo(periodForecasts, positioner),
        // Weather icons and labels
        (context, positioner) => _buildPeriodIcons(periodForecasts, positioner),
        // Day labels at top (12h)
        (context, positioner) =>
            _buildTopDayLabels(periodForecasts, positioner),
        // Period labels at bottom
        (context, positioner) =>
            _buildPeriodLabels(periodForecasts, positioner),
      ],
    );
  }

  static Widget _buildDaySeparators(
    List<PeriodForecast> periodForecasts,
    ChartPositioner positioner,
  ) {
    final List<Widget> separators = [];
    final chartArea = positioner.getChartArea();

    for (var f in periodForecasts) {
      final is0h = f.time.hour == 0;
      final pos = positioner.calculateFromTime(f.time, positioner.minY);
      final width = is0h ? 1.5 : 0.4;

      separators.add(
        Positioned(
          left: pos.dx - (width / 2),
          top: chartArea.top,
          child: Container(
            width: width,
            height: chartArea.height,
            color: Colors.black.withValues(alpha: 0.3),
          ),
        ),
      );
    }
    return Stack(children: separators);
  }

  static Widget _buildNight(
    List<PeriodForecast> periodForecasts,
    DailyWeather forecast,
    ChartPositioner positioner,
  ) {
    List<Widget> backgrounds = [];
    final chartArea = positioner.getChartArea();

    for (var f in periodForecasts) {
      final hour = f.time.hour;
      Color? bgColor;

      if (hour == 0) {
        // Nuit (0-6h) - Darker
        bgColor = Colors.blueGrey.withValues(alpha: 0.35);
      } else if (hour == 18) {
        // Soir (18-0h) - Lighter dark
        bgColor = Colors.blueGrey.withValues(alpha: 0.18);
      }

      if (bgColor != null) {
        final startPos = positioner.calculateFromTime(f.time, positioner.maxY);
        final endPos = positioner.calculateFromTime(
          f.time.add(const Duration(hours: 6)),
          positioner.maxY,
        );

        final left = startPos.dx.clamp(chartArea.left, chartArea.right);
        final right = endPos.dx.clamp(chartArea.left, chartArea.right);
        final width = right - left;

        if (width > 0) {
          backgrounds.add(
            Positioned(
              left: left,
              top: chartArea.top,
              width: width,
              height: chartArea.height,
              child: Container(color: bgColor),
            ),
          );
        }
      }
    }
    return Stack(children: backgrounds);
  }

  static Widget _buildPeriodIcons(
    List<PeriodForecast> periodForecasts,
    ChartPositioner positioner,
  ) {
    final widgets = periodForecasts.map((period) {
      final String? iconPath = ChartHelpers.getIconPath(
        code: period.weatherCode,
        isDay: period.isDay,
      );

      final pos = positioner.calculateFromTime(
        period.time.add(const Duration(hours: 3)),
        period.avgTemperature,
      );

      return Positioned(
        left: pos.dx - 22,
        top: pos.dy - 75,
        child: SizedBox(
          width: 45,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconPath != null)
                SvgPicture.asset(iconPath, width: 35, height: 35),
              const SizedBox(height: 2),
              Text(
                '${period.avgTemperature.round()}°',
                style: ChartTheme.temperatureMaxLabelStyle,
              ),
            ],
          ),
        ),
      );
    }).toList();

    return Stack(children: widgets);
  }

  static Widget _buildPeriodLabels(
    List<PeriodForecast> periodForecasts,
    ChartPositioner positioner,
  ) {
    final widgets = periodForecasts.map((period) {
      final pos = positioner.calculateFromTime(
        period.time.add(const Duration(hours: 3)),
        0,
      );
      final isNewDay = period.time.hour == 0;

      String label = period.name;
      if (isNewDay) {
        label = '${DateFormat('E d', 'fr_FR').format(period.time)}\n$label';
      }

      return Positioned(
        left: pos.dx - 30,
        top:
            positioner.containerSize.height -
            ChartConstants.bottomTitleReservedSize +
            25,
        child: SizedBox(
          width: 60,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: isNewDay
                ? ChartTheme.hour00LabelStyle
                : ChartTheme.hourLabelStyle,
          ),
        ),
      );
    }).toList();

    return Stack(children: widgets);
  }

  /// Build wind direction icons and speed/gusts labels for period chart
  static Widget _buildWindInfo(
    List<PeriodForecast> periodForecasts,
    ChartPositioner positioner,
  ) {
    final widgets = periodForecasts.map((period) {
      final pos = positioner.calculateFromTime(
        period.time.add(const Duration(hours: 3)),
        period.avgTemperature,
      );

      return Positioned(
        left: pos.dx - ChartTheme.windInfoContainerOffset,
        top: pos.dy + 10,
        child: WindIndicator(
          windSpeed: period.maxWindSpeed,
          windGusts: period.maxWindGusts,
          windDirection: period.windDirection ?? 0,
        ),
      );
    }).toList();

    return Stack(children: widgets);
  }

  static Widget _buildWeekends(
    DailyWeather forecast,
    ChartPositioner positioner,
  ) {
    List<Widget> weekendWidgets = [];
    final chartArea = positioner.getChartArea();

    DateTime? blockStart;
    DateTime? blockEnd;

    void addCurrentBlock() {
      if (blockStart != null && blockEnd != null) {
        final startPos = positioner.calculateFromTime(
          blockStart!,
          positioner.maxY,
        );
        final endPos = positioner.calculateFromTime(blockEnd!, positioner.maxY);

        final left = startPos.dx.clamp(chartArea.left, chartArea.right);
        final right = endPos.dx.clamp(chartArea.left, chartArea.right);
        final width = right - left;

        if (width > 0) {
          weekendWidgets.add(
            Positioned(
              left: left,
              top: chartArea.top + 2,
              width: width,
              height: 25,
              child: Container(
                decoration: BoxDecoration(
                  color: ChartTheme.weekendBackgroundColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          );
        }
      }
      blockStart = null;
      blockEnd = null;
    }

    for (var dailyForecast in forecast.dailyForecasts) {
      if (dailyForecast.date.weekday == 6 || dailyForecast.date.weekday == 7) {
        if (blockStart == null) {
          blockStart = dailyForecast.date;
        }
        blockEnd = dailyForecast.date.add(const Duration(days: 1));
      } else {
        addCurrentBlock();
      }
    }
    addCurrentBlock();

    return Stack(children: weekendWidgets);
  }

  static Widget _buildTopDayLabels(
    List<PeriodForecast> periodForecasts,
    ChartPositioner positioner,
  ) {
    final widgets = periodForecasts
        .where((period) => period.time.hour == 12)
        .map((period) {
          final pos = positioner.calculateFromTime(
            period.time,
            positioner.maxY,
          );

          final isWeekend =
              period.time.weekday == DateTime.saturday ||
              period.time.weekday == DateTime.sunday;

          return Positioned(
            left: pos.dx - 40,
            top: positioner.getChartArea().top + 5,
            child: SizedBox(
              width: 80,
              child: Text(
                DateFormat('EEEE d', 'fr_FR').format(period.time),
                textAlign: TextAlign.center,
                style: ChartTheme.hour00LabelStyle.copyWith(
                  color: isWeekend
                      ? Colors.black.withValues(alpha: 0.8)
                      : Colors.black.withValues(alpha: 0.4),
                  fontSize: 14,
                  fontWeight: isWeekend ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
            ),
          );
        })
        .toList();

    return Stack(children: widgets);
  }
}
