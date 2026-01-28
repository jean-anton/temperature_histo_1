import 'package:flutter/material.dart';
import 'chart_config.dart';

/// Utility to calculate screen coordinates from data coordinates.
/// This ensures positioned widgets align perfectly with fl_chart data points.
class ChartPositioner {
  final ChartConfig config;
  final Size containerSize;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;

  const ChartPositioner({
    required this.config,
    required this.containerSize,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });

  /// Usable chart width (excluding axis labels and borders)
  double get usableWidth => containerSize.width - config.horizontalReserved;

  /// Usable chart height (excluding axis labels and borders)
  double get usableHeight => containerSize.height - config.verticalReserved;

  /// Calculates the (x, y) offset on the screen for a given data point (dx, dy).
  ///
  /// Parameters:
  /// - [dx]: X-axis data value (e.g., time in milliseconds)
  /// - [dy]: Y-axis data value (e.g., temperature in °C)
  ///
  /// Returns: Offset representing screen position in pixels
  Offset calculate(double dx, double dy) {
    if (usableWidth <= 0 || usableHeight <= 0) return Offset.zero;

    // Normalize X (0.0 to 1.0)
    final double xFactor = (dx - minX) / (maxX - minX);
    // Normalize Y (0.0 to 1.0)
    final double yFactor = (dy - minY) / (maxY - minY);

    final double x = config.chartAreaLeft + (xFactor * usableWidth);
    final double y =
        containerSize.height -
        config.bottomReservedSize -
        config.bottomAxisNameSize -
        config.borderWidth -
        (yFactor * usableHeight);

    return Offset(x, y);
  }

  /// Calculate position for a time-series data point
  ///
  /// This is a convenience method that takes DateTime values
  Offset calculateFromTime(DateTime time, double value) {
    return calculate(time.millisecondsSinceEpoch.toDouble(), value);
  }

  /// Helper to get the total chart area rectangle
  Rect getChartArea() {
    return Rect.fromLTWH(
      config.chartAreaLeft,
      config.chartAreaTop,
      usableWidth,
      usableHeight,
    );
  }

  /// Get the top Y position of the chart area (for elements like current time line)
  double get chartTop => config.chartAreaTop;

  /// Get the chart height (for elements that span full height)
  double get chartHeight => usableHeight;
}
