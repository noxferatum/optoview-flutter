// lib/widgets/config/speed_selector.dart
import 'package:flutter/material.dart';
import '../../models/test_config.dart';

class SpeedSelector extends StatelessWidget {
  final Velocidad value;
  final ValueChanged<Velocidad> onChanged;

  const SpeedSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Velocidad',
      child: SegmentedButton<Velocidad>(
        segments: const [
          ButtonSegment(value: Velocidad.lenta, label: Text('Lenta')),
          ButtonSegment(value: Velocidad.media, label: Text('Media')),
          ButtonSegment(value: Velocidad.rapida, label: Text('Rápida')),
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
