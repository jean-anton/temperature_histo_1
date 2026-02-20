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

    final size = (windSpeed ?? 0.0) * scaleFactor;

    return Stack(
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
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
        ),
      ],
    );
  }
}
