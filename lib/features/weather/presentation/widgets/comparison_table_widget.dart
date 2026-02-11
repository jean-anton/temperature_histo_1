import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aeroclim/features/weather/domain/weather_model.dart';
import 'package:aeroclim/features/weather/presentation/widgets/common/weather_icon_widget.dart';
import 'package:aeroclim/features/weather/presentation/widgets/common/gust_arrow_widget.dart';
import 'package:aeroclim/features/weather/presentation/widgets/utils/chart_data_provider.dart';

/// Comparison table widget that shows weather data across multiple models.
///
/// Columns represent weather models (Best Match, ECMWF, GFS, ARPEGE).
/// Rows represent time units (day, period, hour) depending on display mode.
/// Each cell shows: weather icon, temperature + apparent/felt temperature, wind icon.
class ComparisonTableWidget extends StatefulWidget {
  final MultiModelWeather? multiModelForecast;
  final MultiModelHourlyWeather? multiModelHourlyForecast;
  final String displayMode;

  const ComparisonTableWidget({
    super.key,
    this.multiModelForecast,
    this.multiModelHourlyForecast,
    required this.displayMode,
  });

  @override
  State<ComparisonTableWidget> createState() => _ComparisonTableWidgetState();
}

class _ComparisonTableWidgetState extends State<ComparisonTableWidget> {
  /// Model keys in display order
  static const List<String> _modelKeys = [
    'best_match',
    'ecmwf_ifs',
    'gfs_seamless',
    'meteofrance_seamless',
  ];

  /// Human-readable model names
  static const Map<String, String> _modelNames = {
    'best_match': 'Best Match',
    'ecmwf_ifs': 'ECMWF IFS HRES',
    'gfs_seamless': 'GFS',
    'meteofrance_seamless': 'ARPEGE',
  };

  final GlobalKey _nowKey = GlobalKey();
  bool _scrolledToNow = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_nowKey.currentContext != null && !_scrolledToNow) {
        Scrollable.ensureVisible(
          _nowKey.currentContext!,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          alignment:
              0.3, // Defines target position in viewport (0.3 = near top)
        );
        _scrolledToNow = true;
      }
    });
  }

  @override
  void didUpdateWidget(covariant ComparisonTableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.displayMode != oldWidget.displayMode) {
      _scrolledToNow = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_nowKey.currentContext != null) {
          Scrollable.ensureVisible(
            _nowKey.currentContext!,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            alignment: 0.3,
          );
          _scrolledToNow = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.displayMode == 'daily') {
      return _buildDailyTable();
    } else if (widget.displayMode == 'periodes') {
      return _buildPeriodesTable();
    } else {
      return _buildHourlyTable();
    }
  }

  // ─────────────────────────────────────────────
  // DAILY MODE
  // ─────────────────────────────────────────────

  Widget _buildDailyTable() {
    if (widget.multiModelForecast == null) {
      return const Center(child: Text('Aucune donnée de comparaison'));
    }

    // Use best_match as reference for dates
    final refModel = widget.multiModelForecast!.models['best_match'];
    if (refModel == null || refModel.dailyForecasts.isEmpty) {
      return const Center(child: Text('Aucune donnée disponible'));
    }

    final List<_TableSection> sections = [];
    for (final daily in refModel.dailyForecasts) {
      final dateText = DateFormat('EEEE d MMMM', 'fr_FR').format(daily.date);

      final rowData = _DailyRowData(date: daily.date, cells: {});
      for (final modelKey in _modelKeys) {
        final modelData = widget.multiModelForecast!.models[modelKey];
        if (modelData != null) {
          final matchingDay = modelData.dailyForecasts.where(
            (d) =>
                d.date.year == daily.date.year &&
                d.date.month == daily.date.month &&
                d.date.day == daily.date.day,
          );
          if (matchingDay.isNotEmpty) {
            rowData.cells[modelKey] = matchingDay.first;
          }
        }
      }

      sections.add(
        _TableSection(
          title: dateText,
          date: daily.date,
          rows: [_buildDailyRow(rowData)],
        ),
      );
    }

    return _buildScrollableTable(sections: sections);
  }

  Widget _buildDailyRow(_DailyRowData rowData) {
    final isWeekend =
        rowData.date.weekday == DateTime.saturday ||
        rowData.date.weekday == DateTime.sunday;

    return Container(
      decoration: BoxDecoration(
        color: isWeekend ? Colors.blue.withValues(alpha: 0.06) : null,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Time label column - Empty in daily mode to avoid duplication with sticky date header
            _buildTimeLabel(''),
            // Model data columns
            ..._modelKeys.map((modelKey) {
              final daily = rowData.cells[modelKey];
              if (daily == null) {
                return _buildEmptyCell();
              }
              return _buildDailyCell(daily);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyCell(DailyForecast daily) {
    return _buildCellContainer(
      children: [
        // Weather Icon + Wind : On Same Line
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WeatherIconWidget(
              code: daily.weatherCodeDaytime ?? daily.weatherCode,
              isDay: 1,
              size: 32,
            ),
            if (daily.windGustsMax != null &&
                daily.windDirection10mDominant != null) ...[
              const SizedBox(width: 8),
              Opacity(
                opacity: 0.9,
                child: GustArrowWidget(
                  windSpeed: daily.windGustsMax,
                  windDirection: daily.windDirection10mDominant,
                  scaleFactor: 1.3,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${daily.temperatureMax.round()}°',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFFD32F2F), // Material Red 700
                ),
              ),
              const Text(
                ' / ',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              Text(
                '${daily.temperatureMin.round()}°',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF1976D2), // Material Blue 700
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // PERIODES (APERÇU) MODE
  // ─────────────────────────────────────────────

  Widget _buildPeriodesTable() {
    if (widget.multiModelHourlyForecast == null) {
      return const Center(child: Text('Aucune donnée de comparaison'));
    }

    // Get period forecasts for each model
    final Map<String, List<PeriodForecast>> modelPeriods = {};
    for (final modelKey in _modelKeys) {
      final hourlyData = widget.multiModelHourlyForecast!.models[modelKey];
      if (hourlyData != null) {
        modelPeriods[modelKey] = ChartDataProvider.getPeriodForecasts(
          hourlyData,
        );
      }
    }

    // Use best_match as reference for period structure
    final refPeriods = modelPeriods['best_match'];
    if (refPeriods == null || refPeriods.isEmpty) {
      return const Center(child: Text('Aucune donnée disponible'));
    }

    // Determine current period slot for scrolling
    final now = DateTime.now();
    // Period starts: 0, 6, 12, 18
    final currentSlotHour = (now.hour ~/ 6) * 6;
    final targetPeriodTime = DateTime(
      now.year,
      now.month,
      now.day,
      currentSlotHour,
    );

    // Group periods by date
    final Map<String, List<_PeriodRowData>> groupedByDate = {};
    for (int i = 0; i < refPeriods.length; i++) {
      final period = refPeriods[i];
      final dateKey = DateFormat('EEEE d MMMM', 'fr_FR').format(period.time);

      groupedByDate.putIfAbsent(dateKey, () => []);

      final rowData = _PeriodRowData(
        time: period.time,
        periodName: period.name,
        cells: {},
        isCurrent: period.time.isAtSameMomentAs(targetPeriodTime),
      );

      for (final modelKey in _modelKeys) {
        final periods = modelPeriods[modelKey];
        if (periods != null && i < periods.length) {
          rowData.cells[modelKey] = periods[i];
        }
      }
      groupedByDate[dateKey]!.add(rowData);
    }

    return _buildScrollableTable(
      sections: groupedByDate.entries.map((entry) {
        return _TableSection(
          title: entry.key,
          date: entry.value.first.time,
          rows: entry.value.asMap().entries.map((e) {
            return _buildPeriodRow(e.value, index: e.key);
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildPeriodRow(_PeriodRowData rowData, {int index = 0}) {
    final isWeekend =
        rowData.time.weekday == DateTime.saturday ||
        rowData.time.weekday == DateTime.sunday;

    // Check if it is a night period
    final isNight =
        rowData.periodName == 'Nuit' || rowData.periodName == 'Soir';

    Color backgroundColor;

    if (isNight) {
      // Dark color for night
      backgroundColor = const Color(0xFFE2E6EA); // BlueGrey 100-ish
    } else if (isWeekend) {
      backgroundColor = const Color(0xFFF5F9FF);
    } else {
      backgroundColor = index.isEven ? Colors.white : const Color(0xFFFAFAFA);
    }

    return Container(
      key: rowData.isCurrent ? _nowKey : null,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _buildTimeLabel(
              rowData.periodName,
              backgroundColor: backgroundColor,
            ),
            ..._modelKeys.map((modelKey) {
              final period = rowData.cells[modelKey];
              if (period == null) {
                return _buildEmptyCell(backgroundColor: backgroundColor);
              }
              return _buildPeriodCell(period);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodCell(PeriodForecast period) {
    return _buildCellContainer(
      children: [
        // Weather Icon + Wind : On Same Line
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WeatherIconWidget(
              code: period.weatherCode,
              isDay: period.isDay,
              size: 32,
            ),
            if (period.maxWindGusts > 0 && period.windDirection != null) ...[
              const SizedBox(width: 8),
              Opacity(
                opacity: 0.8,
                child: GustArrowWidget(
                  windSpeed: period.maxWindGusts,
                  windDirection: period.windDirection,
                  scaleFactor: 1.1,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                '${period.avgTemperature.round()}°',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF263238),
                ),
              ),
              if (period.apparentTemperature != null)
                Text(
                  '   ${period.apparentTemperature!.round()}°',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.2,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // HOURLY MODE
  // ─────────────────────────────────────────────

  Widget _buildHourlyTable() {
    if (widget.multiModelHourlyForecast == null) {
      return const Center(child: Text('Aucune donnée de comparaison'));
    }

    // Use best_match as reference for hours
    final refHourly = widget.multiModelHourlyForecast!.models['best_match'];
    if (refHourly == null || refHourly.hourlyForecasts.isEmpty) {
      return const Center(child: Text('Aucune donnée disponible'));
    }

    final now = DateTime.now();

    // Group by date
    final Map<String, List<_HourlyRowData>> groupedByDate = {};
    for (int i = 0; i < refHourly.hourlyForecasts.length; i++) {
      final hourly = refHourly.hourlyForecasts[i];
      final dateKey = DateFormat('EEEE d MMMM', 'fr_FR').format(hourly.time);

      groupedByDate.putIfAbsent(dateKey, () => []);

      // Check isCurrent
      final isCurrent =
          hourly.time.day == now.day && hourly.time.hour == now.hour;

      final rowData = _HourlyRowData(
        time: hourly.time,
        cells: {},
        isCurrent: isCurrent,
      );
      for (final modelKey in _modelKeys) {
        final hourlyData = widget.multiModelHourlyForecast!.models[modelKey];
        if (hourlyData != null && i < hourlyData.hourlyForecasts.length) {
          rowData.cells[modelKey] = hourlyData.hourlyForecasts[i];
        }
      }
      groupedByDate[dateKey]!.add(rowData);
    }

    return _buildScrollableTable(
      sections: groupedByDate.entries.map((entry) {
        return _TableSection(
          title: entry.key,
          date: entry.value.first.time,
          rows: entry.value.asMap().entries.map((e) {
            return _buildHourlyRow(e.value, index: e.key);
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildHourlyRow(_HourlyRowData rowData, {int index = 0}) {
    final isWeekend =
        rowData.time.weekday == DateTime.saturday ||
        rowData.time.weekday == DateTime.sunday;

    // Check for night hours (approximate logic if isDay not available on row,
    // but we can check the first available cell)
    // Actually we can check rowData.time.hour.
    // Assuming night is roughly 22h-06h?
    // Or we use isDay from best_match if available
    bool isNight = false;
    final bestMatch = rowData.cells['best_match'];
    if (bestMatch != null) {
      isNight = bestMatch.isDay == 0;
    } else {
      // Fallback
      isNight = rowData.time.hour < 6 || rowData.time.hour > 21;
    }

    Color backgroundColor;
    if (isNight) {
      backgroundColor = const Color(0xFFE2E6EA); // BlueGrey 100-ish
    } else if (isWeekend) {
      backgroundColor = const Color(0xFFF5F9FF);
    } else {
      backgroundColor = index.isEven ? Colors.white : const Color(0xFFFAFAFA);
    }

    return Container(
      key: rowData.isCurrent ? _nowKey : null,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _buildTimeLabel(
              DateFormat('HH:mm').format(rowData.time),
              backgroundColor: backgroundColor,
            ),
            ..._modelKeys.map((modelKey) {
              final hourly = rowData.cells[modelKey];
              if (hourly == null) {
                return _buildEmptyCell(backgroundColor: backgroundColor);
              }
              return _buildHourlyCell(hourly);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyCell(HourlyForecast hourly) {
    return _buildCellContainer(
      children: [
        // Weather Icon + Wind : On Same Line
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WeatherIconWidget(
              code: hourly.weatherCode,
              isDay: hourly.isDay,
              size: 32,
            ),
            if (hourly.windGusts != null &&
                hourly.windDirection10m != null) ...[
              const SizedBox(width: 8),
              Opacity(
                opacity: 0.8,
                child: GustArrowWidget(
                  windSpeed: hourly.windGusts,
                  windDirection: hourly.windDirection10m,
                  scaleFactor: 1.1,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                '${(hourly.temperature ?? 0).round()}°',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF263238),
                ),
              ),
              if (hourly.apparentTemperature != null)
                Text(
                  '   ${hourly.apparentTemperature!.round()}°',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.2,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // SHARED UI COMPONENTS
  // ─────────────────────────────────────────────

  Widget _buildScrollableTable({required List<_TableSection> sections}) {
    final double labelWidth = 80.0;
    final double columnWidth = 100.0;
    final double totalWidth = labelWidth + (_modelKeys.length * columnWidth);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: totalWidth,
        child: Column(
          children: [
            // Sticky Model Header (fixed top, scrolls horizontally)
            _buildModelHeaderRow(),
            Expanded(
              child: CustomScrollView(
                slivers: sections.map((section) {
                  return SliverMainAxisGroup(
                    slivers: [
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _StickyHeaderDelegate(
                          height: 35,
                          child: _buildDateHeader(section.title, section.date),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => section.rows[index],
                          childCount: section.rows.length,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelHeaderRow() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF303F9F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Empty corner for time label column
            Container(
              width: 80,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: Colors.white24)),
              ),
              child: const Text('', style: TextStyle(color: Colors.white)),
            ),
            ..._modelKeys.map((modelKey) {
              return Container(
                width: 100,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 4,
                ),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.white10)),
                ),
                child: Text(
                  _modelNames[modelKey]?.toUpperCase() ??
                      modelKey.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader(String dateText, DateTime date) {
    final isWeekend =
        date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

    return Container(
      width: 80.0 + (_modelKeys.length * 100.0),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      decoration: BoxDecoration(
        color: isWeekend ? const Color(0xFFE3F2FD) : Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!, width: 1),
          bottom: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 35,
            color: isWeekend ? Colors.blue[700] : Colors.blueGrey[400],
          ),
          const SizedBox(width: 12),
          Text(
            dateText.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isWeekend ? Colors.blue[900] : Colors.blueGrey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeLabel(String label, {Color? backgroundColor}) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          right: BorderSide(color: Colors.blueGrey[100]!, width: 1.5),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 13,
          color: Colors.blueGrey[900],
        ),
      ),
    );
  }

  Widget _buildCellContainer({required List<Widget> children}) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget _buildEmptyCell({Color? backgroundColor}) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(right: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Text('—', style: TextStyle(color: Colors.grey[400])),
    );
  }
}

// ─────────────────────────────────────────────
// STICKY HEADER DELEGATE
// ─────────────────────────────────────────────

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _StickyHeaderDelegate({required this.child, required this.height});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return child != oldDelegate.child || height != oldDelegate.height;
  }
}

// ─────────────────────────────────────────────
// DATA HOLDER CLASSES
// ─────────────────────────────────────────────

class _TableSection {
  final String title;
  final DateTime date;
  final List<Widget> rows;
  _TableSection({required this.title, required this.date, required this.rows});
}

class _DailyRowData {
  final DateTime date;
  final Map<String, DailyForecast> cells;
  _DailyRowData({required this.date, required this.cells});
}

class _PeriodRowData {
  final DateTime time;
  final String periodName;
  final Map<String, PeriodForecast> cells;
  final bool isCurrent;
  _PeriodRowData({
    required this.time,
    required this.periodName,
    required this.cells,
    this.isCurrent = false,
  });
}

class _HourlyRowData {
  final DateTime time;
  final Map<String, HourlyForecast> cells;
  final bool isCurrent;
  _HourlyRowData({
    required this.time,
    required this.cells,
    this.isCurrent = false,
  });
}
