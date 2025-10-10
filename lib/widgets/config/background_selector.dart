import 'package:flutter/material.dart';
import '../../models/test_config.dart';

class BackgroundSelector extends StatelessWidget {
  final Fondo fondo;
  final bool distractor;
  final ValueChanged<Fondo> onFondoChanged;
  final ValueChanged<bool> onDistractorChanged;

  const BackgroundSelector({
    super.key,
    required this.fondo,
    required this.distractor,
    required this.onFondoChanged,
    required this.onDistractorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Fondo',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SegmentedButton<Fondo>(
              segments: const [
                ButtonSegment(value: Fondo.claro, label: Text('Claro')),
                ButtonSegment(value: Fondo.oscuro, label: Text('Oscuro')),
              ],
              selected: {fondo},
              onSelectionChanged: (s) => onFondoChanged(s.first),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: distractor,
              onChanged: onDistractorChanged,
              title: const Text('Fondo distractor'),
              subtitle:
                  const Text('Añade un patrón suave de baja intensidad.'),
            ),
          ],
        ),
      ),
    );
  }
}
