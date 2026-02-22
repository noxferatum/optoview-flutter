import 'package:flutter/material.dart';
import 'localization_config.dart';

@immutable
class LocalizationResult {
  final LocalizationConfig config;
  final int totalStimuliShown;
  final int correctTouches;
  final int incorrectTouches;
  final int missedStimuli;
  final List<double> reactionTimesMs;
  final int durationActualSeconds;
  final bool completedNaturally;
  final DateTime startedAt;
  final DateTime finishedAt;

  const LocalizationResult({
    required this.config,
    required this.totalStimuliShown,
    required this.correctTouches,
    required this.incorrectTouches,
    required this.missedStimuli,
    required this.reactionTimesMs,
    required this.durationActualSeconds,
    required this.completedNaturally,
    required this.startedAt,
    required this.finishedAt,
  });

  double get accuracy {
    final totalTargets = correctTouches + missedStimuli;
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

  double get stimuliPerMinute {
    if (durationActualSeconds <= 0) return 0;
    return totalStimuliShown / (durationActualSeconds / 60);
  }
}
