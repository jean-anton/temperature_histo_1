import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// Import your data models and icon data
import '../data/weather_icon_data.dart';
import '../models/weather_forecast_model.dart';

class WeatherChart2 extends StatefulWidget {
  final WeatherForecast forecast;

  const WeatherChart2({
    super.key,
    required this.forecast,
  });

  @override
  State<WeatherChart2> createState() => _WeatherChart2State();
}

class _WeatherChart2State extends State<WeatherChart2> {
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    super.initState();
    // Initialize the tooltip behavior for the chart
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      header: '', // We don't need a header for the tooltip
      format: 'point.x: point.y°C', // Customizes the tooltip text
    );
  }

  /// Helper function to find the icon path for a given weather code.
  /// Returns null if the code is not found.
  String? _getIconPathForCode(int? code) {
    if (code == null) return null;
    try {
      // Find the WeatherIcon object where the code matches.
      final iconData =
      weatherIcons.firstWhere((icon) => icon.code == code.toString());
      return iconData.iconPath;
    } catch (e) {
      // This catch block handles cases where a weather code from the API
      // might not be in our local list.
      // print("Icon for weather code '$code' not found.");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using a LayoutBuilder is a robust way to handle responsive width.
    // It provides the constraints of the parent widget.
    return LayoutBuilder(
      builder: (context, constraints) {
        // We calculate a dynamic width for the chart.
        // This gives each day's data point enough space (e.g., 80 pixels).
        final double chartWidth =
            widget.forecast.dailyForecasts.length * 80.0;

        // The chart should be at least as wide as the screen.
        final double minWidth = constraints.maxWidth;

        // --- FIXED: Generate annotations for the weather icons ---
        final List<CartesianChartAnnotation> chartAnnotations = widget
            .forecast.dailyForecasts
            .map((daily) {
          final String? iconPath = _getIconPathForCode(daily.weatherCode);
          // If an icon path is found, create an annotation for it.
          if (iconPath != null) {
            return CartesianChartAnnotation(
              // The widget to display is an SVG icon.
              widget: SizedBox(
                width: 30,
                height: 80,
                child: Column(
                  children: [
                    SvgPicture.asset(iconPath),
                    const SizedBox(height: 6),
                    Text(daily.temperatureMax.round().toString() + '°'),
                  ],
                ),
              ),
              // Position the annotation relative to a data point.
              coordinateUnit: CoordinateUnit.point,
              // The X-value (date) and Y-value (temperature) for positioning.
              x: DateFormat('E, d MMM').format(daily.date),
              // We add a small offset to the Y value to place the icon
              // slightly above the data point and its label.
              // y: daily.temperatureMax + 3,
              y: daily.temperatureMax +1,
            );
          }
          // Return null for days without a valid icon to filter them out.
          return null;
        })
            .whereType<CartesianChartAnnotation>() // Remove nulls from the list
            .toList();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            // The width is the larger of our calculated width or the screen width.
            // This ensures the chart is scrollable if it's too wide for the screen.
            width: chartWidth > minWidth ? chartWidth : minWidth,
            height: 400, // A fixed height for the chart container
            child: SfCartesianChart(
              title: ChartTitle(text: 'Maximum Daily Temperature Forecast'),
              tooltipBehavior: _tooltipBehavior,

              // --- FIXED: Add the generated annotations to the chart ---
              annotations: chartAnnotations,

              // Configure the X-axis (for dates)
              primaryXAxis: CategoryAxis(
                // This helps in placing labels correctly on the axis ticks.
                labelPlacement: LabelPlacement.onTicks,
                // Rotate labels to prevent them from overlapping.
                labelRotation: -45,
              ),

              // Configure the Y-axis (for temperature)
              primaryYAxis: NumericAxis(
                title: AxisTitle(text: 'Temperature (°C)'),
                // Format the axis labels to include the degree symbol.
                labelFormat: '{value}°C',
                // Sets the desired interval for the axis labels.
                interval: 5,
                // Increase the maximum to make space for the icons.
                maximum: widget.forecast.dailyForecasts
                    .map((d) => d.temperatureMax)
                    .reduce((a, b) => a > b ? a : b) +
                    5,
              ),

              // Define the data series to be plotted on the chart
              series: <CartesianSeries<DailyForecast, String>>[
                LineSeries<DailyForecast, String>(
                  // The data source for this series
                  dataSource: widget.forecast.dailyForecasts,

                  // Map data points to the X and Y axes
                  xValueMapper: (DailyForecast daily, _) =>
                      DateFormat('E, d MMM').format(daily.date), // e.g., "Mon, 15 Jul"
                  yValueMapper: (DailyForecast daily, _) =>
                  daily.temperatureMax,

                  name: 'Max Temp', // Used for legends, if enabled

                  // Add markers to each data point for better visibility
                  markerSettings: const MarkerSettings(isVisible: true),

                  // Display the temperature value on top of each data point
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: false,
                    textStyle: TextStyle(fontSize: 15),
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