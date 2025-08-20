// lib/widgets/config/side_selector.dart
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
    return _SectionCard(
      title: 'Lado de estimulación',
      child: SegmentedButton<Lado>(
        segments: const [
          ButtonSegment(value: Lado.izquierda, label: Text('Izq.')),
          ButtonSegment(value: Lado.derecha, label: Text('Der.')),
          ButtonSegment(value: Lado.arriba, label: Text('Arriba')),
          ButtonSegment(value: Lado.abajo, label: Text('Abajo')),
          ButtonSegment(value: Lado.ambos, label: Text('Aleatorio')),
        ],
        selected: {value},
        onSelectionChanged: (s) => onChanged(s.first),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
