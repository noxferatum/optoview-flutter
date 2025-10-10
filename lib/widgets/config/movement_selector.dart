import 'package:flutter/material.dart';
import '../../models/test_config.dart';

class MovementSelector extends StatelessWidget {
  final Movimiento value;
  final ValueChanged<Movimiento> onChanged;

  const MovementSelector({
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
              'Movimiento del estímulo',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SegmentedButton<Movimiento>(
              segments: const [
                ButtonSegment(
                    value: Movimiento.fijo, label: Text('Fijo')),
                ButtonSegment(
                    value: Movimiento.movimiento, label: Text('Movimiento')),
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
