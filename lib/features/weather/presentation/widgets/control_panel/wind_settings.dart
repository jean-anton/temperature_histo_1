import 'package:flutter/material.dart';

class WindSettings extends StatelessWidget {
  final bool showWindInfo;
  final Function(bool) onShowWindInfoChanged;
  final bool showExtendedWindInfo;
  final Function(bool) onShowExtendedWindInfoChanged;
  final double maxGustSpeed;
  final Function(double) onMaxGustSpeedChanged;
  final int maxPrecipitationProbability;
  final Function(int) onMaxPrecipitationProbabilityChanged;
  final double minApparentTemperature;
  final Function(double) onMinApparentTemperatureChanged;

  const WindSettings({
    super.key,
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
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(height: 20),
        const Text(
          ' Filtres table vent',
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildDropdown(
                context: context,
                label: 'Rafales (km/h)',
                value: maxGustSpeed,
                items: [5.0, 10.0, 15.0, 20.0, 25.0, 30.0, 35.0, 40.0, 45.0, 50.0],
                onChanged: onMaxGustSpeedChanged,
                itemLabelBuilder: (v) => v.toStringAsFixed(0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown(
                context: context,
                label: 'Précip (%)',
                value: maxPrecipitationProbability,
                items: [0, 10, 20, 30, 40, 50],
                onChanged: onMaxPrecipitationProbabilityChanged,
                itemLabelBuilder: (v) => '$v%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown(
                context: context,
                label: 'Temp. ressentie min (°C)',
                value: minApparentTemperature,
                items: [0.0, 5.0, 10.0, 15.0, 20.0, 25.0, 30.0],
                onChanged: onMinApparentTemperatureChanged,
                itemLabelBuilder: (v) => v.toStringAsFixed(0),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required BuildContext context,
    required String label,
    required T value,
    required List<T> items,
    required Function(T) onChanged,
    required String Function(T) itemLabelBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          items: items
              .map(
                (v) => DropdownMenuItem(
                  value: v,
                  child: Text(itemLabelBuilder(v)),
                ),
              )
              .toList(),
          onChanged: (v) => v != null ? onChanged(v) : null,
        ),
      ],
    );
  }
}
