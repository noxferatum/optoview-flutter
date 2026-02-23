import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
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
    final l = AppLocalizations.of(context)!;
    return SectionCard(
      title: l.backgroundTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<Fondo>(
            segments: [
              ButtonSegment(value: Fondo.claro, label: Text(l.backgroundLight)),
              ButtonSegment(value: Fondo.oscuro, label: Text(l.backgroundDark)),
              ButtonSegment(value: Fondo.azul, label: Text(l.backgroundBlue)),
            ],
            selected: {fondo},
            onSelectionChanged: (s) => onFondoChanged(s.first),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            value: distractor,
            onChanged: onDistractorChanged,
            title: Text(l.backgroundDistractor),
            subtitle: Text(l.backgroundDistractorSubtitle),
          ),
          if (distractor) ...[
            const SizedBox(height: 8),
            SwitchListTile(
              value: animado,
              onChanged: onAnimadoChanged,
              title: Text(l.backgroundAnimate),
              subtitle: Text(l.backgroundAnimateSubtitle),
            ),
          ],
        ],
      ),
    );
  }
}
