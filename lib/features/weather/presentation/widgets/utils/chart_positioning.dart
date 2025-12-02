import 'package:flutter/material.dart';
import 'chart_constants.dart';

/// Utilities for calculating screen positions in weather charts
class ChartPositioning {
  /// Calculate screen position for a data point in a time-series chart
  ///
  /// This converts data coordinates (time in milliseconds, temperature value)
  /// to screen coordinates (x, y pixels) accounting for chart padding and axis labels.
  ///
  /// Parameters:
  /// - [timeMs]: Time value in milliseconds since epoch
  /// - [value]: Y-axis value (e.g., temperature in °C)
  /// - [containerSize]: Size of the chart container widget
  /// - [minValue]: Minimum Y-axis value (e.g., min temperature)
  /// - [maxValue]: Maximum Y-axis value (e.g., max temperature)
  /// - [startTime]: Start time of the data range
  /// - [endTime]: End time of the data range
  ///
  /// Returns: Offset representing the screen position (x, y) in pixels
  
  static Offset calculatePosition(
    {required double timeMs,
    required double value,
    required Size containerSize,
    required double minValue,
    required double maxValue,
    //HourlyWeather dailyWeather,
    required DateTime startTime,
    required DateTime endTime,}
  ) {
    final chartWidth =
        //constraints.maxWidth -
        containerSize.width -
        ChartConstants.leftAxisTitleSize -
        ChartConstants.leftAxisNameSize -
        2 * ChartConstants.borderWidth;
    final chartHeight =
        //constraints.maxHeight -
        containerSize.height -
        ChartConstants.bottomAxisTitleSize -
        ChartConstants.bottomAxisNameSize -
        2 * ChartConstants.borderWidth;

    //final List<FlSpot> spots = ChartDataProvider.getHourlyTempSpots(dailyWeather);

    //final startTime = dailyWeather.hourlyForecasts.first.time;
    //print("### CJG 192: startTime: $startTime minTemp: $minTemp maxTemp: $maxTemp,${dailyWeather.hourlyForecasts.first.temperature} ");
    final minX = startTime.millisecondsSinceEpoch.toDouble();
    // final maxX = startTime
    //     .add(const Duration(hours: 44))
    //     .millisecondsSinceEpoch
    //     .toDouble();
    final maxX = endTime.millisecondsSinceEpoch.toDouble();
    final minY = minValue - 5;
    final maxY = maxValue + 5;

    final x =
        ChartConstants.leftAxisTitleSize +
        ChartConstants.leftAxisNameSize +
        (timeMs - minX) / (maxX - minX) * chartWidth +
        ChartConstants.borderWidth;
    final y =
        chartHeight -
        ((value - minY) / (maxY - minY)) * chartHeight +
        ChartConstants.borderWidth;

    return Offset(x, y);
  }

  
  
  
  
  
  
  
  static Offset calculatePosition_antigravity({
    required double timeMs,
    required double value,
    required Size containerSize,
    required double minValue,
    required double maxValue,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    // Calculate the total time range in milliseconds
    final double totalTimeMs =
        endTime.millisecondsSinceEpoch.toDouble() -
        startTime.millisecondsSinceEpoch.toDouble();

    // Calculate the usable chart area (excluding padding and axis labels)
    final double chartWidth =
        containerSize.width -
        ChartConstants.leftPadding -
        ChartConstants.rightPadding -
        ChartConstants.leftTitleReservedSize;

    final double chartHeight =
        containerSize.height -
        ChartConstants.topPadding -
        ChartConstants.bottomPadding;

    // Calculate normalized position within the data range (0.0 to 1.0)
    final double normalizedTime =
        (timeMs - startTime.millisecondsSinceEpoch.toDouble()) / totalTimeMs;
    final double normalizedValue = (value - minValue) / (maxValue - minValue);

    // Convert to screen coordinates
    // X: Left padding + axis label space + position within chart
    final double x =
        ChartConstants.leftPadding +
        ChartConstants.leftTitleReservedSize +
        (normalizedTime * chartWidth);

    // Y: Top padding + inverted position (higher values = lower on screen)
    final double y =
        ChartConstants.topPadding + ((1.0 - normalizedValue) * chartHeight);

    return Offset(x, y);
  }

  /// Calculate screen position using index-based positioning (legacy method)
  ///
  /// This is a simpler version for evenly-spaced data points.
  /// Prefer [calculatePosition] for time-series data.
  ///
  /// Parameters:
  /// - [index]: Index of the data point in the series
  /// - [value]: Y-axis value
  /// - [containerSize]: Size of the chart container
  /// - [minValue]: Minimum Y-axis value
  /// - [maxValue]: Maximum Y-axis value
  /// - [maxIndex]: Maximum index value (total points - 1)
  /// - [chartType]: Type of chart ('daily' or 'hourly') for spacing adjustments
  static Offset calculatePositionByIndex({
    required double index,
    required double value,
    required Size containerSize,
    required double minValue,
    required double maxValue,
    required double maxIndex,
    required String chartType,
  }) {
    final double chartWidth =
        containerSize.width -
        ChartConstants.leftPadding -
        ChartConstants.rightPadding -
        ChartConstants.leftTitleReservedSize;

    final double chartHeight =
        containerSize.height -
        ChartConstants.topPadding -
        ChartConstants.bottomPadding;

    final double normalizedIndex = index / maxIndex;
    final double normalizedValue = (value - minValue) / (maxValue - minValue);

    final double x =
        ChartConstants.leftPadding +
        ChartConstants.leftTitleReservedSize +
        (normalizedIndex * chartWidth);

    final double y =
        ChartConstants.topPadding + ((1.0 - normalizedValue) * chartHeight);

    return Offset(x, y);
  }
}
