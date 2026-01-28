import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'chart_config.dart';
import 'positioned_line_chart.dart';

void main() {
  runApp(const PositionedChartExampleApp());
}

class PositionedChartExampleApp extends StatelessWidget {
  const PositionedChartExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(title: const Text('Positioned Chart Library Example')),
        body: const Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(
            child: SizedBox(
              height: 400,
              width: double.infinity,
              child: MyChart(),
            ),
          ),
        ),
      ),
    );
  }
}

class MyChart extends StatelessWidget {
  const MyChart({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Define our data spots
    final spots = [
      const FlSpot(0, 5),
      const FlSpot(2, 12),
      const FlSpot(4, 8),
      const FlSpot(7, 18),
      const FlSpot(10, 10),
    ];

    // 2. Define the configuration (must match whatever we put in LineChartData)
    const config = ChartConfig(
      leftReservedSize: 50.0,
      bottomReservedSize: 50.0,
      borderWidth: 2.0,
    );

    return PositionedLineChart(
      config: config,
      data: LineChartData(
        minX: 0,
        maxX: 10,
        minY: 0,
        maxY: 20,
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.white24, width: config.borderWidth),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: config.leftReservedSize,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: config.bottomReservedSize,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.cyan,
            barWidth: 4,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
      layers: [
        // Layer for temperature labels
        (context, positioner) {
          return Stack(
            children: spots.map((spot) {
              final pos = positioner.calculate(spot.x, spot.y);
              return Positioned(
                left: pos.dx - 20,
                top: pos.dy - 35,
                child: Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Text(
                    '${spot.y.toInt()}°',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.cyan,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
        // Layer for background highlights (e.g. night or weekend)
        (context, positioner) {
          final chartArea = positioner.getChartArea();
          final start = positioner.calculate(4, 0).dx;
          final end = positioner.calculate(7, 0).dx;

          return Positioned(
            left: start,
            top: chartArea.top,
            width: end - start,
            height: chartArea.height,
            child: Container(
              color: Colors.white.withValues(alpha: 0.05),
              child: const Center(
                child: Text(
                  'HIGHLIGHT',
                  style: TextStyle(fontSize: 10, color: Colors.white24),
                ),
              ),
            ),
          );
        },
        // Layer for a custom icon at a specific point
        (context, positioner) {
          final pos = positioner.calculate(7, 18);
          return Positioned(
            left: pos.dx - 15,
            top: pos.dy - 15,
            child: const Icon(Icons.wb_sunny, color: Colors.orange, size: 30),
          );
        },
      ],
    );
  }
}
