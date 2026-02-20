import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:aeroclim/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:aeroclim/features/weather/domain/weather_model.dart';
import 'package:aeroclim/flchart_positioned/flchart_positioned.dart';
import '../utils/chart_constants.dart';
import '../utils/chart_theme.dart';

class ComparisonChartBuilder {
  static Widget build({
    MultiModelWeather? multiModelForecast,
    MultiModelHourlyWeather? multiModelHourlyWeather,
    required String displayMode,
    required Size containerSize,
    required double minTemp,
    required double maxTemp,
    required List<String> labels,
    DailyWeather? forecast,
    required BuildContext context,
  }) {
    final bool isDaily = displayMode == 'daily';

    // Get time range
    DateTime startTime;
    DateTime endTime;

    if (isDaily &&
        multiModelForecast != null &&
        multiModelForecast.models.isNotEmpty) {
      final firstModel = multiModelForecast.models.values.first;
      startTime = firstModel.dailyForecasts.first.date;
      endTime = firstModel.dailyForecasts.last.date;
    } else if (!isDaily &&
        multiModelHourlyWeather != null &&
        multiModelHourlyWeather.models.isNotEmpty) {
      final firstModel = multiModelHourlyWeather.models.values.first;
      startTime = firstModel.hourlyForecasts.first.time;
      endTime = firstModel.hourlyForecasts.last.time;
    } else {
      return Center(child: Text(AppLocalizations.of(context)!.noData));
    }

    final minX = startTime.millisecondsSinceEpoch.toDouble();
    final maxX = endTime.millisecondsSinceEpoch.toDouble();
    final minY = minTemp - 5;
    final maxY = maxTemp + 5;

    final modelColors = {
      'best_match': Colors.orange,
      'ecmwf_ifs': Colors.blue,
      'gfs_seamless': Colors.red,
      'meteofrance_seamless': Colors.green,
    };

    final List<LineChartBarData> lineBarsData = [];
    final List<FlSpot> bestMatchSpots = [];

    final modelsToProcess = isDaily
        ? multiModelForecast?.models.keys.toList() ?? []
        : multiModelHourlyWeather?.models.keys.toList() ?? [];

    for (final modelKey in modelsToProcess) {
      final color = modelColors[modelKey] ?? Colors.grey;
      final List<FlSpot> spots = [];

      if (isDaily) {
        final dailyWeather = multiModelForecast!.models[modelKey]!;
        for (final f in dailyWeather.dailyForecasts) {
          spots.add(
            FlSpot(f.date.millisecondsSinceEpoch.toDouble(), f.temperatureMax),
          );
        }
      } else {
        final hourlyWeather = multiModelHourlyWeather!.models[modelKey]!;
        final List<FlSpot> apparentSpots = [];
        for (final f in hourlyWeather.hourlyForecasts) {
          if (f.temperature != null) {
            spots.add(
              FlSpot(f.time.millisecondsSinceEpoch.toDouble(), f.temperature!),
            );
          }
          if (f.apparentTemperature != null) {
            apparentSpots.add(
              FlSpot(
                f.time.millisecondsSinceEpoch.toDouble(),
                f.apparentTemperature!,
              ),
            );
          }
        }

        if (apparentSpots.isNotEmpty) {
          lineBarsData.add(
            LineChartBarData(
              spots: apparentSpots,
              isCurved: true,
              color: color.withValues(alpha: 0.4),
              barWidth: 1.5,
              dashArray: [4, 4],
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
            ),
          );
        }
      }

      if (spots.isNotEmpty) {
        lineBarsData.add(
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: isDaily,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                    radius: 3,
                    color: color,
                    strokeWidth: 1,
                    strokeColor: Colors.white,
                  ),
            ),
          ),
        );

        if (modelKey == 'best_match') {
          bestMatchSpots.addAll(spots);
        }
      }
    }

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
        checkToShowVerticalLine: isDaily
            ? (value) {
                final dateTime = DateTime.fromMillisecondsSinceEpoch(
                  value.toInt(),
                );
                return dateTime.hour == 0 &&
                    dateTime.minute == 0 &&
                    dateTime.second == 0 &&
                    dateTime.millisecond == 0;
              }
            : (value) => true,
        getDrawingVerticalLine: (value) => FlLine(
          color: ChartTheme.gridLineColor,
          strokeWidth: isDaily ? 1 : 0.5,
        ),
        drawHorizontalLine: true,
        getDrawingHorizontalLine: (value) => FlLine(
          color: ChartTheme.gridLineColorLight,
          strokeWidth: isDaily ? 1 : 0.5,
        ),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          axisNameSize: ChartConstants.bottomAxisNameSize,
          axisNameWidget: Container(),
          sideTitles: SideTitles(
            showTitles: true,
            interval: isDaily
                ? const Duration(days: 1).inMilliseconds.toDouble()
                : const Duration(hours: 2).inMilliseconds.toDouble(),
            reservedSize: ChartConstants.bottomAxisTitleSize,
            getTitlesWidget: (value, meta) => Container(),
          ),
        ),
        leftTitles: AxisTitles(
          axisNameSize: ChartConstants.leftAxisNameSize,
          axisNameWidget: Text(
            isDaily ? AppLocalizations.of(context)!.tempCelsius : '°C',
            style: ChartTheme.axisTitleStyle,
          ),
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: ChartConstants.leftAxisTitleSize,
            interval: 5,
            getTitlesWidget: (value, meta) => Text(
              isDaily ? '${value.round()}°' : '${value.toInt()}',
              style: ChartTheme.axisLabelStyle,
            ),
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      lineBarsData: lineBarsData,
      lineTouchData: const LineTouchData(enabled: false),
      backgroundColor: Colors.transparent,
    );

    return PositionedLineChart(
      config: config,
      data: chartData,
      layers: [
        // Weekend background rectangles for daily mode
        if (isDaily && forecast != null)
          (context, positioner) =>
              _buildWeekendBackgroundRectangles(forecast, positioner),
        // Night rectangles and day separators for hourly mode
        if (!isDaily &&
            forecast != null &&
            multiModelHourlyWeather != null) ...[
          (context, positioner) => _buildNight(
            multiModelHourlyWeather.models.values.first,
            forecast,
            positioner,
          ),
          (context, positioner) => _buildDaySeparators(
            multiModelHourlyWeather.models.values.first,
            positioner,
          ),
        ],
        // X-axis labels
        (context, positioner) => _buildXAxisLabels(
          startTime,
          endTime,
          labels,
          displayMode,
          positioner,
          context,
        ),
        // Temperature labels for best_match
        (context, positioner) => _buildTempLabels(
          bestMatchSpots,
          // modelColors['best_match']!,
          const Color.fromARGB(255, 0, 0, 0),
          positioner,
        ),
      ],
    );
  }

  static Widget _buildWeekendBackgroundRectangles(
    DailyWeather forecast,
    ChartPositioner positioner,
  ) {
    final List<Widget> rectangles = [];
    final chartArea = positioner.getChartArea();

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

  static Widget _buildNight(
    HourlyWeather hourlyWeather,
    DailyWeather forecast,
    ChartPositioner positioner,
  ) {
    List<Widget> nightWidgets = [];
    final startTime = hourlyWeather.hourlyForecasts.first.time;
    final endTime = hourlyWeather.hourlyForecasts.last.time;
    final chartArea = positioner.getChartArea();

    if (forecast.dailyForecasts.isNotEmpty) {
      var firstDay = forecast.dailyForecasts.first;
      if (firstDay.sunrise != null) {
        DateTime sunriseTime = firstDay.sunrise!;
        if (startTime.isBefore(sunriseTime) && sunriseTime.isAfter(startTime)) {
          final sunrisePos = positioner.calculateFromTime(
            sunriseTime,
            positioner.maxY,
          );

          nightWidgets.add(
            Positioned(
              left: chartArea.left,
              top: chartArea.top,
              width: sunrisePos.dx - chartArea.left,
              height: chartArea.height,
              child: Container(color: ChartTheme.nightBackgroundColor),
            ),
          );
        }
      }
    }

    for (var dailyForecast in forecast.dailyForecasts) {
      if (dailyForecast.sunset != null && dailyForecast.sunrise != null) {
        DateTime sunsetTime = dailyForecast.sunset!;
        DateTime sunriseTime = dailyForecast.sunrise!;

        if (sunsetTime.isAfter(startTime) &&
            sunriseTime.isBefore(endTime.add(const Duration(days: 1)))) {
          if (sunriseTime.isBefore(sunsetTime)) {
            sunriseTime = sunriseTime.add(const Duration(days: 1));
          }

          final sunsetPos = positioner.calculateFromTime(
            sunsetTime,
            positioner.maxY,
          );
          final sunrisePos = positioner.calculateFromTime(
            sunriseTime,
            positioner.maxY,
          );

          final nightWidth = sunrisePos.dx - sunsetPos.dx;

          if (nightWidth > 0) {
            nightWidgets.add(
              Positioned(
                left: sunsetPos.dx,
                top: chartArea.top,
                width: nightWidth,
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

  static Widget _buildDaySeparators(
    HourlyWeather hourlyWeather,
    ChartPositioner positioner,
  ) {
    final List<Widget> separators = [];
    final chartArea = positioner.getChartArea();

    for (var f in hourlyWeather.hourlyForecasts) {
      if (f.time.hour == 0 && f.time.minute == 0) {
        final pos = positioner.calculateFromTime(f.time, positioner.minY);

        separators.add(
          Positioned(
            left: pos.dx - 1,
            top: chartArea.top,
            child: Container(
              width: 5,
              height: chartArea.height,
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

  static Widget _buildXAxisLabels(
    DateTime startTime,
    DateTime endTime,
    List<String> labels,
    String displayMode,
    ChartPositioner positioner,
    BuildContext context,
  ) {
    if (labels.isEmpty) return const SizedBox.shrink();

    final List<Widget> widgets = [];
    final bool isDaily = displayMode == 'daily';
    final int step = isDaily ? 1 : 2;

    for (int i = 0; i < labels.length; i += step) {
      final time = isDaily
          ? startTime.add(Duration(days: i))
          : startTime.add(Duration(hours: i));

      TextStyle? style;
      String label = labels[i];

      if (!isDaily) {
        if (time.hour == 0) {
          style = ChartTheme.hour00LabelStyle;
          final monthFormat = DateFormat.MMM(
            Localizations.localeOf(context).languageCode,
          );
          final dayStr = '${time.day} ${monthFormat.format(time)}';
          label += "\n$dayStr";
        } else {
          style = ChartTheme.hourLabelStyle;
        }
      } else {
        style = ChartTheme.dateLabelStyle;
      }

      final pos = positioner.calculateFromTime(time, positioner.minY);

      widgets.add(
        Positioned(
          left: pos.dx - 40,
          top:
              positioner.containerSize.height -
              ChartConstants.bottomTitleReservedSize +
              30,
          child: SizedBox(
            width: 80,
            child: Text(label, textAlign: TextAlign.center, style: style),
          ),
        ),
      );
    }
    return Stack(children: widgets);
  }

  static Widget _buildTempLabels(
    List<FlSpot> spots,
    Color color,
    ChartPositioner positioner,
  ) {
    final widgets = spots.map((spot) {
      final pos = positioner.calculate(spot.x, spot.y);

      return Positioned(
        left: pos.dx - 20,
        top: pos.dy - 30,
        child: SizedBox(
          width: 40,
          child: Text(
            '${spot.y.round()}°',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ),
      );
    }).toList();

    return Stack(children: widgets);
  }
}
