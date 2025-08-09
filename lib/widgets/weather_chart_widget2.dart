import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../data/weather_icon_data.dart';
import '../models/climate_normal_model.dart';
import '../models/weather_forecast_model.dart';
import '../models/weather_icon.dart';

class WeatherChart2 extends StatefulWidget {
  final WeatherForecast? forecast;
  final DailyWeather? dailyWeather;
  final List<ClimateNormal> climateNormals;
  final String displayMode; // 'daily' or 'hourly'

  const WeatherChart2({
    super.key,
    this.forecast,
    this.dailyWeather,
    required this.climateNormals,
    required this.displayMode,
  });

  @override
  State<WeatherChart2> createState() => _WeatherChart2State();
}

class _WeatherChart2State extends State<WeatherChart2> {
  late final List<WeatherDeviation?> _deviations;
  late final double _maxTemp;
  late final double _minTemp;
  late final List<String> _dateLabels;
  late final List<String> _hourLabels;
  int? _touchedIndex;
  OverlayEntry? _overlayEntry;
  Timer? _tooltipTimer;

  @override
  void initState() {
    super.initState();

    if (widget.displayMode == 'daily') {
      _initDailyChart();
    } else {
      _initHourlyChart();
    }
  }

  void _initDailyChart() {
    if (widget.forecast == null) return;

    _deviations = widget.forecast!.dailyForecasts
        .map((daily) => _getDeviationForDay(daily))
        .toList();

    final allTemps = widget.forecast!.dailyForecasts
        .expand((d) => [d.temperatureMax, d.temperatureMin])
        .toList();
    _maxTemp = allTemps.isNotEmpty ? allTemps.reduce(max) : 20;
    _minTemp = allTemps.isNotEmpty ? allTemps.reduce(min) : 0;

    _dateLabels = widget.forecast!.dailyForecasts
        .map((daily) => DateFormat('E, d MMM', 'fr_FR').format(daily.date))
        .toList();
  }

  void _initHourlyChart() {
    if (widget.dailyWeather == null) return;

    final allTemps = widget.dailyWeather!.hourlyForecasts
        .where((h) => h.temperature != null)
        .map((h) => h.temperature!)
        .toList();
    _maxTemp = allTemps.isNotEmpty ? allTemps.reduce(max) : 20;
    _minTemp = allTemps.isNotEmpty ? allTemps.reduce(min) : 0;

    // _hourLabels = widget.dailyWeather!.hourlyForecasts
    //     .map((hourly) => hourly.formattedTime)
    //     .toList();
    _generateHourLabels();
  }

void _generateHourLabels() {
  if (widget.dailyWeather != null && widget.dailyWeather!.hourlyForecasts.isNotEmpty) {
    _hourLabels = widget.dailyWeather!.hourlyForecasts.map((hourly) {
      // Format: "03:00 lun. 12/8"
      // Using 'fr_FR' locale for day abbreviation like 'lun.'
      //return DateFormat('HH:mm EEE dd/M', 'fr_FR').format(hourly.time);
      return DateFormat('HH:mm EEE', 'fr_FR').format(hourly.time);
    }).toList();
  } else {
    _hourLabels = [];
  }
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
    return widget.forecast!.dailyForecasts.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.temperatureMax);
    }).toList();
  }

  List<FlSpot> _getMinTempSpots() {
    return widget.forecast!.dailyForecasts.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.temperatureMin);
    }).toList();
  }

  List<FlSpot> _getNormalMaxSpots() {
    return widget.forecast!.dailyForecasts
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
    return widget.forecast!.dailyForecasts
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

  List<FlSpot> _getHourlyTempSpots() {
    return widget.dailyWeather!.hourlyForecasts.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.temperature ?? 0);
    }).toList();
  }

  List<FlSpot> _getApparentTempSpots() {
    return widget.dailyWeather!.hourlyForecasts.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.apparentTemperature ?? 0);
    }).toList();
  }

  void _removeTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _tooltipTimer?.cancel();
    // setState(() {
    //   _touchedIndex = null;
    // });
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

    if (widget.displayMode == 'daily') {
      _showDailyTooltip(context, touchedIndex, position);
    } else {
      _showHourlyTooltip(context, touchedIndex, position);
    }
  }

  void _showDailyTooltip(
    BuildContext context,
    int touchedIndex,
    Offset position,
  ) {
    if (widget.forecast == null ||
        touchedIndex < 0 ||
        touchedIndex >= widget.forecast!.dailyForecasts.length) {
      return;
    }

    final forecast = widget.forecast!.dailyForecasts[touchedIndex];
    final deviation = touchedIndex < _deviations.length
        ? _deviations[touchedIndex]
        : null;

    final String formattedDate = DateFormat(
      'EEEE, d MMMM',
      'fr_FR',
    ).format(forecast.date);

    _buildTooltip(context, position, formattedDate, forecast, deviation);
  }

  void _showHourlyTooltip(
    BuildContext context,
    int touchedIndex,
    Offset position,
  ) {
    if (widget.dailyWeather == null ||
        touchedIndex < 0 ||
        touchedIndex >= widget.dailyWeather!.hourlyForecasts.length) {
      return;
    }

    final hourly = widget.dailyWeather!.hourlyForecasts[touchedIndex];
    final String formattedDate = DateFormat(
      'EEEE, d MMMM HH:mm',
      'fr_FR',
    ).format(hourly.time);

    _buildTooltip(context, position, formattedDate, hourly);
  }

  void _buildTooltip(
    BuildContext context,
    Offset position,
    String formattedDate,
    dynamic data, [ // DailyForecast or HourlyForecast
    WeatherDeviation? deviation,
  ]) {
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

    // Remove any existing tooltip before showing a new one
    _removeTooltip();

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
                      // Weather Description
                      if (data is DailyForecast)
                        Text(
                          data.weatherCode != null
                              ? '${getDescriptionFr(data.weatherCode!.toString())}'
                              : "",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      // If data is HourlyForecast, you might want a different description or none.
                      // For now, it will not show a description for HourlyForecast.
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        height: 1,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      // Temperature Details
                      if (data is DailyForecast) ...[
                        buildDetailRow(
                          'Temp. max.',
                          '${data.temperatureMax?.toStringAsFixed(1)}°C ${deviation != null ? '(${deviation.maxDeviationText ?? ''})' : ''}',
                          valueColor: (deviation?.maxDeviation ?? 0) > 0
                              ? Colors.redAccent.shade100
                              : Colors.lightBlueAccent.shade100,
                        ),
                        buildDetailRow(
                          'Temp. min.',
                          '${data.temperatureMin?.toStringAsFixed(1)}°C ${deviation != null ? '(${deviation.minDeviationText ?? ''})' : ''}',
                          valueColor: (deviation?.minDeviation ?? 0) > 0
                              ? Colors.redAccent.shade100
                              : Colors.lightBlueAccent.shade100,
                        ),
                      ],
                      if (data is HourlyForecast) ...[
                        buildDetailRow(
                          'Température',
                          '${data.temperature?.toStringAsFixed(1)}°C',
                        ),
                        buildDetailRow(
                          'Ressenti',
                          '${data.apparentTemperature?.toStringAsFixed(1)}°C',
                        ),
                      ],
                      // Precipitation Sum/Amount
                      buildDetailRow(
                        'Précipitations',
                        data is DailyForecast
                            ? data.precipitationSum != null
                                  ? '${data.precipitationSum?.toStringAsFixed(1)} mm' // Use .toStringAsFixed for doubles
                                  : null
                            : data is HourlyForecast
                            ? data.precipitation != null
                                  ? '${data.precipitation?.toStringAsFixed(1)} mm' // Use .toStringAsFixed for doubles
                                  : null
                            : null,
                      ),
                      // Precipitation Hours (DailyForecast only)
                      if (data is DailyForecast)
                        buildDetailRow(
                          'Heures de précip.',
                          data.precipitationHours != null
                              ? '${data.precipitationHours?.toStringAsFixed(1)} h'
                              : null,
                        ),
                      // Precipitation Probability (common to both, but accessing safely)
                      buildDetailRow(
                        'Chance de précip.',
                        data is DailyForecast
                            ? data.precipitationProbabilityMax != null
                                  ? '${data.precipitationProbabilityMax}%'
                                  : null
                            : data is HourlyForecast
                            ? data.precipitationProbability != null
                                  ? '${data.precipitationProbability}%'
                                  : null
                            : null,
                      ),
                      // Snowfall Sum (DailyForecast only)
                      if (data is DailyForecast)
                        buildDetailRow(
                          'Chute de neige',
                          data.snowfallSum != null && data.snowfallSum! > 0
                              ? '${data.snowfallSum?.toStringAsFixed(1)} cm'
                              : null,
                        ),
                      // Cloud Cover (common to both, but accessing safely)
                      buildDetailRow(
                        'Couverture nuageuse',
                        data is DailyForecast
                            ? data.cloudCoverMean != null
                                  ? '${data.cloudCoverMean}%'
                                  : null
                            : data is HourlyForecast
                            ? data.cloudCover != null
                                  ? '${data.cloudCover}%'
                                  : null
                            : null,
                      ),
                      // Wind Speed (common to both, but accessing safely)
                      buildDetailRow(
                        'Vent',
                        data is DailyForecast
                            ? data.windSpeedMax != null
                                  ? '${data.windSpeedMax?.toStringAsFixed(1)} km/h'
                                  : null
                            : data is HourlyForecast
                            ? data.windSpeed != null
                                  ? '${data.windSpeed?.toStringAsFixed(1)} km/h'
                                  : null
                            : null,
                      ),
                      // Wind Gusts (common to both, but accessing safely)
                      buildDetailRow(
                        'Rafales',
                        data is DailyForecast
                            ? data.windGustsMax != null
                                  ? '${data.windGustsMax?.toStringAsFixed(1)} km/h'
                                  : null
                            : data is HourlyForecast
                            ? data.windGusts != null
                                  ? '${data.windGusts?.toStringAsFixed(1)} km/h'
                                  : null
                            : null,
                      ),
                    ],
                  ),
                ),
                Positioned(
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
  }

  Offset _calculateScreenPosition(
    double chartX,
    double chartY,
    Size containerSize,
  ) {
    const double leftTitleReservedSize = 40;
    const double bottomTitleReservedSize = 80;

    final double gridLeft = leftPadding + leftTitleReservedSize;
    final double gridTop = topPadding;

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

    final double minX = 0;
    final double maxX = widget.displayMode == 'daily'
        ? (widget.forecast!.dailyForecasts.length - 1).toDouble()
        : (widget.dailyWeather!.hourlyForecasts.length - 1).toDouble();
    final double minY = (_minTemp - 6).floorToDouble();
    final double maxY = (_maxTemp + 6).ceilToDouble();

    final double normalizedX = (maxX > minX)
        ? (chartX - minX) / (maxX - minX)
        : 0.0;
    final double normalizedY = (maxY > minY)
        ? (chartY - minY) / (maxY - minY)
        : 0.0;

    final double screenX = gridLeft + (normalizedX * gridWidth);
    final double screenY = gridTop + ((1.0 - normalizedY) * gridHeight);

    return Offset(screenX, screenY);
  }

  int? _getTappedIndex(Offset localPosition, Size containerSize) {
    const double leftTitleReservedSize = 40;
    const double bottomTitleReservedSize = 80;

    final double gridLeft = leftPadding + leftTitleReservedSize;
    final double gridTop = topPadding;
    final double gridRight = containerSize.width - rightPadding;
    final double gridBottom =
        containerSize.height - bottomPadding - bottomTitleReservedSize;
    final double gridWidth = gridRight - gridLeft;

    if (localPosition.dx < gridLeft ||
        localPosition.dx > gridRight ||
        localPosition.dy < gridTop ||
        localPosition.dy > gridBottom) {
      return null;
    }

    final double relativeX = localPosition.dx - gridLeft;
    if (gridWidth <= 0) return null;
    final double normalizedX = relativeX / gridWidth;

    final int maxIndex = widget.displayMode == 'daily'
        ? widget.forecast!.dailyForecasts.length - 1
        : widget.dailyWeather!.hourlyForecasts.length - 1;
    if (maxIndex < 0) return null;
    final int index = (normalizedX * maxIndex).round().clamp(0, maxIndex);

    return index;
  }

  Widget _buildDailyChart(Size containerSize) {
    return Stack(
      children: [
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
              maxX: (widget.forecast!.dailyForecasts.length - 1).toDouble(),
              minY: (_minTemp - 6).floorToDouble(),
              maxY: (_maxTemp + 6).ceilToDouble(),
              lineBarsData: [
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
                LineChartBarData(
                  spots: _getNormalMaxSpots(),
                  isCurved: true,
                  color: Colors.red.shade300,
                  barWidth: 2,
                  dashArray: [5, 5],
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
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
                    reservedSize: 80,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= _dateLabels.length) {
                        return const SizedBox.shrink();
                      }
                      return Transform.rotate(
                        angle: -0.785,
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
                    reservedSize: 40,
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
                  return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
                },
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              backgroundColor: Colors.grey.shade50,
              lineTouchData: LineTouchData(enabled: false),
            ),
          ),
        ),
        ...widget.forecast!.dailyForecasts.asMap().entries.map((entry) {
          final int index = entry.key;
          final DailyForecast daily = entry.value;
          final String? iconPath = _getIconPathForCode(daily.weatherCode);
          final WeatherDeviation? deviation = index < _deviations.length
              ? _deviations[index]
              : null;

          if (iconPath == null) return const SizedBox.shrink();

          final screenPos = _calculateScreenPosition(
            index.toDouble(),
            daily.temperatureMax,
            containerSize,
          );

          return Positioned(
            left: screenPos.dx - 22.5,
            top: screenPos.dy - 65,
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
        ...widget.forecast!.dailyForecasts.asMap().entries.map((entry) {
          final int index = entry.key;
          final DailyForecast daily = entry.value;
          final WeatherDeviation? deviation = index < _deviations.length
              ? _deviations[index]
              : null;

          final screenPos = _calculateScreenPosition(
            index.toDouble(),
            daily.temperatureMin,
            containerSize,
          );

          return Positioned(
            left: screenPos.dx - 25,
            top: screenPos.dy + 15,
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
    );
  }

  Widget _buildHourlyChart(Size containerSize) {
    return Stack(
      children: [
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
              maxX: (widget.dailyWeather!.hourlyForecasts.length - 1)
                  .toDouble(),
              minY: (_minTemp - 2).floorToDouble(),
              maxY: (_maxTemp + 2).ceilToDouble(),
              lineBarsData: [
                LineChartBarData(
                  spots: _getHourlyTempSpots(),
                  isCurved: true,
                  color: Colors.blue.shade700,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                          radius: 4,
                          color: Colors.blue.shade900,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.shade50,
                  ),
                ),
                LineChartBarData(
                  spots: _getApparentTempSpots(),
                  isCurved: true,
                  color: Colors.purple.shade400,
                  barWidth: 2,
                  dashArray: [5, 5],
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                          radius: 3,
                          color: Colors.purple.shade800,
                        ),
                  ),
                ),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 2, // Display label every 3 hours
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= _hourLabels.length) {
                        return const SizedBox.shrink();
                      }
                      return Transform.rotate(
                        angle: -0.0,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _hourLabels[index], // Use the new formatted labels
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
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
                    reservedSize: 40,
                    interval: 2,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.round()}°',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
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
                drawVerticalLine: true,
                verticalInterval: 3,
                horizontalInterval: 2,
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                    dashArray: [2, 4],
                  );
                },
                getDrawingHorizontalLine: (value) {
                  return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
                },
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              backgroundColor: Colors.grey.shade50,
              lineTouchData: LineTouchData(enabled: false),
            ),
          ),
        ),
        // Existing weather icons
        ...widget.dailyWeather!.hourlyForecasts.asMap().entries.map((entry) {
          final int index = entry.key;
          final HourlyForecast hourly = entry.value;
          final String? iconPath = _getIconPathForCode(hourly.weatherCode);

          if (iconPath == null) return const SizedBox.shrink();

          final screenPos = _calculateScreenPosition(
            index.toDouble(),
            hourly.temperature ?? 0,
            containerSize,
          );

          return Positioned(
            left: screenPos.dx - 15,
            top: screenPos.dy - 45,
            child: SvgPicture.asset(iconPath, width: 30, height: 30),
          );
        }),
        // Add actual temperature labels
        ...widget.dailyWeather!.hourlyForecasts.asMap().entries.map((entry) {
          final int index = entry.key;
          final HourlyForecast hourly = entry.value;

          if (hourly.temperature == null) return const SizedBox.shrink();

          final screenPos = _calculateScreenPosition(
            index.toDouble(),
            hourly.temperature!,
            containerSize,
          );

          return Positioned(
            left: screenPos.dx - 15, // Adjust positioning as needed
            top: screenPos.dy - 25, // Adjust to place above the dot
            child: SizedBox(
              width: 30,
              child: Text(
                '${hourly.temperature!.round()}°',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          );
        }),
        // Add apparent temperature labels
        ...widget.dailyWeather!.hourlyForecasts.asMap().entries.map((entry) {
          final int index = entry.key;
          final HourlyForecast hourly = entry.value;

          if (hourly.apparentTemperature == null)
            return const SizedBox.shrink();

          final screenPos = _calculateScreenPosition(
            index.toDouble(),
            hourly.apparentTemperature!,
            containerSize,
          );

          return Positioned(
            left: screenPos.dx - 15, // Adjust positioning as needed
            top: screenPos.dy + 5, // Adjust to place below the dot
            child: SizedBox(
              width: 30,
              child: Text(
                '${hourly.apparentTemperature!.round()}°',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                  color: Colors.purple,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double minWidth = constraints.maxWidth;
        final double chartWidth;
        final double finalHeight;

        if (widget.displayMode == 'daily') {
          chartWidth = widget.forecast!.dailyForecasts.length * _widthPerDay;
          finalHeight = 500;
        } else {
          chartWidth = widget.dailyWeather!.hourlyForecasts.length * 60;
          finalHeight = 350;
        }

        final double finalWidth = chartWidth > minWidth ? chartWidth : minWidth;
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
              child: widget.displayMode == 'daily'
                  ? _buildDailyChart(containerSize)
                  : _buildHourlyChart(containerSize),
            ),
          ),
        );
      },
    );
  }
}

// Constants for chart padding
const double leftPadding = 10;
const double topPadding = 10;
const double rightPadding = 10;
const double bottomPadding = 10;
const double _widthPerDay = 80.0;

// Helper class for temperature deviation
class WeatherDeviation {
  final double maxDeviation;
  final double minDeviation;
  final double avgDeviation;
  final ClimateNormal normal;

  WeatherDeviation({
    required this.maxDeviation,
    required this.minDeviation,
    required this.avgDeviation,
    required this.normal,
  });

  String get maxDeviationText =>
      '${maxDeviation > 0 ? '+' : ''}${maxDeviation.toStringAsFixed(1)}';

  String get minDeviationText =>
      '${minDeviation > 0 ? '+' : ''}${minDeviation.toStringAsFixed(1)}';
}
