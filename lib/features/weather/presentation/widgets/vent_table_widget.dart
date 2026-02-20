import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aeroclim/features/weather/presentation/widgets/utils/chart_helpers.dart';
import '../../domain/weather_model.dart';
import 'package:aeroclim/features/weather/presentation/widgets/utils/chart_theme.dart';
import 'package:aeroclim/features/weather/presentation/widgets/common/weather_icon_widget.dart';
import 'package:aeroclim/features/weather/presentation/widgets/common/gust_arrow_widget.dart';
import 'package:aeroclim/l10n/app_localizations.dart';

class VentTableWidget extends StatelessWidget {
  final HourlyWeather hourlyWeather;
  final DailyWeather dailyWeather;
  final double maxGustSpeed;
  final int maxPrecipitationProbability;
  final double minApparentTemperature;

  const VentTableWidget({
    super.key,
    required this.hourlyWeather,
    required this.dailyWeather,
    required this.maxGustSpeed,
    required this.maxPrecipitationProbability,
    required this.minApparentTemperature,
  });

  @override
  Widget build(BuildContext context) {
    final filteredForecasts = _filterForecasts();

    if (filteredForecasts.isEmpty) {
      return _buildEmptyState(context);
    }

    final groupedByDate = _groupByDate(context, filteredForecasts);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoHeader(context),
              const SizedBox(height: 8),
              ...groupedByDate.entries.map((entry) {
                return _buildDateSection(context, entry.key, entry.value);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noMatchingHours,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${AppLocalizations.of(context)!.gusts} max: ${maxGustSpeed.toStringAsFixed(0)} ${AppLocalizations.of(context)!.kmh}\n'
              '${AppLocalizations.of(context)!.precipitation} max: $maxPrecipitationProbability%\n'
              '${AppLocalizations.of(context)!.apparent} min: ${minApparentTemperature.toStringAsFixed(0)}°C',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_alt, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Text(
            '${AppLocalizations.of(context)!.filtersLabel}: ${AppLocalizations.of(context)!.gusts} < ${maxGustSpeed.toStringAsFixed(0)} ${AppLocalizations.of(context)!.kmh} • '
            '${AppLocalizations.of(context)!.precipitation} < $maxPrecipitationProbability% • '
            '${AppLocalizations.of(context)!.apparent} > ${minApparentTemperature.toStringAsFixed(0)}°C',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blue[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(
    BuildContext context,
    String date,
    List<HourlyForecast> forecasts,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            date,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        _buildTable(context, forecasts),
      ],
    );
  }

  Widget _buildTable(BuildContext context, List<HourlyForecast> forecasts) {
    return DataTable(
      headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
      columnSpacing: 16,
      horizontalMargin: 8,
      columns: [
        DataColumn(
          label: Text(
            AppLocalizations.of(context)!.hour,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            AppLocalizations.of(context)!.gustsLabelUnit,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          numeric: true,
        ),
        DataColumn(
          label: Text(
            AppLocalizations.of(context)!.directionAbbr,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            AppLocalizations.of(context)!.weather,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            AppLocalizations.of(context)!.tempLabelUnit,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          numeric: true,
        ),
        DataColumn(
          label: Text(
            AppLocalizations.of(context)!.apparentLabelUnit,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          numeric: true,
        ),
        DataColumn(
          label: Text(
            AppLocalizations.of(context)!.precipLabelUnit,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          numeric: true,
        ),
        DataColumn(
          label: Text(
            AppLocalizations.of(context)!.cloudsLabelUnit,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          numeric: true,
        ),
        DataColumn(
          label: Text(
            AppLocalizations.of(context)!.windByAltitudeRange,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
      rows: forecasts.map((forecast) => _buildRow(context, forecast)).toList(),
    );
  }

  DataRow _buildRow(BuildContext context, HourlyForecast forecast) {
    final now = DateTime.now();
    final isCurrentHour =
        forecast.time.year == now.year &&
        forecast.time.month == now.month &&
        forecast.time.day == now.day &&
        forecast.time.hour == now.hour;

    return DataRow(
      color: isCurrentHour
          ? WidgetStateProperty.all(
              ChartTheme.currentTimeLineColor.withValues(alpha: 0.15),
            )
          : null,
      cells: [
        DataCell(
          Text(
            DateFormat('HH:mm').format(forecast.time),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ChartTheme.windGustColor(forecast.windGusts ?? 0.0),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              (forecast.windGusts ?? 0).toStringAsFixed(0),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        DataCell(
          GustArrowWidget(
            windSpeed: forecast.windGusts,
            windDirection: forecast.windDirection10m,
          ),
        ),
        DataCell(
          WeatherIconWidget(code: forecast.weatherCode, isDay: forecast.isDay),
        ),
        DataCell(
          Text(
            (forecast.temperature ?? 0).toStringAsFixed(1),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        DataCell(
          Text(
            (forecast.apparentTemperature ?? 0).toStringAsFixed(1),
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
        DataCell(
          Text(
            (forecast.precipitationProbability ?? 0).toString(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: (forecast.precipitationProbability ?? 0) > 10
                  ? Colors.blue[700]
                  : Colors.grey[700],
            ),
          ),
        ),
        DataCell(
          Text(
            (forecast.cloudCover ?? 0).toString(),
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
        DataCell(_buildContinuousWindHeatmap(context, forecast)),
      ],
    );
  }

  Widget _buildContinuousWindHeatmap(
    BuildContext context,
    HourlyForecast forecast,
  ) {
    const int numCells = 19;
    final List<Widget> cells = [];

    for (int i = 0; i < numCells; i++) {
      final altitudeStart = 10.0 + (i * 10.0);
      final altitudeEnd = altitudeStart + 10.0;
      final altitudeMid = (altitudeStart + altitudeEnd) / 2.0;

      final windSpeed = _getInterpolatedWindSpeed(forecast, altitudeMid);
      final color = windSpeed != null
          ? ChartTheme.windGustColor(windSpeed)
          : Colors.grey[300]!;

      cells.add(
        Tooltip(
          message: AppLocalizations.of(context)!.altitudeTooltip(
            altitudeMid.toInt(),
            (windSpeed?.toStringAsFixed(1) ?? 'N/A'),
            AppLocalizations.of(context)!.kmh,
          ),
          child: Container(
            width: 12,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 0.5),
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.white, width: 0.5),
            ),
          ),
        ),
      );
    }
    return Row(mainAxisSize: MainAxisSize.min, children: cells);
  }

  double? _getInterpolatedWindSpeed(HourlyForecast forecast, double altitude) {
    final Map<double, double?> altitudeData = {
      10.0: forecast.windSpeed,
      20.0: forecast.windSpeed20m,
      50.0: forecast.windSpeed50m,
      80.0: forecast.windSpeed80m,
      100.0: forecast.windSpeed100m,
      120.0: forecast.windSpeed120m,
      150.0: forecast.windSpeed150m,
      180.0: forecast.windSpeed180m,
      200.0: forecast.windSpeed200m,
    };

    double? lowerAlt, lowerSpeed, upperAlt, upperSpeed;

    for (final entry in altitudeData.entries) {
      if (entry.value != null) {
        if (entry.key <= altitude) {
          if (lowerAlt == null || entry.key > lowerAlt) {
            lowerAlt = entry.key;
            lowerSpeed = entry.value;
          }
        }
        if (entry.key >= altitude) {
          if (upperAlt == null || entry.key < upperAlt) {
            upperAlt = entry.key;
            upperSpeed = entry.value;
          }
        }
      }
    }

    if (lowerAlt == altitude && lowerSpeed != null) return lowerSpeed;
    if (upperAlt == altitude && upperSpeed != null) return upperSpeed;

    if (lowerAlt != null &&
        upperAlt != null &&
        lowerSpeed != null &&
        upperSpeed != null &&
        lowerAlt != upperAlt) {
      final ratio = (altitude - lowerAlt) / (upperAlt - lowerAlt);
      return lowerSpeed + (upperSpeed - lowerSpeed) * ratio;
    }

    return lowerSpeed ?? upperSpeed;
  }

  List<HourlyForecast> _filterForecasts() {
    return hourlyWeather.hourlyForecasts.where((forecast) {
      if (!_isDaytime(forecast)) {
        return false;
      }
      if ((forecast.windGusts ?? 0.0) >= maxGustSpeed) {
        return false;
      }
      if ((forecast.precipitationProbability ?? 0) >=
          maxPrecipitationProbability) {
        return false;
      }
      if ((forecast.apparentTemperature ?? -273.15) < minApparentTemperature) {
        return false;
      }
      return true;
    }).toList();
  }

  bool _isDaytime(HourlyForecast forecast) {
    final dailyForecast = dailyWeather.dailyForecasts.firstWhere(
      (day) =>
          day.date.year == forecast.time.year &&
          day.date.month == forecast.time.month &&
          day.date.day == forecast.time.day,
      orElse: () => dailyWeather.dailyForecasts.first,
    );

    if (dailyForecast.sunrise != null && dailyForecast.sunset != null) {
      return forecast.time.isAfter(dailyForecast.sunrise!) &&
          forecast.time.isBefore(dailyForecast.sunset!);
    }
    return forecast.isDay == 1;
  }

  Map<String, List<HourlyForecast>> _groupByDate(
    BuildContext context,
    List<HourlyForecast> forecasts,
  ) {
    final Map<String, List<HourlyForecast>> grouped = {};
    for (final forecast in forecasts) {
      final dateKey = ChartHelpers.formatLocalizedDate(
        forecast.time,
        Localizations.localeOf(context).toString(),
      );
      grouped.putIfAbsent(dateKey, () => []).add(forecast);
    }
    return grouped;
  }
}
