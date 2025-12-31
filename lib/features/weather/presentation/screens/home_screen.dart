import 'package:flutter/material.dart';

import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:temperature_histo_1/main.dart';

import 'package:temperature_histo_1/features/climate/domain/climate_model.dart';
import 'package:temperature_histo_1/features/weather/domain/weather_model.dart';
import 'package:temperature_histo_1/features/locations/domain/location_model.dart';
import 'package:temperature_histo_1/features/climate/data/climate_repository.dart';
import 'package:temperature_histo_1/features/weather/data/weather_repository.dart';
import 'package:temperature_histo_1/features/locations/data/location_repository.dart';
import 'package:temperature_histo_1/core/services/geolocation_service.dart';
import 'package:temperature_histo_1/core/widgets/error_display_widget.dart';
import 'package:temperature_histo_1/core/widgets/loading_indicator_widget.dart';
import 'package:temperature_histo_1/features/weather/presentation/widgets/weather_chart_widget.dart';
import 'package:temperature_histo_1/features/weather/presentation/widgets/weather_table_widget.dart';
import 'package:temperature_histo_1/features/locations/presentation/widgets/city_management_dialog.dart';
import 'package:temperature_histo_1/features/weather/presentation/widgets/utils/weather_tooltip.dart';
import 'package:temperature_histo_1/features/weather/domain/meteo_france_mapper.dart';
import 'package:temperature_histo_1/features/weather/domain/weathercode_calculator.dart';
import 'package:temperature_histo_1/features/weather/presentation/widgets/vent_table_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherRepository _weatherService = WeatherRepository();
  final ClimateRepository _climateService = ClimateRepository();
  //late final GeolocationService _geolocationService = GeoapifyGeolocationService(geoapifyApiKey);
  late final GeolocationService _geolocationService =
      FallbackGeolocationService([
        // GeoapifyGeolocationService(geoapifyApiKey),
        OpenMeteoGeolocationService(),
        PhotonGeolocationService(),
      ]);
  late final LocationRepository _locationService = LocationRepository(
    _geolocationService,
  );

  static const String _kSelectedClimateLocationKey = 'selectedClimateLocation';
  static const String _kSelectedWeatherLocationKey = 'selectedWeatherLocation';
  static const String _kSelectedModelKey = 'selectedModel';
  static const String _kDisplayModeKey = 'displayMode';
  static const String _kShowWindInfoKey = 'showWindInfo';
  static const String _kShowExtendedWindInfoKey = 'showExtendedWindInfo';
  static const String _kMaxGustSpeedKey = 'maxGustSpeed';
  static const String _kMaxPrecipitationProbabilityKey =
      'maxPrecipitationProbability';

  final Map<String, ClimateLocationInfo> _climateLocationData = {
    '00460_Berus_1961_1990': const ClimateLocationInfo(
      displayName: 'Berus (DE)',
      assetPath: 'assets/data/climatologie_00460_Berus_1961_1990.csv',
      lat: 49.2641,
      lon: 6.6868,
      startYear: 1961,
      endYear: 1990,
    ),
    '04336_Saarbrücken-Ensheim_1961_1990': const ClimateLocationInfo(
      displayName: 'Saarbrücken-Ensheim (DE)',
      assetPath:
          'assets/data/climatologie_04336_Saarbrücken-Ensheim_1961_1990.csv',
      lat: 49.2128,
      lon: 7.1077,
      startYear: 1961,
      endYear: 1990,
    ),
    '04339_Saarbrücken-Sankt-Johann_1961_1990': const ClimateLocationInfo(
      displayName: 'Saarbrücken-St. Johann (DE)',
      assetPath:
          'assets/data/climatologie_04339_Saarbrücken-Sankt-Johann_1961_1990.csv',
      lat: 49.2231,
      lon: 7.0168,
      startYear: 1961,
      endYear: 1990,
    ),
    '05244_Völklingen-Stadt_1961_1982': const ClimateLocationInfo(
      displayName: 'Völklingen-Stadt (DE)',
      assetPath:
          'assets/data/climatologie_05244_Völklingen-Stadt_1961_1982.csv',
      lat: 49.25,
      lon: 6.85,
      startYear: 1961,
      endYear: 1982,
    ),
    '06217_Saarbrücken-Burbach_2001_2010': const ClimateLocationInfo(
      displayName: 'Saarbrücken-Burbach (DE)',
      assetPath:
          'assets/data/climatologie_06217_Saarbrücken-Burbach_2001_2010.csv',
      lat: 49.2406,
      lon: 6.9351,
      startYear: 2001,
      endYear: 2010,
    ),
    '01072_Bad-Dürkheim_1961_1990': const ClimateLocationInfo(
      displayName: 'Bad Dürkheim',
      assetPath: 'assets/data/climatologie_01072_Bad-Dürkheim_1961_1990.csv',
      lat: 49.4719,
      lon: 8.1929,
      startYear: 1961,
      endYear: 1990,
    ),
  };

  Map<String, WeatherLocationInfo> _weatherLocationData = {};
  final Map<String, String> _models = {
    'best_match': 'Best Match',
    'ecmwf_ifs025': 'ECMWF IFS',
    'gfs_seamless': 'GFS',

    'meteofrance_arome_seamless': 'Météo-France (AROME)',
    'meteofrance_seamless': 'ARPEGE',
    'icon_seamless': 'ICON/DWD',
    'meteo_france_api': 'MeteoFrance API',
  };

  // Display mode: 'daily' or 'hourly'
  String _displayMode = 'daily';
  DisplayType _displayType = DisplayType.graphique;
  String _selectedClimateLocation = '04336_Saarbrücken-Ensheim_1961_1990';
  String _selectedWeatherLocation = 'rosbruck_fr';
  String _selectedModel = 'best_match';
  DailyWeather? _forecast;
  HourlyWeather? _hourlyForecast;
  List<ClimateNormal> _climateNormals = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _showWindInfo = true;
  bool _showExtendedWindInfo = false;
  double _maxGustSpeed = 30.0;
  int _maxPrecipitationProbability = 20;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // First load locations, then preferences and data
    final weatherLocations = await _locationService.loadWeatherLocations();
    setState(() {
      _weatherLocationData = weatherLocations;
    });
    await _loadPreferencesAndData();
  }

  Future<void> _loadPreferencesAndData() async {
    await _loadPreferences();
    await _loadData();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _displayMode = prefs.getString(_kDisplayModeKey) ?? 'daily';
      final displayTypeIndex =
          prefs.getInt(_kDisplayModeKey + '_type') ??
          DisplayType.graphique.index;
      _displayType = DisplayType
          .values[displayTypeIndex.clamp(0, DisplayType.values.length - 1)];
      _selectedClimateLocation =
          prefs.getString(_kSelectedClimateLocationKey) ??
          _selectedClimateLocation;
      _selectedWeatherLocation =
          prefs.getString(_kSelectedWeatherLocationKey) ??
          _selectedWeatherLocation;
      _selectedModel = prefs.getString(_kSelectedModelKey) ?? _selectedModel;
      _showWindInfo = prefs.getBool(_kShowWindInfoKey) ?? true;
      _showExtendedWindInfo = prefs.getBool(_kShowExtendedWindInfoKey) ?? false;
      _maxGustSpeed = prefs.getDouble(_kMaxGustSpeedKey) ?? 30.0;
      _maxPrecipitationProbability =
          prefs.getInt(_kMaxPrecipitationProbabilityKey) ?? 20;

      if (!_climateLocationData.containsKey(_selectedClimateLocation)) {
        _selectedClimateLocation = _climateLocationData.keys.first;
      }
      if (_weatherLocationData.isNotEmpty &&
          !_weatherLocationData.containsKey(_selectedWeatherLocation)) {
        _selectedWeatherLocation = _weatherLocationData.keys.first;
      }
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDisplayModeKey, _displayMode);
    await prefs.setInt(_kDisplayModeKey + '_type', _displayType.index);
    await prefs.setString(
      _kSelectedClimateLocationKey,
      _selectedClimateLocation,
    );
    await prefs.setString(
      _kSelectedWeatherLocationKey,
      _selectedWeatherLocation,
    );
    await prefs.setString(_kSelectedModelKey, _selectedModel);
    await prefs.setBool(_kShowWindInfoKey, _showWindInfo);
    await prefs.setBool(_kShowExtendedWindInfoKey, _showExtendedWindInfo);
    await prefs.setDouble(_kMaxGustSpeedKey, _maxGustSpeed);
    await prefs.setInt(
      _kMaxPrecipitationProbabilityKey,
      _maxPrecipitationProbability,
    );
  }

  Future<void> _loadData() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // Check if location data is available
      final climateInfo = _climateLocationData[_selectedClimateLocation];
      final weatherInfo = _weatherLocationData[_selectedWeatherLocation];

      if (climateInfo == null) {
        throw Exception(
          'Climate location data not found for key: $_selectedClimateLocation',
        );
      }

      if (weatherInfo == null) {
        throw Exception(
          'Weather location data not found for key: $_selectedWeatherLocation',
        );
      }

      if (_selectedModel == 'meteo_france_api') {
        late final meteoFranceForecast;
        try {
          meteoFranceForecast = await _weatherService.getMeteoFranceForecast(
            latitude: weatherInfo.lat,
            longitude: weatherInfo.lon,
          );
        } catch (e) {
          throw Exception(
            '# CJG 362: Failed to fetch Météo-France forecast: $e',
          );
        }

        setState(() {
          _climateNormals =
              []; // Or fetch if available, but maybe not compatible with MeteoFrance dates?
          // Actually climate normals depend on location, not weather model. So we should still load them.
        });

        // We need to load climate normals anyway
        final normals = await _climateService.loadClimateNormals(
          climateInfo.assetPath,
        );

        setState(() {
          _climateNormals = normals;
          _forecast = MeteoFranceMapper.mapToDailyWeather(meteoFranceForecast);
          _hourlyForecast = MeteoFranceMapper.mapToHourlyWeather(
            meteoFranceForecast,
          );
          _isLoading = false;
        });
      } else if (_displayMode == 'hourly' ||
          _displayType == DisplayType.vent ||
          _displayType == DisplayType.ventDay ||
          _displayType == DisplayType.ventTable) {
        final results = await Future.wait([
          _climateService.loadClimateNormals(climateInfo.assetPath),
          _weatherService.getHourlyWeatherForecast(
            latitude: weatherInfo.lat,
            longitude: weatherInfo.lon,
            locationName: weatherInfo.displayName,
            model: _selectedModel,
          ),
          _weatherService.getWeatherForecast(
            latitude: weatherInfo.lat,
            longitude: weatherInfo.lon,
            model: _selectedModel,
            locationName: weatherInfo.displayName,
          ),
        ]);

        setState(() {
          _climateNormals = results[0] as List<ClimateNormal>;
          _hourlyForecast = results[1] as HourlyWeather;
          _forecast = results[2] as DailyWeather;
          _isLoading = false;
        });
      } else {
        // Fetch daily, hourly, and climate data in parallel for daytime weathercode calculation
        final results = await Future.wait([
          _climateService.loadClimateNormals(climateInfo.assetPath),
          _weatherService.getWeatherForecast(
            latitude: weatherInfo.lat,
            longitude: weatherInfo.lon,
            model: _selectedModel,
            locationName: weatherInfo.displayName,
          ),
          _weatherService.getHourlyWeatherForecast(
            latitude: weatherInfo.lat,
            longitude: weatherInfo.lon,
            model: _selectedModel,
            locationName: weatherInfo.displayName,
          ),
        ]);

        final climateNormals = results[0] as List<ClimateNormal>;
        final dailyWeather = results[1] as DailyWeather;
        final hourlyWeather = results[2] as HourlyWeather;

        // Calculate daytime weathercodes for each daily forecast
        final enhancedForecasts = dailyWeather.dailyForecasts.map((daily) {
          final result = WeathercodeCalculator.calculateDaytimeWeathercode(
            hourlyForecasts: hourlyWeather.hourlyForecasts,
            targetDate: daily.date,
          );

          return DailyForecast(
            date: daily.date,
            temperatureMax: daily.temperatureMax,
            temperatureMin: daily.temperatureMin,
            precipitationSum: daily.precipitationSum,
            precipitationHours: daily.precipitationHours,
            snowfallSum: daily.snowfallSum,
            precipitationProbabilityMax: daily.precipitationProbabilityMax,
            weatherCode: daily.weatherCode,
            weatherCodeDaytime: result.calculatedCode,
            daytimeHoursAnalyzed: result.hoursAnalyzed,
            cloudCoverMean: daily.cloudCoverMean,
            windSpeedMax: daily.windSpeedMax,
            windGustsMax: daily.windGustsMax,
            windDirection10mDominant: daily.windDirection10mDominant,
            sunrise: daily.sunrise,
            sunset: daily.sunset,
            weatherIcon: daily.weatherIcon,
          );
        }).toList();

        setState(() {
          _climateNormals = climateNormals;
          _forecast = DailyWeather(
            locationName: dailyWeather.locationName,
            model: dailyWeather.model,
            dailyForecasts: enhancedForecasts,
            latitude: dailyWeather.latitude,
            longitude: dailyWeather.longitude,
            timezone: dailyWeather.timezone,
          );
          _hourlyForecast = null;
          _isLoading = false;
        });

        // Log the results
        print('### Daytime weathercode calculation completed for daily mode:');
        for (final forecast in enhancedForecasts.take(5)) {
          print(
            '  ${forecast.formattedDate}: Original=${forecast.weatherCode}, '
            'Daytime=${forecast.weatherCodeDaytime} (${forecast.daytimeHoursAnalyzed}h)',
          );
        }
      }
    } catch (e) {
      setState(() {
        print("### CJG 361: Error loading data: $e");
        _errorMessage =
            'Erreur lors du chargement des données: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _onClimateLocationChanged(String? newLocation) {
    if (newLocation != null && newLocation != _selectedClimateLocation) {
      setState(() {
        _selectedClimateLocation = newLocation;
      });
      _savePreferences();
      _loadData();
    }
  }

  void _onWeatherLocationChanged(String? newLocationKey) {
    if (newLocationKey != null && newLocationKey != _selectedWeatherLocation) {
      final newWeatherLocationInfo = _weatherLocationData[newLocationKey];
      if (newWeatherLocationInfo == null) return;

      String nearestClimateKey = '';
      double minDistance = double.infinity;
      const distance = Distance();
      final newWeatherLatLng = LatLng(
        newWeatherLocationInfo.lat,
        newWeatherLocationInfo.lon,
      );

      _climateLocationData.forEach((key, climateInfo) {
        final climateLatLng = LatLng(climateInfo.lat, climateInfo.lon);
        final currentDistance = distance(newWeatherLatLng, climateLatLng);
        if (currentDistance < minDistance) {
          minDistance = currentDistance;
          nearestClimateKey = key;
        }
      });

      setState(() {
        _selectedWeatherLocation = newLocationKey;
        if (nearestClimateKey.isNotEmpty) {
          _selectedClimateLocation = nearestClimateKey;
        }
      });

      _savePreferences();
      _loadData();
    }
  }

  void _onModelChanged(String? newModel) {
    if (newModel != null && newModel != _selectedModel) {
      setState(() {
        _selectedModel = newModel;
      });
      _savePreferences();
      _loadData();
    }
  }

  void _onDisplayModeChanged(String mode) {
    if (mode != _displayMode) {
      setState(() {
        _displayMode = mode;
      });
      _savePreferences();
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // Dismiss tooltips when tapped anywhere in the UI
          WeatherTooltip.removeTooltip();
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.1),
                Colors.white,
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_isLoading)
                  const LoadingIndicator()
                else if (_errorMessage != null)
                  ErrorDisplay(message: _errorMessage!)
                else if (_forecast != null || _hourlyForecast != null)
                  _buildWeatherDisplay(),
                _buildControlPanel(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    final selectedWeatherInfo = _weatherLocationData[_selectedWeatherLocation];

    const isRunningWithWasm = bool.fromEnvironment('dart.tool.dart2wasm');
    print('Running with Wasm: $isRunningWithWasm');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<String>(
                segments: _models.entries.map((entry) {
                  return ButtonSegment<String>(
                    value: entry.key,
                    label: Text(entry.value),
                  );
                }).toList(),
                selected: {_selectedModel},
                onSelectionChanged: (Set<String> newSelection) {
                  _onModelChanged(newSelection.first);
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Paramètres',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mode d\'affichage:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment<String>(
                  value: 'daily',
                  label: Text('Journalier'),
                ),
                ButtonSegment<String>(value: 'hourly', label: Text('Horaire')),
              ],
              selected: {_displayMode},
              onSelectionChanged: (Set<String> selection) {
                _onDisplayModeChanged(selection.first);
              },
            ),

            const SizedBox(height: 16),
            const Text(
              'Affichage:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<DisplayType>(
                segments: [
                  ButtonSegment<DisplayType>(
                    value: DisplayType.graphique,
                    label: const Text('Graphique'),
                    icon: const Icon(Icons.bar_chart),
                  ),
                  ButtonSegment<DisplayType>(
                    value: DisplayType.tableau,
                    label: const Text('Tableau'),
                    icon: const Icon(Icons.table_chart),
                  ),
                  ButtonSegment<DisplayType>(
                    value: DisplayType.vent,
                    label: const Text('Vent'),
                    icon: const Icon(Icons.air),
                  ),
                  ButtonSegment<DisplayType>(
                    enabled: true,
                    value: DisplayType.ventDay,
                    label: const Text('Vent Jour'),
                    icon: const Icon(Icons.wb_sunny),
                  ),
                  ButtonSegment<DisplayType>(
                    value: DisplayType.ventTable,
                    label: const Text('Table Vent'),
                    icon: const Icon(Icons.table_rows),
                  ),
                ],
                selected: {_displayType},
                onSelectionChanged: (Set<DisplayType> selection) {
                  setState(() {
                    _displayType = selection.first;
                    _savePreferences();
                    if ((_displayType == DisplayType.vent ||
                            _displayType == DisplayType.ventDay ||
                            _displayType == DisplayType.ventTable) &&
                        _hourlyForecast == null) {
                      _loadData();
                    }
                  });
                },
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'Lieu (Prévisions météo):',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedWeatherLocation,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: _weatherLocationData.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value.formattedLocation),
                );
              }).toList(),
              onChanged: _onWeatherLocationChanged,
            ),
            const SizedBox(height: 16),
            const Text(
              'Gestion des villes:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CityManagementDialog(
                      weatherLocations: _weatherLocationData,
                      locationService: _locationService,
                      selectedWeatherLocation: _selectedWeatherLocation,
                      onLocationChanged: _onWeatherLocationChanged,
                      onLocationsUpdated: () async {
                        final weatherLocations = await _locationService
                            .loadWeatherLocations();
                        setState(() {
                          _weatherLocationData = weatherLocations;
                        });
                      },
                    );
                  },
                );
              },
              icon: const Icon(Icons.location_city),
              label: const Text('Gérer les villes'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Station de référence (Données climatiques):',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedClimateLocation,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: _buildSortedClimateLocationItems(selectedWeatherInfo),
              onChanged: _onClimateLocationChanged,
            ),

            const SizedBox(height: 16),
            const Text(
              'Informations vent (km/h):',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: true,
                  label: Text('Afficher'),
                  icon: Icon(Icons.air),
                ),
                ButtonSegment<bool>(
                  value: false,
                  label: Text('Masquer'),
                  icon: Icon(Icons.air_outlined),
                ),
              ],
              selected: {_showWindInfo},
              onSelectionChanged: (Set<bool> selection) {
                setState(() {
                  _showWindInfo = selection.first;
                  _savePreferences();
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Wind Info étendue (km/h):',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: true,
                  label: Text('Oui'),
                  icon: Icon(Icons.add_chart),
                ),
                ButtonSegment<bool>(
                  value: false,
                  label: Text('Non'),
                  icon: Icon(Icons.remove_circle_outline),
                ),
              ],
              selected: {_showExtendedWindInfo},
              onSelectionChanged: (Set<bool> selection) {
                setState(() {
                  _showExtendedWindInfo = selection.first;
                  _savePreferences();
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Filtres Table Vent:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Rafales max (km/h):'),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<double>(
                        value: _maxGustSpeed,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items:
                            [
                                  5.0,
                                  10.0,
                                  15.0,
                                  20.0,
                                  25.0,
                                  30.0,
                                  35.0,
                                  40.0,
                                  45.0,
                                  50.0,
                                  55.0,
                                  60.0,
                                  65.0,
                                  70.0,
                                  75.0,
                                  80.0,
                                  85.0,
                                  90.0,
                                  95.0,
                                  100.0,
                                ]
                                .map(
                                  (value) => DropdownMenuItem<double>(
                                    value: value,
                                    child: Text(value.toStringAsFixed(0)),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _maxGustSpeed = value;
                              _savePreferences();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Précipitations max (%):'),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<int>(
                        value: _maxPrecipitationProbability,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: [0, 10, 20, 30, 40, 50]
                            .map(
                              (value) => DropdownMenuItem<int>(
                                value: value,
                                child: Text('$value%'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _maxPrecipitationProbability = value;
                              _savePreferences();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "version: $VERSION, main: $mainFileName\n Running with Wasm: $isRunningWithWasm",
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildSortedClimateLocationItems(
    WeatherLocationInfo? selectedWeatherInfo,
  ) {
    if (selectedWeatherInfo == null) {
      return _climateLocationData.entries.map((entry) {
        final info = entry.value;
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(
            '${info.displayName} (${info.startYear}-${info.endYear})',
          ),
        );
      }).toList();
    }

    const distance = Distance();
    final weatherLatLng = LatLng(
      selectedWeatherInfo.lat,
      selectedWeatherInfo.lon,
    );

    var climateItemsWithDistance = _climateLocationData.entries.map((entry) {
      final climateLatLng = LatLng(entry.value.lat, entry.value.lon);
      final distanceInMeters = distance(weatherLatLng, climateLatLng);
      return (key: entry.key, info: entry.value, distance: distanceInMeters);
    }).toList();

    climateItemsWithDistance.sort((a, b) => a.distance.compareTo(b.distance));

    return climateItemsWithDistance.map((item) {
      final distanceInKm = (item.distance / 1000).toStringAsFixed(1);
      final distanceText = ' • $distanceInKm km';

      return DropdownMenuItem<String>(
        value: item.key,
        child: Text(
          '${item.info.displayName} (${item.info.startYear}-${item.info.endYear})$distanceText',
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList();
  }

  Widget _buildWeatherDisplay() {
    final weatherInfo = _weatherLocationData[_selectedWeatherLocation];
    final climateInfo = _climateLocationData[_selectedClimateLocation];

    if (weatherInfo == null || climateInfo == null) {
      return const ErrorDisplay(message: "Location information is missing.");
    }

    const distance = Distance();
    final meters = distance(
      LatLng(weatherInfo.lat, weatherInfo.lon),
      LatLng(climateInfo.lat, climateInfo.lon),
    );
    final distanceInKm = (meters / 1000).toStringAsFixed(1);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  weatherInfo.formattedLocation,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Mode: ${_displayMode == 'daily' ? _models[_selectedModel] : 'Horaire'}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                "Réf. climat: ${climateInfo.displayName} (${climateInfo.startYear}-${climateInfo.endYear}) • $distanceInKm km",
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ),
            const SizedBox(height: 8),
            if (_displayType != DisplayType.tableau &&
                _displayType != DisplayType.ventTable)
              WeatherChart2(
                forecast: _forecast,
                hourlyWeather: _hourlyForecast,
                climateNormals: _climateNormals,
                displayMode: _displayMode,
                displayType: _displayType,
                showWindInfo: _showWindInfo,
                showExtendedWindInfo: _showExtendedWindInfo,
              )
            else if (_displayType == DisplayType.ventTable)
              // Display ventTable view
              _hourlyForecast != null && _forecast != null
                  ? VentTableWidget(
                      hourlyWeather: _hourlyForecast!,
                      dailyWeather: _forecast!,
                      maxGustSpeed: _maxGustSpeed,
                      maxPrecipitationProbability: _maxPrecipitationProbability,
                    )
                  : const Center(child: Text('Tableau Vent non disponible'))
            else
              // Display normal table view
              _displayMode == 'daily'
                  ? WeatherTable(
                      forecast: _forecast!,
                      climateNormals: _climateNormals,
                    )
                  : const Center(child: Text('Tableau horaire non implémenté')),
          ],
        ),
      ),
    );
  }
}
