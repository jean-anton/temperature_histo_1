import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:temperature_histo_1/features/weather/domain/weather_model.dart';
import 'package:temperature_histo_1/features/weather/presentation/widgets/utils/chart_theme.dart';
import 'package:temperature_histo_1/features/weather/presentation/widgets/utils/chart_helpers.dart';

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
    // Filter hourly forecasts for favorable conditions
    final filteredForecasts = _filterForecasts();

    if (filteredForecasts.isEmpty) {
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

    // Group forecasts by date
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
      headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
      columnSpacing: 16,
      horizontalMargin: 8,
      columns: const [
        DataColumn(
          label: Text('Heure', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(
          label: Text(
            'Rafales\n(km/h)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          numeric: true,
        ),
        DataColumn(
          label: Text(
            'Rafales\n(km/h)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          numeric: true,
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
        // Hour
        DataCell(
          Text(
            DateFormat('HH:mm').format(forecast.time),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        // Gusts
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
        // Weather icon (SVG from weather_icon_data.dart)
        DataCell(
          _buildGustArrow(forecast.windGusts, forecast.windDirection10m),
        ),
        DataCell(_buildWeatherIcon(forecast.weatherCode, forecast.isDay)),
        // Temperature
        DataCell(
          Text(
            (forecast.temperature ?? 0).toStringAsFixed(1),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        // Apparent temperature
        DataCell(
          Text(
            (forecast.apparentTemperature ?? 0).toStringAsFixed(1),
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
        // Precipitation probability
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
        // Cloud cover
        DataCell(
          Text(
            (forecast.cloudCover ?? 0).toString(),
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
        // Wind heatmap (continuous with weighted averages)
        DataCell(_buildContinuousWindHeatmap(forecast)),
      ],
    );
  }

  Widget _buildWeatherIcon(int? code, int? isDay) {
    if (code == null) {
      return Icon(Icons.help_outline, size: 24, color: Colors.grey[700]);
    }

    // Use ChartHelpers to get the same icon path as used in graphs
    final iconPath = ChartHelpers.getIconPath(code: code, isDay: isDay);

    if (iconPath == null) {
      return Icon(Icons.help_outline, size: 24, color: Colors.grey[700]);
    }

    return SizedBox(
      width: 32,
      height: 32,
      child: SvgPicture.asset(
        iconPath,
        width: 32,
        height: 32,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildGustArrow(double? windSpeed, int? windDirection) {
    if (windSpeed == null || windDirection == null) {
      return Icon(Icons.help_outline, size: 24, color: Colors.grey[700]);
    }
    final windIconPath = "assets/google_weather_icons/v3/arrow.svg";
    final windIconPathContour =
        "assets/google_weather_icons/v3/arrow_contour.svg";
    return Stack(
      children: [
        Transform.rotate(
          //angle: (windDirectionDegrees - 90) * (3.14159 / 180), // Convert degrees to radians
          angle:
              (135 + windDirection) *
              (3.14159 / 180), // Convert degrees to radians
          child: SvgPicture.asset(
            windIconPath,
            // width: 50 * (hourly.windGusts ?? 0.0) / 20, // Scale size by wind speed (max 20 m/s)
            // height: 50 * (hourly.windGusts ?? 0.0) / 20,
            // colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
            width:
                (windSpeed ?? 0.0) * 2, // Scale size by wind speed (max 20 m/s)
            height: (windSpeed ?? 0.0) * 2,
            colorFilter: ColorFilter.mode(
              ChartTheme.windGustColor(windSpeed ?? 0.0),
              BlendMode.srcIn,
            ),
          ),
        ),
        Transform.rotate(
          //angle: (windDirectionDegrees - 90) * (3.14159 / 180), // Convert degrees to radians
          angle:
              (135 + windDirection) *
              (3.14159 / 180), // Convert degrees to radians
          child: SvgPicture.asset(
            windIconPathContour,
            // width: 50 * (hourly.windGusts ?? 0.0) / 20, // Scale size by wind speed (max 20 m/s)
            // height: 50 * (hourly.windGusts ?? 0.0) / 20,
            // colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
            width:
                (windSpeed ?? 0.0) * 2, // Scale size by wind speed (max 20 m/s)
            height: (windSpeed ?? 0.0) * 2,
            colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
            //colorFilter: const ColorFilter.mode(Colors.deepPurple, BlendMode.srcIn),
            // colorFilter: ColorFilter.mode(
            //   gustColor(hourly.windGusts ?? 0.0),
            //   BlendMode.srcIn,
            // ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinuousWindHeatmap(HourlyForecast forecast) {
    // Create continuous heatmap with 19 cells (10m to 200m)
    // Each cell represents a 10m band with interpolated wind speed
    const int numCells = 19;
    final List<Widget> cells = [];

    for (int i = 0; i < numCells; i++) {
      final altitudeStart = 10.0 + (i * 10.0);
      final altitudeEnd = altitudeStart + 10.0;
      final altitudeMid = (altitudeStart + altitudeEnd) / 2.0;

      // Get weighted average wind speed for this altitude band
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

  /// Get interpolated wind speed at a specific altitude using weighted average
  double? _getInterpolatedWindSpeed(HourlyForecast forecast, double altitude) {
    // Define available altitude measurements
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

    // Find bracketing altitudes with data
    double? lowerAlt;
    double? lowerSpeed;
    double? upperAlt;
    double? upperSpeed;

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

    // If exact match, return it
    if (lowerAlt == altitude && lowerSpeed != null) {
      return lowerSpeed;
    }
    if (upperAlt == altitude && upperSpeed != null) {
      return upperSpeed;
    }

    // If we have both bracketing values, interpolate
    if (lowerAlt != null &&
        upperAlt != null &&
        lowerSpeed != null &&
        upperSpeed != null &&
        lowerAlt != upperAlt) {
      final ratio = (altitude - lowerAlt) / (upperAlt - lowerAlt);
      return lowerSpeed + (upperSpeed - lowerSpeed) * ratio;
    }

    // If we only have lower bound, use it
    if (lowerSpeed != null) return lowerSpeed;

    // If we only have upper bound, use it
    if (upperSpeed != null) return upperSpeed;

    // No data available
    return null;
  }

  List<HourlyForecast> _filterForecasts() {
    return hourlyWeather.hourlyForecasts.where((forecast) {
      // Check if daytime
      final isDaytime = _isDaytime(forecast);
      if (!isDaytime) return false;

      // Check gust speed
      final gusts = forecast.windGusts ?? 0.0;
      if (gusts >= maxGustSpeed) return false;

      // Check precipitation probability
      final precipProb = forecast.precipitationProbability ?? 0;
      if (precipProb >= maxPrecipitationProbability) return false;

      // Check apparent temperature
      final apparentTemp = forecast.apparentTemperature ?? -273.15;
      if (apparentTemp < minApparentTemperature) return false;

      return true;
    }).toList();
  }

  bool _isDaytime(HourlyForecast forecast) {
    // Find the corresponding daily forecast
    final dailyForecast = dailyWeather.dailyForecasts.firstWhere(
      (day) =>
          day.date.year == forecast.time.year &&
          day.date.month == forecast.time.month &&
          day.date.day == forecast.time.day,
      orElse: () => dailyWeather.dailyForecasts.first,
    );

    // Check if within sunrise/sunset
    if (dailyForecast.sunrise != null && dailyForecast.sunset != null) {
      return forecast.time.isAfter(dailyForecast.sunrise!) &&
          forecast.time.isBefore(dailyForecast.sunset!);
    }

    // Fallback to isDay flag
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
