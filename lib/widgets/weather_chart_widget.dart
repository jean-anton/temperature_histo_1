import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/climate_normal_model.dart';
import '../models/weather_forecast_model.dart';
import 'utils/weather_deviation.dart';
import 'utils/chart_constants.dart';
import 'utils/chart_helpers.dart';
import 'utils/weather_tooltip.dart';
import 'builders/daily_chart_builder.dart';
import 'builders/hourly_chart_builder.dart';

class WeatherChart2 extends StatefulWidget {
  final DailyWeather? forecast;
  final HourlyWeather? dailyWeather;
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
  // Made reassignable so we can recompute on widget updates.
  late List<WeatherDeviation?> _deviations;
  late double _maxTemp;
  late double _minTemp;
  late List<String> _labels;

  int? _touchedIndex;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeChartData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.displayMode == 'hourly' && widget.dailyWeather != null) {
        _scrollToCurrentTime();
      }
    });
  }

  @override
  void didUpdateWidget(covariant WeatherChart2 oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Recompute chart data when inputs or mode change.
    final modeChanged = oldWidget.displayMode != widget.displayMode;
    final forecastChanged = oldWidget.forecast != widget.forecast;
    final dailyChanged = oldWidget.dailyWeather != widget.dailyWeather;
    final normalsChanged = oldWidget.climateNormals != widget.climateNormals;

    if (modeChanged || forecastChanged || dailyChanged || normalsChanged) {
      _touchedIndex = null;
      _initializeChartData();

      // Scroll after layout so ScrollController has valid extents.
      if (widget.displayMode == 'hourly' && widget.dailyWeather != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToCurrentTime();
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    WeatherTooltip.removeTooltip();
    super.dispose();
  }

  // Initialize chart data based on display mode.
  void _initializeChartData() {
    if (widget.displayMode == 'daily') {
      _initDailyChart();
    } else {
      _initHourlyChart();
    }
  }

  // Initialize daily chart data.
  void _initDailyChart() {
    if (widget.forecast == null) {
      _deviations = [];
      _maxTemp = 0;
      _minTemp = 0;
      _labels = [];
      return;
    }

    _deviations = widget.forecast!.dailyForecasts
        .map((daily) => ChartHelpers.getDeviationForDay(daily, widget.climateNormals))
        .toList();

    final tempRange = ChartHelpers.calculateTempRange(
      widget.forecast,
      widget.dailyWeather,
      widget.displayMode,
    );
    _maxTemp = tempRange['max']!;
    _minTemp = tempRange['min']!;

    _labels = ChartHelpers.generateDateLabels(widget.forecast);
  }

  // Initialize hourly chart data.
  void _initHourlyChart() {
    if (widget.dailyWeather == null) {
      _deviations = [];
      _maxTemp = 0;
      _minTemp = 0;
      _labels = [];
      return;
    }

    _deviations = [];

    final tempRange = ChartHelpers.calculateTempRange(
      widget.forecast,
      widget.dailyWeather,
      widget.displayMode,
    );
    _maxTemp = tempRange['max']!;
    _minTemp = tempRange['min']!;

    _labels = ChartHelpers.generateHourLabels(widget.dailyWeather);
  }

  // Scroll so that the hour equal to (now - 1h) is at the LEFT EDGE of the viewport.
  // If there is no exact match, choose the latest hour <= (now - 1h).
  void _scrollToCurrentTime() {
    final daily = widget.dailyWeather;
    if (daily == null || !_scrollController.hasClients) return;

    final List<HourlyForecast> hours = daily.hourlyForecasts;
    if (hours.isEmpty) return;

    final DateTime target = DateTime.now().toLocal().subtract(const Duration(hours: 1));

    // Pick the last index whose local time <= target. If none, use 0. If beyond, clamp later.
    int targetIndex = 0;
    bool found = false;

    for (int i = 0; i < hours.length; i++) {
      final DateTime t = hours[i].time.toLocal();
      if (t.isBefore(target) || t.isAtSameMomentAs(target)) {
        targetIndex = i;
        found = true;
      } else {
        // Since data is expected in chronological order, we can break on first > target.
        if (found) break;
      }
    }

    _scrollToHourlyIndexLeftAligned(targetIndex);
  }

  // Helper to align a given hourly index to the left edge of the viewport.
  void _scrollToHourlyIndexLeftAligned(int index) {
    if (!_scrollController.hasClients) return;

    final double itemWidth = ChartConstants.hourlyChartWidthPerHour.toDouble();
    double targetOffset = index * itemWidth;

    // Clamp to valid scrollable range.
    final maxExtent = _scrollController.position.maxScrollExtent;
    if (targetOffset < 0) targetOffset = 0;
    if (targetOffset > maxExtent) targetOffset = maxExtent;

    // CJG Animate to the position.
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 1),
      curve: Curves.easeInOut,
    );
  }

  // Handle tap events on the chart.
  void _onChartTap(TapDownDetails details, Size containerSize) {
    final Offset localPosition = details.localPosition;
    final int maxIndex = widget.displayMode == 'daily'
        ? (widget.forecast?.dailyForecasts.length ?? 1) - 1
        : (widget.dailyWeather?.hourlyForecasts.length ?? 1) - 1;

    final int? tappedIndex = ChartHelpers.getTappedIndex(
      localPosition,
      containerSize,
      maxIndex,
    );

    if (tappedIndex != null) {
      setState(() {
        _touchedIndex = tappedIndex;
      });
      _showTooltip(tappedIndex, details.globalPosition);
    }
  }

  // Show tooltip for the tapped data point.
  void _showTooltip(int touchedIndex, Offset position) {
    if (widget.displayMode == 'daily' && widget.forecast != null) {
      WeatherTooltip.showDailyTooltip(
        context,
        touchedIndex,
        position,
        widget.forecast!,
        _deviations,
      );
    } else if (widget.displayMode == 'hourly' && widget.dailyWeather != null) {
      WeatherTooltip.showHourlyTooltip(
        context,
        touchedIndex,
        position,
        widget.dailyWeather!,
      );
    }
  }

  // Calculate chart dimensions.
  Map<String, double> _calculateChartDimensions(double minWidth) {
    late double chartWidth;
    late double finalHeight;
    //print("####CJG MinWidth: $minWidth");
    if (widget.displayMode == 'daily' && widget.forecast != null) {
      chartWidth =
          widget.forecast!.dailyForecasts.length * ChartConstants.widthPerDay;
      finalHeight = ChartConstants.dailyChartHeight;
      if(minWidth > 600) {
        chartWidth = minWidth;
      }


      
    } else if (widget.displayMode == 'hourly' && widget.dailyWeather != null) {
      chartWidth = widget.dailyWeather!.hourlyForecasts.length *
          ChartConstants.hourlyChartWidthPerHour;
      finalHeight = ChartConstants.hourlyChartHeight;
    } else {
      chartWidth = minWidth;
      finalHeight = ChartConstants.dailyChartHeight;
    }

    final double finalWidth = chartWidth > minWidth ? chartWidth : minWidth;

    return {
      'width': finalWidth,
      'height': finalHeight,
    };
  }

  // Build the appropriate chart based on display mode.
  Widget _buildChart(Size containerSize) {
    if (widget.displayMode == 'daily' && widget.forecast != null) {
      return DailyChartBuilder.build(
        forecast: widget.forecast!,
        deviations: _deviations,
        minTemp: _minTemp,
        maxTemp: _maxTemp,
        dateLabels: _labels,
        containerSize: containerSize,
      );
    } else if (widget.displayMode == 'hourly' && widget.dailyWeather != null) {
      return HourlyChartBuilder.build(
        dailyWeather: widget.dailyWeather!,
        minTemp: _minTemp,
        maxTemp: _maxTemp,
        hourLabels: _labels,
        containerSize: containerSize,
      );
    }

    return const Center(
      child: Text(
        'No data available',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dimensions = _calculateChartDimensions(constraints.maxWidth);
        final Size containerSize =
            Size(dimensions['width']!, dimensions['height']!);

        return Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          thickness: 10,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: dimensions['width'],
              height: dimensions['height'],
              child: GestureDetector(
                onTapDown: (details) => _onChartTap(details, containerSize),
                child: _buildChart(containerSize),
              ),
            ),
          ),
        );
      },
    );
  }
}
