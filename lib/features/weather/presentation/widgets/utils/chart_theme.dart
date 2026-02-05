import 'package:flutter/material.dart';

/// Theme and styling constants for weather charts
class ChartTheme {
  // Color schemes
  static const temperatureMaxColor = Color(0xFFFF5722); // Vibrant Orange-Red
  static const temperatureMaxLineColor = Color(0xFFFF7043);
  static const temperatureMaxDotColor = Color(0xFFE64A19);

  static const temperatureMinColor = Color(0xFF03A9F4); // Vibrant Blue
  static const temperatureMinLineColor = Color(0xFF29B6F6);
  static const temperatureMinDotColor = Color(0xFF0288D1);

  static const apparentTempLineColor = Color(
    0xFF90A4AE,
  ); // Blue-Grey for Ressenti

  //static const normalMaxLineColor = Color(0xFFEF9A9A).withValues(alpha: 0.05);
  static const normalMaxLineColor = Color.fromRGBO(248, 97, 97, 1);
  //;
  static const normalMinLineColor = Color.fromRGBO(38, 150, 241, 1);

  static final gridLineColor = Colors.grey.withValues(alpha: 0.05);
  static final gridLineColorLight = Colors.grey.withValues(alpha: 0.02);
  static final borderColor = Colors.grey.withValues(alpha: 0.1);

  static final weekendBackgroundColor = const Color.fromARGB(
    255,
    124,
    159,
    212,
  ).withValues(alpha: 0.4);
  static final nightBackgroundColor = const Color.fromARGB(
    255,
    13,
    18,
    58,
  ).withValues(alpha: 0.25);

  static const currentTimeLineColor = Color(0xFFFFD600); // Bright Yellow

  // Deviation colors
  static final deviationWarmBackground = const Color(0xFFFFEBEB);
  static final deviationCoolBackground = const Color(0xFFEBF5FF);
  static const deviationWarmText = Color(0xFFB71C1C);
  static const deviationCoolText = Color(0xFF0D47A1);

  // Wind colors (by gust speed in km/h)
  static Color windGustColor(double speed) {
    if (speed < 5) return Colors.blue.withValues(alpha: 0.3);
    if (speed < 10) return Colors.green.withValues(alpha: 0.5);
    if (speed < 20) return Colors.amber.withValues(alpha: 0.7);
    if (speed < 30) return Colors.orange.withValues(alpha: 0.8);
    if (speed < 50) return Colors.deepOrange.withValues(alpha: 0.9);
    if (speed < 70) return Colors.red;
    return Colors.black;
  }

  // Text styles
  static const temperatureMaxLabelStyle = TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 18,
    color: Color(0xFF37474F),
  );

  static const temperatureMinLabelStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: Color(0xFF0288D1),
  );

  static const apparentTempLabelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: Colors.black45,
  );

  static const dateLabelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: Color(0xFF1A237E),
  );

  static const hourLabelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.black54,
  );

  static const hour00LabelStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w900,
    color: Color(0xFF1A237E),
  );

  static const axisLabelStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: Colors.black38,
  );

  static const axisTitleStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.0,
    color: Colors.black26,
  );

  static const deviationLabelStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w900,
  );

  // Sizing constants
  static const double weatherIconSize = 48.0;
  static const double weatherIconWidth = 56.0;
  static const double weatherIconOffset = 23.0;
  static const double weatherIconTopOffset = 52.0;

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
  static const double chartLineWidth = 4.0;
  static const double normalLineWidth = 2.5;
  static const int normalLineDashPattern = 6;
  static const List<int> apparentTempDashPattern = [4, 4];

  static const double chartDotRadius = 6.0;
  static const double chartDotStrokeWidth = 2.0;

  // Spacing
  static const double deviationTopMargin = 0.0;
  static const double deviationLeftMargin = 20.0;
  static const double deviationPaddingHorizontal = 6.0;
  static const double deviationPaddingVertical = 2.0;
  static const double deviationBorderRadius = 8.0;

  static const double weatherIconSpacing = 8.0;
  static const double minTempLabelSpacing = 4.0;
}
