import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:aeroclim/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:aeroclim/features/locations/domain/location_model.dart';
import 'package:aeroclim/features/locations/data/location_repository.dart';

import 'package:web/web.dart' as web;
import 'dart:js_interop';

class CityManagementDialog extends StatefulWidget {
  final Map<String, WeatherLocationInfo> weatherLocations;
  final LocationRepository locationService;
  final String? selectedWeatherLocation;
  final Function(String?) onLocationChanged;
  final Future<void> Function() onLocationsUpdated;
  final Function(String?)? onHomeLocationChanged;

  const CityManagementDialog({
    super.key,
    required this.weatherLocations,
    required this.locationService,
    required this.selectedWeatherLocation,
    required this.onLocationChanged,
    required this.onLocationsUpdated,
    this.onHomeLocationChanged,
  });

  @override
  State<CityManagementDialog> createState() => _CityManagementDialogState();
}

class _CityManagementDialogState extends State<CityManagementDialog> {
  late Map<String, WeatherLocationInfo> _currentLocations;
  final TextEditingController _searchController = TextEditingController();
  List<LocationSuggestion> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounceTimer;
  String? _errorMessage;
  String? _homeLocationKey;

  // New fields for coordinate-based entry
  bool _addByCoordinates = false;
  final TextEditingController _coordsController = TextEditingController();
  final TextEditingController _manualNameController = TextEditingController();
  LocationSuggestion? _reverseGeocodedSuggestion;

  @override
  void initState() {
    super.initState();
    _currentLocations = Map.from(widget.weatherLocations);
    _searchController.addListener(_onSearchChanged);
    _loadHomeLocation();
  }

  Future<void> _loadHomeLocation() async {
    final homeKey = await widget.locationService.getHomeLocation();
    setState(() {
      _homeLocationKey = homeKey;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _coordsController.dispose();
    _manualNameController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Cancel previous timer
    _debounceTimer?.cancel();

    if (_searchController.text.isEmpty) {
      setState(() {
        _suggestions = [];
        _errorMessage = null;
      });
      return;
    }

    if (_searchController.text.length >= 2) {
      // Start new timer for debouncing
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        _searchCities();
      });
    }
  }

  Future<void> _searchCities() async {
    if (_searchController.text.isEmpty) {
      setState(() {
        _suggestions = [];
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final suggestions = await widget.locationService.fetchSuggestions(
        _searchController.text,
      );
      setState(() {
        _suggestions = suggestions;
        _errorMessage = suggestions.isEmpty
            ? AppLocalizations.of(context)!.noCityFound
            : null;
      });
    } catch (e) {
      print('Error searching cities: $e');
      setState(() {
        _suggestions = [];
        _errorMessage =
            '${AppLocalizations.of(context)!.searchError}: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addCity(LocationSuggestion suggestion) async {
    await widget.locationService.addCity(suggestion);

    // Reload locations
    final weatherLocations = await widget.locationService
        .loadWeatherLocations();
    setState(() {
      _currentLocations = weatherLocations;
      _searchController.clear();
      _suggestions = [];
    });
    await widget.onLocationsUpdated();

    // If this is the only city or nothing was selected, select it
    if (_currentLocations.length == 1 ||
        (widget.selectedWeatherLocation?.isEmpty ?? true)) {
      final newKey = _currentLocations.keys.last;
      widget.onLocationChanged(newKey);
    }
  }

  Future<void> _handleReverseGeocode() async {
    final coordsStr = _coordsController.text.trim();
    if (coordsStr.isEmpty) return;

    final parts = coordsStr.split(',');
    if (parts.length < 2) return;

    final lat = double.tryParse(parts[0].trim());
    final lon = double.tryParse(parts[1].trim());

    if (lat == null || lon == null) return;

    setState(() => _isLoading = true);
    try {
      final suggestion = await widget.locationService.reverseGeocode(lat, lon);
      if (suggestion != null) {
        setState(() {
          _reverseGeocodedSuggestion = suggestion;
          _manualNameController.text = suggestion.name;
        });
      }
    } catch (e) {
      print('Error reverse geocoding: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addManualCity() async {
    final name = _manualNameController.text.trim();
    final coordsStr = _coordsController.text.trim();
    final parts = coordsStr.split(',');

    if (name.isEmpty || parts.length < 2) {
      setState(
        () => _errorMessage = AppLocalizations.of(context)!.fillAllFields,
      );
      return;
    }

    final lat = double.tryParse(parts[0].trim());
    final lon = double.tryParse(parts[1].trim());

    if (lat == null || lon == null) {
      setState(
        () => _errorMessage = AppLocalizations.of(context)!.invalidCoords,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await widget.locationService.addManualCity(
        name: name,
        lat: lat,
        lon: lon,
        country: _reverseGeocodedSuggestion?.country,
        state: _reverseGeocodedSuggestion?.state,
        county: _reverseGeocodedSuggestion?.county,
      );

      // Reload locations
      final weatherLocations = await widget.locationService
          .loadWeatherLocations();
      setState(() {
        _currentLocations = weatherLocations;
        _coordsController.clear();
        _manualNameController.clear();
        _reverseGeocodedSuggestion = null;
        _errorMessage = null;
        _addByCoordinates = false;
      });
      await widget.onLocationsUpdated();

      // If this is the only city or nothing was selected, select it
      if (_currentLocations.length == 1 ||
          (widget.selectedWeatherLocation?.isEmpty ?? true)) {
        final newKey = _currentLocations.keys.last;
        widget.onLocationChanged(newKey);
      }
    } catch (e) {
      setState(
        () => _errorMessage = AppLocalizations.of(
          context,
        )!.failedToLoadData(e.toString()),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteCity(String cityKey) async {
    await widget.locationService.deleteCity(cityKey);

    // Reload locations
    final weatherLocations = await widget.locationService
        .loadWeatherLocations();
    setState(() {
      _currentLocations = weatherLocations;
    });
    await widget.onLocationsUpdated();

    // If the deleted city was selected, switch to the first available city
    if (widget.selectedWeatherLocation == cityKey &&
        _currentLocations.isNotEmpty) {
      final firstKey = _currentLocations.keys.first;
      widget.onLocationChanged(firstKey);
    }
  }

  bool _isCustomCity(String cityKey) {
    return widget.locationService.isCustomCity(cityKey);
  }

  Future<void> _exportLocations() async {
    setState(() => _isLoading = true);
    try {
      final jsonContent = await widget.locationService.exportCustomCities();

      if (kIsWeb) {
        // Web-specific download logic using package:web (WASM compatible)
        final bytes = utf8.encode(jsonContent);
        final blob = web.Blob([bytes.toJS].toJS);
        final url = web.URL.createObjectURL(blob);
        final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
        anchor.href = url;
        anchor.download = "weather_locations.json";
        anchor.click();
        web.URL.revokeObjectURL(url);
      } else {
        // For other platforms, we might need a different approach or just print it
        // Since the user emphasized web, I'll focus on that.
        // For desktop/mobile, we could use path_provider and write to a file,
        // but let's stick to the web requirement for now.
        setState(
          () =>
              _errorMessage = AppLocalizations.of(context)!.exportNotSupported,
        );
      }
    } catch (e) {
      setState(
        () => _errorMessage = AppLocalizations.of(
          context,
        )!.exportError(e.toString()),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importLocations() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.bytes != null) {
        final content = utf8.decode(result.files.single.bytes!);
        final addedCount = await widget.locationService.importCustomCities(
          content,
        );

        // Reload locations
        final weatherLocations = await widget.locationService
            .loadWeatherLocations();
        await _loadHomeLocation();
        setState(() {
          _currentLocations = weatherLocations;
          _errorMessage = null;
        });
        await widget.onLocationsUpdated();
        widget.onHomeLocationChanged?.call(_homeLocationKey);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.citiesImported(addedCount),
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(
        () => _errorMessage = AppLocalizations.of(
          context,
        )!.importError(e.toString()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.manageCities),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add new city section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: Text(AppLocalizations.of(context)!.addByCityName),
                    selected: !_addByCoordinates,
                    onSelected: (selected) {
                      if (selected) setState(() => _addByCoordinates = false);
                    },
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: Text(AppLocalizations.of(context)!.addByCoordinates),
                    selected: _addByCoordinates,
                    onSelected: (selected) {
                      if (selected) setState(() => _addByCoordinates = true);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (!_addByCoordinates) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.manageCities,
                          hintText: AppLocalizations.of(context)!.addCityHint,
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _searchCities,
                    ),
                  ],
                ),
              ] else ...[
                Column(
                  children: [
                    TextField(
                      controller: _coordsController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(
                          context,
                        )!.addByCoordinates,
                        hintText: AppLocalizations.of(context)!.coordsHint,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (_) => _handleReverseGeocode(),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _manualNameController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(
                          context,
                        )!.locationNameLabel,
                        hintText: AppLocalizations.of(
                          context,
                        )!.enterLocationNameHint,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: Text(
                          AppLocalizations.of(context)!.addThisLocation,
                        ),
                        onPressed: _addManualCity,
                      ),
                    ),
                  ],
                ),
              ],
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              if (_suggestions.isNotEmpty)
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _suggestions[index];
                      return ListTile(
                        title: Text(suggestion.name),
                        subtitle: Text(suggestion.formattedLocation),
                        onTap: () => _addCity(suggestion),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              // List of cities
              Text(
                AppLocalizations.of(context)!.registeredCities,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _currentLocations.length,
                  itemBuilder: (context, index) {
                    final cityKey = _currentLocations.keys.elementAt(index);
                    final cityInfo = _currentLocations[cityKey]!;
                    final isCustom = _isCustomCity(cityKey);
                    final isHome = _homeLocationKey == cityKey;

                    return ListTile(
                      leading: Radio<String>(
                        value: cityKey,
                        groupValue: _homeLocationKey,
                        onChanged: (value) async {
                          await widget.locationService.setHomeLocation(value);
                          setState(() {
                            _homeLocationKey = value;
                          });
                          // Notify parent that home location changed
                          widget.onHomeLocationChanged?.call(value);
                        },
                      ),
                      title: Row(
                        children: [
                          Expanded(child: Text(cityInfo.formattedLocation)),
                          if (isHome)
                            const Icon(
                              Icons.home,
                              size: 16,
                              color: Colors.blue,
                            ),
                        ],
                      ),
                      subtitle: Text(
                        'Lat: ${cityInfo.lat.toStringAsFixed(4)}, Lon: ${cityInfo.lon.toStringAsFixed(4)}',
                      ),
                      trailing: isCustom
                          ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCity(cityKey),
                            )
                          : null, // No delete button for hard-coded cities
                      tileColor: widget.selectedWeatherLocation == cityKey
                          ? Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.1)
                          : null,
                      onTap: () {
                        widget.onLocationChanged(cityKey);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: _exportLocations,
          icon: const Icon(Icons.download),
          label: Text(AppLocalizations.of(context)!.export),
        ),
        TextButton.icon(
          onPressed: _importLocations,
          icon: const Icon(Icons.upload),
          label: Text(AppLocalizations.of(context)!.import),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.close),
        ),
      ],
    );
  }
}
