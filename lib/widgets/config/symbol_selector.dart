import 'package:flutter/material.dart';
import '../../models/test_config.dart';

class SymbolSelector extends StatelessWidget {
  final SimboloCategoria categoria;
  final Forma? forma; // null = aleatoria
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
        _SectionCard(
          title: 'Tipo de estímulo',
          child: SegmentedButton<SimboloCategoria>(
            segments: const [
              ButtonSegment(
                value: SimboloCategoria.letras,
                label: Text('Letras'),
              ),
              ButtonSegment(
                value: SimboloCategoria.numeros,
                label: Text('Números'),
              ),
              ButtonSegment(
                value: SimboloCategoria.formas,
                label: Text('Formas'),
              ),
            ],
            selected: {categoria},
            onSelectionChanged: (s) => onCategoriaChanged(s.first),
          ),
        ),
        if (categoria == SimboloCategoria.formas)
          _SectionCard(
            title: 'Forma (opcional)',
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  key: const ValueKey('aleatoria'),
                  label: const Text('Aleatoria'),
                  selected: forma == null,
                  onSelected: (selected) {
                    if (selected) {
                      onFormaChanged(null);
                    }
                  },
                  selectedColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.25),
                ),
                ...Forma.values.map((f) {
                  final isSelected = f == forma;
                  return ChoiceChip(
                    key: ValueKey(f.name),
                    label: Text(_labelForma(f)),
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
                        .withOpacity(0.25),
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  String _labelForma(Forma f) {
    switch (f) {
      case Forma.circulo:
        return 'Círculo';
      case Forma.cuadrado:
        return 'Cuadrado';
      case Forma.corazon:
        return 'Corazón';
      case Forma.triangulo:
        return 'Triángulo';
      case Forma.trebol:
        return 'Trébol';
    }
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
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
