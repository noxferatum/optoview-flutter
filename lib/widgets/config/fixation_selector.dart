import 'package:flutter/material.dart';
import '../../models/test_config.dart';

class FixationSelector extends StatelessWidget {
  final Fijacion value;
  final ValueChanged<Fijacion> onChanged;

  const FixationSelector({
    super.key,
    required this.value,
    required this.onChanged,
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
              'Punto de fijación',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SegmentedButton<Fijacion>(
              segments: const [
                ButtonSegment(value: Fijacion.cara, label: Text('Cara')),
                ButtonSegment(value: Fijacion.ojo, label: Text('Ojo')),
                ButtonSegment(value: Fijacion.punto, label: Text('Punto')),
                ButtonSegment(value: Fijacion.trebol, label: Text('Trébol')),
                ButtonSegment(value: Fijacion.cruz, label: Text('Cruz')),
              ],
              selected: {value},
              onSelectionChanged: (s) => onChanged(s.first),
            ),
          ],
        ),
      ),
    );
  }
}
