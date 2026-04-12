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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: OptoColors.onSurfaceVariantDark),
              const SizedBox(width: OptoSpacing.sm),
            ],
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: OptoColors.onSurfaceVariantDark,
              ),
            ),
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: OptoSpacing.xs),
          Text(
            description!,
            style: const TextStyle(
              fontSize: 12,
              color: OptoColors.onSurfaceVariantDark,
            ),
          ),
        ],
      ],
    );
  }
}
