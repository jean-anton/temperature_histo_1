import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:temperature_histo_1/features/weather/domain/weather_model.dart';
import 'package:temperature_histo_1/features/locations/domain/location_model.dart';
import 'package:temperature_histo_1/features/locations/data/location_repository.dart';
import 'package:temperature_histo_1/features/locations/presentation/widgets/city_management_dialog.dart';
import 'package:temperature_histo_1/core/widgets/help_dialog.dart';

class ControlPanelWidget extends StatelessWidget {
  final Map<String, String> models;
  final String selectedModel;
  final Function(String) onModelChanged;
  final String displayMode;
  final Function(String) onDisplayModeChanged;
  final DisplayType displayType;
  final Function(DisplayType) onDisplayTypeChanged;
  final Map<String, WeatherLocationInfo> weatherLocationData;
  final String? selectedWeatherLocation;
  final Function(String?) onWeatherLocationChanged;
  final Future<void> Function() onLocationsUpdated;
  final String selectedClimateLocation;
  final Function(String?) onClimateLocationChanged;
  final bool showWindInfo;
  final Function(bool) onShowWindInfoChanged;
  final bool showExtendedWindInfo;
  final Function(bool) onShowExtendedWindInfoChanged;
  final double maxGustSpeed;
  final Function(double) onMaxGustSpeedChanged;
  final int maxPrecipitationProbability;
  final Function(int) onMaxPrecipitationProbabilityChanged;
  final LocationRepository locationService;
  final List<DropdownMenuItem<String>> climateDropDownItems;
  final String version;
  final String mainFileName;
  final bool isRunningWithWasm;
  final ScrollController? scrollController;

  const ControlPanelWidget({
    super.key,
    required this.models,
    required this.selectedModel,
    required this.onModelChanged,
    required this.displayMode,
    required this.onDisplayModeChanged,
    required this.displayType,
    required this.onDisplayTypeChanged,
    required this.weatherLocationData,
    required this.selectedWeatherLocation,
    required this.onWeatherLocationChanged,
    required this.onLocationsUpdated,
    required this.selectedClimateLocation,
    required this.onClimateLocationChanged,
    required this.showWindInfo,
    required this.onShowWindInfoChanged,
    required this.showExtendedWindInfo,
    required this.onShowExtendedWindInfoChanged,
    required this.maxGustSpeed,
    required this.onMaxGustSpeedChanged,
    required this.maxPrecipitationProbability,
    required this.onMaxPrecipitationProbabilityChanged,
    required this.locationService,
    required this.climateDropDownItems,
    required this.version,
    required this.mainFileName,
    required this.isRunningWithWasm,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.0),
        border: Border(
          right: BorderSide(color: Colors.white.withValues(alpha: 0.0)),
        ),
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              'MODÈLE',
              Icons.model_training_outlined,
            ),
            const SizedBox(height: 12),
            _buildModelSelector(),
            //const SizedBox(height: 32),
            // _buildSectionHeader(
            //   context,
            //   'AFFICHAGE',
            //   Icons.visibility_outlined,
            // ),
            const SizedBox(height: 16),
            _buildDisplayModeSelector(),
            const SizedBox(height: 20),
            _buildDisplayTypeSelector(),
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'LOCALISATION', Icons.place_outlined),
            const SizedBox(height: 16),
            _buildLocationSelector(context),
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'PARAMÈTRES VENT', Icons.air),
            const SizedBox(height: 16),
            _buildWindToggles(),
            const SizedBox(height: 20),
            _buildWindFilters(),
            const SizedBox(height: 48),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildModelSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: models.entries.map((entry) {
        final isSelected = selectedModel == entry.key;
        return ChoiceChip(
          label: Text(entry.value),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) onModelChanged(entry.key);
          },
        );
      }).toList(),
    );
  }

  Widget _buildDisplayModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mode temporel:', style: TextStyle(fontSize: 13)),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'daily',
              label: Text('Journalier'),
              icon: Icon(Icons.calendar_today, size: 18),
            ),
            ButtonSegment(
              value: 'hourly',
              label: Text('Horaire'),
              icon: Icon(Icons.access_time, size: 18),
            ),
          ],
          selected: {displayMode},
          onSelectionChanged: (selection) =>
              onDisplayModeChanged(selection.first),
        ),
      ],
    );
  }

  Widget _buildDisplayTypeSelector() {
    final types = [
      (DisplayType.graphique, 'Graph', Icons.bar_chart),
      (DisplayType.vent, 'Vent', Icons.air),
      (DisplayType.ventTable, 'Table Vent', Icons.table_rows),
      (DisplayType.comparatif, 'Comp', Icons.compare_arrows),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Type de vue:', style: TextStyle(fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: types.map((typeInfo) {
            final type = typeInfo.$1;
            final label = typeInfo.$2;
            final icon = typeInfo.$3;
            final isSelected = displayType == type;

            return ChoiceChip(
              avatar: Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : null,
              ),
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onDisplayTypeChanged(type);
              },
              selectedColor: const Color(0xFF1A237E),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : null,
                fontSize: 13,
              ),
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          value: selectedWeatherLocation,
          decoration: const InputDecoration(
            labelText: 'Lieu de prévision',
            prefixIcon: Icon(Icons.location_on_outlined),
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
        OutlinedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => CityManagementDialog(
                weatherLocations: weatherLocationData,
                locationService: locationService,
                selectedWeatherLocation: selectedWeatherLocation,
                onLocationChanged: onWeatherLocationChanged,
                onLocationsUpdated: onLocationsUpdated,
              ),
            );
          },
          icon: const Icon(Icons.settings_suggest_outlined),
          label: const Text('Gérer les villes'),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: selectedClimateLocation,
          decoration: const InputDecoration(
            labelText: 'Station climatique',
            prefixIcon: Icon(Icons.history_outlined),
          ),
          items: climateDropDownItems,
          onChanged: onClimateLocationChanged,
        ),
      ],
    );
  }

  Widget _buildWindToggles() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Afficher le vent'),
          subtitle: const Text('Information de base'),
          value: showWindInfo,
          onChanged: onShowWindInfoChanged,
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text('Vent étendu'),
          subtitle: const Text('Détails par altitude'),
          value: showExtendedWindInfo,
          onChanged: onShowExtendedWindInfoChanged,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildWindFilters() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<double>(
            value: maxGustSpeed,
            decoration: const InputDecoration(labelText: 'Rafales (km/h)'),
            items: [10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 80.0, 100.0]
                .map(
                  (v) => DropdownMenuItem(
                    value: v,
                    child: Text(v.toStringAsFixed(0)),
                  ),
                )
                .toList(),
            onChanged: (v) => v != null ? onMaxGustSpeedChanged(v) : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<int>(
            value: maxPrecipitationProbability,
            decoration: const InputDecoration(labelText: 'Précip (%)'),
            items: [0, 10, 20, 30, 40, 50]
                .map((v) => DropdownMenuItem(value: v, child: Text('$v%')))
                .toList(),
            onChanged: (v) =>
                v != null ? onMaxPrecipitationProbabilityChanged(v) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const HelpDialog(),
            );
          },
          icon: const Icon(Icons.help_outline, size: 18),
          label: const Text('Besoin d\'aide ?'),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Version: $version',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
        Text(
          'Wasm: $isRunningWithWasm',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => launchUrl(
            Uri.parse('https://github.com/jean-anton/temperature_histo_1'),
          ),
          child: Row(
            children: [
              const Icon(Icons.code, size: 14, color: Colors.blue),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'https://github.com/jean-anton/temperature_histo_1',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: Colors.blue[700],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
