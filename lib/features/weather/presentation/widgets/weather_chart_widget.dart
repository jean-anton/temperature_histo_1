import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:aeroclim/features/climate/domain/climate_model.dart';
import 'package:aeroclim/features/weather/domain/weather_model.dart';
import 'utils/chart_constants.dart';
import 'utils/chart_helpers.dart';
import 'utils/weather_tooltip.dart';
import 'builders/daily_chart_builder.dart';
import 'builders/hourly_chart_builder.dart';
import 'builders/wind_chart_builder.dart';
import 'builders/comparison_chart_builder.dart';

class WeatherChart2 extends StatefulWidget {
  final DailyWeather? forecast;
  final HourlyWeather? hourlyWeather;
  final MultiModelWeather? multiModelForecast;
  final MultiModelHourlyWeather? multiModelHourlyWeather;
  final List<ClimateNormal> climateNormals;
  final String displayMode; // 'daily' or 'hourly'
  final DisplayType displayType;
  final bool showWindInfo;
  final bool showExtendedWindInfo;
  final Function(DateTime)? onVisibleDayChanged;

  const WeatherChart2({
    super.key,
    this.forecast,
    this.hourlyWeather,
    this.multiModelForecast,
    this.multiModelHourlyWeather,
    required this.climateNormals,
    required this.displayMode,
    required this.displayType,
    this.showWindInfo = true,
    this.showExtendedWindInfo = false,
    this.onVisibleDayChanged,
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
    _scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentTime();
      _handleScroll(); // Initial position check
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (widget.displayMode != 'hourly' || widget.hourlyWeather == null) return;
    if (!_scrollController.hasClients) return;

    final hourlyWeather = widget.hourlyWeather!;
    if (hourlyWeather.hourlyForecasts.isEmpty) return;

    final offset = _scrollController.offset;
    final startTime = hourlyWeather.hourlyForecasts.first.time;

    // Calculate which hour is at the left edge
    // x = ChartConstants.leftAxisTitleSize + ChartConstants.leftAxisNameSize + (chartX - minX)/(maxX-minX)*chartWidth + borderWidth
    // We want the inverse of this logic to find chartX (time) from x (offset)

    final double axesOffset =
        ChartConstants.leftAxisTitleSize +
        ChartConstants.leftAxisNameSize +
        ChartConstants.borderWidth;

    // Adjust offset to account for left axes
    double adjustedOffset = offset - axesOffset;
    if (adjustedOffset < 0) adjustedOffset = 0;

    final hoursFromStart =
        adjustedOffset / ChartConstants.hourlyChartWidthPerHour;
    final visibleTime = startTime.add(Duration(hours: hoursFromStart.floor()));

    // Normalize to date (midnight)
    final visibleDate = DateTime(
      visibleTime.year,
      visibleTime.month,
      visibleTime.day,
    );

    widget.onVisibleDayChanged?.call(visibleDate);
  }

  @override
  void didUpdateWidget(WeatherChart2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.forecast != oldWidget.forecast ||
        widget.hourlyWeather != oldWidget.hourlyWeather ||
        widget.multiModelForecast != oldWidget.multiModelForecast ||
        widget.multiModelHourlyWeather != oldWidget.multiModelHourlyWeather ||
        widget.displayMode != oldWidget.displayMode ||
        widget.displayType != oldWidget.displayType) {
      _calculateChartData();
    }

    // If we switched to hourly mode or loaded new hourly data, scroll to current time
    if ((widget.displayMode == 'hourly' && oldWidget.displayMode != 'hourly') ||
        (widget.displayMode == 'hourly' &&
            widget.hourlyWeather != oldWidget.hourlyWeather)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentTime();
      });
    }
  }

  void _scrollToCurrentTime() {
    final hourlyWeather = widget.hourlyWeather;
    if (hourlyWeather == null || !_scrollController.hasClients) return;

    // Target is now - 1 hour to show some history context on the left
    final DateTime targetTime = DateTime.now().subtract(
      const Duration(hours: 1),
    );
    _scrollToHourlyTime(targetTime);
  }

  void _scrollToHourlyTime(DateTime targetTime) {
    if (!_scrollController.hasClients || widget.hourlyWeather == null) return;

    final hourlyWeather = widget.hourlyWeather!;
    if (hourlyWeather.hourlyForecasts.isEmpty) return;

    // Calculate chart dimensions logic must match _calculateChartDimensions
    final startTime = hourlyWeather.hourlyForecasts.first.time;
    final endTime = hourlyWeather.hourlyForecasts.last.time.add(
      const Duration(hours: 1),
    );

    final totalHours = endTime.difference(startTime).inHours;
    final totalWidth = totalHours * ChartConstants.hourlyChartWidthPerHour;
    final containerSize = Size(
      totalWidth.toDouble(),
      ChartConstants.hourlyChartHeight,
    );

    // Use the same method that positions elements in the chart
    final screenPos = ChartHelpers.calculateScreenPosition2(
      targetTime.millisecondsSinceEpoch.toDouble(),
      _minTemp, // Y coordinate doesn't matter for X position
      containerSize,
      _minTemp,
      _maxTemp,
      startTime,
      endTime,
    );

    // The X position from calculateScreenPosition2 already includes left axis/padding offsets
    // relative to the chart container.
    // However, the SingleChildScrollView is wrapping the whole chart.
    // We need to check if calculateScreenPosition2 returns x relative to the start of the chart graphic
    // or relative to the start of the drawing area.

    // ChartHelpers.calculateScreenPosition2 returns:
    // x = ChartConstants.leftAxisTitleSize + ChartConstants.leftAxisNameSize + (chartX - minX)/(maxX-minX)*chartWidth + borderWidth

    // This seems to be the coordinate within the chart widget.
    // The scroll view scrolls this entire widget.
    // So targetOffset should be screenPos.dx.

    // Since we want the target time to be at the left edge of the VISIBLE viewport,
    // we scroll exactly to that position.

    double targetOffset = screenPos.dx;

    // We might want to subtract the left padding/titles so that the time mark is exactly at the left edge?
    // If targetOffset is e.g. 100px (because of axis labels), scrolling to 100px will put the target time at x=0 in the viewport.
    // But the axis labels scroll with the chart (they are part of the drawn chart in SingleChildScrollView).
    // Wait, typically axis labels are fixed?
    // Looking at `build`:
    // SingleChildScrollView -> SizedBox -> _buildChart
    // HourlyChartBuilder builds the whole thing including axes using fl_chart.
    // So the axes SCROLL with the chart.
    // If I scroll to `targetOffset`, the pixel at `targetOffset` will be at the left edge of the screen.
    // This effectively hides the left part of the chart (earlier times and maybe left axis labels).
    // If we want "now - 1h" to be at the left edge, we scroll so that the x-position of "now - 1h" becomes 0 relative to viewport.
    // So yes, `targetOffset = screenPos.dx` seems correct, possibly minus some padding if we want a margin.
    // Let's use `screenPos.dx` strictly for now as per plan.

    // Clamp to valid scrollable range
    final maxExtent = _scrollController.position.maxScrollExtent;
    targetOffset = targetOffset.clamp(0.0, maxExtent);

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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

    bool tooltipShown = false;

    if (widget.displayType == DisplayType.comparatif) {
      int? tappedIndex;
      if (widget.displayMode == 'daily' && widget.multiModelForecast != null) {
        final firstModel = widget.multiModelForecast!.models.values.first;
        tappedIndex = ChartHelpers.getTappedIndex(
          chartOffset,
          containerSize,
          firstModel.dailyForecasts.length - 1,
        );
      } else if (widget.displayMode == 'hourly' &&
          widget.multiModelHourlyWeather != null) {
        final firstModel = widget.multiModelHourlyWeather!.models.values.first;
        tappedIndex = ChartHelpers.getTappedIndexForHourly(
          chartOffset,
          containerSize,
          firstModel,
        );
      }

      if (tappedIndex != null) {
        WeatherTooltip.showComparisonTooltip(
          context,
          tappedIndex,
          details.globalPosition,
          widget.displayMode,
          widget.multiModelForecast,
          widget.multiModelHourlyWeather,
        );
        tooltipShown = true;
      }
    } else if ((widget.displayType == DisplayType.vent ||
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
        tooltipShown = true;
      }
    } else if (widget.displayMode == 'daily' && widget.forecast != null) {
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
        tooltipShown = true;
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
        tooltipShown = true;
      }
    }

    if (!tooltipShown) {
      WeatherTooltip.removeTooltip();
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

    if (widget.displayType == DisplayType.comparatif) {
      return ComparisonChartBuilder.build(
        multiModelForecast: widget.multiModelForecast,
        multiModelHourlyWeather: widget.multiModelHourlyWeather,
        displayMode: widget.displayMode,
        containerSize: containerSize,
        minTemp: _minTemp,
        maxTemp: _maxTemp,
        labels: _labels,
        forecast: widget.forecast,
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
        'Aucune donnée disponible',
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
          child: Listener(
            onPointerSignal: (pointerSignal) {
              if (pointerSignal is PointerScrollEvent) {
                final double delta = pointerSignal.scrollDelta.dy != 0
                    ? pointerSignal.scrollDelta.dy
                    : pointerSignal.scrollDelta.dx;
                if (delta != 0) {
                  final double newOffset = _scrollController.offset + delta;
                  _scrollController.jumpTo(
                    newOffset.clamp(
                      0.0,
                      _scrollController.position.maxScrollExtent,
                    ),
                  );
                }
              }
            },
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
          ),
        );
      },
    );
  }
}
