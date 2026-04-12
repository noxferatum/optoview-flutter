import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../design_system/opto_glass_panel.dart';
import '../../theme/opto_colors.dart';

/// Botones de control (pausar/reanudar + terminar) como pastillas de cristal.
class TestControlButtons extends StatelessWidget {
  const TestControlButtons({
    super.key,
    required this.isPaused,
    required this.onTogglePause,
    required this.onStop,
  });

  final bool isPaused;
  final VoidCallback onTogglePause;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Positioned(
      top: 12,
      right: 12,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onTogglePause,
            child: OptoGlassPanel(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPaused ? Icons.play_arrow : Icons.pause,
                    size: 14,
                    color: OptoColors.warning,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isPaused ? l.testResume : l.testPause,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: OptoColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onStop,
            child: OptoGlassPanel(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stop, size: 14, color: OptoColors.error),
                  const SizedBox(width: 6),
                  Text(
                    l.testStop,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: OptoColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
