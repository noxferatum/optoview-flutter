import 'package:flutter/material.dart';
import '../../theme/opto_colors.dart';
import '../../theme/opto_spacing.dart';

enum OptoButtonVariant { primary, secondary, danger }

class OptoActionButton extends StatefulWidget {
  const OptoActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = OptoButtonVariant.primary,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final OptoButtonVariant variant;

  @override
  State<OptoActionButton> createState() => _OptoActionButtonState();
}

class _OptoActionButtonState extends State<OptoActionButton> {
  bool _pressed = false;

  Color get _bg => switch (widget.variant) {
    OptoButtonVariant.primary => OptoColors.primary,
    OptoButtonVariant.secondary => OptoColors.surfaceVariantDark,
    OptoButtonVariant.danger => OptoColors.error.withAlpha(26),
  };

  Color get _fg => switch (widget.variant) {
    OptoButtonVariant.primary => Colors.white,
    OptoButtonVariant.secondary => OptoColors.onSurfaceVariantDark,
    OptoButtonVariant.danger => OptoColors.error,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(OptoSpacing.radiusChip),
            border: widget.variant == OptoButtonVariant.danger
                ? Border.all(color: OptoColors.error.withAlpha(77))
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 16, color: _fg),
                const SizedBox(width: 6),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
