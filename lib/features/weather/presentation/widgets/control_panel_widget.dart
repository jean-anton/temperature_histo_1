import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/link.dart';
import 'package:aeroclim/features/weather/domain/weather_model.dart';
import 'package:aeroclim/features/locations/domain/location_model.dart';
import 'package:aeroclim/features/locations/data/location_repository.dart';
import 'package:aeroclim/core/widgets/help_dialog.dart';
import 'package:aeroclim/features/weather/presentation/widgets/control_panel/model_selector.dart';
import 'package:aeroclim/features/weather/presentation/widgets/control_panel/display_mode_selector.dart';
import 'package:aeroclim/features/weather/presentation/widgets/control_panel/display_type_selector.dart';
import 'package:aeroclim/features/weather/presentation/widgets/control_panel/location_selector.dart';
import 'package:aeroclim/features/weather/presentation/widgets/control_panel/wind_settings.dart';
import 'package:aeroclim/features/weather/presentation/widgets/control_panel/section_header.dart';

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
  final String? homeLocationKey;
  final Function(String?)? onHomeLocationChanged;
  final double minApparentTemperature;
  final Function(double) onMinApparentTemperatureChanged;

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
    required this.minApparentTemperature,
    required this.onMinApparentTemperatureChanged,
    required this.locationService,
    required this.climateDropDownItems,
    required this.version,
    required this.mainFileName,
    required this.isRunningWithWasm,
    this.scrollController,
    this.homeLocationKey,
    this.onHomeLocationChanged,
  });

  @override
  Widget build(BuildContext context) {
    print('### ControlPanelWidget build - homeLocationKey: $homeLocationKey');
    return Material(
      color: Colors.transparent,
      child: Container(
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
              const SectionHeader(
                title: 'MODÈLE',
                icon: Icons.model_training_outlined,
              ),
              const SizedBox(height: 12),
              ModelSelector(
                models: models,
                selectedModel: selectedModel,
                onModelChanged: onModelChanged,
              ),
              const SizedBox(height: 16),
              DisplayModeSelector(
                displayMode: displayMode,
                onDisplayModeChanged: onDisplayModeChanged,
              ),
              const SizedBox(height: 20),
              DisplayTypeSelector(
                displayType: displayType,
                onDisplayTypeChanged: onDisplayTypeChanged,
              ),
              const SizedBox(height: 32),
              const SectionHeader(
                title: 'LOCALISATION',
                icon: Icons.place_outlined,
              ),
              const SizedBox(height: 16),
              LocationSelector(
                weatherLocationData: weatherLocationData,
                selectedWeatherLocation: selectedWeatherLocation,
                onWeatherLocationChanged: onWeatherLocationChanged,
                onLocationsUpdated: onLocationsUpdated,
                locationService: locationService,
                homeLocationKey: homeLocationKey,
                onHomeLocationChanged: onHomeLocationChanged,
                selectedClimateLocation: selectedClimateLocation,
                onClimateLocationChanged: onClimateLocationChanged,
                climateDropDownItems: climateDropDownItems,
              ),
              const SizedBox(height: 32),
              const SectionHeader(title: 'PARAMÈTRES VENT', icon: Icons.air),
              const SizedBox(height: 16),
              WindSettings(
                showWindInfo: showWindInfo,
                onShowWindInfoChanged: onShowWindInfoChanged,
                showExtendedWindInfo: showExtendedWindInfo,
                onShowExtendedWindInfoChanged: onShowExtendedWindInfoChanged,
                maxGustSpeed: maxGustSpeed,
                onMaxGustSpeedChanged: onMaxGustSpeedChanged,
                maxPrecipitationProbability: maxPrecipitationProbability,
                onMaxPrecipitationProbabilityChanged:
                    onMaxPrecipitationProbabilityChanged,
                minApparentTemperature: minApparentTemperature,
                onMinApparentTemperatureChanged:
                    onMinApparentTemperatureChanged,
              ),
              const SizedBox(height: 48),
              _buildFooter(context),
            ],
          ),
        ),
      ),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Link(
              uri: Uri.parse(
                'https://github.com/jean-anton/aeroclim',
              ),
              target: LinkTarget.blank,
              builder: (context, followLink) => InkWell(
                onTap: followLink,
                child: Row(
                  children: [
                    const Icon(Icons.code, size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      'Code Source (GitHub)',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: Colors.blue[700],
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            const SelectableText(
              'https://github.com/jean-anton/aeroclim',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}
