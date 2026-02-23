import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/test_config.dart';
import 'section_card.dart';

class StimulusColorSelector extends StatelessWidget {
  final EstimuloColor value;
  final ValueChanged<EstimuloColor> onChanged;

  const StimulusColorSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SectionCard(
      title: l.colorTitle,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: EstimuloColor.values
            .map(
              (option) => ChoiceChip(
                label: _ColorChipLabel(option: option),
                selected: value == option,
                onSelected: (_) => onChanged(option),
              ),
            )
            .toList(),
      ),
    );
  }
}

String _colorLabel(AppLocalizations l, EstimuloColor c) => switch (c) {
      EstimuloColor.rojo => l.colorRed,
      EstimuloColor.verde => l.colorGreen,
      EstimuloColor.azul => l.colorBlue,
      EstimuloColor.amarillo => l.colorYellow,
      EstimuloColor.blanco => l.colorWhite,
      EstimuloColor.morado => l.colorPurple,
      EstimuloColor.negro => l.colorBlack,
      EstimuloColor.aleatorio => l.colorRandom,
    };

class _ColorChipLabel extends StatelessWidget {
  final EstimuloColor option;

  const _ColorChipLabel({required this.option});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final bool isRandom = option.isRandom;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isRandom)
          const Icon(Icons.all_inclusive, size: 18)
        else
          _ColorDot(color: option.color),
        const SizedBox(width: 6),
        Text(_colorLabel(l, option)),
      ],
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  const _ColorDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 4,
            spreadRadius: 0.5,
          ),
        ],
      ),
    );
  }
}
