import 'package:flutter/material.dart';
import '../../models/test_config.dart';
import 'section_card.dart';

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
    return SectionCard(
      title: 'Movimiento del estímulo',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<Movimiento>(
            segments: const [
              ButtonSegment(value: Movimiento.fijo, label: Text('Fijo')),
              ButtonSegment(
                  value: Movimiento.horizontal, label: Text('Horizontal')),
              ButtonSegment(
                  value: Movimiento.vertical, label: Text('Vertical')),
              ButtonSegment(
                  value: Movimiento.aleatorio, label: Text('Aleatorio')),
            ],
            selected: {value},
            onSelectionChanged: (s) => onChanged(s.first),
          ),
          const SizedBox(height: 12),
          Text(
            _descripcionMovimiento(value),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _descripcionMovimiento(Movimiento m) => switch (m) {
        Movimiento.fijo => 'El estímulo permanece estático en su posición.',
        Movimiento.horizontal =>
          'El estímulo se desliza de izquierda a derecha o viceversa.',
        Movimiento.vertical =>
          'El estímulo se desliza de arriba a abajo o viceversa.',
        Movimiento.aleatorio =>
          'El estímulo cambia aleatoriamente entre desplazamiento horizontal y vertical.',
      };
}
