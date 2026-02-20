import 'package:flutter/material.dart';
import 'package:aeroclim/l10n/app_localizations.dart';
import '../utils/chart_theme.dart';
import 'gust_arrow_widget.dart';

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
  final double scaleFactor;

  const WindIndicator({
    super.key,
    required this.windSpeed,
    this.windGusts,
    required this.windDirection,
    this.scaleFactor = ChartTheme.windIconSizeMultiplier,
  });

  @override
  Widget build(BuildContext context) {
    final double size = (windGusts ?? windSpeed) * scaleFactor;

    return SizedBox(
      width: ChartTheme.windInfoContainerWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Wind speed label
          Text(
            '${windSpeed.round()} ${AppLocalizations.of(context)!.kmh}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),

          // Use the specialized GustArrowWidget for the direction arrow
          // Use SizedBox with reduced height + OverflowBox to remove the large gap
          // created by the square bounding box of the rotated arrow
          SizedBox(
            height: size * 0.5,
            child: OverflowBox(
              maxHeight: size,
              maxWidth: size,
              child: GustArrowWidget(
                windSpeed: windGusts ?? windSpeed,
                windDirection: windDirection,
                scaleFactor: scaleFactor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
