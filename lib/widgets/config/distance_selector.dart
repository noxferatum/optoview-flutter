import 'package:flutter/material.dart';
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
    final isAleatoria = modo == DistanciaModo.aleatorio;

    return SectionCard(
      title: 'Distancia al centro',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            value: isAleatoria,
            title: const Text('Aleatoria'),
            subtitle: const Text(
              'Cambia aleatoriamente la distancia del estímulo',
            ),
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
                  'Distancia actual: ${distanciaPct.toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
