import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/chart_theme.dart';

/// Reusable widget for displaying wind direction and speed
///
/// Shows:
/// - Wind speed in km/h
/// - Rotating arrow indicating wind direction
/// - Color-coded by gust speed
class WindIndicator extends StatelessWidget {
  final double windSpeed;
  final double? windGusts;
  final int windDirection;

  const WindIndicator({
    super.key,
    required this.windSpeed,
    this.windGusts,
    required this.windDirection,
  });

  @override
  Widget build(BuildContext context) {
    final double gustSpeed = windGusts ?? windSpeed;
    final Color gustColor = ChartTheme.windGustColor(gustSpeed);

    // Wind icon paths
    const String windIconPath = "assets/google_weather_icons/v3/arrow.svg";
    const String windIconPathContour =
        "assets/google_weather_icons/v3/arrow_contour.svg";

    // Calculate arrow size based on gust speed
    final double arrowSize = gustSpeed * ChartTheme.windIconSizeMultiplier;

    // Arrow points east (90°) by default, rotate from there
    final double rotationAngle = (135 + windDirection) * (3.14159 / 180);

    return SizedBox(
      width: ChartTheme.windInfoContainerWidth,
      child: Column(
        children: [
          // Wind speed label
          Text(
            '${windSpeed.round()} km/h',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),

          // Wind direction arrow with color based on gusts
          Stack(
            children: [
              // Colored arrow
              Transform.rotate(
                angle: rotationAngle,
                child: SvgPicture.asset(
                  windIconPath,
                  width: arrowSize,
                  height: arrowSize,
                  colorFilter: ColorFilter.mode(gustColor, BlendMode.srcIn),
                ),
              ),

              // Contour overlay for better visibility
              Transform.rotate(
                angle: rotationAngle,
                child: SvgPicture.asset(
                  windIconPathContour,
                  width: arrowSize,
                  height: arrowSize,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
