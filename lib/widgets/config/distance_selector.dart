// lib/widgets/config/distance_selector.dart
import 'package:flutter/material.dart';
import '../../models/test_config.dart';

class DistanceSelector extends StatelessWidget {
  final DistanciaModo modo;
  final double distanciaPct; // 0–100
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
    final isAleatoria = modo == DistanciaModo.aleatoria;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Proximidad al centro',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Aleatoria en cada aparición'),
              value: isAleatoria,
              onChanged: (v) =>
                  onModoChanged(v ? DistanciaModo.aleatoria : DistanciaModo.controlada),
            ),
            const SizedBox(height: 8),
            Opacity(
              opacity: isAleatoria ? 0.4 : 1,
              child: IgnorePointer(
                ignoring: isAleatoria,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Slider(
                      value: distanciaPct,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      label: '${distanciaPct.toStringAsFixed(0)}%',
                      onChanged: onDistChanged,
                    ),
                    Text(
                      'Distancia: ${distanciaPct.toStringAsFixed(0)} % '
                      '(0 = centro, 100 = borde)',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
