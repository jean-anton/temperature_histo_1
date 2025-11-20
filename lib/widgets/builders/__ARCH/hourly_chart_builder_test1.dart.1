import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/weather_forecast_model.dart';
import '../utils/chart_constants.dart';
import '../utils/chart_helpers.dart';
import '../utils/chart_data_provider.dart';

class HourlyChartBuilder_test1 {
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
    print(
      "### CJG 192: startTime: $startTime minTemp: $minTemp maxTemp: $maxTemp,${hourlyWeather.hourlyForecasts.first.temperature} ",
    );
    final minX = startTime.millisecondsSinceEpoch.toDouble();
    final maxX = hourlyWeather.hourlyForecasts.last.time.millisecondsSinceEpoch
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
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              verticalInterval: const Duration(
                hours: 1,
              ).inMilliseconds.toDouble(),
              getDrawingVerticalLine: (value) =>
                  FlLine(color: Colors.grey, strokeWidth: 0.5),
              drawHorizontalLine: true,
              horizontalInterval: 5,
              getDrawingHorizontalLine: (value) =>
                  FlLine(color: Colors.grey, strokeWidth: 0.5),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                dotData: const FlDotData(show: true),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
