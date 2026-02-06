import 'package:fl_chart/fl_chart.dart';
import 'package:aeroclim/features/climate/domain/climate_model.dart';
import 'package:aeroclim/features/weather/domain/weather_model.dart';
//import 'weather_deviation.dart';

/// Provides chart data for different chart types
class ChartDataProvider {
  /// Get maximum temperature spots for daily chart
  static List<FlSpot> getMaxTempSpots(DailyWeather forecast) {
    return forecast.dailyForecasts.asMap().entries.map((entry) {
      return FlSpot(
        entry.value.date.millisecondsSinceEpoch.toDouble(),
        entry.value.temperatureMax,
      );
    }).toList();
  }

  /// Get minimum temperature spots for daily chart
  static List<FlSpot> getMinTempSpots(DailyWeather forecast) {
    return forecast.dailyForecasts.asMap().entries.map((entry) {
      return FlSpot(
        entry.value.date.millisecondsSinceEpoch.toDouble(),
        entry.value.temperatureMin,
      );
    }).toList();
  }

  /// Get normal maximum temperature spots for daily chart
  static List<FlSpot> getNormalMaxSpots(
    DailyWeather forecast,
    List<WeatherDeviation?> deviations,
  ) {
    return forecast.dailyForecasts
        .asMap()
        .entries
        .map((entry) {
          final normal = entry.key < deviations.length
              ? deviations[entry.key]?.normal
              : null;
          return FlSpot(
            entry.value.date.millisecondsSinceEpoch.toDouble(),
            normal?.temperatureMax ?? 0,
          );
        })
        .where((spot) => spot.y != 0)
        .toList();
  }

  /// Get normal minimum temperature spots for daily chart
  static List<FlSpot> getNormalMinSpots(
    DailyWeather forecast,
    List<WeatherDeviation?> deviations,
  ) {
    return forecast.dailyForecasts
        .asMap()
        .entries
        .map((entry) {
          final normal = entry.key < deviations.length
              ? deviations[entry.key]?.normal
              : null;
          return FlSpot(
            entry.value.date.millisecondsSinceEpoch.toDouble(),
            normal?.temperatureMin ?? 0,
          );
        })
        .where((spot) => spot.y != 0)
        .toList();
  }

  /// Get hourly temperature spots for hourly chart
  static List<FlSpot> getHourlyTempSpots(HourlyWeather dailyWeather) {
    return dailyWeather.hourlyForecasts.map((hourly) {
      return FlSpot(
        hourly.time.millisecondsSinceEpoch.toDouble(),
        hourly.temperature ?? 0,
      );
    }).toList();
  }

  /// Get apparent temperature spots for hourly chart
  static List<FlSpot> getHourlyApparentTempSpots(HourlyWeather dailyWeather) {
    return dailyWeather.hourlyForecasts.map((hourly) {
      return FlSpot(
        hourly.time.millisecondsSinceEpoch.toDouble(),
        hourly.apparentTemperature ?? 0,
      );
    }).toList();
  }

  /// Get period forecasts from hourly weather
  static List<PeriodForecast> getPeriodForecasts(HourlyWeather hourlyWeather) {
    final List<PeriodForecast> periodForecasts = [];
    if (hourlyWeather.hourlyForecasts.isEmpty) return periodForecasts;

    // Group hourly forecasts by 6-hour periods
    // 00-06: Nuit, 06-12: Matin, 12-18: Après-midi, 18-00: Soir
    DateTime currentPeriodStart = _getPeriodStartTime(
      hourlyWeather.hourlyForecasts.first.time,
    );
    List<HourlyForecast> currentPeriodHours = [];

    for (final hourly in hourlyWeather.hourlyForecasts) {
      DateTime hourlyPeriodStart = _getPeriodStartTime(hourly.time);

      if (hourlyPeriodStart != currentPeriodStart) {
        if (currentPeriodHours.isNotEmpty) {
          periodForecasts.add(
            _createPeriodForecast(currentPeriodStart, currentPeriodHours),
          );
        }
        currentPeriodStart = hourlyPeriodStart;
        currentPeriodHours = [hourly];
      } else {
        currentPeriodHours.add(hourly);
      }
    }

    if (currentPeriodHours.isNotEmpty) {
      periodForecasts.add(
        _createPeriodForecast(currentPeriodStart, currentPeriodHours),
      );
    }

    return periodForecasts;
  }

  static DateTime _getPeriodStartTime(DateTime time) {
    int hour = (time.hour ~/ 6) * 6;
    return DateTime(time.year, time.month, time.day, hour);
  }

  static PeriodForecast _createPeriodForecast(
    DateTime startTime,
    List<HourlyForecast> hours,
  ) {
    final name = _getPeriodName(startTime.hour);
    final avgTemp =
        hours
            .where((h) => h.temperature != null)
            .map((h) => h.temperature!)
            .fold(0.0, (a, b) => a + b) /
        hours.where((h) => h.temperature != null).length;

    // Averages/Representative values for new fields
    double? avgApparent;
    if (hours.any((h) => h.apparentTemperature != null)) {
      final validHours = hours.where((h) => h.apparentTemperature != null);
      avgApparent =
          validHours
              .map((h) => h.apparentTemperature!)
              .fold(0.0, (a, b) => a + b) /
          validHours.length;
    }

    double? avgPrecip;
    if (hours.any((h) => h.precipitation != null)) {
      final validHours = hours.where((h) => h.precipitation != null);
      avgPrecip =
          validHours.map((h) => h.precipitation!).fold(0.0, (a, b) => a + b) /
          validHours.length;
    }

    double? avgProb;
    if (hours.any((h) => h.precipitationProbability != null)) {
      final validHours = hours.where((h) => h.precipitationProbability != null);
      avgProb =
          validHours
              .map((h) => h.precipitationProbability!.toDouble())
              .fold(0.0, (a, b) => a + b) /
          validHours.length;
    }

    double? avgRain;
    if (hours.any((h) => h.rain != null)) {
      final validHours = hours.where((h) => h.rain != null);
      avgRain =
          validHours.map((h) => h.rain!).fold(0.0, (a, b) => a + b) /
          validHours.length;
    }

    double? avgCloud;
    if (hours.any((h) => h.cloudCover != null)) {
      final validHours = hours.where((h) => h.cloudCover != null);
      avgCloud =
          validHours
              .map((h) => h.cloudCover!.toDouble())
              .fold(0.0, (a, b) => a + b) /
          validHours.length;
    }

    double? avgHum;
    if (hours.any((h) => h.humidity != null)) {
      final validHours = hours.where((h) => h.humidity != null);
      avgHum =
          validHours
              .map((h) => h.humidity!.toDouble())
              .fold(0.0, (a, b) => a + b) /
          validHours.length;
    }

    double? avgSun;
    if (hours.any((h) => h.sunshineDuration != null)) {
      final validHours = hours.where((h) => h.sunshineDuration != null);
      avgSun =
          validHours
              .map((h) => h.sunshineDuration!)
              .fold(0.0, (a, b) => a + b) /
          validHours.length;
    }

    // Extended wind averages
    double? _avgWind(double? Function(HourlyForecast) getter) {
      if (hours.any((h) => getter(h) != null)) {
        final validHours = hours.where((h) => getter(h) != null);
        return validHours.map((h) => getter(h)!).fold(0.0, (a, b) => a + b) /
            validHours.length;
      }
      return null;
    }

    // For weather code, use most frequent
    final weatherCode = _getRepresentativeWeatherCode(hours);
    final maxWind = hours
        .where((h) => h.windSpeed != null)
        .map((h) => h.windSpeed!)
        .fold(0.0, (a, b) => a > b ? a : b);
    final maxGusts = hours
        .where((h) => h.windGusts != null)
        .map((h) => h.windGusts!)
        .fold(0.0, (a, b) => a > b ? a : b);

    // Wind direction from the sample with max wind speed
    int? windDir;
    if (hours.isNotEmpty) {
      final maxWindHour = hours.reduce(
        (a, b) => (a.windSpeed ?? 0) > (b.windSpeed ?? 0) ? a : b,
      );
      windDir = maxWindHour.windDirection10m;
    }

    // isDay if most hours are day
    final isDay = hours.where((h) => h.isDay == 1).length > hours.length / 2
        ? 1
        : 0;

    return PeriodForecast(
      time: startTime,
      name: name,
      avgTemperature: avgTemp,
      weatherCode: weatherCode,
      maxWindSpeed: maxWind,
      maxWindGusts: maxGusts,
      windDirection: windDir,
      isDay: isDay,
      apparentTemperature: avgApparent,
      precipitationProbability: avgProb?.round(),
      precipitation: avgPrecip,
      rain: avgRain,
      cloudCover: avgCloud?.round(),
      humidity: avgHum?.round(),
      sunshineDuration: avgSun,
      windSpeed20m: _avgWind((h) => h.windSpeed20m),
      windSpeed50m: _avgWind((h) => h.windSpeed50m),
      windSpeed80m: _avgWind((h) => h.windSpeed80m),
      windSpeed100m: _avgWind((h) => h.windSpeed100m),
      windSpeed120m: _avgWind((h) => h.windSpeed120m),
      windSpeed150m: _avgWind((h) => h.windSpeed150m),
      windSpeed180m: _avgWind((h) => h.windSpeed180m),
      windSpeed200m: _avgWind((h) => h.windSpeed200m),
    );
  }

  static String _getPeriodName(int hour) {
    if (hour >= 0 && hour < 6) return 'Nuit';
    if (hour >= 6 && hour < 12) return 'Matin';
    if (hour >= 12 && hour < 18) return 'A-M';
    if (hour >= 18) return 'Soir';
    return '';
  }

  static int? _getRepresentativeWeatherCode(List<HourlyForecast> hours) {
    if (hours.isEmpty) return null;
    final Map<int, int> counts = {};
    for (final h in hours) {
      if (h.weatherCode != null) {
        counts[h.weatherCode!] = (counts[h.weatherCode!] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  /// Get period temperature spots for chart
  static List<FlSpot> getPeriodTempSpots(List<PeriodForecast> periodForecasts) {
    return periodForecasts.map((PeriodForecast period) {
      // Center the spot at 3h, 9h, 15h, 21h
      final centeredTime = period.time.add(const Duration(hours: 3));
      return FlSpot(
        centeredTime.millisecondsSinceEpoch.toDouble(),
        period.avgTemperature,
      );
    }).toList();
  }

  /// Get period apparent temperature spots for chart
  static List<FlSpot> getPeriodApparentTempSpots(
    List<PeriodForecast> periodForecasts,
  ) {
    return periodForecasts.map((PeriodForecast period) {
      // Center the spot at 3h, 9h, 15h, 21h
      final centeredTime = period.time.add(const Duration(hours: 3));
      return FlSpot(
        centeredTime.millisecondsSinceEpoch.toDouble(),
        period.apparentTemperature ?? 0,
      );
    }).toList();
  }
}
