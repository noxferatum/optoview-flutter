import 'package:flutter/material.dart';
import 'macdonald_config.dart';

@immutable
class MacDonaldResult {
  final MacDonaldConfig config;
  final bool completedNaturally;
  final int durationActualSeconds;
  final DateTime startedAt;
  final DateTime finishedAt;
  final int totalLetrasShown;
  final int correctTouches;
  final int incorrectTouches;
  final int missedLetras;
  final List<double> reactionTimesMs;
  final int anillosCompletados;
  final List<double> tiempoPorAnillo;

  const MacDonaldResult({
    required this.config,
    required this.completedNaturally,
    required this.durationActualSeconds,
    required this.startedAt,
    required this.finishedAt,
    required this.totalLetrasShown,
    required this.correctTouches,
    required this.incorrectTouches,
    required this.missedLetras,
    required this.reactionTimesMs,
    required this.anillosCompletados,
    required this.tiempoPorAnillo,
  });

  double get accuracy {
    final totalTargets = correctTouches + missedLetras;
    if (totalTargets <= 0) return 0;
    return correctTouches / totalTargets;
  }

  double get avgReactionTimeMs {
    if (reactionTimesMs.isEmpty) return 0;
    return reactionTimesMs.reduce((a, b) => a + b) / reactionTimesMs.length;
  }

  double get bestReactionTimeMs {
    if (reactionTimesMs.isEmpty) return 0;
    return reactionTimesMs.reduce((a, b) => a < b ? a : b);
  }

  double get worstReactionTimeMs {
    if (reactionTimesMs.isEmpty) return 0;
    return reactionTimesMs.reduce((a, b) => a > b ? a : b);
  }
}
