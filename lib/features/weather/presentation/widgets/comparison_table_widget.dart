import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aeroclim/l10n/app_localizations.dart';
import 'package:aeroclim/features/weather/presentation/widgets/utils/chart_helpers.dart';
import '../../domain/weather_model.dart';
import 'package:aeroclim/features/weather/presentation/widgets/common/gust_arrow_widget.dart';
import 'package:aeroclim/features/weather/presentation/widgets/utils/chart_data_provider.dart';
import 'package:aeroclim/features/weather/presentation/widgets/utils/weather_tooltip.dart';
import 'package:aeroclim/features/weather/presentation/widgets/common/weather_icon_widget.dart';

class ComparisonTableWidget extends StatefulWidget {
  final MultiModelWeather? multiModelForecast;
  final MultiModelHourlyWeather? multiModelHourlyForecast;
  final String displayMode;
  final bool showExtendedWindInfo;

  const ComparisonTableWidget({
    super.key,
    this.multiModelForecast,
    this.multiModelHourlyForecast,
    required this.displayMode,
    this.showExtendedWindInfo = false,
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

  static Map<String, String> _getModelNames(BuildContext context) => {
    'best_match': AppLocalizations.of(context)!.bestMatch,
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
          final locale = Localizations.localeOf(context).toString();
          final formattedDate = ChartHelpers.formatLocalizedDate(item, locale);
          topInfo = _TableRowInfo(
            title: formattedDate[0].toUpperCase() + formattedDate.substring(1),
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
      final String locale = AppLocalizations.of(context)!.localeName;
      final dateText = ChartHelpers.formatLocalizedDate(daily.date, locale);
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
      final String locale = AppLocalizations.of(context)!.localeName;
      final dateText = ChartHelpers.formatLocalizedDate(period.time, locale);
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
      final String locale = AppLocalizations.of(context)!.localeName;
      final dateText = ChartHelpers.formatLocalizedDate(hourly.time, locale);
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
                    final locale = AppLocalizations.of(context)!.localeName;
                    final formattedDate = ChartHelpers.formatLocalizedDate(
                      item,
                      locale,
                    );
                    return _buildDateHeader(
                      formattedDate[0].toUpperCase() +
                          formattedDate.substring(1),
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

    final l10n = AppLocalizations.of(context)!;
    String leftLabel = widget.displayMode == 'hourly'
        ? l10n.hour
        : (widget.displayMode == 'periodes' ? l10n.period : '');

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
                  _getModelNames(context)[k]!.toUpperCase(),
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
                        ? AppLocalizations.of(context)!.hour
                        : (widget.displayMode == 'periodes'
                              ? AppLocalizations.of(context)!.period
                              : ''),
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
    final dayLabel = DateFormat(
      'E d',
      AppLocalizations.of(context)!.localeName,
    ).format(data.date);
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
                : _buildDailyCell(data.cells[k]!, modelKey: k),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyCell(DailyForecast d, {String? modelKey}) {
    return GestureDetector(
      onTapDown: (details) {
        WeatherTooltip.showDailyForecastTooltip(
          context,
          d,
          details.globalPosition,
          modelName: modelKey != null
              ? _getModelNames(context)[modelKey]
              : null,
          showExtendedWindInfo: widget.showExtendedWindInfo,
        );
      },
      child: _buildCellContainer(
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
                const SizedBox(width: 2),
                Opacity(
                  opacity: 0.9,
                  child: GustArrowWidget(
                    windSpeed: d.windGustsMax,
                    windDirection: d.windDirection10mDominant,
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
      ),
    );
  }

  Widget _buildPeriodRow(_PeriodRowData data, {int index = 0}) {
    final isNight =
        data.periodName.toLowerCase() == 'night' ||
        data.periodName.toLowerCase() == 'evening' ||
        data.periodName == 'Nuit' ||
        data.periodName == 'Soir';
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
                : _buildPeriodCell(data.cells[k]!, modelKey: k),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodCell(PeriodForecast p, {String? modelKey}) {
    return GestureDetector(
      onTapDown: (details) {
        WeatherTooltip.showPeriodForecastTooltip(
          context,
          p,
          details.globalPosition,
          modelName: modelKey != null
              ? _getModelNames(context)[modelKey]
              : null,
          showExtendedWindInfo: widget.showExtendedWindInfo,
        );
      },
      child: _buildCellContainer(
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
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Container(
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
      ),
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
                : _buildHourlyCell(data.cells[k]!, modelKey: k),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyCell(HourlyForecast h, {String? modelKey}) {
    return GestureDetector(
      onTapDown: (details) {
        WeatherTooltip.showHourlyForecastTooltip(
          context,
          h,
          details.globalPosition,
          modelName: modelKey != null
              ? _getModelNames(context)[modelKey]
              : null,
          showExtendedWindInfo: widget.showExtendedWindInfo,
        );
      },
      child: _buildCellContainer(
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
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Container(
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
      ),
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
        _translate(context, text),
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

    // 1. Flatten the list: if the first item is a Row, extract its children.
    // This turns [Row(A, B), Container, Widget] into [A, B, Container, Widget].
    List<Widget> flattenedChildren = [];
    if (children.isNotEmpty) {
      if (children[0] is Row) {
        flattenedChildren.addAll((children[0] as Row).children);
        flattenedChildren.addAll(children.skip(1));
      } else {
        flattenedChildren = children;
      }
    }

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
      child: Stack(
        clipBehavior: Clip.none,
        children: flattenedChildren.asMap().entries.map((entry) {
          int index = entry.key;
          Widget child = entry.value;
          //print('### CJG : index: $index');
          double top = 0;
          double left = 0;

          // 2. Map coordinates based on the new flattened indices
          if (index == 0) { // weather icon
            // First item of the original Row
            top = 0;
            left = 5;
          } else if (index == 1) { // container
            // Second item of the original Row
            top = -30; // Per your specific requirement
            left = 50;
          } else if (index == 2) { // wind speed
            // The original Container() that was at index 1
            top = -10;
            left = 40;
          } else if (index == 3) { // container
            // The original Container() that was at index 1
            top = 50;
            left = 0;
          } else if (index == 4) { // temperature
            // The original Container() that was at index 1
            top = 50;
            left = 10;
          }

          return Positioned(top: top, left: left, child: index == 3 || index == 1 ? Container(color: Colors.red, width: 0, height: 0) : child);
        }).toList(),
      ),
    );
  }

  // Widget _buildCellContainer({required List<Widget> children}) {
  //   final screenWidth = MediaQuery.of(context).size.width;
  //   final double columnWidth = screenWidth < 500 ? 90.0 : 100.0;
  //   return Container(
  //     width: columnWidth,
  //     height: _rowHeight,
  //     padding: const EdgeInsets.symmetric(vertical: 8),
  //     decoration: BoxDecoration(
  //       border: Border(
  //         right: BorderSide(color: Colors.grey[400]!, width: 1),
  //         bottom: BorderSide(color: Colors.grey[400]!, width: 1.0),
  //       ),
  //     ),
  //     //CJG  child: Column(
  //     child: Stack(
  //       clipBehavior: Clip.none,
  //       children: children.asMap().entries.map((entry) {
  //         int index = entry.key;
  //         print('### CJG : index: $index');

  //         // Position 1: top -10, left 0
  //         // Position 2: top -10, left 50
  //         // Position 3: top 50, left 0
  //         double top = 0;
  //         double left = 0;

  //         if (index == 0) {
  //           top = -10;
  //           left = 0;
  //         }
  //         if (index == 1) {
  //           top = -30;
  //           left = 50;
  //         }
  //         if (index == 2) {
  //           top = 50;
  //           left = 0;
  //         }

  //         return Positioned(top: top, left: left, child: index == 1 ? entry.value : Container());
  //       }).toList(),
  //     ),
  //   );
  // }

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

  Widget _noData() => Center(child: Text(AppLocalizations.of(context)!.noData));

  String _translate(BuildContext context, String text) {
    final l10n = AppLocalizations.of(context)!;
    final lower = text.toLowerCase();
    if (lower == 'nuit' ||
        lower == 'night' ||
        lower == 'nacht' ||
        lower == 'noche')
      return l10n.night;
    if (lower == 'matin' ||
        lower == 'morning' ||
        lower == 'morgen' ||
        lower == 'mañana' ||
        lower == 'manana')
      return l10n.morning;
    if (lower == 'a-m' ||
        lower == 'afternoon' ||
        lower == 'nachmittag' ||
        lower == 'tarde')
      return l10n.afternoon;
    if (lower == 'soir' || lower == 'evening' || lower == 'abend')
      return l10n.evening;
    return text;
  }
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
