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

  Color _bg(ColorScheme cs) => switch (widget.variant) {
    OptoButtonVariant.primary => OptoColors.primary,
    OptoButtonVariant.secondary => cs.surfaceContainerHighest,
    OptoButtonVariant.danger => OptoColors.error.withAlpha(26),
  };

  Color _fg(ColorScheme cs) => switch (widget.variant) {
    OptoButtonVariant.primary => Colors.white,
    OptoButtonVariant.secondary => cs.onSurfaceVariant,
    OptoButtonVariant.danger => OptoColors.error,
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = _bg(cs);
    final fg = _fg(cs);
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
            color: bg,
            borderRadius: BorderRadius.circular(OptoSpacing.radiusChip),
            border: widget.variant == OptoButtonVariant.danger
                ? Border.all(color: OptoColors.error.withAlpha(77))
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 16, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
