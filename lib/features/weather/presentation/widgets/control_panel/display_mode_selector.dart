import 'package:flutter/material.dart';

class DisplayModeSelector extends StatelessWidget {
  final String displayMode;
  final Function(String) onDisplayModeChanged;

  const DisplayModeSelector({
    super.key,
    required this.displayMode,
    required this.onDisplayModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mode temporel:', style: TextStyle(fontSize: 13)),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'daily',
              label: FittedBox(child: Text('Journalier', softWrap: false)),
              icon: Icon(Icons.calendar_today, size: 16),
            ),
            ButtonSegment(
              value: 'periodes',
              label: FittedBox(child: Text('Aperçu', softWrap: false)),
              icon: Icon(Icons.view_quilt, size: 16),
            ),
            ButtonSegment(
              value: 'hourly',
              label: FittedBox(child: Text('Horaire', softWrap: false)),
              icon: Icon(Icons.access_time, size: 16),
            ),
          ],
          selected: {displayMode},
          onSelectionChanged: (selection) =>
              onDisplayModeChanged(selection.first),
        ),
      ],
    );
  }
}
