import 'weather_model.dart';

/// Weather code groups based on WMO standards
enum WeatherGroup {
  clear, // 0
  cloudy, // 1
  fog, // 2
  precipitation, // 3
  snow, // 4
  storm, // 5
}

/// Utility class for calculating daytime-representative weathercodes
/// from hourly forecast data using WMO code grouping and severity analysis.
class WeathercodeCalculator {
  // Configuration
  static const int daytimeStartHour = 6;
  static const int daytimeEndHour = 20;
  static const double severityThreshold = 0.25; // 25%

  /// Maps a WMO weathercode to its weather group category
  static WeatherGroup getWeatherGroup(int weatherCode) {
    // Group 0: Clear (0, 1)
    if (weatherCode >= 0 && weatherCode <= 1) {
      return WeatherGroup.clear;
    }
    // Group 1: Cloudy (2, 3)
    else if (weatherCode >= 2 && weatherCode <= 3) {
      return WeatherGroup.cloudy;
    }
    // Group 2: Fog (45, 48)
    else if (weatherCode == 45 || weatherCode == 48) {
      return WeatherGroup.fog;
    }
    // Group 4: Snow (71-77, 85-86)
    else if ((weatherCode >= 71 && weatherCode <= 77) ||
        (weatherCode >= 85 && weatherCode <= 86)) {
      return WeatherGroup.snow;
    }
    // Group 5: Storm (95-99)
    else if (weatherCode >= 95 && weatherCode <= 99) {
      return WeatherGroup.storm;
    }
    // Group 3: Precipitation (51-67, 80-82) - default for remaining codes
    else {
      return WeatherGroup.precipitation;
    }
  }

  /// Checks if a weather group is considered severe
  static bool isSevereGroup(WeatherGroup group) {
    return group == WeatherGroup.precipitation ||
        group == WeatherGroup.snow ||
        group == WeatherGroup.storm;
  }

  /// Calculates the daytime-representative weathercode for a specific day
  /// from hourly forecast data.
  ///
  /// Returns a result containing:
  /// - calculatedCode: The representative weathercode (or null if insufficient data)
  /// - hoursAnalyzed: Number of daytime hours used in calculation
  ///
  /// Algorithm:
  /// 1. Filter hourly data for daytime hours (6h-20h, isDay==1)
  /// 2. Group weathercodes by category
  /// 3. Find the mode (most frequent group)
  /// 4. Check if any severe group exceeds severity threshold (25%)
  /// 5. If so, override with that severe group
  /// 6. Return the most frequent specific code within the winning group
  static DaytimeWeathercodeResult calculateDaytimeWeathercode({
    required List<HourlyForecast> hourlyForecasts,
    required DateTime targetDate,
  }) {
    // Step 1: Filter for daytime hours on the target date
    final daytimeHours = hourlyForecasts.where((forecast) {
      final isSameDay =
          forecast.time.year == targetDate.year &&
          forecast.time.month == targetDate.month &&
          forecast.time.day == targetDate.day;

      final isDaytime = forecast.isDay == 1;
      final isInHourRange =
          forecast.time.hour >= daytimeStartHour &&
          forecast.time.hour < daytimeEndHour;

      final hasWeatherCode = forecast.weatherCode != null;

      return isSameDay && isDaytime && isInHourRange && hasWeatherCode;
    }).toList();

    // Edge case: No daytime hours available
    if (daytimeHours.isEmpty) {
      return DaytimeWeathercodeResult(calculatedCode: null, hoursAnalyzed: 0);
    }

    // Step 2: Count hours per group and track specific codes
    final Map<WeatherGroup, int> groupCounts = {};
    final Map<WeatherGroup, List<int>> groupCodes = {};

    for (final hourly in daytimeHours) {
      final code = hourly.weatherCode!;
      final group = getWeatherGroup(code);

      groupCounts[group] = (groupCounts[group] ?? 0) + 1;
      groupCodes.putIfAbsent(group, () => []).add(code);
    }

    // Step 3: Find the mode (most frequent group)
    WeatherGroup? modeGroup;
    int maxCount = 0;

    groupCounts.forEach((group, count) {
      if (count > maxCount) {
        maxCount = count;
        modeGroup = group;
      }
    });

    // Step 4: Check for severity threshold override
    final totalHours = daytimeHours.length;

    // Check severe groups in order of severity: Storm > Snow > Precipitation
    for (final severeGroup in [
      WeatherGroup.storm,
      WeatherGroup.snow,
      WeatherGroup.precipitation,
    ]) {
      final count = groupCounts[severeGroup] ?? 0;
      final percentage = count / totalHours;

      if (percentage > severityThreshold) {
        modeGroup = severeGroup;
        break; // Use the first (most severe) group that exceeds threshold
      }
    }

    // Step 5: Select the most frequent specific code within the winning group
    if (modeGroup == null) {
      return DaytimeWeathercodeResult(
        calculatedCode: null,
        hoursAnalyzed: totalHours,
      );
    }

    final codesInGroup = groupCodes[modeGroup] ?? [];
    final representativeCode = _getMostFrequentCode(codesInGroup);

    return DaytimeWeathercodeResult(
      calculatedCode: representativeCode,
      hoursAnalyzed: totalHours,
    );
  }

  /// Returns the most frequent code from a list of codes.
  /// In case of a tie, returns the higher (more severe) code.
  static int _getMostFrequentCode(List<int> codes) {
    if (codes.isEmpty) {
      throw ArgumentError('Cannot find most frequent code from empty list');
    }

    final Map<int, int> codeFrequency = {};
    for (final code in codes) {
      codeFrequency[code] = (codeFrequency[code] ?? 0) + 1;
    }

    int? mostFrequentCode;
    int maxFrequency = 0;

    codeFrequency.forEach((code, frequency) {
      if (frequency > maxFrequency ||
          (frequency == maxFrequency &&
              (mostFrequentCode == null || code > mostFrequentCode!))) {
        mostFrequentCode = code;
        maxFrequency = frequency;
      }
    });

    return mostFrequentCode!;
  }
}

/// Result of daytime weathercode calculation
class DaytimeWeathercodeResult {
  final int? calculatedCode;
  final int hoursAnalyzed;

  DaytimeWeathercodeResult({
    required this.calculatedCode,
    required this.hoursAnalyzed,
  });
}
