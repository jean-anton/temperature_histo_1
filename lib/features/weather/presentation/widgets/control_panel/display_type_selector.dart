import 'package:flutter/material.dart';
import 'package:aeroclim/features/weather/domain/weather_model.dart';

class DisplayTypeSelector extends StatelessWidget {
  final DisplayType displayType;
  final Function(DisplayType) onDisplayTypeChanged;

  const DisplayTypeSelector({
    super.key,
    required this.displayType,
    required this.onDisplayTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final types = [
      (DisplayType.graphique, 'Graph', Icons.bar_chart),
      (DisplayType.vent, 'Vent', Icons.air),
      (DisplayType.ventTable, 'Table Vent', Icons.table_rows),
      (DisplayType.comparatif, 'Comp', Icons.compare_arrows),
      (DisplayType.comparatifTable, 'Table Comp', Icons.grid_on),
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
}
