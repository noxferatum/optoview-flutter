import 'package:flutter/material.dart';
import '../../models/test_config.dart';

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
    final isAleatoria = modo == DistanciaModo.aleatoria;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Distancia al centro',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: isAleatoria,
              title: const Text('Aleatoria'),
              subtitle: const Text('Cambia aleatoriamente la distancia del estímulo'),
              onChanged: (v) =>
                  onModoChanged(v ? DistanciaModo.aleatoria : DistanciaModo.fijo),
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
                    'Distancia actual: ${distanciaPct.toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
