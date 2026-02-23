import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// Botones de control (pausar/reanudar + terminar) para los tests.
class TestControlButtons extends StatelessWidget {
  final bool isPaused;
  final VoidCallback onTogglePause;
  final VoidCallback onStop;

  const TestControlButtons({
    super.key,
    required this.isPaused,
    required this.onTogglePause,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Positioned(
      top: 24,
      right: 24,
      child: Row(
        children: [
          Semantics(
            button: true,
            label: isPaused ? l.testResume : l.testPause,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.black45,
              ),
              onPressed: onTogglePause,
              icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
              label: Text(isPaused ? l.testResume : l.testPause),
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            label: l.testStop,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.black45,
              ),
              onPressed: onStop,
              icon: const Icon(Icons.stop),
              label: Text(l.testStop),
            ),
          ),
        ],
      ),
    );
  }
}
