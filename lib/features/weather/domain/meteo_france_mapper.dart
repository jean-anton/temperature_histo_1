import 'package:temperature_histo_1/features/weather/domain/meteo_france_model.dart';
import 'package:temperature_histo_1/features/weather/domain/weather_model.dart';

class MeteoFranceMapper {
  static DailyWeather mapToDailyWeather(MeteoFranceForecast forecast) {
    return DailyWeather(
      locationName: forecast.position.name,
      model: 'MeteoFrance',
      latitude: forecast.position.lat,
      longitude: forecast.position.lon,
      timezone: forecast.position.timezone,
      dailyForecasts: forecast.dailyForecast.map((d) {
        return DailyForecast(
          date: d.date,
          temperatureMax: d.maxTemp ?? 0.0,
          temperatureMin: d.minTemp ?? 0.0,
          precipitationSum: d.precipitation24h,
          weatherIcon: d.weatherIcon, // Pass the icon string directly
          sunrise: d.sunrise != null
              ? DateTime.fromMillisecondsSinceEpoch(d.sunrise! * 1000)
              : null,
          sunset: d.sunset != null
              ? DateTime.fromMillisecondsSinceEpoch(d.sunset! * 1000)
              : null,
          // Map other fields if possible, or leave null
          weatherCode: _mapIconToCode(d.weatherIcon),
        );
      }).toList(),
    );
  }

  static HourlyWeather mapToHourlyWeather(MeteoFranceForecast forecast) {
    var previousHourlyForecastTime = forecast.forecast.first.date.subtract(
      const Duration(hours: 2),
    );
    //DateTime.fromMillisecondsSinceEpoch(forecast.forecast.first.dt * 1000);
    return HourlyWeather(
      locationName: forecast.position.name,
      latitude: forecast.position.lat,
      longitude: forecast.position.lon,
      timezone: forecast.position.timezone,
      hourlyForecasts: forecast.forecast
          .map((h) {
            final time = h.date;
            if (time.difference(previousHourlyForecastTime).inHours < 0) {
              return null;
            }
            previousHourlyForecastTime = time;
            // print(
            //     '#### CJG hourly.time: ${h.date}, weatherIcon: ${h.weatherIcon}, weatherCode: ${_mapIconToCode(h.weatherIcon)},${h.weatherDesc}  ');
            return HourlyForecast(
              time: h.date,
              temperature: h.temp ?? 0.0,
              apparentTemperature: h.windchill,
              precipitation: h.rain1h + (h.snow1h ?? 0.0),
              rain: h.rain1h,
              weatherIcon: h.weatherIcon,
              windSpeed: h.windSpeed,
              windGusts: h.windGust,
              windDirection10m: h.windDirection,
              humidity: h
                  .humidity, // Existing model doesn't have humidity in HourlyForecast?
              // Wait, HourlyForecast doesn't have humidity field in the file I read?
              // Let's check. It has cloudCover, precipitationProbability...
              // It does NOT have humidity.
              weatherCode: _mapIconToCode(h.weatherIcon),
            );
          })
          .whereType<HourlyForecast>()
          .toList(),
    );
  }

  static int _mapIconToCode1(String? icon) {
    if (icon == null) return 0;
    // Basic mapping to WMO codes to support existing logic if needed
    if (icon.contains('p1') || icon.contains('p2') || icon.contains('p4'))
      return 1; // Clear/Partly cloudy
    if (icon.contains('p3')) return 3; // Cloudy
    if (icon.contains('p6')) return 45; // Fog
    if (icon.contains('p13')) return 61; // Rain
    if (icon.contains('p14')) return 63; // Rain/Showers
    if (icon.contains('p24')) return 95; // Thunderstorm
    return 0;
  }


  static int _mapIconToCode(String? icon) {
  if (icon == null) return 0;

  switch (icon) {
    // Clear / Sunny
    case 'p1j':
    case 'p1n':
      return 0;
    case 'p1bisj':
    case 'p1bisn':
      return 1;

    // Partly cloudy / Variable
    case 'p2j':
    case 'p2n':
    case 'p2bisj':
    case 'p2bisn':
      return 2;

    // Cloudy / Overcast
    case 'p3j':
    case 'p3n':
    case 'p3bisj':
    case 'p3bisn':
    case 'p4j':
    case 'p4n':
      return 3;

    // Fog / Mist / Haze
    case 'p5j':
    case 'p5n':
    case 'p5bisn':
    case 'p6j':
    case 'p6n':
    case 'p7j':
    case 'p7n':
      return 45;

    // Light rain
    case 'p12j':
    case 'p12n':
    case 'p13j':
    case 'p13n':
    case 'p13terj':
    case 'p13tern':
      return 61;

    // Moderate rain
    case 'p14terj':
    case 'p14tern':
      return 63;

    // Heavy rain
    case 'p15j':
    case 'p15n':
      return 65;

    // Showers
    case 'p12bisj':
    case 'p12bisn':
      return 80;
    case 'p14bisj':
    case 'p14bisn':
      return 81;

    // Thunderstorms
    case 'p16bisj':
    case 'p16bisn':
    case 'p28n':
      return 95;

    // Snow
    case 'p18j':
    case 'p18n':
      return 71;
    case 'p19bisj':
      return 85;
    case 'p20bisj':
    case 'p20bisn':
      return 67;

    default:
      return 0;
  }
}

}
