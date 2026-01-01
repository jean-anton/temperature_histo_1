import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:temperature_histo_1/features/weather/domain/weather_model.dart';
import '../utils/chart_constants.dart';
import '../utils/chart_helpers.dart';
import '../utils/chart_data_provider.dart';
import '../utils/chart_theme.dart';
import '../utils/chart_positioning.dart';

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

    final minX = startTime.millisecondsSinceEpoch.toDouble();
    // final maxX = startTime
    //     .add(const Duration(hours: 44))
    //     .millisecondsSinceEpoch
    //     .toDouble();
    //final maxX = hourlyWeather.hourlyForecasts.last.time.subtract(Duration(days: 1)).millisecondsSinceEpoch.toDouble();
    final maxX = hourlyWeather.hourlyForecasts.last.time
        //.add(const Duration(hours: 1))
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
              getDrawingVerticalLine: (value) =>
                  FlLine(color: ChartTheme.gridLineColor, strokeWidth: 0.5),
              drawHorizontalLine: true,
              horizontalInterval: 5,
              getDrawingHorizontalLine: (value) => FlLine(
                color: ChartTheme.gridLineColorLight,
                strokeWidth: 0.5,
              ),
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
                  interval: 5,
                  reservedSize: ChartConstants.leftAxisTitleSize,
                  getTitlesWidget: (value, meta) => Text('${value.toInt()}'),
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
                isCurved: true,
                spots: spots,
                dotData: const FlDotData(show: true),
              ),
            ],
            backgroundColor: Colors.transparent,
            lineTouchData: const LineTouchData(enabled: false),
          ),
        ),

        ..._buildNight(
          hourlyWeather,
          forecast,
          minTemp,
          maxTemp,
          containerSize,
        ),
        ..._buildWeatherIcons(hourlyWeather, minTemp, maxTemp, containerSize),
        // _buildCurrentTimeLine(hourlyWeather, minTemp, maxTemp, containerSize),
        ..._buildApparentTempLabels(
          hourlyWeather,
          minTemp,
          maxTemp,
          containerSize,
        ),
        ..._buildHourLabels(
          hourlyWeather,
          minTemp,
          maxTemp,
          containerSize,
          hourLabels,
        ),
        _buildCurrentTimeLine(hourlyWeather, minTemp, maxTemp, containerSize),
        ..._buildSunriseSunsetInfo(
          hourlyWeather,
          forecast,
          minTemp,
          maxTemp,
          containerSize,
        ),
        if (showWindInfo)
          ..._buildWindInfo(hourlyWeather, minTemp, maxTemp, containerSize),
      ],
    );
  }

  static List<Widget> _buildNight(
    HourlyWeather hourlyWeather,
    DailyWeather forecast,
    double minTemp,
    double maxTemp,
    Size containerSize,
  ) {
    List<Widget> nightWidgets = [];

    // Get the start time of the hourly forecast
    final startTime = hourlyWeather.hourlyForecasts.first.time;
    final endTime = hourlyWeather.hourlyForecasts.last.time;

    // Check if the chart starts during a night period (before sunrise of the first day)
    if (forecast.dailyForecasts.isNotEmpty) {
      // Check the first day's sunrise to see if chart starts before sunrise
      var firstDay = forecast.dailyForecasts.first;
      if (firstDay.sunrise != null) {
        DateTime sunriseTime = firstDay.sunrise!;
        if (startTime.isBefore(sunriseTime) && sunriseTime.isAfter(startTime)) {
          // Chart starts during night period (before sunrise of first day)
          final sunriseScreenPos = ChartPositioning.calculatePosition(
            timeMs: sunriseTime.millisecondsSinceEpoch.toDouble(),
            value: maxTemp,
            containerSize: containerSize,
            minValue: minTemp,
            maxValue: maxTemp,
            startTime: startTime,
            endTime: endTime,
          );

          nightWidgets.add(
            Positioned(
              left:
                  ChartConstants.leftPadding +
                  ChartConstants
                      .leftTitleReservedSize, // Start from the left edge of the chart area
              top: ChartConstants.topPadding,
              width:
                  sunriseScreenPos.dx -
                  (ChartConstants.leftPadding +
                      ChartConstants.leftTitleReservedSize),
              height:
                  containerSize.height -
                  ChartConstants.topPadding -
                  ChartConstants.bottomPadding,
              child: Container(
                color: ChartTheme.nightBackgroundColor,
                child: null,
              ),
            ),
          );
        }
      }
    }

    // Iterate through daily forecasts to find sunset/sunrise times
    for (var dailyForecast in forecast.dailyForecasts) {
      // Check if both sunset and sunrise exist for this day
      if (dailyForecast.sunset != null && dailyForecast.sunrise != null) {
        // Calculate sunset and sunrise times for the current day
        DateTime sunsetTime = dailyForecast.sunset!;
        DateTime sunriseTime = dailyForecast.sunrise!;

        // Only consider night periods that fall within our hourly forecast range
        if (sunsetTime.isAfter(startTime) &&
            sunriseTime.isBefore(endTime.add(const Duration(days: 1)))) {
          // If sunrise is the next day, adjust accordingly
          if (sunriseTime.isBefore(sunsetTime)) {
            sunriseTime = sunriseTime.add(
              const Duration(days: 1),
            ); // Sunrise is next day
          }

          // Calculate screen positions for sunset and sunrise
          final sunsetScreenPos = ChartPositioning.calculatePosition(
            timeMs: sunsetTime.millisecondsSinceEpoch.toDouble(),
            value: maxTemp,
            containerSize: containerSize,
            minValue: minTemp,
            maxValue: maxTemp,
            startTime: hourlyWeather.hourlyForecasts.first.time,
            endTime: hourlyWeather.hourlyForecasts.last.time,
          );

          final sunriseScreenPos = ChartPositioning.calculatePosition(
            timeMs: sunriseTime.millisecondsSinceEpoch.toDouble(),
            value: maxTemp,
            containerSize: containerSize,
            minValue: minTemp,
            maxValue: maxTemp,
            startTime: hourlyWeather.hourlyForecasts.first.time,
            endTime: hourlyWeather.hourlyForecasts.last.time,
          );

          // Calculate the width of the night rectangle
          final nightWidth = sunriseScreenPos.dx - sunsetScreenPos.dx;

          // Only add the rectangle if it has a positive width (valid time range)
          if (nightWidth > 0) {
            nightWidgets.add(
              Positioned(
                left: sunsetScreenPos.dx,
                top: ChartConstants.topPadding,
                width: nightWidth,
                height:
                    containerSize.height -
                    ChartConstants.topPadding -
                    ChartConstants.bottomPadding,
                child: Container(
                  color: ChartTheme.nightBackgroundColor,
                  child: null,
                ),
              ),
            );
          }
        }
      }
    }

    return nightWidgets;
  }

  /// Build a vertical line marking the current time
  static Widget _buildCurrentTimeLine(
    HourlyWeather hourlyWeather,
    double minTemp,
    double maxTemp,
    Size containerSize,
  ) {
    // Find the index of the current time in the hourly forecasts
    final now = DateTime.now();
    final screenPos = ChartPositioning.calculatePosition(
      timeMs: now.millisecondsSinceEpoch.toDouble(),
      value: minTemp,
      containerSize: containerSize,
      minValue: minTemp,
      maxValue: maxTemp,
      startTime: hourlyWeather.hourlyForecasts.first.time,
      endTime: hourlyWeather.hourlyForecasts.last.time,
    );

    return Positioned(
      left: screenPos.dx,
      top: ChartConstants.topPadding,
      child: Container(
        width: 2,
        height:
            containerSize.height -
            ChartConstants.topPadding -
            ChartConstants.bottomPadding,
        color: ChartTheme.currentTimeLineColor,
      ),
    );
  }

  /// Build weather icons for hourly chart
  static List<Widget> _buildWeatherIcons(
    HourlyWeather hourlyWeather,
    double minTemp,
    double maxTemp,
    Size containerSize,
  ) {
    return hourlyWeather.hourlyForecasts.asMap().entries.map((entry) {
      final int index = entry.key;
      final HourlyForecast hourly = entry.value;
      final String? iconPath = ChartHelpers.getIconPath(
        code: hourly.weatherCode,
        iconName: hourly.weatherIcon,
        isDay: hourly.isDay,
      );

      if (iconPath == null) return const SizedBox.shrink();

      //print("### CJG 291: iconPath: $iconPath, isDay: ${hourly.isDay}");
      var screenPosition = ChartPositioning.calculatePosition(
        timeMs: hourly.time.millisecondsSinceEpoch.toDouble(),
        value: hourly.temperature ?? 0,
        containerSize: containerSize,
        minValue: minTemp,
        maxValue: maxTemp,
        startTime: hourlyWeather.hourlyForecasts.first.time,
        endTime: hourlyWeather.hourlyForecasts.last.time,
      );

      // //print("### CJG 291: iconPath: $iconPath, isDay: ${hourly.isDay}");
      // var screenPosition = ChartPositioning.calculatePosition(
      //   timeMs: hourly.time.millisecondsSinceEpoch.toDouble(),
      //   value: hourly.temperature ?? 0,
      //   containerSize: containerSize,
      //   minValue: minTemp,
      //   maxValue: maxTemp,
      //   startTime: hourlyWeather.hourlyForecasts.first.time,
      //   endTime: hourlyWeather.hourlyForecasts.last.time,
      // );
      //print("### CJG 293: screenPosition: $screenPosition");

      //screenPosition = Offset(298.5, 212.3);
      final x = screenPosition.dx;
      final y = screenPosition.dy;
      return Positioned(
        left: x - 22.5,
        top: y - 75,
        child: SizedBox(
          width: 45,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(iconPath, width: 45, height: 45),
              const SizedBox(height: 4),
              Text(
                '${hourly.temperature!.round()}°',
                style: ChartTheme.temperatureMaxLabelStyle,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  /// Build apparent temperature labels
  static List<Widget> _buildApparentTempLabels(
    HourlyWeather hourlyWeather,
    double minTemp,
    double maxTemp,
    Size containerSize,
  ) {
    return hourlyWeather.hourlyForecasts.asMap().entries.map((entry) {
      final HourlyForecast hourly = entry.value;

      if (hourly.apparentTemperature == null) return const SizedBox.shrink();

      final screenPos = ChartPositioning.calculatePosition(
        timeMs: hourly.time.millisecondsSinceEpoch.toDouble(),
        value: hourly.temperature ?? 0,
        containerSize: containerSize,
        minValue: minTemp,
        maxValue: maxTemp,
        startTime: hourlyWeather.hourlyForecasts.first.time,
        endTime: hourlyWeather.hourlyForecasts.last.time,
      );
      if (entry.key == 0) {
        print(
          "### CJG 396: hourly.time: ${hourly.time}, value: ${hourly.temperature}, containerSize: $containerSize, minTemp: $minTemp, maxTemp: $maxTemp, startTime: ${hourlyWeather.hourlyForecasts.first.time}, endTime: ${hourlyWeather.hourlyForecasts.last.time}, screenPos: $screenPos",
        );
      }
      return Positioned(
        left: screenPos.dx - 25,
        top: screenPos.dy + 5,
        child: SizedBox(
          width: 50,
          child: Text(
            '${hourly.apparentTemperature!.round()}°',
            //'x',
            textAlign: TextAlign.center,
            style: ChartTheme.apparentTempLabelStyle,
          ),
        ),
      );
    }).toList();
  }

  /// Build wind direction icons and speed/gusts labels for hourly chart
  static List<Widget> _buildWindInfo(
    HourlyWeather hourlyWeather,
    double minTemp,
    double maxTemp,
    Size containerSize,
  ) {
    return hourlyWeather.hourlyForecasts.asMap().entries.map((entry) {
      final int index = entry.key;
      final HourlyForecast hourly = entry.value;

      if (hourly.windSpeed == null) return const SizedBox.shrink();

      var screenPosition = ChartPositioning.calculatePosition(
        timeMs: hourly.time.millisecondsSinceEpoch.toDouble(),
        value: hourly.temperature ?? 0,
        containerSize: containerSize,
        minValue: minTemp,
        maxValue: maxTemp,
        startTime: hourlyWeather.hourlyForecasts.first.time,
        endTime: hourlyWeather.hourlyForecasts.last.time,
      );
      //print("### CJG 293: screenPosition: $screenPosition");

      //screenPosition = Offset(298.5, 212.3);
      final x = screenPosition.dx;
      final y = screenPosition.dy;

      //final windIconPath = ChartHelpers.getWindDirectionIconPath(hourly.windDirection10m);
      final windIconPath = "assets/google_weather_icons/v3/arrow.svg";
      final windIconPathContour =
          "assets/google_weather_icons/v3/arrow_contour.svg";

      //final windIconPath = "assets/google_weather_icons/v3/arrow_centered_jg.svg";
      final windDirectionDegrees = hourly.windDirection10m ?? 0;

      return Positioned(
        left: x - 100,
        top: y + 25, // Position below temperature
        child: SizedBox(
          width: 200,
          child: Column(
            //mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${hourly.windSpeed!.round()} km/h',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue, // Blue color for wind speed
                ),
              ),
              // Wind direction icon with rotation
              // Arrow SVG points east (90°) by default, so rotate relative to that
              Stack(
                children: [
                  Transform.rotate(
                    //angle: (windDirectionDegrees - 90) * (3.14159 / 180), // Convert degrees to radians
                    angle:
                        (135 + windDirectionDegrees) *
                        (3.14159 / 180), // Convert degrees to radians
                    child: SvgPicture.asset(
                      windIconPath,
                      // width: 50 * (hourly.windGusts ?? 0.0) / 20, // Scale size by wind speed (max 20 m/s)
                      // height: 50 * (hourly.windGusts ?? 0.0) / 20,
                      // colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
                      width:
                          (hourly.windGusts ?? 0.0) *
                          2, // Scale size by wind speed (max 20 m/s)
                      height: (hourly.windGusts ?? 0.0) * 2,
                      colorFilter: ColorFilter.mode(
                        ChartTheme.windGustColor(hourly.windGusts ?? 0.0),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  Transform.rotate(
                    //angle: (windDirectionDegrees - 90) * (3.14159 / 180), // Convert degrees to radians
                    angle:
                        (135 + windDirectionDegrees) *
                        (3.14159 / 180), // Convert degrees to radians
                    child: SvgPicture.asset(
                      windIconPathContour,
                      // width: 50 * (hourly.windGusts ?? 0.0) / 20, // Scale size by wind speed (max 20 m/s)
                      // height: 50 * (hourly.windGusts ?? 0.0) / 20,
                      // colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
                      width:
                          (hourly.windGusts ?? 0.0) *
                          2, // Scale size by wind speed (max 20 m/s)
                      height: (hourly.windGusts ?? 0.0) * 2,
                      //colorFilter: const ColorFilter.mode(Colors.deepPurple, BlendMode.srcIn),
                      // colorFilter: ColorFilter.mode(
                      //   gustColor(hourly.windGusts ?? 0.0),
                      //   BlendMode.srcIn,
                      // ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  /// Build hour labels for the bottom axis
  static List<Widget> _buildHourLabels(
    HourlyWeather hourlyWeather,
    double minTemp,
    double maxTemp,
    Size containerSize,
    List<String> hourLabels,
  ) {
    return hourlyWeather.hourlyForecasts
        .asMap()
        .entries
        .where((entry) => entry.key % 2 == 0) // keep only every 3rd
        .map((entry) {
          final int index = entry.key;
          final HourlyForecast hourly = entry.value;
          final String? label =
              hourLabels.isNotEmpty && index < hourLabels.length
              ? hourLabels[index]
              : null;

          if (label == null) return const SizedBox.shrink();

          final screenPos = ChartPositioning.calculatePosition(
            timeMs: hourly.time.millisecondsSinceEpoch.toDouble(),
            value: hourly.temperature ?? 0,
            containerSize: containerSize,
            minValue: minTemp,
            maxValue: maxTemp,
            startTime: hourlyWeather.hourlyForecasts.first.time,
            endTime: hourlyWeather.hourlyForecasts.last.time,
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
                label+'x',
                textAlign: TextAlign.center,
                style: ChartTheme.hourLabelStyle,
                // style: const TextStyle(
                //   fontSize: 15,
                //   fontWeight: FontWeight.w500,
                //   color: Colors.black87,
                // ),
              ),
            ),
          );
        })
        .toList();
  }

  /// Build sunrise and sunset icons and times
  static List<Widget> _buildSunriseSunsetInfo(
    HourlyWeather hourlyWeather,
    DailyWeather forecast,
    double minTemp,
    double maxTemp,
    Size containerSize,
  ) {
    final List<Widget> sunriseSunsetWidgets = [];
    final double chartWidth =
        containerSize.width -
        ChartConstants.leftPadding -
        ChartConstants.rightPadding -
        ChartConstants.leftTitleReservedSize;
    final double hourWidth = chartWidth / hourlyWeather.hourlyForecasts.length;

    for (var daily in forecast.dailyForecasts) {
      if (daily.sunrise != null) {
        // Extract hour and minute from sunrise time
        final int sunriseHour = daily.sunrise!.hour;
        final int sunriseMinute = daily.sunrise!.minute;
        int hourIndex = -1;

        // Find the matching hour index in hourly forecasts
        for (int i = 0; i < hourlyWeather.hourlyForecasts.length; i++) {
          if (hourlyWeather.hourlyForecasts[i].time.day == daily.date.day &&
              hourlyWeather.hourlyForecasts[i].time.hour == sunriseHour) {
            hourIndex = i;
            break;
          }
        }

        if (hourIndex != -1) {
          final screenPos = ChartPositioning.calculatePosition(
            timeMs: daily.sunrise!.millisecondsSinceEpoch.toDouble(),
            value: ChartConstants.bottomTitleReservedSize - 15,
            containerSize: containerSize,
            minValue: minTemp,
            maxValue: maxTemp,
            startTime: hourlyWeather.hourlyForecasts.first.time,
            endTime: hourlyWeather.hourlyForecasts.last.time,
          );

          sunriseSunsetWidgets.add(
            Positioned(
              left: screenPos.dx - 20,
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
        // Extract hour and minute from sunset time
        final int sunsetHour = daily.sunset!.hour;
        final int sunsetMinute = daily.sunset!.minute;
        int hourIndex = -1;

        // Find the matching hour index in hourly forecasts
        for (int i = 0; i < hourlyWeather.hourlyForecasts.length; i++) {
          if (hourlyWeather.hourlyForecasts[i].time.day == daily.date.day &&
              hourlyWeather.hourlyForecasts[i].time.hour == sunsetHour) {
            hourIndex = i;
            break;
          }
        }

        if (hourIndex != -1) {
          final screenPos = ChartPositioning.calculatePosition(
            timeMs: daily.sunset!.millisecondsSinceEpoch.toDouble(),
            value: ChartConstants.bottomTitleReservedSize - 15,
            containerSize: containerSize,
            minValue: minTemp,
            maxValue: maxTemp,
            startTime: hourlyWeather.hourlyForecasts.first.time,
            endTime: hourlyWeather.hourlyForecasts.last.time,
          );

          sunriseSunsetWidgets.add(
            Positioned(
              left: screenPos.dx - 20,
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

    return sunriseSunsetWidgets;
  }
}
