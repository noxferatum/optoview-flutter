import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/test_config.dart';
import 'section_card.dart';

class SymbolSelector extends StatelessWidget {
  final SimboloCategoria categoria;
  final Forma? forma;
  final ValueChanged<SimboloCategoria> onCategoriaChanged;
  final ValueChanged<Forma?> onFormaChanged;
  final VoidCallback onFormaClear;

  const SymbolSelector({
    super.key,
    required this.categoria,
    required this.forma,
    required this.onCategoriaChanged,
    required this.onFormaChanged,
    required this.onFormaClear,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      children: [
        SectionCard(
          title: l.symbolTitle,
          child: SegmentedButton<SimboloCategoria>(
            segments: [
              ButtonSegment(
                value: SimboloCategoria.letras,
                label: _IconLabel(icon: Icons.translate, text: l.symbolLetters),
              ),
              ButtonSegment(
                value: SimboloCategoria.numeros,
                label: _IconLabel(icon: Icons.pin, text: l.symbolNumbers),
              ),
              ButtonSegment(
                value: SimboloCategoria.formas,
                label: _IconLabel(
                    icon: Icons.category_outlined, text: l.symbolShapes),
              ),
            ],
            selected: {categoria},
            onSelectionChanged: (s) => onCategoriaChanged(s.first),
          ),
        ),
        if (categoria == SimboloCategoria.formas)
          SectionCard(
            title: l.symbolFormTitle,
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                ...Forma.values.map((f) {
                  final isSelected = f == forma;
                  return ChoiceChip(
                    key: ValueKey(f.name),
                    label: _IconLabel(
                      icon: _iconForForma(f),
                      text: _formaLabel(l, f),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        onFormaChanged(f);
                      } else {
                        onFormaChanged(null);
                      }
                    },
                    selectedColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.25),
                  );
                }),
                ChoiceChip(
                  key: const ValueKey('aleatoria'),
                  label: _IconLabel(
                    icon: Icons.all_inclusive,
                    text: l.symbolFormRandom,
                  ),
                  selected: forma == null,
                  onSelected: (selected) {
                    if (selected) onFormaChanged(null);
                  },
                  selectedColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.25),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

String _formaLabel(AppLocalizations l, Forma f) => switch (f) {
      Forma.circulo => l.formaCircle,
      Forma.cuadrado => l.formaSquare,
      Forma.corazon => l.formaHeart,
      Forma.triangulo => l.formaTriangle,
      Forma.trebol => l.formaClover,
    };

class _IconLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  const _IconLabel({required this.icon, required this.text});

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

IconData _iconForForma(Forma forma) => switch (forma) {
      Forma.circulo => Icons.circle,
      Forma.cuadrado => Icons.check_box_outline_blank,
      Forma.corazon => Icons.favorite_border,
      Forma.triangulo => Icons.change_history,
      Forma.trebol => Icons.filter_vintage,
    };
