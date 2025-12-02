import 'package:intl/intl.dart';

class MeteoFranceForecast {
  final Position position;
  final int updatedOn;
  final List<MeteoFranceDailyForecast> dailyForecast;
  final List<MeteoFranceHourlyForecast> forecast;
  final List<MeteoFranceProbabilityForecast> probabilityForecast;

  MeteoFranceForecast({
    required this.position,
    required this.updatedOn,
    required this.dailyForecast,
    required this.forecast,
    required this.probabilityForecast,
  });

  factory MeteoFranceForecast.fromJson(Map<String, dynamic> json) {
    return MeteoFranceForecast(
      position: Position.fromJson(json['position']),
      updatedOn: json['updated_on'] as int,
      dailyForecast: (json['daily_forecast'] as List)
          .map((e) => MeteoFranceDailyForecast.fromJson(e))
          .toList(),
      forecast: (json['forecast'] as List)
          .map((e) => MeteoFranceHourlyForecast.fromJson(e))
          .toList(),
      probabilityForecast:
          (json['probability_forecast'] as List?)
              ?.map((e) => MeteoFranceProbabilityForecast.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Position {
  final double lat;
  final double lon;
  final int alti;
  final String name;
  final String country;
  final String dept;
  final String timezone;

  Position({
    required this.lat,
    required this.lon,
    required this.alti,
    required this.name,
    required this.country,
    required this.dept,
    required this.timezone,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      alti: json['alti'] as int,
      name: json['name'] as String,
      country: json['country'] as String,
      dept: json['dept'] as String,
      timezone: json['timezone'] as String,
    );
  }
}

class MeteoFranceDailyForecast {
  final int dt;
  final double? minTemp;
  final double? maxTemp;
  final int? minHumidity;
  final int? maxHumidity;
  final double precipitation24h;
  final int? uv;
  final String? weatherIcon;
  final String? weatherDesc;
  final int? sunrise;
  final int? sunset;

  MeteoFranceDailyForecast({
    required this.dt,
    this.minTemp,
    this.maxTemp,
    this.minHumidity,
    this.maxHumidity,
    required this.precipitation24h,
    this.uv,
    this.weatherIcon,
    this.weatherDesc,
    this.sunrise,
    this.sunset,
  });

  factory MeteoFranceDailyForecast.fromJson(Map<String, dynamic> json) {
    return MeteoFranceDailyForecast(
      dt: json['dt'] as int,
      minTemp: (json['T'] != null)
          ? (json['T']['min'] as num?)?.toDouble()
          : null,
      maxTemp: (json['T'] != null)
          ? (json['T']['max'] as num?)?.toDouble()
          : null,
      minHumidity: (json['humidity'] != null)
          ? json['humidity']['min'] as int?
          : null,
      maxHumidity: (json['humidity'] != null)
          ? json['humidity']['max'] as int?
          : null,
      precipitation24h: (json['precipitation'] != null)
          ? (json['precipitation']['24h'] as num?)?.toDouble() ?? 0.0
          : 0.0,
      uv: json['uv'] as int?,
      weatherIcon: (json['weather12H'] != null)
          ? json['weather12H']['icon'] as String?
          : null,
      weatherDesc: (json['weather12H'] != null)
          ? json['weather12H']['desc'] as String?
          : null,
      sunrise: (json['sun'] != null) ? json['sun']['rise'] as int? : null,
      sunset: (json['sun'] != null) ? json['sun']['set'] as int? : null,
    );
  }

  DateTime get date => DateTime.fromMillisecondsSinceEpoch(dt * 1000);
  String get formattedDate => DateFormat('dd/MM').format(date);
}

class MeteoFranceHourlyForecast {
  final int dt;
  final double? temp;
  final double? windchill;
  final int? humidity;
  final double rain1h;
  final double? snow1h;
  final int? clouds;
  final String? weatherIcon;
  final String? weatherDesc;
  final double? windSpeed;
  final double? windGust;
  final int? windDirection;

  MeteoFranceHourlyForecast({
    required this.dt,
    this.temp,
    this.windchill,
    this.humidity,
    required this.rain1h,
    this.snow1h,
    this.clouds,
    this.weatherIcon,
    this.weatherDesc,
    this.windSpeed,
    this.windGust,
    this.windDirection,
  });

  factory MeteoFranceHourlyForecast.fromJson(Map<String, dynamic> json) {
    return MeteoFranceHourlyForecast(
      dt: json['dt'] as int,
      temp: (json['T'] != null)
          ? (json['T']['value'] as num?)?.toDouble()
          : null,
      windchill: (json['T'] != null)
          ? (json['T']['windchill'] as num?)?.toDouble()
          : null,
      humidity: json['humidity'] as int?,
      rain1h: (json['rain'] != null)
          ? (json['rain']['1h'] as num?)?.toDouble() ?? 0.0
          : 0.0,
      snow1h: (json['snow'] != null)
          ? (json['snow']['1h'] as num?)?.toDouble()
          : null,
      clouds: json['clouds'] as int?,
      weatherIcon: (json['weather'] != null)
          ? json['weather']['icon'] as String?
          : null,
      weatherDesc: (json['weather'] != null)
          ? json['weather']['desc'] as String?
          : null,
      windSpeed: (json['wind'] != null)
          ? (json['wind']['speed'] as num?)?.toDouble()
          : null,
      windGust: (json['wind'] != null)
          ? (json['wind']['gust'] as num?)?.toDouble()
          : null,
      windDirection: (json['wind'] != null)
          ? json['wind']['direction'] as int?
          : null,
    );
  }

  DateTime get date => DateTime.fromMillisecondsSinceEpoch(dt * 1000);
  String get formattedTime => DateFormat('HH:mm').format(date);
}

class MeteoFranceProbabilityForecast {
  final int dt;
  final int? rain3h;
  final int? rain6h;

  MeteoFranceProbabilityForecast({required this.dt, this.rain3h, this.rain6h});

  factory MeteoFranceProbabilityForecast.fromJson(Map<String, dynamic> json) {
    return MeteoFranceProbabilityForecast(
      dt: json['dt'] as int,
      rain3h: json['rain']['3h'] as int?,
      rain6h: json['rain']['6h'] as int?,
    );
  }
}
