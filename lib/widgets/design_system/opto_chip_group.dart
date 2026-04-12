import 'package:flutter/material.dart';
import '../../theme/opto_colors.dart';
import '../../theme/opto_spacing.dart';

class OptoChipItem<T> {
  const OptoChipItem({
    required this.value,
    required this.label,
    this.icon,
    this.color,
  });

  final T value;
  final String label;
  final IconData? icon;
  final Color? color;
}

class OptoChipGroup<T> extends StatelessWidget {
  const OptoChipGroup({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  final List<OptoChipItem<T>> items;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: items.map((item) {
        final isSelected = item.value == selected;
        return GestureDetector(
          onTap: () => onSelected(item.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? OptoColors.primary.withAlpha(38)
                  : OptoColors.surfaceVariantDark,
              borderRadius: BorderRadius.circular(OptoSpacing.radiusChip),
              border: Border.all(
                color: isSelected
                    ? OptoColors.primary.withAlpha(77)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.color != null) ...[
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                if (item.icon != null) ...[
                  Icon(
                    item.icon,
                    size: 14,
                    color: isSelected
                        ? OptoColors.peripheral
                        : OptoColors.onSurfaceVariantDark,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? OptoColors.peripheral
                        : OptoColors.onSurfaceVariantDark,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
