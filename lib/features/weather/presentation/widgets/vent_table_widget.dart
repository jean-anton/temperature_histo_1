import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:temperature_histo_1/features/weather/domain/weather_model.dart';
import 'package:temperature_histo_1/features/weather/presentation/widgets/utils/chart_theme.dart';
import 'package:temperature_histo_1/features/weather/presentation/widgets/common/weather_icon_widget.dart';
import 'package:temperature_histo_1/features/weather/presentation/widgets/common/gust_arrow_widget.dart';

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
      return _buildEmptyState();
    }

    final groupedByDate = _groupByDate(filteredForecasts);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoHeader(),
              const SizedBox(height: 8),
              ...groupedByDate.entries.map((entry) {
                return _buildDateSection(entry.key, entry.value);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'Aucune heure ne répond aux critères sélectionnés',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Rafales max: ${maxGustSpeed.toStringAsFixed(0)} km/h\n'
              'Précipitations max: $maxPrecipitationProbability%\n'
              'Ressenti min: ${minApparentTemperature.toStringAsFixed(0)}°C',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoHeader() {
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
            'Filtres: Rafales < ${maxGustSpeed.toStringAsFixed(0)} km/h • '
            'Précip < $maxPrecipitationProbability% • '
            'Ressenti > ${minApparentTemperature.toStringAsFixed(0)}°C',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blue[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(String date, List<HourlyForecast> forecasts) {
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
        _buildTable(forecasts),
      ],
    );
  }

  Widget _buildTable(List<HourlyForecast> forecasts) {
    return DataTable(
      headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
      columnSpacing: 16,
      horizontalMargin: 8,
      columns: const [
        DataColumn(
          label: Text('Heure', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(
          label: Text(
            'Vent\n(km/h)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          numeric: true,
        ),
        DataColumn(
          label: Text('Dir.', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(
          label: Text('Météo', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(
          label: Text(
            'Temp\n(°C)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          numeric: true,
        ),
        DataColumn(
          label: Text(
            'Ressenti\n(°C)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          numeric: true,
        ),
        DataColumn(
          label: Text(
            'Précip\n(%)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          numeric: true,
        ),
        DataColumn(
          label: Text(
            'Nuages\n(%)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          numeric: true,
        ),
        DataColumn(
          label: Text(
            'Vent par altitude (10m-200m)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
      rows: forecasts.map((forecast) => _buildRow(forecast)).toList(),
    );
  }

  DataRow _buildRow(HourlyForecast forecast) {
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
            scaleFactor: 1.5,
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
        DataCell(_buildContinuousWindHeatmap(forecast)),
      ],
    );
  }

  Widget _buildContinuousWindHeatmap(HourlyForecast forecast) {
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
          message:
              '${altitudeMid.toInt()}m: ${windSpeed?.toStringAsFixed(1) ?? 'N/A'} km/h',
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
    List<HourlyForecast> forecasts,
  ) {
    final Map<String, List<HourlyForecast>> grouped = {};
    for (final forecast in forecasts) {
      final dateKey = DateFormat('EEEE d MMMM', 'fr_FR').format(forecast.time);
      grouped.putIfAbsent(dateKey, () => []).add(forecast);
    }
    return grouped;
  }
}
