import 'package:flutter/material.dart';
import '../../models/test_config.dart';
import 'section_card.dart';

class FixationSelector extends StatelessWidget {
  final Fijacion value;
  final ValueChanged<Fijacion> onChanged;

  const FixationSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Punto de fijación',
      child: SegmentedButton<Fijacion>(
        segments: [
          ButtonSegment(
            value: Fijacion.cara,
            label: _FixationLabel(icon: Icons.face, text: 'Cara'),
          ),
          ButtonSegment(
            value: Fijacion.ojo,
            label: _FixationLabel(icon: Icons.remove_red_eye, text: 'Ojo'),
          ),
          ButtonSegment(
            value: Fijacion.punto,
            label: _FixationLabel(icon: Icons.circle, text: 'Punto'),
          ),
          ButtonSegment(
            value: Fijacion.trebol,
            label:
                _FixationLabel(icon: Icons.filter_vintage, text: 'Trébol'),
          ),
          ButtonSegment(
            value: Fijacion.cruz,
            label: _FixationLabel(icon: Icons.add, text: 'Cruz'),
          ),
        ],
        selected: {value},
        onSelectionChanged: (s) => onChanged(s.first),
      ),
    );
  }
}

class _FixationLabel extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FixationLabel({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }
}
