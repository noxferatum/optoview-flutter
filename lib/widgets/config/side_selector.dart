import 'package:flutter/material.dart';
import '../../models/test_config.dart';
import 'section_card.dart';

class SideSelector extends StatelessWidget {
  final Lado value;
  final ValueChanged<Lado> onChanged;

  const SideSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Lado de estimulación',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<Lado>(
            segments: const [
              ButtonSegment(value: Lado.izquierda, label: Text('Izquierda')),
              ButtonSegment(value: Lado.derecha, label: Text('Derecha')),
              ButtonSegment(value: Lado.arriba, label: Text('Arriba')),
              ButtonSegment(value: Lado.abajo, label: Text('Abajo')),
              ButtonSegment(value: Lado.ambos, label: Text('Ambos')),
              ButtonSegment(value: Lado.aleatorio, label: Text('Aleatorio')),
            ],
            selected: {value},
            onSelectionChanged: (s) => onChanged(s.first),
          ),
          const SizedBox(height: 12),
          Text(
            _descripcionLado(value),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _descripcionLado(Lado l) => switch (l) {
        Lado.izquierda =>
          'Los estímulos aparecerán únicamente en el lado izquierdo de la pantalla.',
        Lado.derecha =>
          'Los estímulos aparecerán únicamente en el lado derecho de la pantalla.',
        Lado.ambos => 'Los estímulos podrán aparecer en ambos lados.',
        Lado.arriba =>
          'Los estímulos aparecerán únicamente en la parte superior.',
        Lado.abajo =>
          'Los estímulos aparecerán únicamente en la parte inferior.',
        Lado.aleatorio =>
          'El lado de aparición de los estímulos será aleatorio en cada ciclo.',
      };
}
