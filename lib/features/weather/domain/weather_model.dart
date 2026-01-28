import 'package:intl/intl.dart';
// ADD THIS IMPORT: Required for date formatting initialization.
import 'package:intl/date_symbol_data_local.dart';
import '../data/weather_repository.dart';

enum DisplayType { graphique, tableau, vent, ventDay, ventTable, comparatif }

class DailyWeather {
  final String locationName;
  final String model;
  final List<DailyForecast> dailyForecasts;
  final double latitude;
  final double longitude;
  final String timezone;

  DailyWeather({
    required this.locationName,
    required this.model,
    required this.dailyForecasts,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  /// Creates a WeatherForecast instance from a JSON map.
  ///
  /// This factory is robust against `null` or missing values in the API response.
  /// It initializes `locationName` and `model` with empty strings, as they are not
  /// present in the JSON. Use the `copyWith` method to add them later.
  factory DailyWeather.fromJson(Map<String, dynamic> json) {
    final dailyData = json['daily'] as Map<String, dynamic>? ?? {};

    // Extract all data lists from the API response.
    final timeList = dailyData['time'] as List?;
    final maxTempList = dailyData['temperature_2m_max'] as List?;
    final minTempList = dailyData['temperature_2m_min'] as List?;
    final precipitationSumList = dailyData['precipitation_sum'] as List?;
    final precipitationHoursList = dailyData['precipitation_hours'] as List?;
    final snowfallSumList = dailyData['snowfall_sum'] as List?;
    final precipitationProbabilityMaxList =
        dailyData['precipitation_probability_max'] as List?;
    final weatherCodeList = dailyData['weathercode'] as List?;
    final cloudCoverMeanList = dailyData['cloudcover_mean'] as List?;
    final windSpeedMaxList = dailyData['windspeed_10m_max'] as List?;
    final windGustsMaxList = dailyData['windgusts_10m_max'] as List?;
    final windDirection10mDominantList =
        dailyData['wind_direction_10m_dominant'] as List?;
    final sunriseList = dailyData['sunrise'] as List?;
    final sunsetList = dailyData['sunset'] as List?;

    // If essential time data is missing, we cannot proceed.
    if (timeList == null) {
      return DailyWeather(
        locationName: '',
        model: '',
        dailyForecasts: [],
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
        timezone: json['timezone'] as String? ?? '',
      );
    }

    final forecasts = <DailyForecast>[];
    for (int i = 0; i < timeList.length; i++) {
      // --- FIX: Check if the core data for this day is valid ---
      // If temperature_2m_max is null, the model doesn't provide data for this day.
      // We skip this iteration to avoid creating an empty DailyForecast object.
      if (maxTempList?[i] == null) {
        continue;
      }

      // Safely create a DailyForecast object for each day.
      forecasts.add(
        DailyForecast(
          date: DateTime.parse(timeList[i] as String),
          temperatureMax: (maxTempList?[i] as num?)?.toDouble() ?? 0.0,
          temperatureMin: (minTempList?[i] as num?)?.toDouble() ?? 0.0,
          precipitationSum: (precipitationSumList?[i] as num?)?.toDouble(),
          precipitationHours: (precipitationHoursList?[i] as num?)?.toDouble(),
          snowfallSum: (snowfallSumList?[i] as num?)?.toDouble(),
          precipitationProbabilityMax:
              (precipitationProbabilityMaxList?[i] as num?)?.toInt(),
          weatherCode: (weatherCodeList?[i] as num?)?.toInt(),
          cloudCoverMean: (cloudCoverMeanList?[i] as num?)?.toInt(),
          windSpeedMax: (windSpeedMaxList?[i] as num?)?.toDouble(),
          windGustsMax: (windGustsMaxList?[i] as num?)?.toDouble(),
          windDirection10mDominant: (windDirection10mDominantList?[i] as num?)
              ?.toInt(),
          sunrise: sunriseList?[i] != null
              ? DateTime.parse(sunriseList?[i] as String)
              : null,
          sunset: sunsetList?[i] != null
              ? DateTime.parse(sunsetList?[i] as String)
              : null,
        ),
      );
    }

    return DailyWeather(
      locationName: '', // To be set via copyWith
      model: '', // To be set via copyWith
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: json['timezone'] as String,
      dailyForecasts: forecasts,
    );
  }

  /// Creates a copy of this WeatherForecast but with the given fields replaced with the new values.
  DailyWeather copyWith({String? locationName, String? model}) {
    return DailyWeather(
      locationName: locationName ?? this.locationName,
      model: model ?? this.model,
      dailyForecasts: dailyForecasts,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
    );
  }

  @override
  String toString() {
    final forecastsString = dailyForecasts.map((f) => '  - $f').join('\n');
    return '''
WeatherForecast(
  locationName: '$locationName', model: '$model',
  latitude: $latitude, longitude: $longitude,
  dailyForecasts: [
$forecastsString
  ]
)''';
  }
}

class DailyForecast {
  final DateTime date;
  final double temperatureMax;
  final double temperatureMin;
  // NEW: Added fields for extended weather data
  final double? precipitationSum;
  final double? precipitationHours;
  final double? snowfallSum;
  final int? precipitationProbabilityMax;
  final int? weatherCode;
  final int? weatherCodeDaytime; // NEW: Calculated daytime-only weathercode
  final int?
  daytimeHoursAnalyzed; // NEW: Number of daytime hours used in calculation
  final int? cloudCoverMean;
  final double? windSpeedMax;
  final double? windGustsMax;
  final int? windDirection10mDominant;
  final DateTime? sunrise;
  final DateTime? sunset;
  final String? weatherIcon;

  DailyForecast({
    required this.date,
    required this.temperatureMax,
    required this.temperatureMin,
    // New fields
    this.precipitationSum,
    this.precipitationHours,
    this.snowfallSum,
    this.precipitationProbabilityMax,
    this.weatherCode,
    this.weatherCodeDaytime,
    this.daytimeHoursAnalyzed,
    this.cloudCoverMean,
    this.windSpeedMax,
    this.windGustsMax,
    this.windDirection10mDominant,
    this.sunrise,
    this.sunset,
    this.weatherIcon,
  });

  // Convenience getters for use in UI
  int get dayOfYear => int.parse(DateFormat('D').format(date));
  String get formattedDate => DateFormat('EEEE d MMMM', 'fr_FR').format(date);

  @override
  String toString() {
    // IMPROVEMENT: Handle null values gracefully for a cleaner printout.
    final precipText = precipitationSum != null
        ? '${precipitationSum}mm'
        : 'N/A';
    final windText = windSpeedMax != null
        ? '${windSpeedMax?.toStringAsFixed(1)}km/h'
        : 'N/A';
    final codeText = weatherCode != null ? '$weatherCode' : 'N/A';
    final codeDaytimeText = weatherCodeDaytime != null
        ? '$weatherCodeDaytime (${daytimeHoursAnalyzed}h)'
        : 'N/A';

    return 'DailyForecast(date: $formattedDate, max: ${temperatureMax.toStringAsFixed(1)}°C, min: ${temperatureMin.toStringAsFixed(1)}°C, precip: $precipText, wind: $windText, code: $codeText, codeDaytime: $codeDaytimeText)';
  }
}

// Add to weather_forecast_model.dart
class HourlyWeather {
  final String locationName;
  final double latitude;
  final double longitude;
  final String timezone;
  final List<HourlyForecast> hourlyForecasts;

  HourlyWeather({
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.hourlyForecasts,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    final hourlyData = json['hourly'] as Map<String, dynamic>? ?? {};

    final timeList = hourlyData['time'] as List?;
    final temperatureList = hourlyData['temperature_2m'] as List?;
    final weatherCodeList = hourlyData['weather_code'] as List?;
    final apparentTemperatureList = hourlyData['apparent_temperature'] as List?;
    final precipitationProbabilityList =
        hourlyData['precipitation_probability'] as List?;
    final precipitationList = hourlyData['precipitation'] as List?;
    final rainList = hourlyData['rain'] as List?;
    final cloudCoverList = hourlyData['cloud_cover'] as List?;
    final windSpeedList = hourlyData['wind_speed_10m'] as List?;
    //final windGustsList = hourlyData['windgusts_10m'] as List?;
    final windGustsList =
        (hourlyData['windgusts_10m'] ?? hourlyData['wind_gusts_10m']) as List?;
    final isDayList = hourlyData['is_day'] as List?;
    final sunshineDurationList = hourlyData['sunshine_duration'] as List?;
    final windDirectionList = hourlyData['wind_direction_10m'] as List?;
    final windSpeed20mList = hourlyData['windspeed_20m'] as List?;
    final windSpeed50mList = hourlyData['windspeed_50m'] as List?;
    final windSpeed80mList = hourlyData['windspeed_80m'] as List?;
    final windSpeed100mList = hourlyData['windspeed_100m'] as List?;
    final windSpeed120mList = hourlyData['windspeed_120m'] as List?;
    final windSpeed150mList = hourlyData['windspeed_150m'] as List?;
    final windSpeed180mList = hourlyData['windspeed_180m'] as List?;
    final windSpeed200mList = hourlyData['windspeed_200m'] as List?;

    final forecasts = <HourlyForecast>[];

    if (timeList != null) {
      for (int i = 0; i < timeList.length; i++) {
        if (temperatureList?[i] == null) {
          continue;
        }
        forecasts.add(
          HourlyForecast(
            time: DateTime.parse(timeList[i] as String),
            temperature: (temperatureList?[i] as num?)?.toDouble(),
            weatherCode: (weatherCodeList?[i] as num?)?.toInt(),
            apparentTemperature: (apparentTemperatureList?[i] as num?)
                ?.toDouble(),
            precipitationProbability: (precipitationProbabilityList?[i] as num?)
                ?.toInt(),
            precipitation: (precipitationList?[i] as num?)?.toDouble(),
            rain: (rainList?[i] as num?)?.toDouble(),
            cloudCover: (cloudCoverList?[i] as num?)?.toInt(),
            windSpeed: (windSpeedList?[i] as num?)?.toDouble(),
            windGusts: (windGustsList?[i] as num?)?.toDouble(),
            isDay: (isDayList?[i] as num?)?.toInt(),
            sunshineDuration: (sunshineDurationList?[i] as num?)?.toDouble(),
            windDirection10m: (windDirectionList?[i] as num?)?.toInt(),
            windSpeed20m: (windSpeed20mList?[i] as num?)?.toDouble(),
            windSpeed50m: (windSpeed50mList?[i] as num?)?.toDouble(),
            windSpeed80m: (windSpeed80mList?[i] as num?)?.toDouble(),
            windSpeed100m: (windSpeed100mList?[i] as num?)?.toDouble(),
            windSpeed120m: (windSpeed120mList?[i] as num?)?.toDouble(),
            windSpeed150m: (windSpeed150mList?[i] as num?)?.toDouble(),
            windSpeed180m: (windSpeed180mList?[i] as num?)?.toDouble(),
            windSpeed200m: (windSpeed200mList?[i] as num?)?.toDouble(),
          ),
        );
      }
    }

    return HourlyWeather(
      locationName: '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: json['timezone'] as String,
      hourlyForecasts: forecasts,
    );
  }

  HourlyWeather copyWith({
    String? locationName,
    List<HourlyForecast>? hourlyForecasts,
  }) {
    return HourlyWeather(
      locationName: locationName ?? this.locationName,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
      hourlyForecasts: hourlyForecasts ?? this.hourlyForecasts,
    );
  }

  @override
  String toString() {
    final hourlyString = hourlyForecasts.map((h) => '  - $h').join('\n');
    return '''
DailyWeather(
  locationName: '$locationName',
  latitude: $latitude, longitude: $longitude,
  hourlyForecasts: [
$hourlyString
  ]
)''';
  }
}

class HourlyForecast {
  final DateTime time;
  final double? temperature;
  final int? weatherCode;
  final double? apparentTemperature;
  final int? precipitationProbability;
  final double? precipitation;
  final double? rain;
  final int? cloudCover;
  final int? humidity;
  final double? windSpeed;
  final double? windGusts;
  final int? isDay;
  final double? sunshineDuration;
  final int? windDirection10m;
  final double? windSpeed20m;
  final double? windSpeed50m;
  final double? windSpeed80m;
  final double? windSpeed100m;
  final double? windSpeed120m;
  final double? windSpeed150m;
  final double? windSpeed180m;
  final double? windSpeed200m;
  final String? weatherIcon;

  HourlyForecast({
    required this.time,
    this.temperature,
    this.weatherCode,
    this.apparentTemperature,
    this.precipitationProbability,
    this.precipitation,
    this.rain,
    this.cloudCover,
    this.humidity,
    this.windSpeed,
    this.windGusts,
    this.isDay,
    this.sunshineDuration,
    this.windDirection10m,
    this.windSpeed20m,
    this.windSpeed50m,
    this.windSpeed80m,
    this.windSpeed100m,
    this.windSpeed120m,
    this.windSpeed150m,
    this.windSpeed180m,
    this.windSpeed200m,
    this.weatherIcon,
  });

  String get formattedTime => DateFormat('HH:mm').format(time);

  @override
  String toString() {
    return 'HourlyForecast(time: $formattedTime, temp: $temperature°C, feels: $apparentTemperature°C, rainProb: $precipitationProbability%, rain: $rain mm, clouds: $cloudCover%, wind: $windSpeed km/h, gusts: $windGusts km/h, isDay: $isDay, sunshine: $sunshineDuration s, windDir: $windDirection10m°)';
  }
}

class MultiModelWeather {
  final String locationName;
  final Map<String, DailyWeather> models;
  final double latitude;
  final double longitude;

  MultiModelWeather({
    required this.locationName,
    required this.models,
    required this.latitude,
    required this.longitude,
  });
}

class MultiModelHourlyWeather {
  final String locationName;
  final Map<String, HourlyWeather> models;
  final double latitude;
  final double longitude;

  MultiModelHourlyWeather({
    required this.locationName,
    required this.models,
    required this.latitude,
    required this.longitude,
  });
}

// Add to the bottom of weather_forecast_model.dart
void testDailyWeather() async {
  await initializeDateFormatting('fr_FR', null);

  final weatherService = WeatherRepository();
  const locationName = 'Metz';
  const lat = 49.0812;
  const lon = 6.7453;

  print("--- Testing getDailyWeatherForecast for '$locationName' ---");

  try {
    final dailyWeather = await weatherService.getHourlyWeatherForecast(
      latitude: lat,
      longitude: lon,
      locationName: locationName,
      model: 'best_match',
    );

    print("#### Daily Weather Result:\n${dailyWeather.toString()}");
    print("\nTotal hours: ${dailyWeather.hourlyForecasts.length}");

    if (dailyWeather.hourlyForecasts.isNotEmpty) {
      final firstHour = dailyWeather.hourlyForecasts.first;
      print("\n--- First hour data ---");
      print("Time: ${firstHour.formattedTime}");
      print("Temperature: ${firstHour.temperature}°C");
      print("Feels like: ${firstHour.apparentTemperature}°C");
      print("Rain probability: ${firstHour.precipitationProbability}%");
    }
  } catch (e) {
    print("An error occurred: $e");
  }
}

// Update main function to call testDailyWeather
void main() async {
  // ... existing test code ...

  // Add call to new test
  testDailyWeather();
}

/// A self-contained main function to test the model and service together.
/// You can run this file directly from your IDE to verify the logic.
void main2() async {
  // FIX: Initialize date formatting for the 'fr_FR' locale.
  // This must be done before any locale-specific date formatting is used.
  await initializeDateFormatting('fr_FR', null);

  // Setup
  final weatherService = WeatherRepository();
  const locationName = 'Saarbrücken-Ensheim';
  // Use a model that doesn't provide a full 16-day forecast to test the fix.
  // const selectedModel = 'meteofrance_seamless';
  const selectedModel = 'best_match';
  const lat = 49.21;
  const lon = 7.11;

  print(
    "--- Testing WeatherService -> WeatherForecast model parsing for '$locationName' ---",
  );

  try {
    // 1. Fetch the forecast using the service.
    final DailyWeather forecast = await weatherService.getWeatherForecast(
      latitude: lat,
      longitude: lon,
      model: selectedModel,
      locationName: locationName,
    );

    // 2. Print the final, populated object to verify all data was parsed correctly.
    print("#### Forecast Result:\n${forecast.toString()}");
    print("\nTotal forecast days found: ${forecast.dailyForecasts.length}");

    // 3. Verify a few specific fields from the new data.
    if (forecast.dailyForecasts.isNotEmpty) {
      print("\n--- Verification of first day's data ---");
      final firstDay = forecast.dailyForecasts.first;
      print("Max Temp: ${firstDay.temperatureMax}°C");
      print("Precipitation Sum: ${firstDay.precipitationSum} mm");
      print("Weather Code: ${firstDay.weatherCode}");
      print("Max Wind Speed: ${firstDay.windSpeedMax} km/h");
    }
  } catch (e) {
    print("An error occurred during the test: $e");
  }
}
