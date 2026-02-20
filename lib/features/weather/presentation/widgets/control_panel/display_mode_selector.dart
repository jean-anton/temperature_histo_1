import 'package:flutter/material.dart';
import 'package:aeroclim/l10n/app_localizations.dart';

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
        Text(
          AppLocalizations.of(context)!.timeMode,
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(
              value: 'daily',
              label: FittedBox(
                child: Text(
                  AppLocalizations.of(context)!.dailyLabel,
                  softWrap: false,
                ),
              ),
              icon: Icon(Icons.calendar_today, size: 16),
            ),
            ButtonSegment(
              value: 'periodes',
              label: FittedBox(
                child: Text(
                  AppLocalizations.of(context)!.previewLabel,
                  softWrap: false,
                ),
              ),
              icon: Icon(Icons.view_quilt, size: 16),
            ),
            ButtonSegment(
              value: 'hourly',
              label: FittedBox(
                child: Text(
                  AppLocalizations.of(context)!.hourly,
                  softWrap: false,
                ),
              ),
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
