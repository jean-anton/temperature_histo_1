import 'package:flutter/material.dart';

class ModelSelector extends StatelessWidget {
  final Map<String, String> models;
  final String selectedModel;
  final Function(String) onModelChanged;

  const ModelSelector({
    super.key,
    required this.models,
    required this.selectedModel,
    required this.onModelChanged,
  });

  @override
  Widget build(BuildContext context) {
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
}
