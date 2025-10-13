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

            // Segmentos de selección
            SegmentedButton<Movimiento>(
              segments: const [
                ButtonSegment(
                  value: Movimiento.fijo,
                  label: Text('Fijo'),
                ),
                ButtonSegment(
                  value: Movimiento.horizontal,
                  label: Text('Horizontal'),
                ),
                ButtonSegment(
                  value: Movimiento.vertical,
                  label: Text('Vertical'),
                ),
                ButtonSegment(
                  value: Movimiento.aleatorio,
                  label: Text('Aleatorio'),
                ),
              ],
              selected: {value},
              onSelectionChanged: (s) => onChanged(s.first),
            ),

            const SizedBox(height: 12),

            // Descripción de ayuda contextual
            Text(
              _descripcionMovimiento(value),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _descripcionMovimiento(Movimiento m) {
    switch (m) {
      case Movimiento.fijo:
        return 'El estímulo permanece estático en su posición.';
      case Movimiento.horizontal:
        return 'El estímulo se desliza de izquierda a derecha o viceversa.';
      case Movimiento.vertical:
        return 'El estímulo se desliza de arriba a abajo o viceversa.';
      case Movimiento.aleatorio:
        return 'El estímulo cambia aleatoriamente entre desplazamiento horizontal y vertical.';
    }
  }
}
