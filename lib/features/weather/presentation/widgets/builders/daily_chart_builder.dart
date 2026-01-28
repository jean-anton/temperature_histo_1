import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:temperature_histo_1/features/climate/domain/climate_model.dart';
import 'package:temperature_histo_1/features/weather/domain/weather_model.dart';
import 'package:temperature_histo_1/flchart_positioned/flchart_positioned.dart';
import '../utils/chart_constants.dart';
import '../utils/chart_helpers.dart';
import '../utils/chart_data_provider.dart';
import '../utils/chart_theme.dart';
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
    final List<FlSpot> spotsMaxTemp = ChartDataProvider.getMaxTempSpots(
      forecast,
    );

    final startTime = forecast.dailyForecasts.first.date;
    final endTime = forecast.dailyForecasts.last.date;

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
        verticalInterval: const Duration(hours: 1).inMilliseconds.toDouble(),
        horizontalInterval: 5,
        checkToShowVerticalLine: (value) {
          final dateTime = DateTime.fromMillisecondsSinceEpoch(value.toInt());
          return dateTime.hour == 0 &&
              dateTime.minute == 0 &&
              dateTime.second == 0 &&
              dateTime.millisecond == 0;
        },
        getDrawingVerticalLine: (value) {
          return FlLine(color: ChartTheme.gridLineColor, strokeWidth: 1);
        },
        getDrawingHorizontalLine: (value) {
          return FlLine(color: ChartTheme.gridLineColorLight, strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          axisNameSize: ChartConstants.bottomAxisNameSize,
          axisNameWidget: Container(),
          sideTitles: SideTitles(
            showTitles: true,
            interval: const Duration(days: 1).inMilliseconds.toDouble(),
            reservedSize: ChartConstants.bottomAxisTitleSize,
            getTitlesWidget: (value, meta) => Container(),
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
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spotsMaxTemp,
          isCurved: true,
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
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ChartTheme.temperatureMinLineColor.withValues(alpha: 0.1),
                ChartTheme.temperatureMinLineColor.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
        LineChartBarData(
          spots: ChartDataProvider.getNormalMaxSpots(forecast, deviations),
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
          spots: ChartDataProvider.getNormalMinSpots(forecast, deviations),
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
      backgroundColor: Colors.transparent,
      lineTouchData: const LineTouchData(enabled: false),
    );

    return PositionedLineChart(
      config: config,
      data: chartData,
      layers: [
        // Weekend background rectangles (rendered first, behind everything)
        (context, positioner) =>
            _buildWeekendBackgroundRectangles(forecast, positioner),
        // Weather icons and max temp labels
        (context, positioner) =>
            _buildWeatherIcons(forecast, deviations, positioner),
        // Min temp labels
        (context, positioner) =>
            _buildMinTempLabels(forecast, deviations, positioner),
        // Day labels at bottom
        (context, positioner) =>
            _buildDayLabels(forecast, positioner, dateLabels),
        // Wind info if enabled
        if (showWindInfo)
          (context, positioner) => _buildWindInfo(forecast, positioner),
      ],
    );
  }

  static Widget _buildDayLabels(
    DailyWeather forecast,
    ChartPositioner positioner,
    List<String> labels,
  ) {
    final widgets = forecast.dailyForecasts
        .asMap()
        .entries
        .where((entry) => entry.key % 1 == 0)
        .map((entry) {
          final int index = entry.key;
          final DailyForecast daily = entry.value;
          final String? label = labels.isNotEmpty && index < labels.length
              ? labels[index]
              : null;

          if (label == null) return const SizedBox.shrink();

          final pos = positioner.calculateFromTime(daily.date, positioner.minY);

          return Positioned(
            left: pos.dx - 40,
            top:
                positioner.containerSize.height -
                ChartConstants.bottomTitleReservedSize +
                30,
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

    return Stack(children: widgets);
  }

  /// Build background rectangles for weekend days (Saturday and Sunday)
  static Widget _buildWeekendBackgroundRectangles(
    DailyWeather forecast,
    ChartPositioner positioner,
  ) {
    final List<Widget> rectangles = [];

    for (int i = 0; i < forecast.dailyForecasts.length; i++) {
      final daily = forecast.dailyForecasts[i];
      final bool isWeekend =
          daily.date.weekday == DateTime.saturday ||
          daily.date.weekday == DateTime.sunday;

      if (isWeekend) {
        final leftTime = daily.date.subtract(const Duration(hours: 12));
        final posLeft = positioner.calculateFromTime(leftTime, 0);

        final DateTime nextDate = i < forecast.dailyForecasts.length - 1
            ? forecast.dailyForecasts[i + 1].date
            : daily.date.add(const Duration(days: 1));

        final rightTime = nextDate.subtract(const Duration(hours: 12));
        final posRight = positioner.calculateFromTime(rightTime, 0);

        final double dayWidth = posRight.dx - posLeft.dx;
        final chartArea = positioner.getChartArea();

        rectangles.add(
          Positioned(
            left: posLeft.dx,
            top: chartArea.top,
            child: Container(
              width: dayWidth,
              height: chartArea.height,
              color: ChartTheme.weekendBackgroundColor,
            ),
          ),
        );
      }
    }

    return Stack(children: rectangles);
  }

  /// Build weather icons and max temperature labels
  static Widget _buildWeatherIcons(
    DailyWeather forecast,
    List<WeatherDeviation?> deviations,
    ChartPositioner positioner,
  ) {
    final widgets = forecast.dailyForecasts.asMap().entries.map((entry) {
      final int index = entry.key;
      final DailyForecast daily = entry.value;
      final weatherCodeToUse = daily.weatherCodeDaytime ?? daily.weatherCode;
      final String? iconPath = ChartHelpers.getIconPath(
        code: weatherCodeToUse,
        iconName: daily.weatherIcon,
      );
      final WeatherDeviation? deviation = index < deviations.length
          ? deviations[index]
          : null;

      if (iconPath == null) return const SizedBox.shrink();

      final pos = positioner.calculateFromTime(
        daily.date,
        daily.temperatureMax,
      );

      return Positioned(
        left: pos.dx - 10,
        top: pos.dy - 80,
        child: SizedBox(
          width: 55,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(iconPath, width: 45, height: 45),
              //const SizedBox(height: 0),
              Row(
                children: [
                  Text(
                    '${daily.temperatureMax.round()}°',
                    style: ChartTheme.temperatureMaxLabelStyle,
                  ),
                  const SizedBox(width: 5),
                  if (deviation != null)
                    Container(
                      // margin: const EdgeInsets.only(
                      //   top: ChartTheme.deviationTopMargin,
                      //   left: ChartTheme.deviationLeftMargin,
                      // ),
                      // padding: const EdgeInsets.symmetric(
                      //   horizontal: ChartTheme.deviationPaddingHorizontal,
                      //   vertical: ChartTheme.deviationPaddingVertical,
                      // ),
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
            ],
          ),
        ),
      );
    }).toList();

    return Stack(children: widgets);
  }

  /// Build minimum temperature labels
  static Widget _buildMinTempLabels(
    DailyWeather forecast,
    List<WeatherDeviation?> deviations,
    ChartPositioner positioner,
  ) {
    final widgets = forecast.dailyForecasts.asMap().entries.map((entry) {
      final int index = entry.key;
      final DailyForecast daily = entry.value;
      final WeatherDeviation? deviation = index < deviations.length
          ? deviations[index]
          : null;

      final pos = positioner.calculateFromTime(
        daily.date,
        daily.temperatureMin,
      );

      return Positioned(
        left: pos.dx - 15,
        top: pos.dy + 10,
        child: SizedBox(
          width: 50,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    '${daily.temperatureMin.round()}°',
                    style: ChartTheme.temperatureMinLabelStyle,
                  ),
                  if (deviation != null) const SizedBox(width: 4),
                  if (deviation != null)
                    Container(
                      //margin: const EdgeInsets.only(top: 0, left: 20),
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
            ],
          ),
        ),
      );
    }).toList();

    return Stack(children: widgets);
  }

  /// Build wind direction icons and speed/gusts labels for daily chart
  static Widget _buildWindInfo(
    DailyWeather forecast,
    ChartPositioner positioner,
  ) {
    final widgets = forecast.dailyForecasts.asMap().entries.map((entry) {
      final DailyForecast daily = entry.value;

      if (daily.windSpeedMax == null || daily.windGustsMax == null) {
        return const SizedBox.shrink();
      }

      final pos = positioner.calculateFromTime(
        daily.date,
        daily.temperatureMax,
      );

      return Positioned(
        left: pos.dx - ChartTheme.windInfoContainerOffset,
        top: pos.dy + 10,
        child: WindIndicator(
          windSpeed: daily.windSpeedMax!,
          windGusts: daily.windGustsMax,
          windDirection: daily.windDirection10mDominant ?? 0,
        ),
      );
    }).toList();

    return Stack(children: widgets);
  }
}
