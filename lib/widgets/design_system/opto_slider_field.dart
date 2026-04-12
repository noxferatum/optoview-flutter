import 'package:flutter/material.dart';
import '../../theme/opto_colors.dart';

class OptoSliderField extends StatelessWidget {
  const OptoSliderField({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.unit = '',
    this.formatValue,
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final int? divisions;
  final String unit;
  final String Function(double)? formatValue;

  @override
  Widget build(BuildContext context) {
    final display = formatValue?.call(value) ?? value.toStringAsFixed(0);
    return Row(
      children: [
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: OptoColors.primary,
              inactiveTrackColor: OptoColors.surfaceVariantDark,
              thumbColor: OptoColors.primary,
              overlayColor: OptoColors.primary.withAlpha(31),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 56,
          child: Text(
            '$display$unit',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: OptoColors.onSurfaceDark,
            ),
          ),
        ),
      ],
    );
  }
}
