class AppConstants {
  static const String weatherApiBaseUrl =
      'https://api.open-meteo.com/v1/forecast';

  // Weather Models
  static const String modelEcmwfIfs025 = 'ecmwf_ifs025';
  static const String modelMeteoFranceAromeSeamless =
      'meteofrance_arome_seamless';
  static const String modelMeteoFranceSeamless = 'meteofrance_seamless';
  static const String modelIconSeamless = 'icon_seamless';
  static const String modelGfsSeamless = 'gfs_seamless';
  static const String modelBestMatch = 'best_match';

  // Daily Parameters
  static const String defaultDailyParameters =
      'temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_hours,snowfall_sum,precipitation_probability_max,weathercode,cloudcover_mean,windspeed_10m_max,windgusts_10m_max,wind_direction_10m_dominant,sunrise,sunset';

  // Helper to get parameters for specific models
  static String getHourlyParameters(String model) {
    const baseParams =
        'temperature_2m,weather_code,apparent_temperature,'
        'precipitation_probability,precipitation,rain,'
        'cloud_cover,wind_speed_10m,windgusts_10m,'
        'is_day,sunshine_duration,wind_direction_10m';

    switch (model) {
      case modelEcmwfIfs025:
        return '$baseParams,windspeed_100m';

      case modelMeteoFranceAromeSeamless:
      case modelMeteoFranceSeamless:
        return '$baseParams,'
            'windspeed_20m,windspeed_50m,windspeed_80m,windspeed_100m,windspeed_120m,windspeed_150m,windspeed_180m,windspeed_200m';

      case modelIconSeamless:
        return '$baseParams,'
            'windspeed_80m,windspeed_120m,windspeed_180m';

      default:
        return baseParams;
    }
  }
}
