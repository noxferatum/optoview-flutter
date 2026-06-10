import 'package:flutter/material.dart';
import 'field_detection_config.dart';
import 'macdonald_result.dart' show LetterEvent;

/// Cuadrante del campo visual respecto al punto de fijación.
enum FieldQuadrant { topLeft, topRight, bottomLeft, bottomRight }

@immutable
class FieldDetectionResult {
  final FieldDetectionConfig config;
  final String patientName;
  final bool completedNaturally;
  final DateTime startedAt;
  final DateTime finishedAt;
  final int totalLetrasShown;
  final int correctCount;
  final int missedCount;
  final List<double> reactionTimesMs; // sólo aciertos
  final List<LetterEvent> letterEvents;
  final List<double> tiempoPorAnillo; // ms desde primera letra del anillo a última
  final int totalDurationMs;

  const FieldDetectionResult({
    required this.config,
    required this.patientName,
    required this.completedNaturally,
    required this.startedAt,
    required this.finishedAt,
    required this.totalLetrasShown,
    required this.correctCount,
    required this.missedCount,
    required this.reactionTimesMs,
    required this.letterEvents,
    required this.tiempoPorAnillo,
    required this.totalDurationMs,
  });

  double get accuracy {
    final total = correctCount + missedCount;
    if (total <= 0) return 0;
    return correctCount / total;
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

  // Métricas por anillo
  Map<int, int> get hitsByRing {
    final m = <int, int>{};
    for (final e in letterEvents) {
      if (e.isHit) m[e.ringIndex] = (m[e.ringIndex] ?? 0) + 1;
    }
    return m;
  }

  Map<int, int> get missesByRing {
    final m = <int, int>{};
    for (final e in letterEvents) {
      if (!e.isHit) m[e.ringIndex] = (m[e.ringIndex] ?? 0) + 1;
    }
    return m;
  }

  Map<int, double> get accuracyByRing {
    final hits = hitsByRing;
    final misses = missesByRing;
    final out = <int, double>{};
    for (int r = 0; r < config.numAnillos; r++) {
      final h = hits[r] ?? 0;
      final m = misses[r] ?? 0;
      out[r] = (h + m) > 0 ? h / (h + m) : 0;
    }
    return out;
  }

  Map<int, double> get avgRtByRing {
    final hitTimesByRing = <int, List<double>>{};
    int hitIdx = 0;
    for (final e in letterEvents) {
      if (e.isHit) {
        if (hitIdx < reactionTimesMs.length) {
          hitTimesByRing
              .putIfAbsent(e.ringIndex, () => [])
              .add(reactionTimesMs[hitIdx]);
        }
        hitIdx++;
      }
    }
    final out = <int, double>{};
    for (int r = 0; r < config.numAnillos; r++) {
      final list = hitTimesByRing[r];
      out[r] = (list == null || list.isEmpty)
          ? 0
          : list.reduce((a, b) => a + b) / list.length;
    }
    return out;
  }

  /// Determina el cuadrante de un evento a partir de sus coordenadas
  /// normalizadas (-1..1 con origen en el centro de la pantalla).
  static FieldQuadrant quadrantOf(LetterEvent e) {
    final isLeft = e.dx < 0;
    final isTop = e.dy < 0;
    if (isTop && isLeft) return FieldQuadrant.topLeft;
    if (isTop && !isLeft) return FieldQuadrant.topRight;
    if (!isTop && isLeft) return FieldQuadrant.bottomLeft;
    return FieldQuadrant.bottomRight;
  }

  Map<FieldQuadrant, int> get hitsByQuadrant {
    final m = <FieldQuadrant, int>{};
    for (final e in letterEvents) {
      if (e.isHit) {
        final q = quadrantOf(e);
        m[q] = (m[q] ?? 0) + 1;
      }
    }
    return m;
  }

  Map<FieldQuadrant, int> get missesByQuadrant {
    final m = <FieldQuadrant, int>{};
    for (final e in letterEvents) {
      if (!e.isHit) {
        final q = quadrantOf(e);
        m[q] = (m[q] ?? 0) + 1;
      }
    }
    return m;
  }

  Map<FieldQuadrant, double> get accuracyByQuadrant {
    final hits = hitsByQuadrant;
    final misses = missesByQuadrant;
    final out = <FieldQuadrant, double>{};
    for (final q in FieldQuadrant.values) {
      final h = hits[q] ?? 0;
      final m = misses[q] ?? 0;
      out[q] = (h + m) > 0 ? h / (h + m) : 0;
    }
    return out;
  }

  Map<FieldQuadrant, double> get avgRtByQuadrant {
    final timesByQ = <FieldQuadrant, List<double>>{};
    int hitIdx = 0;
    for (final e in letterEvents) {
      if (e.isHit) {
        if (hitIdx < reactionTimesMs.length) {
          timesByQ
              .putIfAbsent(quadrantOf(e), () => [])
              .add(reactionTimesMs[hitIdx]);
        }
        hitIdx++;
      }
    }
    final out = <FieldQuadrant, double>{};
    for (final q in FieldQuadrant.values) {
      final list = timesByQ[q];
      out[q] = (list == null || list.isEmpty)
          ? 0
          : list.reduce((a, b) => a + b) / list.length;
    }
    return out;
  }
}
