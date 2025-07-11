import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../data/weather_icon_data.dart';
import '../models/climate_normal_model.dart';
import '../models/weather_forecast_model.dart';
import '../models/weather_icon.dart';
import '../services/climate_data_service.dart';

// region Chart Data Models
// These private classes encapsulate the data structures needed specifically for the charts.

/// Data model for the main temperature chart.
class _ChartData {
  final int x;
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final double? normalMaxTemp;
  final double? normalMinTemp;
  final double? maxTempDeviation;
  final double? minTempDeviation;
  final String? iconPath;
  final String? weatherDescription;
  final double? precipitationSum;
  final int? precipitationProbability;
  final double? windSpeed;
  final int? cloudCover;
  final int? weatherCode;

  _ChartData({
    required this.x,
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    this.normalMaxTemp,
    this.normalMinTemp,
    this.maxTempDeviation,
    this.minTempDeviation,
    this.iconPath,
    this.weatherDescription,
    this.precipitationSum,
    this.precipitationProbability,
    this.windSpeed,
    this.cloudCover,
    this.weatherCode,
  });
}



class WeatherChart extends StatefulWidget {
  final WeatherForecast forecast;
  final List<ClimateNormal> climateNormals;

  const WeatherChart({
    super.key,
    required this.forecast,
    required this.climateNormals,
  });

  @override
  State<WeatherChart> createState() => _WeatherChartState();
}

class _WeatherChartState extends State<WeatherChart> {
  final ClimateDataService _climateService = ClimateDataService();
  late TooltipBehavior _tooltipBehavior;
  late Map<String, WeatherIcon> _weatherIconMap;

  // Chart data lists
  List<_ChartData> _chartData = [];

  // UI State
  bool _showDeviations = false;

  @override
  void initState() {
    super.initState();
    _weatherIconMap = {for (var icon in weatherIcons) icon.code: icon};
    _initializeTooltip();
    _prepareChartData();
  }

  @override
  void didUpdateWidget(WeatherChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reprocess data if the input forecast or normals change.
    if (widget.forecast != oldWidget.forecast ||
        widget.climateNormals != oldWidget.climateNormals) {
      _prepareChartData();
    }
  }

  /// Configures the tooltip behavior for the temperature chart.
  void _initializeTooltip() {
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      // **FIX**: Simplified tooltip configuration for better mobile web compatibility
      color: Colors.black87,
      elevation: 4,
      canShowMarker: true,
      tooltipPosition: TooltipPosition.auto, // Changed from pointer to auto
      duration: 3000, // Auto-hide after 3 seconds
      builder: _buildSimplifiedTooltip, // Use simplified builder
    );
  }

  /// Transforms forecast and climate data into a format suitable for the charts.
  void _prepareChartData() {
    final newChartData = <_ChartData>[];
    // final newDeviationData = <_DeviationChartData>[];

    for (int i = 0; i < widget.forecast.dailyForecasts.length; i++) {
      final forecast = widget.forecast.dailyForecasts[i];
      final normal = ClimateNormal.findByDayOfYear(
        widget.climateNormals,
        forecast.dayOfYear,
      );
      final weatherIcon = _weatherIconMap[forecast.weatherCode?.toString()];

      final deviation = _climateService.calculateDeviation(
        forecast.temperatureMax,
        forecast.temperatureMin,
        forecast.dayOfYear,
        widget.climateNormals,
      );

      // Prepare data for the main temperature chart
      newChartData.add(_ChartData(
        x: i,
        date: forecast.date,
        maxTemp: forecast.temperatureMax,
        minTemp: forecast.temperatureMin,
        normalMaxTemp: normal?.temperatureMax,
        normalMinTemp: normal?.temperatureMin,
        maxTempDeviation: deviation.maxDeviation,
        minTempDeviation: deviation.minDeviation,
        iconPath: weatherIcon?.iconPath,
        weatherDescription: weatherIcon?.descriptionFr,
        precipitationSum: forecast.precipitationSum,
        precipitationProbability: forecast.precipitationProbabilityMax,
        windSpeed: forecast.windSpeedMax,
        cloudCover: forecast.cloudCoverMean,
        weatherCode: forecast.weatherCode,
      ));

    }

    setState(() {
      _chartData = newChartData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 450,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _buildTemperatureChart(),
          ),
        ),
      ],
    );
  }

  // region Main Chart Builders

  /// Builds the primary temperature forecast chart.
  Widget _buildTemperatureChart() {
    // Using a ValueKey ensures Flutter replaces the widget correctly in the AnimatedSwitcher.
    return SingleChildScrollView(
      key: const ValueKey('temperature_chart'),
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        // Ensure the chart is wide enough to scroll on small screens.
        width: MediaQuery.of(context).size.width < 600
            ? MediaQuery.of(context).size.width * 2
            : MediaQuery.of(context).size.width,
        height: 400,
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          primaryXAxis: _buildCategoryXAxis(),
          primaryYAxis: _buildNumericYAxis(),
          tooltipBehavior: _tooltipBehavior,
          annotations: _buildWeatherIconAnnotations(),
          series: <CartesianSeries>[
            _buildTempSeries(isMaxTemp: true),
            // _buildTempSeries(isMaxTemp: false),
            // Optional: Uncomment to show climate normal lines
            // _buildNormalTempSeries(isMaxTemp: true),
            // _buildNormalTempSeries(isMaxTemp: false),
          ],
        ),
      ),
    );
  }

  CategoryAxis _buildCategoryXAxis({String? title}) {
    return CategoryAxis(
      title: AxisTitle(text: title ?? ''),
      labelStyle: const TextStyle(
        color: Colors.grey,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      majorGridLines: const MajorGridLines(width: 0),
      labelIntersectAction: AxisLabelIntersectAction.rotate45,
    );
  }

  /// Creates the Y-axis for the charts.
  NumericAxis _buildNumericYAxis({
    String? title,
    String format = '{value}°',
    double interval = 5,
  }) {
    return NumericAxis(
      title: AxisTitle(text: title ?? ''),
      labelStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      labelFormat: format,
      interval: interval,
      axisLine: const AxisLine(width: 0),
      majorTickLines: const MajorTickLines(size: 0),
    );
  }

  /// Creates the series for either max or min temperature.
  SplineSeries<_ChartData, String> _buildTempSeries({required bool isMaxTemp}) {
    return SplineSeries<_ChartData, String>(
      dataSource: _chartData,
      xValueMapper: (data, _) => '${data.date.day}/${data.date.month}',
      yValueMapper: (data, _) => isMaxTemp ? data.maxTemp : data.minTemp,
      name: isMaxTemp
          ? 'Température maximum prévue'
          : 'Température minimum prévue',
      color: isMaxTemp ? Colors.red.shade400 : Colors.blue.shade400,
      width: 3,
      markerSettings: const MarkerSettings(isVisible: false),
      dataLabelSettings: DataLabelSettings(
        isVisible: true,
        labelAlignment: isMaxTemp
            ? ChartDataLabelAlignment.top
            : ChartDataLabelAlignment.bottom,
        builder: (data, point, series, pointIndex, seriesIndex) {
          final chartData = data as _ChartData;
          return Padding(
            padding: EdgeInsets.only(bottom: isMaxTemp ? 30.0 : 0),
            child: _buildTempLabel(
              isMaxTemp ? chartData.maxTemp : chartData.minTemp,
              isMaxTemp
                  ? chartData.maxTempDeviation
                  : chartData.minTempDeviation,
            ),
          );
        },
      ),
    );
  }

  /// Creates annotations for weather icons on the temperature chart.
  List<CartesianChartAnnotation> _buildWeatherIconAnnotations() {
    return [
      for (final data in _chartData)
        if (data.iconPath != null)
          CartesianChartAnnotation(
            widget: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: SvgPicture.asset(data.iconPath!),
              ),
            ),
            coordinateUnit: CoordinateUnit.point,
            region: AnnotationRegion.chart,
            x: '${data.date.day}/${data.date.month}',
            y: data.maxTemp,
          ),
    ];
  }

  Widget _buildSimplifiedTooltip(dynamic data, dynamic point, dynamic series,
      int pointIndex, int seriesIndex) {
    final chartData = data as _ChartData;
    final isMaxTemp = series.name == 'Température maximum prévue';
    final temp = isMaxTemp ? chartData.maxTemp : chartData.minTemp;
    final tempLabel = isMaxTemp ? 'Max' : 'Min';

    // **FIX**: Simplified tooltip without complex Stack layout
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2)
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE d MMMM', 'fr_FR').format(chartData.date),
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14
            ),
          ),
          if (chartData.weatherDescription != null) ...[
            const SizedBox(height: 4),
            Text(
              chartData.weatherDescription!,
              style: const TextStyle(
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                  fontSize: 12
              ),
            ),
          ],
          const SizedBox(height: 8),
          _buildSimpleTooltipRow(Icons.thermostat, 'Temp. $tempLabel: ${temp.round()}°C'),
          if (chartData.precipitationSum != null && chartData.precipitationSum! > 0)
            _buildSimpleTooltipRow(Icons.water_drop,
                'Précip: ${chartData.precipitationSum?.toStringAsFixed(1)} mm'),
          if (chartData.precipitationProbability != null && chartData.precipitationProbability! > 0)
            _buildSimpleTooltipRow(Icons.umbrella,
                'Prob. préc: ${chartData.precipitationProbability}%'),
          if (chartData.windSpeed != null && chartData.windSpeed! > 0)
            _buildSimpleTooltipRow(
                Icons.air, 'Vent: ${chartData.windSpeed?.round()} km/h'),
        ],
      ),
    );
  }

  /// Builds a simple row within the tooltip without complex layouts.
  Widget _buildSimpleTooltipRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the data label for temperature points on the chart.
  Widget _buildTempLabel(double temp, double? deviation) {
    final tempStyle = const TextStyle(
        color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold);

    if (deviation == null) {
      return Text('${temp.round()}°', style: tempStyle);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${temp.round()}°', style: tempStyle),
        Text(
          '${deviation > 0 ? '+' : ''}${deviation.round()}°',
          style: TextStyle(
            color: _getDeviationColor(deviation),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Determines the color for a deviation value.
  Color _getDeviationColor(double deviation) {
    if (deviation > 2) return Colors.red[700]!;
    if (deviation > 0.5) return Colors.orange[700]!;
    if (deviation < -2) return Colors.blue[800]!;
    if (deviation < -0.5) return Colors.blue[500]!;
    return Colors.green[700]!;
  }
// endregion
}