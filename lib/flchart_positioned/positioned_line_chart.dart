import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'chart_config.dart';
import 'chart_positioner.dart';

/// Callback type for building positioned layers on top of the chart
typedef LayerBuilder =
    Widget Function(BuildContext context, ChartPositioner positioner);

/// A wrapper for LineChart that makes it easy to add Positioned layers
/// which are perfectly synchronized with the chart's data space.
///
/// Example usage:
/// ```dart
/// PositionedLineChart(
///   config: ChartConfig.temperature(),
///   data: LineChartData(...),
///   layers: [
///     (context, positioner) {
///       return Stack(
///         children: spots.map((spot) {
///           final pos = positioner.calculate(spot.x, spot.y);
///           return Positioned(
///             left: pos.dx - 20,
///             top: pos.dy - 30,
///             child: Text('${spot.y}°'),
///           );
///         }).toList(),
///       );
///     },
///   ],
/// );
/// ```
class PositionedLineChart extends StatelessWidget {
  final LineChartData data;
  final ChartConfig config;
  final List<LayerBuilder> layers;

  const PositionedLineChart({
    super.key,
    required this.data,
    required this.config,
    this.layers = const [],
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Size containerSize = Size(
          constraints.maxWidth,
          constraints.maxHeight,
        );

        final positioner = ChartPositioner(
          config: config,
          containerSize: containerSize,
          minX: data.minX,
          maxX: data.maxX,
          minY: data.minY,
          maxY: data.maxY,
        );

        return Stack(
          children: [
            LineChart(data),
            ...layers.map((builder) => builder(context, positioner)),
          ],
        );
      },
    );
  }
}
