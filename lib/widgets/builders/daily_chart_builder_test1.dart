import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:temperature_histo_1/models/climate_normal_model.dart';

import '../../models/weather_forecast_model.dart';
import '../utils/chart_constants.dart';
import '../utils/chart_helpers.dart';
import '../utils/chart_data_provider.dart';

/// Builder for daily weather chart
class DailyChartBuilder_test {
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
    // for (DailyForecast df in forecast.dailyForecasts) {
    //   print(
    //     "### CJG 256: Daily date: ${df.date}, maxTemp: ${df.temperatureMax} ",
    //   );
    // }

    for (int i = 0; i < forecast.dailyForecasts.length - 1; i++) {
      final current = forecast.dailyForecasts[i].date.millisecondsSinceEpoch;
      final next = forecast.dailyForecasts[i + 1].date.millisecondsSinceEpoch;
      final diff = next - current;
      final hours = diff / (1000 * 60 * 60);
      print("### Day ${i} to ${i + 1}: difference = $hours hours (${diff}ms)");
    }
    print(
      "### CJG 192: startTime: $startTime minTemp: $minTemp maxTemp: $maxTemp,${forecast.dailyForecasts.first.temperatureMax} ",
    );
    //final minX = startTime.millisecondsSinceEpoch.toDouble();
    final minX = startTime.millisecondsSinceEpoch.toDouble() + 1000;
    final maxX = forecast.dailyForecasts.last.date.millisecondsSinceEpoch
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
                color: Colors.grey.shade300,
                width: ChartConstants.borderWidth,
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              verticalInterval: const Duration(
                hours: 1,
              ).inMilliseconds.toDouble(),

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
                return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
              },
            ),

            lineBarsData: [
              LineChartBarData(
                spots: spotsMAxTemp,
                dotData: const FlDotData(show: true),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
