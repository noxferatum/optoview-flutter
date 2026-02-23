import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
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
    final l = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return SectionCard(
      title: l.sideTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: Lado.values.map((lado) {
              final isSelected = lado == value;
              return ChoiceChip(
                label: Text(_ladoLabel(l, lado)),
                selected: isSelected,
                onSelected: (_) => onChanged(lado),
                selectedColor: colorScheme.primary.withValues(alpha: 0.25),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text(
            _descripcionLado(l, value),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _ladoLabel(AppLocalizations l, Lado lado) => switch (lado) {
        Lado.izquierda => l.sideLeft,
        Lado.derecha => l.sideRight,
        Lado.arriba => l.sideTop,
        Lado.abajo => l.sideBottom,
        Lado.ambos => l.sideBoth,
        Lado.aleatorio => l.sideRandom,
      };

  String _descripcionLado(AppLocalizations l, Lado lado) => switch (lado) {
        Lado.izquierda => l.sideDescLeft,
        Lado.derecha => l.sideDescRight,
        Lado.ambos => l.sideDescBoth,
        Lado.arriba => l.sideDescTop,
        Lado.abajo => l.sideDescBottom,
        Lado.aleatorio => l.sideDescRandom,
      };
}
