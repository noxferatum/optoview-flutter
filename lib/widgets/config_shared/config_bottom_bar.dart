import 'package:flutter/material.dart';
import '../../theme/opto_colors.dart';
import '../../theme/opto_spacing.dart';

/// Barra inferior fija con resumen de configuración + botón de iniciar.
class ConfigBottomBar extends StatelessWidget {
  const ConfigBottomBar({
    super.key,
    required this.summary,
    required this.onStart,
    required this.startLabel,
  });

  final String summary;
  final VoidCallback onStart;
  final String startLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: OptoColors.surfaceDark,
        border: Border(top: BorderSide(color: OptoColors.surfaceVariantDark)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              summary,
              style: const TextStyle(fontSize: 11, color: OptoColors.onSurfaceVariantDark),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: onStart,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: OptoColors.primary,
                borderRadius: BorderRadius.circular(OptoSpacing.radiusChip),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_arrow, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(startLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
