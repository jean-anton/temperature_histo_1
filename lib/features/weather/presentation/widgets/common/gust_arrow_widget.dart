import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aeroclim/features/weather/presentation/widgets/utils/chart_theme.dart';

class GustArrowWidget extends StatelessWidget {
  final double? windSpeed;
  final int? windDirection;
  final double scaleFactor;

  const GustArrowWidget({
    super.key,
    required this.windSpeed,
    required this.windDirection,
    this.scaleFactor = ChartTheme.windIconSizeMultiplier,
  });

  @override
  Widget build(BuildContext context) {
    if (windSpeed == null || windDirection == null) {
      return const Icon(Icons.help_outline, size: 24, color: Colors.grey);
    }
    const windIconPath = "assets/google_weather_icons/v4/arrow.svg";
    const windIconPathContour =
        "assets/google_weather_icons/v4/arrow_contour.svg";

    // Adjust arrow size: keep constant for low gusts, up to 3x for high gusts
    const double minGust = 5.0; // km/h
    const double maxGust = 75.0; // km/h
    final double baseSize = scaleFactor;
    double sizeFactor;
    if (windSpeed! < minGust) {
      sizeFactor = 1.0;
    } else if (windSpeed! > maxGust) {
      sizeFactor = 3.0;
    } else {
      // Linear interpolation between 1.0 and 3.0
      sizeFactor = 1.0 + ((windSpeed! - minGust) / (maxGust - minGust)) * 2.0;
    }
    final size = baseSize * sizeFactor * 20;

    return SizedBox(
      width: size,
      height: size,
      child: OverflowBox(
        alignment: Alignment.center,
        child: Stack(
          children: [
            Transform.rotate(
              angle: (135 + windDirection!) * (3.14159 / 180),
              child: SvgPicture.asset(
                windIconPath,
                width: size,
                height: size,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  ChartTheme.windGustColor(windSpeed ?? 0.0),
                  BlendMode.srcIn,
                ),
              ),
            ),
            Transform.rotate(
              angle: (135 + windDirection!) * (3.14159 / 180),
              child: SvgPicture.asset(
                windIconPathContour,
                width: size,
                height: size,
                fit: BoxFit.contain,
                // colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                colorFilter: const ColorFilter.mode(
                  Colors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
            //Text("${windSpeed.toString()} $size", style: const TextStyle(fontSize: 12)),
            ],
        ),
      ),
    );
  }
}
