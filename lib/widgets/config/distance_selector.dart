import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/test_config.dart';
import 'section_card.dart';

class DistanceSelector extends StatelessWidget {
  final DistanciaModo modo;
  final double distanciaPct;
  final ValueChanged<DistanciaModo> onModoChanged;
  final ValueChanged<double> onDistChanged;

  const DistanceSelector({
    super.key,
    required this.modo,
    required this.distanciaPct,
    required this.onModoChanged,
    required this.onDistChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isAleatoria = modo == DistanciaModo.aleatorio;

    return SectionCard(
      title: l.distanceTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            value: isAleatoria,
            title: Text(l.distanceRandom),
            subtitle: Text(l.distanceRandomSubtitle),
            onChanged: (v) => onModoChanged(
              v ? DistanciaModo.aleatorio : DistanciaModo.fijo,
            ),
          ),
          const SizedBox(height: 8),
          if (!isAleatoria)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Slider(
                  value: distanciaPct,
                  min: 10,
                  max: 100,
                  divisions: 18,
                  label: '${distanciaPct.toStringAsFixed(0)}%',
                  onChanged: onDistChanged,
                ),
                Text(
                  l.distanceCurrent(distanciaPct.toStringAsFixed(0)),
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
