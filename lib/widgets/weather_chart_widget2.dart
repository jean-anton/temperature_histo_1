import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

// Import your data models and icon data
import '../data/weather_icon_data.dart';
import '../models/climate_normal_model.dart';
import '../models/weather_forecast_model.dart';
import '../models/weather_icon.dart';

class WeatherChart2 extends StatefulWidget {
  final WeatherForecast forecast;
  final List<ClimateNormal> climateNormals;

  const WeatherChart2({
    super.key,
    required this.forecast,
    required this.climateNormals,
  });

  @override
  State<WeatherChart2> createState() => _WeatherChart2State();
}

class _WeatherChart2State extends State<WeatherChart2> {
  // Cache expensive calculations for better performance
  late final List<WeatherDeviation?> _deviations;
  late final double _maxTemp;
  late final double _minTemp;
  late final List<String> _dateLabels;
  int? _touchedIndex;
  OverlayEntry? _overlayEntry;

  // Chart padding constants - these must align with the Padding widget below
  static const double leftPadding = 10;
  static const double topPadding = 10;
  static const double rightPadding = 10;
  static const double bottomPadding = 10;
  static const double _widthPerDay = 80.0; // Width allocated for each day
  Timer? _tooltipTimer;

  @override
  void initState() {
    super.initState();

    // Pre-calculate all deviations to avoid repeated calculations
    _deviations = widget.forecast.dailyForecasts
        .map((daily) => _getDeviationForDay(daily))
        .toList();

    // Calculate temperature range
    final allTemps = widget.forecast.dailyForecasts
        .expand((d) => [d.temperatureMax, d.temperatureMin])
        .toList();
    _maxTemp = allTemps.isNotEmpty ? allTemps.reduce(max) : 20;
    _minTemp = allTemps.isNotEmpty ? allTemps.reduce(min) : 0;

    // Pre-calculate date labels
    _dateLabels = widget.forecast.dailyForecasts
        .map((daily) => DateFormat('E, d MMM', 'fr_FR').format(daily.date))
        .toList();
  }

  @override
  void dispose() {
    _removeTooltip();
    super.dispose();
  }

  String? getDescriptionFr(String code) {
    final match = weatherIcons.firstWhere(
      (icon) => icon.code == code,
      orElse: () => WeatherIcon(
        code: '',
        iconPath: '',
        descriptionEn: '',
        descriptionFr: '',
      ),
    );

    return match.code.isEmpty ? null : match.descriptionFr;
  }

  WeatherDeviation? _getDeviationForDay(DailyForecast dailyForecast) {
    final normal = ClimateNormal.findByDayOfYear(
      widget.climateNormals,
      dailyForecast.dayOfYear,
    );
    if (normal == null) {
      return null;
    }
    return WeatherDeviation(
      maxDeviation: dailyForecast.temperatureMax - normal.temperatureMax,
      minDeviation: dailyForecast.temperatureMin - normal.temperatureMin,
      avgDeviation:
          ((dailyForecast.temperatureMax + dailyForecast.temperatureMin) / 2) -
          ((normal.temperatureMax + normal.temperatureMin) / 2),
      normal: normal,
    );
  }

  String? _getIconPathForCode(int? code) {
    if (code == null) return null;
    try {
      final iconData = weatherIcons.firstWhere(
        (icon) => icon.code == code.toString(),
      );
      return iconData.iconPath;
    } catch (e) {
      return null;
    }
  }

  List<FlSpot> _getMaxTempSpots() {
    return widget.forecast.dailyForecasts.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.temperatureMax);
    }).toList();
  }

  List<FlSpot> _getMinTempSpots() {
    return widget.forecast.dailyForecasts.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.temperatureMin);
    }).toList();
  }

  List<FlSpot> _getNormalMaxSpots() {
    return widget.forecast.dailyForecasts
        .asMap()
        .entries
        .map((entry) {
          final normal = entry.key < _deviations.length
              ? _deviations[entry.key]?.normal
              : null;
          return FlSpot(entry.key.toDouble(), normal?.temperatureMax ?? 0);
        })
        .where((spot) => spot.y != 0)
        .toList();
  }

  List<FlSpot> _getNormalMinSpots() {
    return widget.forecast.dailyForecasts
        .asMap()
        .entries
        .map((entry) {
          final normal = entry.key < _deviations.length
              ? _deviations[entry.key]?.normal
              : null;
          return FlSpot(entry.key.toDouble(), normal?.temperatureMin ?? 0);
        })
        .where((spot) => spot.y != 0)
        .toList();
  }

  void _removeTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _tooltipTimer?.cancel();
    setState(() {
      _touchedIndex = null;
    });
  }

  void scheduleTooltipRemoval() {
    _tooltipTimer = Timer(const Duration(seconds: 10), () {
      _removeTooltip();
    });
  }

  void cancelTooltipRemoval() {
    _tooltipTimer?.cancel();
  }

  void _showTooltip(BuildContext context, int touchedIndex, Offset position) {
    _removeTooltip();

    if (touchedIndex < 0 ||
        touchedIndex >= widget.forecast.dailyForecasts.length) {
      return;
    }

    final forecast = widget.forecast.dailyForecasts[touchedIndex];
    final deviation = touchedIndex < _deviations.length
        ? _deviations[touchedIndex]
        : null;

    final String formattedDate = DateFormat(
      'EEEE, d MMMM',
      'fr_FR',
    ).format(forecast.date);

    Widget buildDetailRow(String label, String? value, {Color? valueColor}) {
      if (value == null || value.isEmpty) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: ',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontSize: 13,
                  fontWeight: valueColor != null
                      ? FontWeight.bold
                      : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final screenSize = MediaQuery.of(context).size;
    double tooltipLeft = position.dx - 150;
    double tooltipTop = position.dy - 320;

    if (tooltipLeft < 10) {
      tooltipLeft = 10;
    } else if (tooltipLeft + 300 > screenSize.width - 10) {
      tooltipLeft = screenSize.width - 310;
    }

    if (tooltipTop < 10) {
      tooltipTop = position.dy + 20;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: tooltipLeft,
        top: tooltipTop,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(maxHeight: 290),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blueGrey.shade800.withOpacity(0.95),
                  Colors.blueGrey.shade900.withOpacity(0.95),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        forecast.weatherCode != null
                            ? '${getDescriptionFr(forecast.weatherCode!.toString())}'
                            : "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        height: 1,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      buildDetailRow(
                        'Temp. max.',
                        '${forecast.temperatureMax.toStringAsFixed(1)}°C ${deviation != null ? '(${deviation.maxDeviationText})' : ''}',
                        valueColor: (deviation?.maxDeviation ?? 0) > 0
                            ? Colors.redAccent.shade100
                            : Colors.lightBlueAccent.shade100,
                      ),
                      buildDetailRow(
                        'Temp. min.',
                        '${forecast.temperatureMin.toStringAsFixed(1)}°C ${deviation != null ? '(${deviation.minDeviationText})' : ''}',
                        valueColor: (deviation?.minDeviation ?? 0) > 0
                            ? Colors.redAccent.shade100
                            : Colors.lightBlueAccent.shade100,
                      ),
                      buildDetailRow(
                        'Précipitations',
                        forecast.precipitationSum != null
                            ? '${forecast.precipitationSum} mm'
                            : null,
                      ),
                      buildDetailRow(
                        'Heures de précip.',
                        forecast.precipitationHours != null
                            ? '${forecast.precipitationHours} h'
                            : null,
                      ),
                      buildDetailRow(
                        'Chance de précip.',
                        forecast.precipitationProbabilityMax != null
                            ? '${forecast.precipitationProbabilityMax}%'
                            : null,
                      ),
                      buildDetailRow(
                        'Chute de neige',
                        forecast.snowfallSum != null &&
                                forecast.snowfallSum! > 0
                            ? '${forecast.snowfallSum} cm'
                            : null,
                      ),
                      buildDetailRow(
                        'Couverture nuageuse',
                        forecast.cloudCoverMean != null
                            ? '${forecast.cloudCoverMean}%'
                            : null,
                      ),
                      buildDetailRow(
                        'Vent',
                        forecast.windSpeedMax != null
                            ? '${forecast.windSpeedMax?.toStringAsFixed(1)} km/h'
                            : null,
                      ),
                      buildDetailRow(
                        'Rafales',
                        forecast.windGustsMax != null
                            ? '${forecast.windGustsMax?.toStringAsFixed(1)} km/h'
                            : null,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  //CJG1
                  right: 8,
                  top: 8,
                  child: GestureDetector(
                    onTap: _removeTooltip,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    scheduleTooltipRemoval();
    // Future.delayed(const Duration(seconds: 10), () {
    //   _removeTooltip();
    // });
  }

  Offset _calculateScreenPosition(
    double chartX,
    double chartY,
    Size containerSize,
  ) {
    // These constants MUST match the `reservedSize` properties in `FlTitlesData`.
    const double leftTitleReservedSize = 40;
    const double bottomTitleReservedSize = 80;

    // The chart's grid area (drawable area for lines) starts after the external padding AND internal title reservations.
    final double gridLeft = leftPadding + leftTitleReservedSize;
    final double gridTop =
        topPadding; // Top titles are disabled, so no reserved space.

    // Calculate the width and height of the actual grid area.
    // Right titles are disabled, so no reserved space on the right.
    final double gridWidth =
        containerSize.width -
        leftPadding -
        rightPadding -
        leftTitleReservedSize;
    final double gridHeight =
        containerSize.height -
        topPadding -
        bottomPadding -
        bottomTitleReservedSize;

    // Get the min/max values from the chart data.
    final double minX = 0;
    final double maxX = (widget.forecast.dailyForecasts.length - 1).toDouble();
    final double minY = (_minTemp - 6).floorToDouble();
    final double maxY = (_maxTemp + 6).ceilToDouble();

    // Avoid division by zero if there's only one data point.
    final double normalizedX = (maxX > minX)
        ? (chartX - minX) / (maxX - minX)
        : 0.0;
    final double normalizedY = (maxY > minY)
        ? (chartY - minY) / (maxY - minY)
        : 0.0;

    // Calculate screen coordinates relative to the container.
    // X position = grid's starting X + position within the grid.
    final double screenX = gridLeft + (normalizedX * gridWidth);
    // Y position = grid's starting Y + position within the grid (inverted for screen coordinates).
    final double screenY = gridTop + ((1.0 - normalizedY) * gridHeight);

    return Offset(screenX, screenY);
  }

  /// **FIXED:** Detects which data point index was tapped.
  /// This new version uses the correct grid boundaries, accounting for all padding
  /// and reserved title space, ensuring the correct tooltip is shown on tap.
  int? _getTappedIndex(Offset localPosition, Size containerSize) {
    // These constants MUST match the `reservedSize` properties in `FlTitlesData`.
    const double leftTitleReservedSize = 40;
    const double bottomTitleReservedSize = 80;

    // Define the bounding box of the chart's grid area.
    final double gridLeft = leftPadding + leftTitleReservedSize;
    final double gridTop = topPadding;
    final double gridRight = containerSize.width - rightPadding;
    final double gridBottom =
        containerSize.height - bottomPadding - bottomTitleReservedSize;
    final double gridWidth = gridRight - gridLeft;

    // Check if the tap occurred within the horizontal and vertical bounds of the grid.
    if (localPosition.dx < gridLeft ||
        localPosition.dx > gridRight ||
        localPosition.dy < gridTop ||
        localPosition.dy > gridBottom) {
      return null;
    }

    // Calculate the relative horizontal position of the tap within the grid.
    final double relativeX = localPosition.dx - gridLeft;

    // Avoid division by zero if grid width is zero.
    if (gridWidth <= 0) return null;
    final double normalizedX = relativeX / gridWidth;

    // Convert the normalized position to a data point index and clamp it to be safe.
    final int maxIndex = widget.forecast.dailyForecasts.length - 1;
    if (maxIndex < 0) return null; // No data points
    final int index = (normalizedX * maxIndex).round().clamp(0, maxIndex);

    return index;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double minWidth = constraints.maxWidth;
        final double chartWidth =
            widget.forecast.dailyForecasts.length * _widthPerDay;
        final double finalWidth = chartWidth > minWidth ? chartWidth : minWidth;
        final double finalHeight =
            500; // Increased height to provide more tooltip space
        final Size containerSize = Size(finalWidth, finalHeight);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: finalWidth,
            height: finalHeight,
            child: GestureDetector(
              onTapDown: (TapDownDetails details) {
                final Offset localPosition = details.localPosition;
                final int? tappedIndex = _getTappedIndex(
                  localPosition,
                  containerSize,
                );
                if (tappedIndex != null) {
                  setState(() {
                    _touchedIndex = tappedIndex;
                  });
                  _showTooltip(context, tappedIndex, details.globalPosition);
                }
              },
              child: Stack(
                children: [
                  // Main chart
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      leftPadding,
                      topPadding,
                      rightPadding,
                      bottomPadding,
                    ),
                    child: LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: (widget.forecast.dailyForecasts.length - 1)
                            .toDouble(),
                        minY: (_minTemp - 6).floorToDouble(),
                        maxY: (_maxTemp + 6).ceilToDouble(),
                        lineBarsData: [
                          // Max temperature line
                          LineChartBarData(
                            spots: _getMaxTempSpots(),
                            isCurved: true,
                            color: Colors.red.shade300,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) =>
                                  FlDotCirclePainter(
                                    radius: 5,
                                    color: Colors.red.shade600,
                                    strokeWidth: 3,
                                    strokeColor: Colors.white,
                                  ),
                            ),
                            belowBarData: BarAreaData(show: false),
                          ),
                          // Min temperature line
                          LineChartBarData(
                            spots: _getMinTempSpots(),
                            isCurved: true,
                            color: Colors.blue.shade300,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) =>
                                  FlDotCirclePainter(
                                    radius: 5,
                                    color: Colors.blue.shade600,
                                    strokeWidth: 1,
                                    strokeColor: Colors.white,
                                  ),
                            ),
                            belowBarData: BarAreaData(show: false),
                          ),
                          // Normal max temperature (dashed)
                          LineChartBarData(
                            spots: _getNormalMaxSpots(),
                            isCurved: true,
                            color: Colors.red.shade300,
                            barWidth: 2,
                            dashArray: [5, 5],
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                          ),
                          // Normal min temperature (dashed)
                          LineChartBarData(
                            spots: _getNormalMinSpots(),
                            isCurved: true,
                            color: Colors.blue.shade300,
                            barWidth: 2,
                            dashArray: [5, 5],
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize:
                                  80, // MUST match constant in calculation functions
                              interval:
                                  1, // Draw a title for every 1 unit (each day)
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= _dateLabels.length) {
                                  return const SizedBox.shrink();
                                }
                                return Transform.rotate(
                                  angle: -0.785, // -45 degrees
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Text(
                                      _dateLabels[index],
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            axisNameWidget: const Text(
                              'Température (°C)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize:
                                  40, // MUST match constant in calculation functions
                              interval: 5,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.round()}°',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 5,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.shade200,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        backgroundColor: Colors.grey.shade50,
                        lineTouchData: LineTouchData(enabled: false),
                      ),
                    ),
                  ),
                  // Weather icons positioned correctly above max temp points
                  ...widget.forecast.dailyForecasts.asMap().entries.map((
                    entry,
                  ) {
                    final int index = entry.key;
                    final DailyForecast daily = entry.value;
                    final String? iconPath = _getIconPathForCode(
                      daily.weatherCode,
                    );
                    final WeatherDeviation? deviation =
                        index < _deviations.length ? _deviations[index] : null;

                    if (iconPath == null) return const SizedBox.shrink();

                    // Calculate correct position using the new, accurate function
                    final screenPos = _calculateScreenPosition(
                      index.toDouble(),
                      daily.temperatureMax,
                      containerSize,
                    );

                    return Positioned(
                      left: screenPos.dx - 22.5, // Center the 45px wide icon
                      top: screenPos.dy - 65, // Position above the point
                      child: SizedBox(
                        width: 45,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(iconPath, width: 45, height: 45),
                            const SizedBox(height: 4),
                            Text(
                              '${daily.temperatureMax.round()}°',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Colors.black87,
                              ),
                            ),
                            if (deviation != null)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: deviation.maxDeviation > 0
                                      ? Colors.red.shade50
                                      : Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  deviation.maxDeviationText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: deviation.maxDeviation > 0
                                        ? Colors.red.shade900
                                        : Colors.blue.shade900,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                  // Min temperature labels positioned correctly below min temp points
                  ...widget.forecast.dailyForecasts.asMap().entries.map((
                    entry,
                  ) {
                    final int index = entry.key;
                    final DailyForecast daily = entry.value;
                    final WeatherDeviation? deviation =
                        index < _deviations.length ? _deviations[index] : null;

                    // Calculate correct position using the new, accurate function
                    final screenPos = _calculateScreenPosition(
                      index.toDouble(),
                      daily.temperatureMin,
                      containerSize,
                    );

                    return Positioned(
                      left: screenPos.dx - 25, // Center the label
                      top: screenPos.dy + 15, // Position below the point
                      child: SizedBox(
                        width: 50,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${daily.temperatureMin.round()}°',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            if (deviation != null)
                              Text(
                                deviation.minDeviationText,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: deviation.minDeviation > 0
                                      ? Colors.red.shade600
                                      : Colors.blue.shade600,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
