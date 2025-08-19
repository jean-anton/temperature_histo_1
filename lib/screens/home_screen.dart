import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../models/climate_normal_model.dart';
import '../models/weather_forecast_model.dart';
import '../services/climate_data_service.dart';
import '../services/weather_service.dart';
import '../widgets/error_display_widget.dart';
import '../widgets/loading_indicator_widget.dart';
import '../widgets/weather_chart_widget_refactored.dart';
import '../widgets/weather_table_widget.dart';

class ClimateLocationInfo {
  final String displayName;
  final String assetPath;
  final double lat;
  final double lon;
  final int startYear;
  final int endYear;

  const ClimateLocationInfo({
    required this.displayName,
    required this.assetPath,
    required this.lat,
    required this.lon,
    required this.startYear,
    required this.endYear,
  });
}

class WeatherLocationInfo {
  final String displayName;
  final double lat;
  final double lon;

  const WeatherLocationInfo({
    required this.displayName,
    required this.lat,
    required this.lon,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final ClimateDataService _climateService = ClimateDataService();

  static const String _kSelectedClimateLocationKey = 'selectedClimateLocation';
  static const String _kSelectedWeatherLocationKey = 'selectedWeatherLocation';
  static const String _kSelectedModelKey = 'selectedModel';
  static const String _kDisplayModeKey = 'displayMode';

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

  late final Map<String, WeatherLocationInfo> _weatherLocationData;
  final Map<String, String> _models = {
    'best_match': 'Best Match',
    'ecmwf_ifs025': 'ECMWF IFS',
    'gfs_seamless': 'GFS',
    'meteofrance_seamless': 'ARPEGE',
    'icon_seamless': 'ICON/DWD',
  };

  // Display mode: 'daily' or 'hourly'
  String _displayMode = 'daily';
  String _selectedClimateLocation = '04336_Saarbrücken-Ensheim_1961_1990';
  String _selectedWeatherLocation = 'rosbruck_fr';
  String _selectedModel = 'best_match';
  WeatherForecast? _forecast;
  DailyWeather? _hourlyForecast;
  List<ClimateNormal> _climateNormals = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _showChart = true;

  @override
  void initState() {
    super.initState();
    _initializeLocations();
    _loadPreferencesAndData();
  }

  void _initializeLocations() {
    final weatherLocations = <String, WeatherLocationInfo>{
      'rosbruck_fr': const WeatherLocationInfo(
        displayName: 'Rosbruck',
        lat: 49.15,
        lon: 6.85,
      ),
      'lachambre_fr': const WeatherLocationInfo(
        displayName: 'Lachambre',
        lat: 49.13,
        lon: 6.78,
      ),
      'bad_duerkheim_de': const WeatherLocationInfo(
        displayName: 'Bad Dürkheim',
        lat: 49.4719,
        lon: 8.1929,
      ),
    };

    _weatherLocationData = weatherLocations;
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

      if (!_climateLocationData.containsKey(_selectedClimateLocation)) {
        _selectedClimateLocation = _climateLocationData.keys.first;
      }
      if (!_weatherLocationData.containsKey(_selectedWeatherLocation)) {
        _selectedWeatherLocation = _weatherLocationData.keys.first;
      }
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDisplayModeKey, _displayMode);
    await prefs.setString(
        _kSelectedClimateLocationKey, _selectedClimateLocation);
    await prefs.setString(
        _kSelectedWeatherLocationKey, _selectedWeatherLocation);
    await prefs.setString(_kSelectedModelKey, _selectedModel);
  }

  Future<void> _loadData() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final climateInfo = _climateLocationData[_selectedClimateLocation]!;
      final weatherInfo = _weatherLocationData[_selectedWeatherLocation]!;

      if (_displayMode == 'hourly') {
        final results = await Future.wait([
          _climateService.loadClimateNormals(climateInfo.assetPath),
          _weatherService.getDailyWeatherForecast(
            latitude: weatherInfo.lat,
            longitude: weatherInfo.lon,
            locationName: weatherInfo.displayName,
            model: _selectedModel,
          ),
        ]);

        setState(() {
          _climateNormals = results[0] as List<ClimateNormal>;
          _hourlyForecast = results[1] as DailyWeather;
          _forecast = null;
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
          _forecast = results[1] as WeatherForecast;
          _hourlyForecast = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
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
      final newWeatherLatLng =
      LatLng(newWeatherLocationInfo.lat, newWeatherLocationInfo.lon);

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
      body: Container(
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
    );
  }

  Widget _buildControlPanel() {
    final selectedWeatherInfo = _weatherLocationData[_selectedWeatherLocation];

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
            const Text('Mode d\'affichage:',
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment<String>(
                  value: 'daily',
                  label: Text('Journalier'),
                ),
                ButtonSegment<String>(
                  value: 'hourly',
                  label: Text('Horaire'),
                ),
              ],
              selected: {_displayMode},
              onSelectionChanged: (Set<String> selection) {
                _onDisplayModeChanged(selection.first);
              },
            ),
            const SizedBox(height: 16),
            const Text('Lieu (Prévisions météo):',
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedWeatherLocation,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _weatherLocationData.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value.displayName),
                );
              }).toList(),
              onChanged: _onWeatherLocationChanged,
            ),
            const SizedBox(height: 16),
            const Text('Station de référence (Données climatiques):',
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedClimateLocation,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _buildSortedClimateLocationItems(selectedWeatherInfo),
              onChanged: _onClimateLocationChanged,
            ),
            const SizedBox(height: 16),
            const Text('Affichage:',
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                    value: true,
                    label: Text('Graphique'),
                    icon: Icon(Icons.bar_chart)),
                ButtonSegment<bool>(
                    value: false,
                    label: Text('Tableau'),
                    icon: Icon(Icons.table_chart)),
              ],
              selected: {_showChart},
              onSelectionChanged: (Set<bool> selection) {
                setState(() {
                  _showChart = selection.first;
                });
              },
            ),
            const SizedBox(height: 16),
            Text("version: $VERSION, main: $mainFileName"),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildSortedClimateLocationItems(
      WeatherLocationInfo? selectedWeatherInfo) {
    if (selectedWeatherInfo == null) {
      return _climateLocationData.entries.map((entry) {
        final info = entry.value;
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(
              '${info.displayName} (${info.startYear}-${info.endYear})'),
        );
      }).toList();
    }

    const distance = Distance();
    final weatherLatLng =
    LatLng(selectedWeatherInfo.lat, selectedWeatherInfo.lon);

    var climateItemsWithDistance = _climateLocationData.entries.map((entry) {
      final climateLatLng = LatLng(entry.value.lat, entry.value.lon);
      final distanceInMeters = distance(weatherLatLng, climateLatLng);
      return (
      key: entry.key,
      info: entry.value,
      distance: distanceInMeters
      );
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
                  weatherInfo.displayName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
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
                dailyWeather: _hourlyForecast,
                climateNormals: _climateNormals,
                displayMode: _displayMode,
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