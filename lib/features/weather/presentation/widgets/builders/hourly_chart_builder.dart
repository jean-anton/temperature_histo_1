import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aeroclim/features/weather/domain/weather_model.dart';
import 'package:aeroclim/flchart_positioned/flchart_positioned.dart';
import '../utils/chart_constants.dart';
import '../utils/chart_helpers.dart';
import '../utils/chart_data_provider.dart';
import '../utils/chart_theme.dart';

/// Builder for hourly weather chart
class HourlyChartBuilder {
  /// Build the hourly chart widget
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
    final List<FlSpot> spots = ChartDataProvider.getHourlyTempSpots(
      hourlyWeather,
    );

    final startTime = hourlyWeather.hourlyForecasts.first.time;
    final endTime = hourlyWeather.hourlyForecasts.last.time;

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
            interval: const Duration(hours: 2).inMilliseconds.toDouble(),
            reservedSize: ChartConstants.bottomAxisTitleSize,
            getTitlesWidget: (value, meta) => Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(),
            ),
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
          spots: ChartDataProvider.getHourlyApparentTempSpots(hourlyWeather),
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
        // Night background rectangles (behind everything)
        (context, positioner) =>
            _buildNight(hourlyWeather, forecast, positioner),
        // Weather icons
        (context, positioner) => _buildWeatherIcons(hourlyWeather, positioner),
        // Apparent temperature labels
        // (context, positioner) =>
        //     _buildApparentTempLabels(hourlyWeather, positioner),
        // Hour labels at bottom
        (context, positioner) =>
            _buildHourLabels(hourlyWeather, positioner, hourLabels),
        // Current time line
        (context, positioner) =>
            _buildCurrentTimeLine(hourlyWeather, positioner),
        // Sunrise/sunset info
        (context, positioner) =>
            _buildSunriseSunsetInfo(hourlyWeather, forecast, positioner),
        // Day separators
        (context, positioner) => _buildDaySeparators(hourlyWeather, positioner),
        // Wind info if enabled
        if (showWindInfo)
          (context, positioner) => _buildWindInfo(hourlyWeather, positioner),
      ],
    );
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

  static Widget _buildNight(
    HourlyWeather hourlyWeather,
    DailyWeather forecast,
    ChartPositioner positioner,
  ) {
    List<Widget> nightWidgets = [];
    final startTime = hourlyWeather.hourlyForecasts.first.time;
    final endTime = hourlyWeather.hourlyForecasts.last.time;
    final chartArea = positioner.getChartArea();

    // Check if chart starts during night period (before sunrise of first day)
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
              //child: Container(color: Colors.red),
            ),
          );
        }
      }
    }

    // Iterate through daily forecasts to find sunset/sunrise times
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

  /// Build weather icons for hourly chart
  static Widget _buildWeatherIcons(
    HourlyWeather hourlyWeather,
    ChartPositioner positioner,
  ) {
    final widgets = hourlyWeather.hourlyForecasts.asMap().entries.map((entry) {
      final HourlyForecast hourly = entry.value;

      // Skip if no temperature data
      if (hourly.temperature == null) return const SizedBox.shrink();

      final String? iconPath = ChartHelpers.getIconPath(
        code: hourly.weatherCode,
        iconName: hourly.weatherIcon,
        isDay: hourly.isDay,
      );

      final pos = positioner.calculateFromTime(
        hourly.time,
        hourly.temperature ?? 0,
      );

      return Positioned(
        left: pos.dx - 10,
        top: pos.dy - 75,
        child: SizedBox(
          width: 45,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Only show weather icon if available (some models like ECMWF IFS don't provide weather_code)
              if (iconPath != null)
                SvgPicture.asset(iconPath, width: 45, height: 45),
              if (iconPath != null) const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    '${hourly.temperature!.round()}°',
                    style: ChartTheme.temperatureMaxLabelStyle,
                  ),
                  const SizedBox(width: 2),
                  if (hourly.apparentTemperature != null)
                    Text(
                      ' ${hourly.apparentTemperature!.round()}°',
                      style: ChartTheme.apparentTempLabelStyle,
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

  /// Build apparent temperature labels
  static Widget _buildApparentTempLabels(
    HourlyWeather hourlyWeather,
    ChartPositioner positioner,
  ) {
    final widgets = hourlyWeather.hourlyForecasts.asMap().entries.map((entry) {
      final HourlyForecast hourly = entry.value;

      if (hourly.apparentTemperature == null) return const SizedBox.shrink();

      final pos = positioner.calculateFromTime(
        hourly.time,
        hourly.temperature ?? 0,
      );

      return Positioned(
        left: pos.dx - 25,
        top: pos.dy + 5,
        child: SizedBox(
          width: 50,
          child: Text(
            '${hourly.apparentTemperature!.round()}°',
            textAlign: TextAlign.center,
            style: ChartTheme.apparentTempLabelStyle,
          ),
        ),
      );
    }).toList();

    return Stack(children: widgets);
  }

  /// Build wind direction icons and speed/gusts labels for hourly chart
  static Widget _buildWindInfo(
    HourlyWeather hourlyWeather,
    ChartPositioner positioner,
  ) {
    final widgets = hourlyWeather.hourlyForecasts.asMap().entries.map((entry) {
      final HourlyForecast hourly = entry.value;

      if (hourly.windSpeed == null) return const SizedBox.shrink();

      final pos = positioner.calculateFromTime(
        hourly.time,
        hourly.temperature ?? 0,
      );

      final windIconPath = "assets/google_weather_icons/v3/arrow.svg";
      final windIconPathContour =
          "assets/google_weather_icons/v3/arrow_contour.svg";
      final windDirectionDegrees = hourly.windDirection10m ?? 0;

      return Positioned(
        left: pos.dx - 100,
        top: pos.dy + 10,
        child: SizedBox(
          width: 200,
          child: Column(
            children: [
              Text(
                '${hourly.windSpeed!.round()} km/h',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
              Stack(
                children: [
                  Transform.rotate(
                    angle: (135 + windDirectionDegrees) * (3.14159 / 180),
                    child: SvgPicture.asset(
                      windIconPath,
                      width: (hourly.windGusts ?? 0.0) * 2,
                      height: (hourly.windGusts ?? 0.0) * 2,
                      colorFilter: ColorFilter.mode(
                        ChartTheme.windGustColor(hourly.windGusts ?? 0.0),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  Transform.rotate(
                    angle: (135 + windDirectionDegrees) * (3.14159 / 180),
                    child: SvgPicture.asset(
                      windIconPathContour,
                      width: (hourly.windGusts ?? 0.0) * 2,
                      height: (hourly.windGusts ?? 0.0) * 2,
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

  /// Build hour labels for the bottom axis
  static Widget _buildHourLabels(
    HourlyWeather hourlyWeather,
    ChartPositioner positioner,
    List<String> hourLabels,
  ) {
    final widgets = hourlyWeather.hourlyForecasts
        .asMap()
        .entries
        .where((entry) => entry.key % 2 == 0)
        .map((entry) {
          final int index = entry.key;
          final HourlyForecast hourly = entry.value;
          final date = hourly.time;
          TextStyle? style;
          String day = "";
          if (date.hour == 0) {
            style = ChartTheme.hour00LabelStyle;
            day =
                '${date.day} ${['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'][date.month - 1]}';
          } else {
            style = ChartTheme.hourLabelStyle;
          }
          final String? label =
              hourLabels.isNotEmpty && index < hourLabels.length
              ? hourLabels[index] + "\n" + day
              : null;

          if (label == null) return const SizedBox.shrink();

          final pos = positioner.calculateFromTime(
            hourly.time,
            hourly.temperature ?? 0,
          );

          return Positioned(
            left: pos.dx - 40,
            top:
                positioner.containerSize.height -
                ChartConstants.bottomTitleReservedSize +
                30,
            child: SizedBox(
              width: 80,
              child: Text(label, textAlign: TextAlign.center, style: style),
            ),
          );
        })
        .toList();

    return Stack(children: widgets);
  }

  /// Build sunrise and sunset icons and times
  static Widget _buildSunriseSunsetInfo(
    HourlyWeather hourlyWeather,
    DailyWeather forecast,
    ChartPositioner positioner,
  ) {
    final List<Widget> sunriseSunsetWidgets = [];

    for (var daily in forecast.dailyForecasts) {
      if (daily.sunrise != null) {
        final int sunriseHour = daily.sunrise!.hour;
        final int sunriseMinute = daily.sunrise!.minute;
        int hourIndex = -1;

        for (int i = 0; i < hourlyWeather.hourlyForecasts.length; i++) {
          if (hourlyWeather.hourlyForecasts[i].time.day == daily.date.day &&
              hourlyWeather.hourlyForecasts[i].time.hour == sunriseHour) {
            hourIndex = i;
            break;
          }
        }

        if (hourIndex != -1) {
          final pos = positioner.calculateFromTime(daily.sunrise!, 0);

          sunriseSunsetWidgets.add(
            Positioned(
              left: pos.dx - 20,
              bottom: ChartConstants.bottomTitleReservedSize - 15,
              child: Column(
                children: [
                  const Icon(Icons.wb_sunny, color: Colors.amber, size: 25),
                  Text(
                    '${sunriseHour.toString().padLeft(2, '0')}:${sunriseMinute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }

      if (daily.sunset != null) {
        final int sunsetHour = daily.sunset!.hour;
        final int sunsetMinute = daily.sunset!.minute;
        int hourIndex = -1;

        for (int i = 0; i < hourlyWeather.hourlyForecasts.length; i++) {
          if (hourlyWeather.hourlyForecasts[i].time.day == daily.date.day &&
              hourlyWeather.hourlyForecasts[i].time.hour == sunsetHour) {
            hourIndex = i;
            break;
          }
        }

        if (hourIndex != -1) {
          final pos = positioner.calculateFromTime(daily.sunset!, 0);

          sunriseSunsetWidgets.add(
            Positioned(
              left: pos.dx - 20,
              bottom: ChartConstants.bottomTitleReservedSize - 15,
              child: Column(
                children: [
                  const Icon(
                    Icons.nights_stay,
                    color: Colors.blueGrey,
                    size: 25,
                  ),
                  Text(
                    '${sunsetHour.toString().padLeft(2, '0')}:${sunsetMinute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    }

    return Stack(children: sunriseSunsetWidgets);
  }
}
