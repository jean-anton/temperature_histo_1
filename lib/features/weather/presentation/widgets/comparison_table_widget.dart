import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aeroclim/features/weather/domain/weather_model.dart';
import 'package:aeroclim/features/weather/presentation/widgets/common/weather_icon_widget.dart';
import 'package:aeroclim/features/weather/presentation/widgets/common/gust_arrow_widget.dart';
import 'package:aeroclim/features/weather/presentation/widgets/utils/chart_data_provider.dart';

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
  static const List<String> _modelKeys = [
    'best_match',
    'ecmwf_ifs',
    'gfs_seamless',
    'meteofrance_seamless',
  ];

  static const Map<String, String> _modelNames = {
    'best_match': 'Best Match',
    'ecmwf_ifs': 'ECMWF IFS HRES',
    'gfs_seamless': 'GFS',
    'meteofrance_seamless': 'ARPEGE',
  };

  static const double _rowHeight = 90.0;
  static const double _sepHeight = 35.0;

  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<_TableRowInfo?> _headerNotifier = ValueNotifier(null);
  final GlobalKey _nowKey = GlobalKey();

  List<dynamic> _flatItems = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _resetScroll();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _headerNotifier.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _flatItems.isEmpty) return;

    final offset = _scrollController.offset;
    double accumulated = 0;
    _TableRowInfo? topInfo;

    for (var item in _flatItems) {
      double h = (item is DateTime) ? _sepHeight : _rowHeight;
      if (accumulated + h > offset) {
        if (item is! DateTime) {
          topInfo = item.info;
        } else {
          // If top is exactly a separator, we might want its info too
          topInfo = _TableRowInfo(
            title: DateFormat('EEEE d MMMM', 'fr_FR').format(item),
            date: item,
          );
        }
        break;
      }
      accumulated += h;
    }

    if (topInfo != null && _headerNotifier.value != topInfo) {
      _headerNotifier.value = topInfo;
    }
  }

  @override
  void didUpdateWidget(covariant ComparisonTableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.displayMode != oldWidget.displayMode) {
      _resetScroll();
    }
  }

  void _resetScroll() {
    _headerNotifier.value = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients || _flatItems.isEmpty) return;

      double targetOffset = 0;
      bool found = false;

      for (final item in _flatItems) {
        if (item is DateTime) {
          // Check if this separator matches today (for daily mode with no isCurrent)
          targetOffset += _sepHeight;
        } else if (item is _DailyRowData) {
          if (item.isCurrent) {
            found = true;
            break;
          }
          targetOffset += _rowHeight;
        } else if (item is _PeriodRowData) {
          if (item.isCurrent) {
            found = true;
            break;
          }
          targetOffset += _rowHeight;
        } else if (item is _HourlyRowData) {
          if (item.isCurrent) {
            found = true;
            break;
          }
          targetOffset += _rowHeight;
        }
      }

      if (found) {
        // Clamp to valid range and offset a bit so the current row
        // isn't right at the very top
        final maxScroll = _scrollController.position.maxScrollExtent;
        final adjusted = (targetOffset - _rowHeight).clamp(0.0, maxScroll);
        _scrollController.animateTo(
          adjusted,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
      _onScroll();
    });
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

  Widget _buildDailyTable() {
    if (widget.multiModelForecast == null) return _noData();
    final refModel = widget.multiModelForecast!.models['best_match'];
    if (refModel == null || refModel.dailyForecasts.isEmpty) return _noData();

    final now = DateTime.now();
    _flatItems = [];
    for (final daily in refModel.dailyForecasts) {
      final dateText = DateFormat('EEEE d MMMM', 'fr_FR').format(daily.date);
      final isCurrent =
          daily.date.year == now.year &&
          daily.date.month == now.month &&
          daily.date.day == now.day;
      final rowData = _DailyRowData(
        date: daily.date,
        cells: {},
        isCurrent: isCurrent,
        info: _TableRowInfo(title: dateText, date: daily.date),
      );
      for (final modelKey in _modelKeys) {
        final modelData = widget.multiModelForecast!.models[modelKey];
        if (modelData != null) {
          final matchingDay = modelData.dailyForecasts.where(
            (d) =>
                d.date.year == daily.date.year &&
                d.date.month == daily.date.month &&
                d.date.day == daily.date.day,
          );
          if (matchingDay.isNotEmpty)
            rowData.cells[modelKey] = matchingDay.first;
        }
      }
      _flatItems.add(rowData);
    }
    return _buildScrollableTable();
  }

  Widget _buildPeriodesTable() {
    if (widget.multiModelHourlyForecast == null) return _noData();
    final Map<String, List<PeriodForecast>> modelPeriods = {};
    for (final modelKey in _modelKeys) {
      final hourly = widget.multiModelHourlyForecast!.models[modelKey];
      if (hourly != null)
        modelPeriods[modelKey] = ChartDataProvider.getPeriodForecasts(hourly);
    }
    final refPeriods = modelPeriods['best_match'];
    if (refPeriods == null || refPeriods.isEmpty) return _noData();

    final now = DateTime.now();
    final currentSlotHour = (now.hour ~/ 6) * 6;
    final targetTime = DateTime(now.year, now.month, now.day, currentSlotHour);

    _flatItems = [];
    for (int i = 0; i < refPeriods.length; i++) {
      final period = refPeriods[i];
      final dateText = DateFormat('EEEE d MMMM', 'fr_FR').format(period.time);
      if (i == 0 || period.time.day != refPeriods[i - 1].time.day) {
        _flatItems.add(period.time);
      }
      final rowData = _PeriodRowData(
        time: period.time,
        periodName: period.name,
        cells: {},
        isCurrent: period.time.isAtSameMomentAs(targetTime),
        info: _TableRowInfo(
          title: '$dateText (${period.name})',
          date: period.time,
        ),
      );
      for (final modelKey in _modelKeys) {
        final periods = modelPeriods[modelKey];
        if (periods != null && i < periods.length)
          rowData.cells[modelKey] = periods[i];
      }
      _flatItems.add(rowData);
    }
    return _buildScrollableTable();
  }

  Widget _buildHourlyTable() {
    if (widget.multiModelHourlyForecast == null) return _noData();
    final refHourly = widget.multiModelHourlyForecast!.models['best_match'];
    if (refHourly == null || refHourly.hourlyForecasts.isEmpty)
      return _noData();

    final now = DateTime.now();
    _flatItems = [];
    for (int i = 0; i < refHourly.hourlyForecasts.length; i++) {
      final hourly = refHourly.hourlyForecasts[i];
      final dateText = DateFormat('EEEE d MMMM', 'fr_FR').format(hourly.time);
      if (i == 0 ||
          hourly.time.day != refHourly.hourlyForecasts[i - 1].time.day) {
        _flatItems.add(hourly.time);
      }
      final isCurrent =
          hourly.time.day == now.day && hourly.time.hour == now.hour;
      final rowData = _HourlyRowData(
        time: hourly.time,
        cells: {},
        isCurrent: isCurrent,
        info: _TableRowInfo(
          title: '$dateText (${DateFormat('HH:mm').format(hourly.time)})',
          date: hourly.time,
        ),
      );
      for (final modelKey in _modelKeys) {
        final data = widget.multiModelHourlyForecast!.models[modelKey];
        if (data != null && i < data.hourlyForecasts.length)
          rowData.cells[modelKey] = data.hourlyForecasts[i];
      }
      _flatItems.add(rowData);
    }
    return _buildScrollableTable();
  }

  Widget _buildScrollableTable() {
    final screenWidth = MediaQuery.of(context).size.width;
    final double labelWidth = screenWidth < 500 ? 65.0 : 80.0;
    final double columnWidth = screenWidth < 500 ? 90.0 : 100.0;
    final double totalWidth = labelWidth + (_modelKeys.length * columnWidth);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: totalWidth,
        child: Column(
          children: [
            _buildModelHeaderRow(),
            ValueListenableBuilder<_TableRowInfo?>(
              valueListenable: _headerNotifier,
              builder: (context, info, _) {
                return _buildDateHeader(
                  info?.title ?? '',
                  info?.date ?? DateTime.now(),
                  isSticky: true,
                );
              },
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _flatItems.length,
                itemBuilder: (context, index) {
                  final item = _flatItems[index];
                  if (item is DateTime) {
                    return _buildDateHeader(
                      DateFormat('EEEE d MMMM', 'fr_FR').format(item),
                      item,
                      isSticky: false,
                    );
                  } else if (item is _DailyRowData) {
                    return _buildDailyRow(item);
                  } else if (item is _PeriodRowData) {
                    return _buildPeriodRow(item, index: index);
                  } else if (item is _HourlyRowData) {
                    return _buildHourlyRow(item, index: index);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelHeaderRow() {
    final screenWidth = MediaQuery.of(context).size.width;
    final labelWidth = screenWidth < 500 ? 65.0 : 80.0;
    final columnWidth = screenWidth < 500 ? 90.0 : 100.0;

    String leftLabel = widget.displayMode == 'hourly'
        ? 'HEURE'
        : (widget.displayMode == 'periodes' ? 'PÉRIODE' : '');

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF303F9F)],
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: labelWidth,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.white30, width: 1.5),
                ),
              ),
              child: Text(
                leftLabel,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
            ..._modelKeys.map(
              (k) => Container(
                width: columnWidth,
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.white24)),
                ),
                child: Text(
                  _modelNames[k]!.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader(
    String title,
    DateTime date, {
    required bool isSticky,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double labelWidth = screenWidth < 500 ? 65.0 : 80.0;
    final isWeekend =
        date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

    return Container(
      height: _sepHeight,
      decoration: BoxDecoration(
        color: isWeekend ? const Color(0xFFE3F2FD) : Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: labelWidth,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey[400]!, width: 1.5),
              ),
            ),
            child: isSticky
                ? Text(
                    widget.displayMode == 'hourly'
                        ? 'HEURE'
                        : (widget.displayMode == 'periodes' ? 'PÉRIODE' : ''),
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[400],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: Center(
              child: Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: isWeekend ? Colors.blue[900] : Colors.blueGrey[800],
                ),
              ),
            ),
          ),
          SizedBox(width: labelWidth),
        ],
      ),
    );
  }

  Widget _buildDailyRow(_DailyRowData data) {
    final dayLabel = DateFormat('E d', 'fr_FR').format(data.date);
    return Container(
      key: data.isCurrent ? _nowKey : null,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[400]!, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          _buildTimeLabel(dayLabel),
          ..._modelKeys.map(
            (k) => data.cells[k] == null
                ? _buildEmptyCell()
                : _buildDailyCell(data.cells[k]!),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyCell(DailyForecast d) {
    return _buildCellContainer(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WeatherIconWidget(
              code: d.weatherCodeDaytime ?? d.weatherCode,
              isDay: 1,
              size: 32,
            ),
            if (d.windGustsMax != null &&
                d.windDirection10mDominant != null) ...[
              const SizedBox(width: 8),
              Opacity(
                opacity: 0.9,
                child: GustArrowWidget(
                  windSpeed: d.windGustsMax,
                  windDirection: d.windDirection10mDominant,
                  scaleFactor: 1.3,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Container(
          // padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          // decoration: BoxDecoration(
          //   color: Colors.white.withValues(alpha: 0.5),
          //   borderRadius: BorderRadius.circular(4),
          // ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${d.temperatureMax.round()}°',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFFD32F2F),
                ),
              ),
              const Text(
                ' / ',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              Text(
                '${d.temperatureMin.round()}°',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF1976D2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodRow(_PeriodRowData data, {int index = 0}) {
    final isNight = data.periodName == 'Nuit' || data.periodName == 'Soir';
    final color = isNight
        ? const Color(0xFFE2E6EA)
        : (index.isEven ? Colors.white : const Color(0xFFFAFAFA));
    return Container(
      key: data.isCurrent ? _nowKey : null,
      color: color,
      child: Row(
        children: [
          _buildTimeLabel(data.periodName, backgroundColor: color),
          ..._modelKeys.map(
            (k) => data.cells[k] == null
                ? _buildEmptyCell(backgroundColor: color)
                : _buildPeriodCell(data.cells[k]!),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodCell(PeriodForecast p) {
    return _buildCellContainer(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WeatherIconWidget(code: p.weatherCode, isDay: p.isDay, size: 32),
            if (p.maxWindGusts > 0 && p.windDirection != null) ...[
              const SizedBox(width: 8),
              Opacity(
                opacity: 0.8,
                child: GustArrowWidget(
                  windSpeed: p.maxWindGusts,
                  windDirection: p.windDirection,
                  scaleFactor: 1.1,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Container(
          // padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          // decoration: BoxDecoration(
          //   color: Colors.white,
          //   borderRadius: BorderRadius.circular(6),
          //   border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          //   boxShadow: [
          //     BoxShadow(
          //       color: Colors.black.withValues(alpha: 0.03),
          //       blurRadius: 2,
          //       offset: const Offset(0, 1),
          //     ),
          //   ],
          // ),

          // child: Column(
          //   children: [
          //     Text(
          //       '${p.avgTemperature.round()}°',
          //       style: const TextStyle(
          //         fontWeight: FontWeight.bold,
          //         fontSize: 14,
          //         color: Color(0xFF263238),
          //       ),
          //     ),
          //     if (p.apparentTemperature != null)
          //       Text(
          //         '${p.apparentTemperature!.round()}°',
          //         style: TextStyle(
          //           fontSize: 13,
          //           color: Colors.grey[600],
          //           height: 1.2,
          //         ),
          //       ),
          //   ],
          // ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${p.avgTemperature.round()}°',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF263238),
                ),
              ),
              if (p.apparentTemperature != null) ...[
                const SizedBox(width: 8),
                Text(
                  '${p.apparentTemperature!.round()}°',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyRow(_HourlyRowData data, {int index = 0}) {
    final bestMatch = data.cells['best_match'];
    final isNight = bestMatch?.isDay == 0;
    final color = isNight
        ? const Color(0xFFE2E6EA)
        : (index.isEven ? Colors.white : const Color(0xFFFAFAFA));
    return Container(
      key: data.isCurrent ? _nowKey : null,
      color: color,
      child: Row(
        children: [
          _buildTimeLabel(
            DateFormat('HH:mm').format(data.time),
            backgroundColor: color,
          ),
          ..._modelKeys.map(
            (k) => data.cells[k] == null
                ? _buildEmptyCell(backgroundColor: color)
                : _buildHourlyCell(data.cells[k]!),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyCell(HourlyForecast h) {
    return _buildCellContainer(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WeatherIconWidget(code: h.weatherCode, isDay: h.isDay, size: 32),
            if (h.windGusts != null && h.windDirection10m != null) ...[
              const SizedBox(width: 8),
              Opacity(
                opacity: 0.8,
                child: GustArrowWidget(
                  windSpeed: h.windGusts,
                  windDirection: h.windDirection10m,
                  scaleFactor: 1.1,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Container(
          // padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          // decoration: BoxDecoration(
          //   color: Colors.white,
          //   borderRadius: BorderRadius.circular(6),
          //   border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          //   boxShadow: [
          //     BoxShadow(
          //       color: Colors.black.withValues(alpha: 0.03),
          //       blurRadius: 2,
          //       offset: const Offset(0, 1),
          //     ),
          //   ],
          // ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(h.temperature ?? 0).round()}°',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF263238),
                ),
              ),
              if (h.apparentTemperature != null) ...[
                const SizedBox(width: 8),
                Text(
                  '${h.apparentTemperature!.round()}°',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeLabel(String text, {Color? backgroundColor}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double labelWidth = screenWidth < 500 ? 65.0 : 80.0;
    return Container(
      width: labelWidth,
      height: _rowHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          right: BorderSide(color: Colors.grey[400]!, width: 1.5),
          bottom: BorderSide(color: Colors.grey[400]!, width: 1.0),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey[700],
        ),
      ),
    );
  }

  Widget _buildCellContainer({required List<Widget> children}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double columnWidth = screenWidth < 500 ? 90.0 : 100.0;
    return Container(
      width: columnWidth,
      height: _rowHeight,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey[400]!, width: 1),
          bottom: BorderSide(color: Colors.grey[400]!, width: 1.0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }

  Widget _buildEmptyCell({Color? backgroundColor}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double columnWidth = screenWidth < 500 ? 90.0 : 100.0;
    return Container(
      width: columnWidth,
      height: _rowHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          right: BorderSide(color: Colors.grey[400]!, width: 1),
          bottom: BorderSide(color: Colors.grey[400]!, width: 1.0),
        ),
      ),
      child: Text('—', style: TextStyle(color: Colors.grey[400])),
    );
  }

  Widget _noData() => const Center(child: Text('Aucune donnée disponible'));
}

class _TableRowInfo {
  final String title;
  final DateTime date;
  _TableRowInfo({required this.title, required this.date});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _TableRowInfo && title == other.title && date == other.date;
  @override
  int get hashCode => title.hashCode ^ date.hashCode;
}

class _DailyRowData {
  final DateTime date;
  final Map<String, DailyForecast> cells;
  final bool isCurrent;
  final _TableRowInfo info;
  _DailyRowData({
    required this.date,
    required this.cells,
    this.isCurrent = false,
    required this.info,
  });
}

class _PeriodRowData {
  final DateTime time;
  final String periodName;
  final Map<String, PeriodForecast> cells;
  final bool isCurrent;
  final _TableRowInfo info;
  _PeriodRowData({
    required this.time,
    required this.periodName,
    required this.cells,
    this.isCurrent = false,
    required this.info,
  });
}

class _HourlyRowData {
  final DateTime time;
  final Map<String, HourlyForecast> cells;
  final bool isCurrent;
  final _TableRowInfo info;
  _HourlyRowData({
    required this.time,
    required this.cells,
    this.isCurrent = false,
    required this.info,
  });
}
