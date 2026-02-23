import 'package:flutter/material.dart';
import 'test_config.dart';

@immutable
class TestResult {
  final TestConfig config;
  final int totalStimuliShown;
  final int durationActualSeconds;
  final bool completedNaturally;
  final DateTime startedAt;
  final DateTime finishedAt;

  const TestResult({
    required this.config,
    required this.totalStimuliShown,
    required this.durationActualSeconds,
    required this.completedNaturally,
    required this.startedAt,
    required this.finishedAt,
  });

  double get stimuliPerMinute {
    if (durationActualSeconds <= 0) return 0;
    return totalStimuliShown / (durationActualSeconds / 60);
  }
}
