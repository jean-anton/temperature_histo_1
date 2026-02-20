import 'package:flutter/material.dart';
import 'package:aeroclim/l10n/app_localizations.dart';
import 'package:aeroclim/features/locations/domain/location_model.dart';
import 'package:aeroclim/features/locations/data/location_repository.dart';
import 'package:aeroclim/features/locations/presentation/widgets/city_management_dialog.dart';
import 'package:aeroclim/core/config/app_config.dart';

class LocationSelector extends StatelessWidget {
  final Map<String, WeatherLocationInfo> weatherLocationData;
  final String? selectedWeatherLocation;
  final Function(String?) onWeatherLocationChanged;
  final Future<void> Function() onLocationsUpdated;
  final LocationRepository locationService;
  final String? homeLocationKey;
  final Function(String?)? onHomeLocationChanged;
  final String selectedClimateLocation;
  final Function(String?) onClimateLocationChanged;
  final List<DropdownMenuItem<String>> climateDropDownItems;

  const LocationSelector({
    super.key,
    required this.weatherLocationData,
    required this.selectedWeatherLocation,
    required this.onWeatherLocationChanged,
    required this.onLocationsUpdated,
    required this.locationService,
    this.homeLocationKey,
    this.onHomeLocationChanged,
    required this.selectedClimateLocation,
    required this.onClimateLocationChanged,
    required this.climateDropDownItems,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          value: selectedWeatherLocation,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.forecastLocation,
            prefixIcon: const Icon(Icons.location_on_outlined),
          ),
          items: weatherLocationData.entries.map((entry) {
            return DropdownMenuItem(
              value: entry.key,
              child: Text(entry.value.formattedLocation),
            );
          }).toList(),
          onChanged: onWeatherLocationChanged,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => CityManagementDialog(
                      weatherLocations: weatherLocationData,
                      locationService: locationService,
                      selectedWeatherLocation: selectedWeatherLocation,
                      onLocationChanged: onWeatherLocationChanged,
                      onLocationsUpdated: onLocationsUpdated,
                      onHomeLocationChanged: onHomeLocationChanged,
                    ),
                  );
                },
                icon: const Icon(Icons.settings_suggest_outlined),
                label: Text(AppLocalizations.of(context)!.manageCities),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: homeLocationKey != null
                  ? () => onWeatherLocationChanged(homeLocationKey)
                  : null,
              icon: const Icon(Icons.home, size: 20),
              label: Text(AppLocalizations.of(context)!.home),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (AppConfig.includeClimate)
          DropdownButtonFormField<String>(
            value: selectedClimateLocation,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.climateStation,
              prefixIcon: const Icon(Icons.history_outlined),
            ),
            items: climateDropDownItems,
            onChanged: onClimateLocationChanged,
          ),
      ],
    );
  }
}
