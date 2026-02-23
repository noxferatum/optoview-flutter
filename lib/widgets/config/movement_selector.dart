import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
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
    final l = AppLocalizations.of(context)!;
    return SectionCard(
      title: l.movementTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<Movimiento>(
            segments: [
              ButtonSegment(value: Movimiento.fijo, label: Text(l.movementFixed)),
              ButtonSegment(
                  value: Movimiento.horizontal, label: Text(l.movementHorizontal)),
              ButtonSegment(
                  value: Movimiento.vertical, label: Text(l.movementVertical)),
              ButtonSegment(
                  value: Movimiento.aleatorio, label: Text(l.movementRandom)),
            ],
            selected: {value},
            onSelectionChanged: (s) => onChanged(s.first),
          ),
          const SizedBox(height: 12),
          Text(
            _descripcionMovimiento(l, value),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _descripcionMovimiento(AppLocalizations l, Movimiento m) => switch (m) {
        Movimiento.fijo => l.movementDescFixed,
        Movimiento.horizontal => l.movementDescHorizontal,
        Movimiento.vertical => l.movementDescVertical,
        Movimiento.aleatorio => l.movementDescRandom,
      };
}
