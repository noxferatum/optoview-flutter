import 'package:flutter/material.dart';
import '../../models/test_config.dart';

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
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Color del estímulo',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
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
          ],
        ),
      ),
    );
  }
}

class _ColorChipLabel extends StatelessWidget {
  final EstimuloColor option;

  const _ColorChipLabel({required this.option});

  @override
  Widget build(BuildContext context) {
    final bool isRandom = option.isRandom;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isRandom)
          const Icon(Icons.all_inclusive, size: 18)
        else
          _ColorDot(color: option.color),
        const SizedBox(width: 6),
        Text(option.label),
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
