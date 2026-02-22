import 'package:flutter/material.dart';
import '../../models/test_config.dart';
import 'section_card.dart';

class BackgroundSelector extends StatelessWidget {
  final Fondo fondo;
  final bool distractor;
  final bool animado;
  final ValueChanged<Fondo> onFondoChanged;
  final ValueChanged<bool> onDistractorChanged;
  final ValueChanged<bool> onAnimadoChanged;

  const BackgroundSelector({
    super.key,
    required this.fondo,
    required this.distractor,
    required this.animado,
    required this.onFondoChanged,
    required this.onDistractorChanged,
    required this.onAnimadoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Fondo y distractor',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<Fondo>(
            segments: const [
              ButtonSegment(value: Fondo.claro, label: Text('Claro')),
              ButtonSegment(value: Fondo.oscuro, label: Text('Oscuro')),
              ButtonSegment(value: Fondo.azul, label: Text('Azul')),
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
          if (distractor) ...[
            const SizedBox(height: 8),
            SwitchListTile(
              value: animado,
              onChanged: onAnimadoChanged,
              title: const Text('Animar distractor'),
              subtitle: const Text(
                'Activa un movimiento leve del patrón para aumentar la dificultad visual.',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
