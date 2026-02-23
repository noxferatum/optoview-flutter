import 'package:flutter/material.dart';

/// Muestra el tiempo restante (y opcionalmente más info) en la esquina
/// superior izquierda del test.
class TestTimerDisplay extends StatelessWidget {
  final String text;

  const TestTimerDisplay({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 24,
      left: 24,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
