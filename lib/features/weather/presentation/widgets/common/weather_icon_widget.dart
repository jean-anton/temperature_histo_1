import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:temperature_histo_1/features/weather/presentation/widgets/utils/chart_helpers.dart';

class WeatherIconWidget extends StatelessWidget {
  final int? code;
  final int? isDay;
  final double size;

  const WeatherIconWidget({
    super.key,
    required this.code,
    required this.isDay,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    if (code == null) {
      return Icon(
        Icons.help_outline,
        size: size * 0.75,
        color: Colors.grey[700],
      );
    }

    final iconPath = ChartHelpers.getIconPath(code: code!, isDay: isDay);

    if (iconPath == null) {
      return Icon(
        Icons.help_outline,
        size: size * 0.75,
        color: Colors.grey[700],
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
        iconPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
