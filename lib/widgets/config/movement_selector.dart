// lib/widgets/config/movement_selector.dart
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
    return _SectionCard(
      title: 'Movimiento del estímulo',
      child: SegmentedButton<Movimiento>(
        segments: const [
          ButtonSegment(value: Movimiento.fijo, label: Text('Fijo')),
          // Renombrado: antes decía "Vertical"
          ButtonSegment(value: Movimiento.vertical, label: Text('Movimiento')),
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
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
