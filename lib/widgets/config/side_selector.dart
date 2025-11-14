import 'package:flutter/material.dart';
import '../../models/test_config.dart';

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
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Lado de estimulación',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // Selector de lado
            SegmentedButton<Lado>(
              segments: const [
                ButtonSegment(
                  value: Lado.izquierda,
                  label: Text('Izquierda'),
                ),
                ButtonSegment(
                  value: Lado.derecha,
                  label: Text('Derecha'),
                ),
                ButtonSegment(
                  value: Lado.arriba,
                  label: Text('Arriba'),
                ),
                ButtonSegment(
                  value: Lado.abajo,
                  label: Text('Abajo'),
                ),
                ButtonSegment(
                  value: Lado.ambos,
                  label: Text('Ambos'),
                ),
                ButtonSegment(
                  value: Lado.aleatorio,
                  label: Text('Aleatorio'),
                ),
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
      ),
    );
  }

  String _descripcionLado(Lado l) {
    switch (l) {
      case Lado.izquierda:
        return 'Los estímulos aparecerán únicamente en el lado izquierdo de la pantalla.';
      case Lado.derecha:
        return 'Los estímulos aparecerán únicamente en el lado derecho de la pantalla.';
      case Lado.ambos:
        return 'Los estímulos podrán aparecer en ambos lados.';
      case Lado.arriba:
        return 'Los estímulos aparecerán únicamente en la parte superior.';
      case Lado.abajo:
        return 'Los estímulos aparecerán únicamente en la parte inferior.';
      case Lado.aleatorio:
        return 'El lado de aparición de los estímulos será aleatorio en cada ciclo.';
    }
  }
}
