import 'package:flutter/material.dart';
import 'package:aeroclim/features/climate/domain/climate_model.dart';
import 'package:aeroclim/features/weather/domain/weather_model.dart';
import 'package:aeroclim/features/weather/presentation/widgets/utils/chart_helpers.dart';
import 'package:aeroclim/features/climate/data/climate_repository.dart';
import 'package:aeroclim/core/config/app_config.dart';
import 'package:aeroclim/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class WeatherTable extends StatelessWidget {
  final DailyWeather forecast;
  final List<ClimateNormal> climateNormals;
  final ClimateRepository _climateService = ClimateRepository();

  WeatherTable({
    super.key,
    required this.forecast,
    this.climateNormals = const [], // Optional with empty default
  });

  @override
  Widget build(BuildContext context) {
    final showClimate = AppConfig.includeClimate && climateNormals.isNotEmpty;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        horizontalMargin: 0,
        columnSpacing: 0,
        headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
        columns: _buildColumns(context, showClimate),
        rows: forecast.dailyForecasts.map((dailyForecast) {
          final deviation = showClimate
              ? _climateService.calculateDeviation(
                  dailyForecast.temperatureMax,
                  dailyForecast.temperatureMin,
                  dailyForecast.dayOfYear,
                  climateNormals,
                )
              : null;
          return DataRow(
            cells: _buildCells(context, dailyForecast, deviation, showClimate),
          );
        }).toList(),
      ),
    );
  }

  List<DataColumn> _buildColumns(BuildContext context, bool showClimate) {
    final columns = [
      DataColumn(
        label: Text(
          AppLocalizations.of(context)!.date,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      DataColumn(
        label: Text(
          AppLocalizations.of(context)!.max,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        numeric: true,
      ),
      DataColumn(
        label: Text(
          AppLocalizations.of(context)!.min,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        numeric: true,
      ),
    ];

    if (showClimate) {
      columns.addAll([
        DataColumn(
          label: Text(
            AppLocalizations.of(context)!.dMax,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          numeric: true,
        ),
        DataColumn(
          label: Text(
            AppLocalizations.of(context)!.dMin,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          numeric: true,
        ),
        DataColumn(
          label: Text(
            AppLocalizations.of(context)!.normalMax,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          numeric: true,
        ),
        DataColumn(
          label: Text(
            AppLocalizations.of(context)!.normalMin,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          numeric: true,
        ),
        DataColumn(
          label: Text(
            AppLocalizations.of(context)!.avgDeviation,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          numeric: true,
        ),
      ]);
    }

    return columns;
  }

  List<DataCell> _buildCells(
    BuildContext context,
    DailyForecast dailyForecast,
    WeatherDeviation? deviation,
    bool showClimate,
  ) {
    final cells = [
      DataCell(
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            '${ChartHelpers.formatLocalizedDate(dailyForecast.date, Localizations.localeOf(context).toString())}',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
          ),
        ),
      ),
      DataCell(
        Text(
          '  ${dailyForecast.temperatureMax.toStringAsFixed(0)}° ',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      DataCell(
        Text(
          '    ${dailyForecast.temperatureMin.toStringAsFixed(0)}° ',
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
    ];

    if (showClimate && deviation != null) {
      cells.addAll([
        DataCell(
          _buildDeviationBadge(
            deviation.maxDeviation,
            deviation.maxDeviationText,
          ),
        ),
        DataCell(
          _buildDeviationBadge(
            deviation.minDeviation,
            deviation.minDeviationText,
          ),
        ),
        DataCell(
          Text(
            deviation.normal != null
                ? '${deviation.normal!.temperatureMax.toStringAsFixed(1)}°C'
                : 'N/A',
            style: TextStyle(color: Colors.red.withValues(alpha: 0.7)),
          ),
        ),
        DataCell(
          Text(
            deviation.normal != null
                ? '${deviation.normal!.temperatureMin.toStringAsFixed(1)}°C'
                : 'N/A',
            style: TextStyle(color: Colors.red.withValues(alpha: 0.7)),
          ),
        ),
        DataCell(
          _buildDeviationBadge(
            deviation.avgDeviation,
            deviation.avgDeviationText,
            fontSize: 12,
          ),
        ),
      ]);
    }

    return cells;
  }

  Widget _buildDeviationBadge(
    double deviation,
    String text, {
    double fontSize = 16,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getDeviationColor(deviation),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }

  Color _getDeviationColor(double deviation) {
    if (deviation > 2) return Colors.red[700]!;
    if (deviation > 1) return Colors.orange[600]!;
    if (deviation > 0.5) return Colors.orange[400]!;
    if (deviation > -0.5) return Colors.green[600]!;
    if (deviation > -1) return Colors.blue[400]!;
    if (deviation > -2) return Colors.blue[600]!;
    return Colors.blue[800]!;
  }
}
