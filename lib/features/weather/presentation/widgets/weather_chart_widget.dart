import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:temperature_histo_1/features/climate/domain/climate_model.dart';
import 'package:temperature_histo_1/features/weather/domain/weather_model.dart';
import 'utils/weather_deviation.dart';
import 'utils/chart_constants.dart';
import 'utils/chart_helpers.dart';
import 'utils/weather_tooltip.dart';
import 'builders/daily_chart_builder.dart';
import 'builders/hourly_chart_builder.dart';

class WeatherChart2 extends StatefulWidget {
  final DailyWeather? forecast;
  final HourlyWeather? hourlyWeather;
  final List<ClimateNormal> climateNormals;
  final String displayMode; // 'daily' or 'hourly'
  final bool showWindInfo;
  final bool showExtendedWindInfo;

  const WeatherChart2({
    super.key,
    this.forecast,
    this.hourlyWeather,
    required this.climateNormals,
    required this.displayMode,
    this.showWindInfo = true,
    this.showExtendedWindInfo = false,
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
      if (widget.displayMode == 'hourly' && widget.hourlyWeather != null) {
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
    final dailyChanged = oldWidget.hourlyWeather != widget.hourlyWeather;
    final normalsChanged = oldWidget.climateNormals != widget.climateNormals;

    if (modeChanged || forecastChanged || dailyChanged || normalsChanged) {
      _touchedIndex = null;
      _initializeChartData();

      // Scroll after layout so ScrollController has valid extents.
      if (widget.displayMode == 'hourly' && widget.hourlyWeather != null) {
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
        .map(
          (daily) =>
              ChartHelpers.getDeviationForDay(daily, widget.climateNormals),
        )
        .toList();

    final tempRange = ChartHelpers.calculateTempRange(
      widget.forecast,
      widget.hourlyWeather,
      widget.displayMode,
    );
    _maxTemp = tempRange['max']!;
    _minTemp = tempRange['min']!;

    _labels = ChartHelpers.generateDateLabels(widget.forecast);
  }

  // Initialize hourly chart data.
  void _initHourlyChart() {
    if (widget.hourlyWeather == null) {
      _deviations = [];
      _maxTemp = 0;
      _minTemp = 0;
      _labels = [];
      return;
    }

    _deviations = [];

    final tempRange = ChartHelpers.calculateTempRange(
      widget.forecast,
      widget.hourlyWeather,
      widget.displayMode,
    );
    _maxTemp = tempRange['max']!;
    _minTemp = tempRange['min']!;

    _labels = ChartHelpers.generateHourLabels(widget.hourlyWeather);
  }

  // Scroll so that the hour equal to (now - 1h) is at the LEFT EDGE of the viewport.
  void _scrollToCurrentTime() {
    final hourlyWeather = widget.hourlyWeather;
    if (hourlyWeather == null || !_scrollController.hasClients) return;

    final DateTime targetTime = DateTime.now().subtract(
      const Duration(hours: 1),
    );
    _scrollToHourlyTime(targetTime);
  }

  /// Helper to scroll the chart to a specific time, aligning it to the left edge.
  ///
  /// This method calculates the precise pixel offset by using the same
  /// `calculateScreenPosition2` helper that the chart uses to draw its elements.
  /// This ensures that the scroll position is perfectly synchronized with the
  /// time-based rendering of the chart, avoiding alignment issues caused by
  /// mismatched calculation logic (e.g., index-based vs. time-based).
  void _scrollToHourlyTime(DateTime targetTime) {
    if (!_scrollController.hasClients || widget.hourlyWeather == null) return;

    final hourlyWeather = widget.hourlyWeather!;

    // To calculate the correct screen position, we need the total dimensions
    // of the chart as if it were fully rendered.
    final totalWidth =
        hourlyWeather.hourlyForecasts.length *
        ChartConstants.hourlyChartWidthPerHour;
    final containerSize = Size(totalWidth, ChartConstants.hourlyChartHeight);

    // Use the canonical helper to convert a time coordinate into a pixel coordinate.
    // This guarantees consistency with the chart's own rendering logic.
    final screenPos = ChartHelpers.calculateScreenPosition2(
      targetTime.millisecondsSinceEpoch.toDouble(),
      _minTemp, // Y-coordinate is not relevant for horizontal scrolling.
      containerSize,
      _minTemp,
      _maxTemp,
      hourlyWeather.hourlyForecasts.first.time,
      hourlyWeather.hourlyForecasts.last.time,
    );

    // `screenPos.dx` gives the absolute pixel position from the left edge of the
    // chart widget. To align this position with the left edge of the viewport,
    // we must subtract the chart's internal padding.
    double targetOffset =
        screenPos.dx -
        ChartConstants.leftPadding -
        ChartConstants.leftTitleReservedSize;

    // Ensure the calculated offset is within the valid scrollable range.
    final maxExtent = _scrollController.position.maxScrollExtent;
    targetOffset = targetOffset.clamp(0.0, maxExtent);

    // Animate the scroll to the calculated offset.
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Handle tap events on the chart.
  void _onChartTap(TapDownDetails details, Size containerSize) {
    final Offset localPosition = details.localPosition;

    int? tappedIndex;

    if (widget.displayMode == 'daily') {
      final int maxIndex = (widget.forecast?.dailyForecasts.length ?? 1) - 1;
      tappedIndex = ChartHelpers.getTappedIndex(
        localPosition,
        containerSize,
        maxIndex,
      );
    } else if (widget.displayMode == 'hourly' && widget.hourlyWeather != null) {
      // Use time-based positioning for hourly charts
      tappedIndex = ChartHelpers.getTappedIndexForHourly(
        localPosition,
        containerSize,
        widget.hourlyWeather!,
      );
    }

    if (tappedIndex != null) {
      setState(() {
        _touchedIndex = tappedIndex;
      });
      _showTooltip(tappedIndex, details.globalPosition);
    } else {
      // If tapped outside data points, dismiss any active tooltip
      WeatherTooltip.removeTooltip();
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
    } else if (widget.displayMode == 'hourly' && widget.hourlyWeather != null) {
      WeatherTooltip.showHourlyTooltip(
        context,
        touchedIndex,
        position,
        widget.hourlyWeather!,
        showExtendedWindInfo: widget.showExtendedWindInfo,
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
      if (minWidth > 600) {
        chartWidth = minWidth;
      }
    } else if (widget.displayMode == 'hourly' && widget.hourlyWeather != null) {
      chartWidth =
          widget.hourlyWeather!.hourlyForecasts.last.time
              .difference(widget.hourlyWeather!.hourlyForecasts.first.time)
              .inHours *
          ChartConstants.hourlyChartWidthPerHour;
      finalHeight = ChartConstants.hourlyChartHeight;
    } else {
      chartWidth = minWidth;
      finalHeight = ChartConstants.dailyChartHeight;
    }

    final double finalWidth = chartWidth > minWidth ? chartWidth : minWidth;

    return {'width': finalWidth, 'height': finalHeight};
  }

  // Build the appropriate chart based on display mode.
  Widget _buildChart(Size containerSize, BoxConstraints constraints) {
    if (widget.displayMode == 'daily' && widget.forecast != null) {
      return DailyChartBuilder.build(
        forecast: widget.forecast!,
        deviations: _deviations,
        minTemp: _minTemp,
        maxTemp: _maxTemp,
        dateLabels: _labels,
        containerSize: containerSize,
        showWindInfo: widget.showWindInfo,
      );
    } else if (widget.displayMode == 'hourly' && widget.hourlyWeather != null) {
      return HourlyChartBuilder.build(
        //return HourlyChartBuilder_test1.build(
        //return HourlyChartBuilderOLD.build(
        hourlyWeather: widget.hourlyWeather!,
        forecast: widget.forecast!,
        minTemp: _minTemp,
        maxTemp: _maxTemp,
        hourLabels: _labels,
        constraints: constraints,

        containerSize: containerSize,
        showWindInfo: widget.showWindInfo,
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
        final Size containerSize = Size(
          dimensions['width']!,
          dimensions['height']!,
        );

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
                child: _buildChart(containerSize, constraints),
              ),
            ),
          ),
        );
      },
    );
  }
}
