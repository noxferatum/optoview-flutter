import 'package:flutter/material.dart';
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
    return Column(
      children: [
        SectionCard(
          title: 'Tipo de estímulo',
          child: SegmentedButton<SimboloCategoria>(
            segments: const [
              ButtonSegment(
                value: SimboloCategoria.letras,
                label: _SegmentLabel(icon: Icons.translate, text: 'Letras'),
              ),
              ButtonSegment(
                value: SimboloCategoria.numeros,
                label: _SegmentLabel(icon: Icons.pin, text: 'Números'),
              ),
              ButtonSegment(
                value: SimboloCategoria.formas,
                label: _SegmentLabel(
                    icon: Icons.category_outlined, text: 'Formas'),
              ),
            ],
            selected: {categoria},
            onSelectionChanged: (s) => onCategoriaChanged(s.first),
          ),
        ),
        if (categoria == SimboloCategoria.formas)
          SectionCard(
            title: 'Forma (opcional)',
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                ...Forma.values.map((f) {
                  final isSelected = f == forma;
                  return ChoiceChip(
                    key: ValueKey(f.name),
                    label: _FormaLabel(
                      icon: _iconForForma(f),
                      text: f.label,
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
                  label: const _FormaLabel(
                    icon: Icons.all_inclusive,
                    text: 'Aleatoria',
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

class _SegmentLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SegmentLabel({required this.icon, required this.text});

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

class _FormaLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FormaLabel({required this.icon, required this.text});

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
