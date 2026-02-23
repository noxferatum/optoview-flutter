import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../l10n/app_localizations.dart';

/// Card con slider para configurar la duración del test (en segundos).
class DurationCard extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const DurationCard({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.durationTitle,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            Slider(
              value: value.toDouble(),
              min: AppConstants.minDurationSeconds.toDouble(),
              max: AppConstants.maxDurationSeconds.toDouble(),
              divisions: 29,
              label: '$value s',
              onChanged: (v) => onChanged(v.round()),
            ),
          ],
        ),
      ),
    );
  }
}
