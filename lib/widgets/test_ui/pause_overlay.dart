import 'dart:ui';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/opto_colors.dart';

/// Overlay con blur mostrado cuando la prueba está en pausa.
/// Muestra estadísticas de progreso y botones de reanudar/terminar.
class PauseOverlay extends StatelessWidget {
  const PauseOverlay({
    super.key,
    required this.remainingSeconds,
    required this.elapsedSeconds,
    required this.stimuliShown,
    required this.onResume,
    required this.onStop,
  });

  final int remainingSeconds;
  final int elapsedSeconds;
  final int stimuliShown;
  final VoidCallback onResume;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Positioned.fill(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            color: const Color(0xFF0F1216).withAlpha(217),
            alignment: Alignment.center,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 340),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
              decoration: BoxDecoration(
                color: OptoColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: OptoColors.surfaceVariantDark),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pause icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: OptoColors.warning.withAlpha(31),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.pause, size: 24, color: OptoColors.warning),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l.testPaused,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: OptoColors.onSurfaceDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.testPauseHint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: OptoColors.onSurfaceVariantDark),
                  ),
                  const SizedBox(height: 20),
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _PauseStat(value: '$remainingSeconds', label: l.testStatRemaining),
                      _PauseStat(value: '$elapsedSeconds', label: l.testStatElapsed),
                      _PauseStat(value: '$stimuliShown', label: l.testStatStimuli),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: onStop,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: OptoColors.surfaceVariantDark,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.stop, size: 16, color: OptoColors.error),
                              const SizedBox(width: 6),
                              Text(l.testStop, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: OptoColors.error)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: onResume,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: OptoColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.play_arrow, size: 16, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(l.testResume, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PauseStat extends StatelessWidget {
  const _PauseStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: OptoColors.onSurfaceDark)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: OptoColors.onSurfaceVariantDark, letterSpacing: 0.5)),
      ],
    );
  }
}
