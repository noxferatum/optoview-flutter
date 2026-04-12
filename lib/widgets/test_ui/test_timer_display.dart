import 'package:flutter/material.dart';
import '../design_system/opto_glass_panel.dart';
import '../../theme/opto_colors.dart';

/// Muestra el tiempo restante (y opcionalmente estímulos) en la esquina
/// superior izquierda del test, dentro de un panel de cristal.
class TestTimerDisplay extends StatelessWidget {
  const TestTimerDisplay({
    super.key,
    required this.remainingSeconds,
    this.stimuliCount,
  });

  final int remainingSeconds;
  final int? stimuliCount;

  String get _formatted {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      left: 12,
      child: OptoGlassPanel(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer_outlined, size: 14, color: OptoColors.onSurfaceVariantDark),
            const SizedBox(width: 8),
            Text(
              _formatted,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: OptoColors.onSurfaceDark,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            if (stimuliCount != null) ...[
              Container(
                width: 1,
                height: 16,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: Colors.white.withAlpha(26),
              ),
              Text(
                '$stimuliCount est.',
                style: const TextStyle(
                  fontSize: 11,
                  color: OptoColors.onSurfaceVariantDark,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
