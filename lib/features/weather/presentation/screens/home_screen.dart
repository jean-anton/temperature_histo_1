import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
import 'package:temperature_histo_1/features/weather/domain/weathercode_calculator.dart';

import 'package:temperature_histo_1/core/widgets/responsive_layout.dart';
import 'package:temperature_histo_1/features/weather/presentation/widgets/control_panel_widget.dart';
import 'package:temperature_histo_1/features/weather/presentation/widgets/weather_display_widget.dart';
import 'package:temperature_histo_1/features/locations/presentation/widgets/city_management_dialog.dart';
import 'package:temperature_histo_1/core/widgets/help_dialog.dart';

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
  static const String _kDisclaimerAcceptedKey = 'disclaimerAccepted';

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
      displayName: 'Bad Dürkheim (DE)',
      assetPath: 'assets/data/climatologie_01072_Bad-Dürkheim_1961_1990.csv',
      lat: 49.4719,
      lon: 8.1929,
      startYear: 1961,
      endYear: 1990,
    ),
  };

  bool _isDisclaimerAccepted = false;
  Map<String, WeatherLocationInfo> _weatherLocationData = {};
  final Map<String, String> _models = {
    'best_match': 'Best Match',
    'ecmwf_ifs025': 'ECMWF IFS',
    'gfs_seamless': 'GFS',

    'meteofrance_arome_seamless': 'Météo-France (AROME)',
    'meteofrance_seamless': 'ARPEGE',
    'icon_seamless': 'ICON/DWD',
  };

  // Display mode: 'daily' or 'hourly'
  String _displayMode = 'daily';
  DisplayType _displayType = DisplayType.graphique;
  String _selectedClimateLocation = '04336_Saarbrücken-Ensheim_1961_1990';
  String? _selectedWeatherLocation;
  String _selectedModel = 'best_match';
  DailyWeather? _forecast;
  HourlyWeather? _hourlyForecast;
  MultiModelWeather? _multiModelForecast;
  MultiModelHourlyWeather? _multiModelHourlyForecast;
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

    // If no locations, automatically show city management after initial load
    // ONLY if disclaimer has been accepted. If not, the disclaimer acceptance
    // button logic will handle showing the dialog.
    if (_weatherLocationData.isEmpty && mounted && _isDisclaimerAccepted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCityManagementDialog();
      });
    }
  }

  void _showCityManagementDialog() {
    showDialog(
      context: context,
      builder: (context) => CityManagementDialog(
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
          // Auto-select first city if nothing is selected
          if (_selectedWeatherLocation == null && weatherLocations.isNotEmpty) {
            _onWeatherLocationChanged(weatherLocations.keys.first);
          }
        },
      ),
    );
  }

  Future<void> _loadPreferencesAndData() async {
    await _loadPreferences();
    if (_weatherLocationData.isNotEmpty) {
      await _loadData();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = "Aucune ville enregistrée. Veuillez en ajouter une.";
      });
    }
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
      _isDisclaimerAccepted = prefs.getBool(_kDisclaimerAcceptedKey) ?? false;

      if (!_climateLocationData.containsKey(_selectedClimateLocation)) {
        _selectedClimateLocation = _climateLocationData.keys.first;
      }

      if (_weatherLocationData.isNotEmpty) {
        if (_selectedWeatherLocation == null ||
            !_weatherLocationData.containsKey(_selectedWeatherLocation)) {
          _selectedWeatherLocation = _weatherLocationData.keys.first;
        }
      } else {
        _selectedWeatherLocation = null;
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
      _selectedWeatherLocation ?? '',
    );
    await prefs.setString(_kSelectedModelKey, _selectedModel);
    await prefs.setBool(_kShowWindInfoKey, _showWindInfo);
    await prefs.setBool(_kShowExtendedWindInfoKey, _showExtendedWindInfo);
    await prefs.setDouble(_kMaxGustSpeedKey, _maxGustSpeed);
    await prefs.setInt(
      _kMaxPrecipitationProbabilityKey,
      _maxPrecipitationProbability,
    );
    await prefs.setBool(_kDisclaimerAcceptedKey, _isDisclaimerAccepted);
  }

  Future<void> _loadData() async {
    if (_isLoading && _forecast != null) {
      return; // Already loading and we have data, avoid redundant calls
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

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

      if (_displayType == DisplayType.comparatif) {
        final modelsToFetch = [
          'best_match',
          'ecmwf_ifs025',
          'gfs_seamless',
          'meteofrance_seamless',
        ];

        // 1. Load climate normals first
        final normals = await _climateService.loadClimateNormals(
          climateInfo.assetPath,
        );

        // 2. Fetch daily and hourly data sequentially or in small batches
        // Sequential fetching is safer against 429 errors.
        final dailyModels = <String, DailyWeather>{};
        final hourlyModels = <String, HourlyWeather>{};

        for (final m in modelsToFetch) {
          dailyModels[m] = await _weatherService.getWeatherForecast(
            latitude: weatherInfo.lat,
            longitude: weatherInfo.lon,
            model: m,
            locationName: weatherInfo.displayName,
          );
          // Add a tiny delay between models to be even safer
          await Future.delayed(const Duration(milliseconds: 100));

          hourlyModels[m] = await _weatherService.getHourlyWeatherForecast(
            latitude: weatherInfo.lat,
            longitude: weatherInfo.lon,
            model: m,
            locationName: weatherInfo.displayName,
          );
          await Future.delayed(const Duration(milliseconds: 100));
        }

        setState(() {
          _climateNormals = normals;
          _multiModelForecast = MultiModelWeather(
            locationName: weatherInfo.displayName,
            models: dailyModels,
            latitude: weatherInfo.lat,
            longitude: weatherInfo.lon,
          );
          _multiModelHourlyForecast = MultiModelHourlyWeather(
            locationName: weatherInfo.displayName,
            models: hourlyModels,
            latitude: weatherInfo.lat,
            longitude: weatherInfo.lon,
          );
          _forecast = dailyModels['best_match'];
          _hourlyForecast = hourlyModels['best_match'];
          _isLoading = false;
        });
        return;
      }

      if (_displayMode == 'hourly' ||
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
    if (!_isDisclaimerAccepted) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wb_sunny_outlined,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Bienvenue dans Température Histo',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'AVERTISSEMENT',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[900],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Les données présentées sont fournies à titre strictement informatif et peuvent différer des conditions réelles. Elles ne doivent jamais être utilisées pour la préparation ou la prise de décision concernant des activités aéronautiques avec présence humaine, telles que le parapente, le deltaplane, l’ULM, le kite, la montgolfière ou toute forme d’aviation habitée.\n\n',
                        style: TextStyle(fontSize: 15, height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.privacy_tip_outlined,
                            size: 16,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Confidentialité : Aucun cookie ni tracker. Aucune donnée collectée.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue[900],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => launchUrl(
                          Uri.parse(
                            'https://github.com/jean-anton/temperature_histo_1',
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.code,
                              size: 16,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Code Source sur GitHub',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue[700],
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'L’auteur de l’application décline toute responsabilité quant aux décisions prises ou aux incidents survenus à la suite de l’utilisation des informations affichées.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const HelpDialog(),
                          );
                        },
                        icon: const Icon(Icons.help_outline),
                        label: const Text('Lire l\'aide'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isDisclaimerAccepted = true;
                            _savePreferences();
                            if (_weatherLocationData.isEmpty) {
                              _showCityManagementDialog();
                            } else {
                              _loadData();
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Accepter'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    final weatherInfo = _weatherLocationData[_selectedWeatherLocation ?? ''];
    final climateInfo = _climateLocationData[_selectedClimateLocation];

    final mainDisplay = (_isLoading)
        ? const Center(child: LoadingIndicator())
        : (_errorMessage != null)
        ? ErrorDisplay(message: _errorMessage!)
        : (weatherInfo != null && climateInfo != null)
        ? WeatherDisplayWidget(
            weatherInfo: weatherInfo,
            climateInfo: climateInfo,
            modelName: _models[_selectedModel] ?? '',
            displayMode: _displayMode,
            displayType: _displayType,
            forecast: _forecast,
            hourlyForecast: _hourlyForecast,
            multiModelForecast: _multiModelForecast,
            multiModelHourlyForecast: _multiModelHourlyForecast,
            climateNormals: _climateNormals,
            showWindInfo: _showWindInfo,
            showExtendedWindInfo: _showExtendedWindInfo,
            maxGustSpeed: _maxGustSpeed,
            maxPrecipitationProbability: _maxPrecipitationProbability,
            onRefresh: _loadData,
          )
        : _weatherLocationData.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_off_outlined,
                  size: 64,
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune ville enregistrée',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ajoutez une ville dans le menu "Gérer les villes" pour commencer.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _showCityManagementDialog,
                  icon: const Icon(Icons.add_location_alt),
                  label: const Text('Gérer les villes'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          )
        : const Center(child: Text('Sélectionnez une localisation'));

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: ResponsiveLayout.isMobile(context)
          ? FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => DraggableScrollableSheet(
                    initialChildSize: 0.63,
                    minChildSize: 0.4,
                    maxChildSize: 0.95,
                    expand: false,
                    builder: (context, scrollController) {
                      return StatefulBuilder(
                        builder: (context, setBottomSheetState) {
                          return Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 12),
                                Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                Expanded(
                                  child: _buildControlPanel(
                                    scrollController: scrollController,
                                    onStateChanged: () =>
                                        setBottomSheetState(() {}),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.menu, color: Colors.white),
            )
          : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: ResponsiveLayout(
            mobile: mainDisplay,
            desktop: Row(
              children: [
                SizedBox(width: 350, child: _buildControlPanel()),
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Colors.black12,
                ),
                Expanded(child: mainDisplay),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ControlPanelWidget _buildControlPanel({
    ScrollController? scrollController,
    VoidCallback? onStateChanged,
  }) {
    final weatherInfo = _weatherLocationData[_selectedWeatherLocation];
    return ControlPanelWidget(
      models: _models,
      selectedModel: _selectedModel,
      onModelChanged: (val) {
        _onModelChanged(val);
        onStateChanged?.call();
      },
      displayMode: _displayMode,
      onDisplayModeChanged: (val) {
        _onDisplayModeChanged(val);
        onStateChanged?.call();
      },
      displayType: _displayType,
      onDisplayTypeChanged: (type) {
        setState(() {
          _displayType = type;
          _savePreferences();
          final needsMultiModel =
              _displayType == DisplayType.comparatif &&
              (_multiModelForecast == null ||
                  _multiModelHourlyForecast == null);
          final needsHourly =
              (_displayType == DisplayType.vent ||
                  _displayType == DisplayType.ventDay ||
                  _displayType == DisplayType.ventTable) &&
              _hourlyForecast == null;

          if (needsMultiModel || needsHourly) {
            _loadData();
          }
        });
        onStateChanged?.call();
      },
      weatherLocationData: _weatherLocationData,
      selectedWeatherLocation: _selectedWeatherLocation,
      onWeatherLocationChanged: (val) {
        _onWeatherLocationChanged(val);
        onStateChanged?.call();
      },
      onLocationsUpdated: () async {
        final weatherLocations = await _locationService.loadWeatherLocations();
        setState(() {
          _weatherLocationData = weatherLocations;
        });
        // Auto-select first city if nothing is selected
        if (_selectedWeatherLocation == null && weatherLocations.isNotEmpty) {
          _onWeatherLocationChanged(weatherLocations.keys.first);
        }
        onStateChanged?.call();
      },
      selectedClimateLocation: _selectedClimateLocation,
      onClimateLocationChanged: (val) {
        _onClimateLocationChanged(val);
        onStateChanged?.call();
      },
      showWindInfo: _showWindInfo,
      onShowWindInfoChanged: (val) {
        setState(() {
          _showWindInfo = val;
          _savePreferences();
        });
        onStateChanged?.call();
      },
      showExtendedWindInfo: _showExtendedWindInfo,
      onShowExtendedWindInfoChanged: (val) {
        setState(() {
          _showExtendedWindInfo = val;
          _savePreferences();
        });
        onStateChanged?.call();
      },
      maxGustSpeed: _maxGustSpeed,
      onMaxGustSpeedChanged: (val) {
        setState(() {
          _maxGustSpeed = val;
          _savePreferences();
        });
        onStateChanged?.call();
      },
      maxPrecipitationProbability: _maxPrecipitationProbability,
      onMaxPrecipitationProbabilityChanged: (val) {
        setState(() {
          _maxPrecipitationProbability = val;
          _savePreferences();
        });
        onStateChanged?.call();
      },
      locationService: _locationService,
      climateDropDownItems: _buildSortedClimateLocationItems(weatherInfo),
      version: VERSION,
      mainFileName: mainFileName,
      isRunningWithWasm: const bool.fromEnvironment('dart.tool.dart2wasm'),
      scrollController: scrollController,
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
}
