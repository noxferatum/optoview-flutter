import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/opto_colors.dart';
import '../../theme/opto_spacing.dart';

class OptoGlassPanel extends StatelessWidget {
  const OptoGlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.blurSigma = 8.0,
    this.bgOpacity = 0.7,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double blurSigma;
  final double bgOpacity;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(OptoSpacing.radiusPill),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding ?? const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: OptoColors.backgroundDark.withAlpha((bgOpacity * 255).round()),
            borderRadius: BorderRadius.circular(OptoSpacing.radiusPill),
            border: Border.all(
              color: Colors.white.withAlpha(15),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
