import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// Import your data models and icon data
import '../data/weather_icon_data.dart';
import '../models/climate_normal_model.dart';
import '../models/weather_forecast_model.dart';

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
  late TooltipBehavior _tooltipBehavior;

  // Cache expensive calculations for better performance
  late final List<WeatherDeviation?> _deviations;
  late final List<CartesianChartAnnotation> _chartAnnotations;

  @override
  void initState() {
    super.initState();

    // Pre-calculate all deviations to avoid repeated calculations
    _deviations = widget.forecast.dailyForecasts
        .map((daily) => _getDeviationForDay(daily))
        .toList();

    // Pre-build all annotations for better performance
    _chartAnnotations = _buildChartAnnotations();

    _tooltipBehavior = TooltipBehavior(
      enable: true,
      tooltipPosition: TooltipPosition.auto, // Auto-adjust position to avoid clipping [[8]]
      activationMode: ActivationMode.singleTap,
      duration: 4000,
      canShowMarker: true,
      shadowColor: Colors.black26,
      elevation: 8,
      builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
          int seriesIndex) {
        final DailyForecast forecast = data as DailyForecast;

        // Use pre-calculated deviation for better performance
        final WeatherDeviation? deviation = pointIndex < _deviations.length
            ? _deviations[pointIndex]
            : null;

        final String formattedDate =
        DateFormat('EEEE, d MMMM', 'fr_FR').format(forecast.date);

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
                      fontWeight:
                      valueColor != null ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(12),
          constraints: BoxConstraints(maxHeight: 280), // Limit tooltip height
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
              )
            ],
          ),
          child: SingleChildScrollView(
            // Make tooltip scrollable if content overflows
            child: IntrinsicWidth(
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
                  buildDetailRow('Précipitations',
                      forecast.precipitationSum != null ? '${forecast.precipitationSum} mm' : null),
                  buildDetailRow('Heures de précip.',
                      forecast.precipitationHours != null ? '${forecast.precipitationHours} h' : null),
                  buildDetailRow(
                      'Chance de précip.',
                      forecast.precipitationProbabilityMax != null
                          ? '${forecast.precipitationProbabilityMax}%'
                          : null),
                  buildDetailRow(
                      'Chute de neige',
                      forecast.snowfallSum != null && forecast.snowfallSum! > 0
                          ? '${forecast.snowfallSum} cm'
                          : null),
                  buildDetailRow('Couverture nuageuse',
                      forecast.cloudCoverMean != null ? '${forecast.cloudCoverMean}%' : null),
                  buildDetailRow(
                      'Vent',
                      forecast.windSpeedMax != null
                          ? '${forecast.windSpeedMax?.toStringAsFixed(1)} km/h'
                          : null),
                  buildDetailRow(
                      'Rafales',
                      forecast.windGustsMax != null
                          ? '${forecast.windGustsMax?.toStringAsFixed(1)} km/h'
                          : null),
                ],
              ),
            ),
          ),
        );
      },
    );
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
      avgDeviation: ((dailyForecast.temperatureMax + dailyForecast.temperatureMin) / 2) -
          ((normal.temperatureMax + normal.temperatureMin) / 2),
      normal: normal,
    );
  }

  String? _getIconPathForCode(int? code) {
    if (code == null) return null;
    try {
      final iconData =
      weatherIcons.firstWhere((icon) => icon.code == code.toString());
      return iconData.iconPath;
    } catch (e) {
      return null;
    }
  }

  List<CartesianChartAnnotation> _buildChartAnnotations() {
    return widget.forecast.dailyForecasts.asMap().entries.map((entry) {
      final int index = entry.key;
      final DailyForecast daily = entry.value;
      final String? iconPath = _getIconPathForCode(daily.weatherCode);
      final WeatherDeviation? deviation =
      index < _deviations.length ? _deviations[index] : null;

      if (iconPath != null) {
        return CartesianChartAnnotation(
          widget: Container(
            width: 45,
            height: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(iconPath, width: 32, height: 32),
                const SizedBox(height: 1),
                Text(
                  '${daily.temperatureMax.round()}°',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 14),
                if (deviation != null)
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: deviation.maxDeviation > 0
                          ? Colors.red.shade100
                          : Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      deviation.maxDeviationText,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: deviation.maxDeviation > 0
                            ? Colors.red.shade700
                            : Colors.blue.shade700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          coordinateUnit: CoordinateUnit.point,
          x: DateFormat('E, d MMM', 'fr_FR').format(daily.date),
          y: daily.temperatureMax + 2,
        );
      }
      return null;
    }).whereType<CartesianChartAnnotation>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double chartWidth =
            widget.forecast.dailyForecasts.length * 50.0;
        final double minWidth = constraints.maxWidth;

        // Calculate dynamic axis range for both min and max temps
        final allTemps = widget.forecast.dailyForecasts
            .expand((d) => [d.temperatureMax, d.temperatureMin])
            .toList();
        final double maxTemp = allTemps.reduce(max);
        final double minTemp = allTemps.reduce(min);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: chartWidth > minWidth ? chartWidth : minWidth,
            height: 500, // Increased height to provide more tooltip space
            child: SfCartesianChart(
              // title: ChartTitle(
              //   text: 'Prévisions de température quotidiennes',
              //   textStyle: const TextStyle(
              //     fontSize: 18,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.black87,
              //   ),
              // ),
              legend: Legend(
                isVisible: false,
                position: LegendPosition.top,
                alignment: ChartAlignment.center,
                itemPadding: 20,
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                legendItemBuilder:
                    (String name, dynamic series, dynamic point, int seriesIndex) {
                  return Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: seriesIndex == 0
                          ? Colors.red.shade50
                          : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: seriesIndex == 0
                            ? Colors.red.shade200
                            : Colors.blue.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: seriesIndex == 0
                                ? Colors.red.shade600
                                : Colors.blue.shade600,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: seriesIndex == 0
                                ? Colors.red.shade700
                                : Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              tooltipBehavior: _tooltipBehavior,
              annotations: _chartAnnotations,
              primaryXAxis: CategoryAxis(
                labelPlacement: LabelPlacement.onTicks,
                labelRotation: -45,
                labelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                axisLine: AxisLine(
                  color: Colors.grey.shade400,
                  width: 1,
                ),
                majorTickLines: MajorTickLines(
                  color: Colors.grey.shade400,
                  width: 1,
                ),
                majorGridLines: MajorGridLines(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              primaryYAxis: NumericAxis(
                title: AxisTitle(
                  text: 'Température (°C)',
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                labelFormat: '{value}°C',
                labelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                interval: 5,
                minimum: (minTemp - 6).floorToDouble(),
                maximum: (maxTemp + 6).ceilToDouble(),
                axisLine: AxisLine(
                  color: Colors.grey.shade400,
                  width: 1,
                ),
                majorTickLines: MajorTickLines(
                  color: Colors.grey.shade400,
                  width: 1,
                ),
                majorGridLines: MajorGridLines(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
                minorGridLines: MinorGridLines(
                  color: Colors.grey.shade100,
                  width: 0.5,
                ),
              ),
              plotAreaBorderColor: Colors.grey.shade300,
              plotAreaBorderWidth: 1,
              backgroundColor: Colors.grey.shade50,
              enableAxisAnimation: true,
              enableSideBySideSeriesPlacement: false,
              series: <CartesianSeries<DailyForecast, String>>[
                // MAX TEMPERATURE SERIES
                LineSeries<DailyForecast, String>(
                  name: 'Temp. max.',
                  dataSource: widget.forecast.dailyForecasts,
                  xValueMapper: (DailyForecast daily, _) =>
                      DateFormat('E, d MMM', 'fr_FR').format(daily.date),
                  yValueMapper: (DailyForecast daily, _) =>
                  daily.temperatureMax,
                  color: Colors.red.shade600,
                  width: 3,
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    width: 10,
                    height: 10,
                    shape: DataMarkerType.circle,
                    borderWidth: 3,
                    borderColor: Colors.white,
                    color: Colors.red.shade600,
                  ),
                  animationDuration: 1500,
                  animationDelay: 0,
                  selectionBehavior: SelectionBehavior(
                    enable: true,
                    selectedColor: Colors.red.shade800,
                    unselectedColor: Colors.red.shade300,
                    selectedBorderColor: Colors.orange,
                    selectedBorderWidth: 2,
                  ),
                  dataLabelSettings: DataLabelSettings(
                    isVisible: false,
                    labelPosition: ChartDataLabelPosition.outside,
                    labelAlignment: ChartDataLabelAlignment.top,
                    margin: const EdgeInsets.only(bottom: 8),
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    builder: (dynamic data, dynamic point, dynamic series,
                        int pointIndex, int seriesIndex) {
                      final forecast = data as DailyForecast;
                      final deviation = pointIndex < _deviations.length
                          ? _deviations[pointIndex]
                          : null;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          border:
                          Border.all(color: Colors.red.shade300, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${forecast.temperatureMax.round()}°',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                            if (deviation != null)
                              Text(
                                deviation.maxDeviationText,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  color: deviation.maxDeviation > 0
                                      ? Colors.red.shade600
                                      : Colors.blue.shade600,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // MIN TEMPERATURE SERIES
                LineSeries<DailyForecast, String>(
                  name: 'Temp. min.',
                  dataSource: widget.forecast.dailyForecasts,
                  xValueMapper: (DailyForecast daily, _) =>
                      DateFormat('E, d MMM', 'fr_FR').format(daily.date),
                  yValueMapper: (DailyForecast daily, _) =>
                  daily.temperatureMin,
                  color: Colors.blue.shade600,
                  width: 3,
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    width: 10,
                    height: 10,
                    shape: DataMarkerType.circle,
                    borderWidth: 3,
                    borderColor: Colors.white,
                    color: Colors.blue.shade600,
                  ),
                  animationDuration: 1500,
                  animationDelay: 300,
                  selectionBehavior: SelectionBehavior(
                    enable: true,
                    selectedColor: Colors.blue.shade800,
                    unselectedColor: Colors.blue.shade300,
                    selectedBorderColor: Colors.lightBlue,
                    selectedBorderWidth: 2,
                  ),
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.outside,
                    labelAlignment: ChartDataLabelAlignment.bottom,
                    margin: const EdgeInsets.only(top: 1),
                    textStyle: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    builder: (dynamic data, dynamic point, dynamic series,
                        int pointIndex, int seriesIndex) {
                      final forecast = data as DailyForecast;
                      final deviation = pointIndex < _deviations.length
                          ? _deviations[pointIndex]
                          : null;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${forecast.temperatureMin.round()}°',
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
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: deviation.minDeviation > 0
                                      ? Colors.red.shade600
                                      : Colors.blue.shade600,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}