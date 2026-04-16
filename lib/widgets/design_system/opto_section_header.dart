import 'package:flutter/material.dart';
import '../../theme/opto_colors.dart';
import '../../theme/opto_spacing.dart';

class OptoSectionHeader extends StatelessWidget {
  const OptoSectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.description,
  });

  final String title;
  final IconData? icon;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: OptoSpacing.sm),
            ],
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: OptoSpacing.xs),
          Text(
            description!,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
