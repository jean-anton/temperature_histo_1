import 'package:flutter/material.dart';

/// Theme and styling constants for weather charts
class ChartTheme {
  // Color schemes
  static const temperatureMaxColor = Colors.red;
  static final temperatureMaxLineColor = Colors.red.shade400;
  static final temperatureMaxDotColor = Colors.red.shade600;

  static const temperatureMinColor = Colors.blue;
  static final temperatureMinLineColor = Colors.blue.shade300;
  static final temperatureMinDotColor = Colors.blue.shade600;

  static final normalMaxLineColor = Colors.red.shade300;
  static final normalMinLineColor = Colors.blue.shade300;

  static final gridLineColor = Colors.grey.shade300;
  static final gridLineColorLight = Colors.grey.shade200;
  static final borderColor = Colors.grey.shade300;

  static final weekendBackgroundColor = Colors.lightBlue.shade300.withValues(
    alpha: 0.3,
  );
  static final nightBackgroundColor = Colors.indigo.shade900.withValues(
    alpha: 0.4,
  );

  static final currentTimeLineColor = Colors.orange.shade600;

  // Deviation colors
  static final deviationWarmBackground = Colors.red.shade50;
  static final deviationCoolBackground = Colors.blue.shade50;
  static final deviationWarmText = Colors.red.shade900;
  static final deviationCoolText = Colors.blue.shade900;

  // Wind colors (by gust speed in km/h)
  static Color windGustColor(double speed) {
    if (speed < 5) return Colors.blue.withValues(alpha: 0.3);
    if (speed < 10) return Colors.green.withValues(alpha: 0.5);
    if (speed < 20) return Colors.yellow.withValues(alpha: 0.7);
    if (speed < 30) return Colors.orange.withValues(alpha: 0.8);
    if (speed < 50) return Colors.red.withValues(alpha: 0.9);
    if (speed < 70) return Colors.purple;
    return Colors.black;
  }

  // Text styles
  static const temperatureMaxLabelStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 17,
    color: Colors.black87,
  );

  static final temperatureMinLabelStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.blue.shade700,
  );

  static const apparentTempLabelStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.black54,
  );

  static const dateLabelStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w900,
    color: Colors.black87,
  );

  static const hourLabelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static const axisLabelStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: Colors.black87,
  );

  static const axisTitleStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static const deviationLabelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  // Sizing constants
  static const double weatherIconSize = 45.0;
  static const double weatherIconWidth = 55.0;
  static const double weatherIconOffset = 22.5;
  static const double weatherIconTopOffset = 50.0;

  static const double temperatureLabelWidth = 50.0;
  static const double temperatureLabelOffset = 25.0;

  static const double dateLabelWidth = 80.0;
  static const double dateLabelOffset = 40.0;

  static const double hourLabelWidth = 60.0;

  static const double windIconMaxSize = 50.0;
  static const double windIconSizeMultiplier = 2.0;
  static const double windInfoContainerWidth = 200.0;
  static const double windInfoContainerOffset = 100.0;

  // Chart line styles
  static const double chartLineWidth = 3.0;
  static const double normalLineWidth = 2.0;
  static const int normalLineDashPattern = 5;

  static const double chartDotRadius = 5.0;
  static const double chartDotStrokeWidth = 1.0;

  // Spacing
  static const double deviationTopMargin = 0.0;
  static const double deviationLeftMargin = 20.0;
  static const double deviationPaddingHorizontal = 4.0;
  static const double deviationPaddingVertical = 0.0;
  static const double deviationBorderRadius = 4.0;

  static const double weatherIconSpacing = 8.0;
  static const double minTempLabelSpacing = 4.0;
}
