import 'package:flutter/material.dart';
import '../../models/test_config.dart';
import 'section_card.dart';

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
    return SectionCard(
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
