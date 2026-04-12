import 'package:flutter/material.dart';
import '../../theme/opto_colors.dart';
import '../../theme/opto_spacing.dart';

class OptoCard extends StatelessWidget {
  const OptoCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(OptoSpacing.md),
      decoration: BoxDecoration(
        color: OptoColors.surfaceDark,
        borderRadius: BorderRadius.circular(OptoSpacing.radiusCard),
        border: Border.all(color: OptoColors.surfaceVariantDark),
      ),
      child: child,
    );
  }
}
