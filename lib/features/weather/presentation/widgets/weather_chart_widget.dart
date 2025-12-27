import 'package:flutter/material.dart';
import 'package:temperature_histo_1/features/climate/domain/climate_model.dart';
import 'package:temperature_histo_1/features/weather/domain/weather_model.dart';
import 'utils/chart_constants.dart';
import 'utils/chart_helpers.dart';
import 'utils/weather_tooltip.dart';
import 'builders/daily_chart_builder.dart';
import 'builders/hourly_chart_builder.dart';
import 'builders/wind_chart_builder.dart';

class WeatherChart2 extends StatefulWidget {
  final DailyWeather? forecast;
  final HourlyWeather? hourlyWeather;
  final List<ClimateNormal> climateNormals;
  final String displayMode; // 'daily' or 'hourly'
  final DisplayType displayType;
  final bool showWindInfo;
  final bool showExtendedWindInfo;

  const WeatherChart2({
    super.key,
    this.forecast,
    this.hourlyWeather,
    required this.climateNormals,
    required this.displayMode,
    required this.displayType,
    this.showWindInfo = true,
    this.showExtendedWindInfo = false,
  });

  @override
  State<WeatherChart2> createState() => _WeatherChart2State();
}

class _WeatherChart2State extends State<WeatherChart2> {
  final ScrollController _scrollController = ScrollController();
  List<WeatherDeviation?> _deviations = [];
  double _minTemp = 0;
  double _maxTemp = 40;
  List<String> _labels = [];

  @override
  void initState() {
    super.initState();
    _calculateChartData();
  }

  @override
  void didUpdateWidget(WeatherChart2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.forecast != oldWidget.forecast ||
        widget.hourlyWeather != oldWidget.hourlyWeather ||
        widget.displayMode != oldWidget.displayMode ||
        widget.displayType != oldWidget.displayType) {
      _calculateChartData();
    }
  }

  void _calculateChartData() {
    final range = ChartHelpers.calculateTempRange(
      widget.forecast,
      widget.hourlyWeather,
      widget.displayMode,
    );
    _minTemp = range['min'] ?? 0;
    _maxTemp = range['max'] ?? 40;

    if (widget.displayMode == 'daily' && widget.forecast != null) {
      _deviations = widget.forecast!.dailyForecasts.map((daily) {
        return ChartHelpers.getDeviationForDay(daily, widget.climateNormals);
      }).toList();
      _labels = ChartHelpers.generateDateLabels(widget.forecast);
    } else if (widget.displayMode == 'hourly' && widget.hourlyWeather != null) {
      _labels = ChartHelpers.generateHourLabels(widget.hourlyWeather!);
    }
  }

  void _onChartTap(TapDownDetails details, Size containerSize) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    final double scrollOffset = _scrollController.offset;
    final Offset chartOffset = Offset(
      localOffset.dx + scrollOffset,
      localOffset.dy,
    );

    if ((widget.displayType == DisplayType.vent ||
            widget.displayType == DisplayType.ventDay) &&
        widget.hourlyWeather != null) {
      final tappedIndex = ChartHelpers.getTappedIndexForHourly(
        chartOffset,
        containerSize,
        widget.hourlyWeather!,
      );
      if (tappedIndex != null) {
        WeatherTooltip.showHourlyTooltip(
          context,
          tappedIndex,
          details.globalPosition,
          widget.hourlyWeather!,
          showExtendedWindInfo: widget.showExtendedWindInfo,
        );
      }
      return;
    }

    if (widget.displayMode == 'daily' && widget.forecast != null) {
      final tappedIndex = ChartHelpers.getTappedIndex(
        chartOffset,
        containerSize,
        widget.forecast!.dailyForecasts.length - 1,
      );
      if (tappedIndex != null) {
        WeatherTooltip.showDailyTooltip(
          context,
          tappedIndex,
          details.globalPosition,
          widget.forecast!,
          _deviations,
        );
      }
    } else if (widget.displayMode == 'hourly' && widget.hourlyWeather != null) {
      final tappedIndex = ChartHelpers.getTappedIndexForHourly(
        chartOffset,
        containerSize,
        widget.hourlyWeather!,
      );
      if (tappedIndex != null) {
        WeatherTooltip.showHourlyTooltip(
          context,
          tappedIndex,
          details.globalPosition,
          widget.hourlyWeather!,
          showExtendedWindInfo: widget.showExtendedWindInfo,
        );
      }
    }
  }

  Map<String, double> _calculateChartDimensions(double containerWidth) {
    double chartWidth = containerWidth;
    double finalHeight = ChartConstants.dailyChartHeight;
    const double minWidth = 600.0;

    if (widget.displayMode == 'daily' && widget.forecast != null) {
      if (widget.displayType == DisplayType.vent ||
          widget.displayType == DisplayType.ventDay) {
        chartWidth =
            widget.forecast!.dailyForecasts.length *
            ChartConstants.widthPerDayWind;
      } else {
        chartWidth =
            widget.forecast!.dailyForecasts.length * ChartConstants.widthPerDay;
      }
      finalHeight = ChartConstants.dailyChartHeight;
    } else if (widget.displayMode == 'hourly' && widget.hourlyWeather != null) {
      chartWidth =
          widget.hourlyWeather!.hourlyForecasts.last.time
              .difference(widget.hourlyWeather!.hourlyForecasts.first.time)
              .inHours *
          ChartConstants.hourlyChartWidthPerHour;
      finalHeight = ChartConstants.hourlyChartHeight;
    }

    final double finalWidth = chartWidth > minWidth ? chartWidth : minWidth;

    return {'width': finalWidth, 'height': finalHeight};
  }

  // Build the appropriate chart based on display mode.
  Widget _buildChart(Size containerSize, BoxConstraints constraints) {
    // Check display type first for Vent mode
    if ((widget.displayType == DisplayType.vent ||
            widget.displayType == DisplayType.ventDay) &&
        widget.hourlyWeather != null) {
      final startTime = widget.displayMode == 'daily'
          ? widget.forecast!.dailyForecasts.first.date
          : widget.hourlyWeather!.hourlyForecasts.first.time;
      final endTime = widget.displayMode == 'daily'
          ? widget.forecast!.dailyForecasts.last.date.add(
              const Duration(days: 1),
            )
          : widget.hourlyWeather!.hourlyForecasts.last.time.add(
              const Duration(hours: 1),
            );

      return WindChartBuilder.build(
        hourlyWeather: widget.hourlyWeather!,
        forecast: widget.forecast!,
        containerSize: containerSize,
        displayMode: widget.displayMode,
        displayType: widget.displayType,
        startTime: startTime,
        endTime: endTime,
        labels: _labels,
        minY: -20.0,
        maxY: 210,
      );
    }

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
