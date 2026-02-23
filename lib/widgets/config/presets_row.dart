import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// Entrada genérica de preset.
class PresetEntry<T> {
  final String name;
  final String description;
  final IconData icon;
  final T config;

  const PresetEntry({
    required this.name,
    required this.description,
    required this.icon,
    required this.config,
  });
}

/// Fila de chips de presets, genérica sobre el tipo de config.
class PresetsRow<T> extends StatelessWidget {
  final List<PresetEntry<T>> presets;
  final ValueChanged<T> onPresetSelected;

  const PresetsRow({
    super.key,
    required this.presets,
    required this.onPresetSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.presetsTitle,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presets.map((preset) {
            return ActionChip(
              avatar: Icon(preset.icon, size: 18),
              label: Text(preset.name),
              tooltip: preset.description,
              onPressed: () => onPresetSelected(preset.config),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
        Text(
          l.presetsHint,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
