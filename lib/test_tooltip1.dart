import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Chart App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const WeatherChartPage(),
    );
  }
}

class WeatherChartPage extends StatefulWidget {
  const WeatherChartPage({super.key});

  @override
  State<WeatherChartPage> createState() => _WeatherChartPageState();
}

class _WeatherChartPageState extends State<WeatherChartPage> {
  late List<WeatherData> data;
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    super.initState();
    data = getWeatherData();
    _tooltip = TooltipBehavior(
      enable: true,
      // Make the tooltip container transparent since we provide our own styled container
      color: Colors.transparent,
      elevation: 0,
      builder:
          (
            dynamic data,
            dynamic point,
            dynamic series,
            int pointIndex,
            int seriesIndex,
          ) {
            final weather = data as WeatherData;
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(weather.iconPath, width: 40, height: 40),
                  const SizedBox(height: 8),
                  Text(
                    weather.day,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${weather.temperature.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    weather.condition,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            );
          },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Temperature Chart'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.blue.shade100],
          ),
        ),
        child: WeatherChart_stub(tooltip: _tooltip, data: data),
      ),
    );
  }
}

List<WeatherData> getWeatherData() {
  final List<WeatherData> weatherData = [
    WeatherData(
      'Monday',
      22.5,
      'Partly Cloudy',
      'assets/google_weather_icons/v4/partly_cloudy_day.svg',
    ),
    WeatherData(
      'Tuesday',
      28.3,
      'Cloudy',
      'assets/google_weather_icons/v4/cloudy.svg',
    ),
    WeatherData(
      'Wednesday',
      31.2,
      'Sunny',
      'assets/google_weather_icons/v4/clear_day.svg',
    ),
    WeatherData(
      'Thursday',
      26.8,
      'Partly Cloudy',
      'assets/google_weather_icons/v4/partly_cloudy_day.svg',
    ),
    WeatherData(
      'Friday',
      19.1,
      'Rainy',
      'assets/google_weather_icons/v4/rain.svg',
    ),
    WeatherData(
      'Saturday',
      24.7,
      'Cloudy',
      'assets/google_weather_icons/v4/cloudy.svg',
    ),
    WeatherData(
      'Sunday',
      29.4,
      'Sunny',
      'assets/google_weather_icons/v4/clear_day.svg',
    ),
    WeatherData(
      'Mon 2',
      23.4,
      'Sunny',
      'assets/google_weather_icons/v4/clear_day.svg',
    ),
    WeatherData(
      'Tue 2',
      25.9,
      'Sunny',
      'assets/google_weather_icons/v4/clear_day.svg',
    ),
    WeatherData(
      'Wed 2',
      30.1,
      'Sunny',
      'assets/google_weather_icons/v4/clear_day.svg',
    ),
    WeatherData(
      'Thu 2',
      27.5,
      'Sunny',
      'assets/google_weather_icons/v4/clear_day.svg',
    ),
    WeatherData(
      'Fri 2',
      21.3,
      'Rainy',
      'assets/google_weather_icons/v4/rain.svg',
    ),
    WeatherData(
      'Sat 2',
      22.0,
      'Cloudy',
      'assets/google_weather_icons/v4/cloudy.svg',
    ),
    WeatherData(
      'Sun 2',
      28.8,
      'Partly Cloudy',
      'assets/google_weather_icons/v4/partly_cloudy_day.svg',
    ),
    WeatherData(
      'Mon 3',
      29.4,
      'Sunny',
      'assets/google_weather_icons/v4/clear_day.svg',
    ),
    WeatherData(
      'Tue 3',
      29.4,
      'Sunny',
      'assets/google_weather_icons/v4/clear_day.svg',
    ),
    WeatherData(
      'Wed 3',
      29.4,
      'Sunny',
      'assets/google_weather_icons/v4/clear_day.svg',
    ),
    WeatherData(
      'Thu 3',
      29.4,
      'Sunny',
      'assets/google_weather_icons/v4/clear_day.svg',
    ),
    WeatherData(
      'Fri 3',
      29.4,
      'Sunny',
      'assets/google_weather_icons/v4/clear_day.svg',
    ),
    WeatherData(
      'Sat 3',
      29.4,
      'Sunny',
      'assets/google_weather_icons/v4/clear_day.svg',
    ),
    WeatherData(
      'Sun 3',
      29.4,
      'Sunny',
      'assets/google_weather_icons/v4/clear_day.svg',
    ),
  ];
  return weatherData;
}

class WeatherChart_stub extends StatelessWidget {
  const WeatherChart_stub({
    super.key,
    required TooltipBehavior tooltip,
    required this.data,
  }) : _tooltip = tooltip;

  final TooltipBehavior _tooltip;
  final List<WeatherData> data;

  @override
  Widget build(BuildContext context) {
    // This outer scroll view handles vertical scrolling for the entire page content.
    // return SingleChildScrollView(
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        // Set a dynamic width to enable scrolling on smaller screens
        width: MediaQuery.of(context).size.width < 600
            ? MediaQuery.of(context).size.width * 2
            : MediaQuery.of(context).size.width,
        height: 400,
        child: SfCartesianChart(
          primaryXAxis: const CategoryAxis(
            labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            // --- IMPROVEMENT: Prevents labels from overlapping ---
            labelIntersectAction: AxisLabelIntersectAction.rotate45,
          ),
          primaryYAxis: const NumericAxis(
            minimum: 15,
            maximum: 35,
            interval: 5,
            labelFormat: '{value}°C',
            labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          tooltipBehavior: _tooltip,
          plotAreaBorderWidth: 0,
          annotations: data.map((weather) {
            return CartesianChartAnnotation(
              widget: Container(
                width: 28,
                height: 28,
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
                  padding: const EdgeInsets.all(3),
                  child: SvgPicture.asset(weather.iconPath),
                ),
              ),
              coordinateUnit: CoordinateUnit.point,
              x: weather.day,
              y: weather.temperature,
            );
          }).toList(),
          series: <CartesianSeries<WeatherData, String>>[
            LineSeries<WeatherData, String>(
              dataSource: data,
              xValueMapper: (WeatherData weather, _) => weather.day,
              yValueMapper: (WeatherData weather, _) => weather.temperature,
              name: 'Temperature',
              color: Colors.orange.shade600,
              width: 3,
              markerSettings: const MarkerSettings(isVisible: false),
              dataLabelSettings: DataLabelSettings(
                isVisible: true,
                labelAlignment: ChartDataLabelAlignment.top,
                builder:
                    (
                      dynamic data,
                      dynamic point,
                      dynamic series,
                      int pointIndex,
                      int seriesIndex,
                    ) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Text(
                          '${(data as WeatherData).temperature.toStringAsFixed(0)}°',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherData {
  WeatherData(this.day, this.temperature, this.condition, this.iconPath);

  final String day;
  final double temperature;
  final String condition;
  final String iconPath;
}
