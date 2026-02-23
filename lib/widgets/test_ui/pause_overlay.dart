import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// Overlay semitransparente mostrado cuando la prueba está en pausa.
class PauseOverlay extends StatelessWidget {
  final int remainingSeconds;
  final VoidCallback onResume;
  final VoidCallback onStop;

  const PauseOverlay({
    super.key,
    required this.remainingSeconds,
    required this.onResume,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.pause_circle_filled,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                l.testPaused,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.testTimeRemaining(remainingSeconds),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton.icon(
                    onPressed: onResume,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(l.testResume),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                    ),
                    onPressed: onStop,
                    icon: const Icon(Icons.stop),
                    label: Text(l.testStop),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
