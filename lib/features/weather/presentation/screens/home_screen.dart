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

    'meteofrance_seamless': 'ARPEGE',
    'icon_seamless': 'ICON/DWD',
    'meteo_france_api': 'MeteoFrance API',
  };

  // Display mode: 'daily' or 'hourly'
  String _displayMode = 'daily';
  String _selectedClimateLocation = '04336_Saarbrücken-Ensheim_1961_1990';
  String _selectedWeatherLocation = 'rosbruck_fr';
  String _selectedModel = 'best_match';
  DailyWeather? _forecast;
  HourlyWeather? _hourlyForecast;
  List<ClimateNormal> _climateNormals = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _showChart = true;
  bool _showWindInfo = true;

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
      _selectedClimateLocation =
          prefs.getString(_kSelectedClimateLocationKey) ??
          _selectedClimateLocation;
      _selectedWeatherLocation =
          prefs.getString(_kSelectedWeatherLocationKey) ??
          _selectedWeatherLocation;
      _selectedModel = prefs.getString(_kSelectedModelKey) ?? _selectedModel;
      _showWindInfo = prefs.getBool(_kShowWindInfoKey) ?? true;

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
          throw Exception('# CJG 362: Failed to fetch Météo-France forecast: $e');
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
      } else if (_displayMode == 'hourly') {
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
        final results = await Future.wait([
          _climateService.loadClimateNormals(climateInfo.assetPath),
          _weatherService.getWeatherForecast(
            latitude: weatherInfo.lat,
            longitude: weatherInfo.lon,
            model: _selectedModel,
            locationName: weatherInfo.displayName,
          ),
        ]);

        setState(() {
          _climateNormals = results[0] as List<ClimateNormal>;
          _forecast = results[1] as DailyWeather;
          _hourlyForecast = null;
          _isLoading = false;
        });
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
              'Affichage:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: true,
                  label: Text('Graphique'),
                  icon: Icon(Icons.bar_chart),
                ),
                ButtonSegment<bool>(
                  value: false,
                  label: Text('Tableau'),
                  icon: Icon(Icons.table_chart),
                ),
              ],
              selected: {_showChart},
              onSelectionChanged: (Set<bool> selection) {
                setState(() {
                  _showChart = selection.first;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Informations vent:',
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
            if (_showChart)
              WeatherChart2(
                forecast: _forecast,
                hourlyWeather: _hourlyForecast,
                climateNormals: _climateNormals,
                displayMode: _displayMode,
                showWindInfo: _showWindInfo,
              )
            else
              // TODO: Implement hourly table view
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
