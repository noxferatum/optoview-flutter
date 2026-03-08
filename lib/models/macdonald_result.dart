import 'package:flutter/material.dart';
import 'macdonald_config.dart';

/// Evento de una letra en el chart: posición normalizada + acierto/fallo.
@immutable
class LetterEvent {
  /// Posición X normalizada [-1, 1] respecto al centro del chart.
  final double dx;

  /// Posición Y normalizada [-1, 1] respecto al centro del chart.
  final double dy;

  final int ringIndex;
  final bool isHit;

  const LetterEvent({
    required this.dx,
    required this.dy,
    required this.ringIndex,
    required this.isHit,
  });

  Map<String, dynamic> toJson() => {
        'dx': dx,
        'dy': dy,
        'ringIndex': ringIndex,
        'isHit': isHit,
      };

  factory LetterEvent.fromJson(Map<String, dynamic> json) => LetterEvent(
        dx: (json['dx'] as num).toDouble(),
        dy: (json['dy'] as num).toDouble(),
        ringIndex: json['ringIndex'] as int,
        isHit: json['isHit'] as bool,
      );
}

@immutable
class MacDonaldResult {
  final MacDonaldConfig config;
  final String patientName;
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
  final List<LetterEvent> letterEvents;

  const MacDonaldResult({
    required this.config,
    required this.patientName,
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
    this.letterEvents = const [],
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
