import 'package:flutter_test/flutter_test.dart';
import 'package:optoview_flutter/models/field_detection_config.dart';
import 'package:optoview_flutter/models/field_detection_result.dart';
import 'package:optoview_flutter/models/macdonald_result.dart' show LetterEvent;

void main() {
  // Dataset determinista:
  //  e1 ring0 topLeft     hit  -> rt 100
  //  e2 ring0 topRight    miss
  //  e3 ring1 bottomLeft  hit  -> rt 200
  //  e4 ring1 bottomRight hit  -> rt 300
  //  e5 ring1 topRight    miss
  // reactionTimesMs está alineado con el ORDEN de aciertos: [100, 200, 300].
  const events = [
    LetterEvent(dx: -0.5, dy: -0.5, ringIndex: 0, isHit: true),
    LetterEvent(dx: 0.5, dy: -0.5, ringIndex: 0, isHit: false),
    LetterEvent(dx: -0.5, dy: 0.5, ringIndex: 1, isHit: true),
    LetterEvent(dx: 0.5, dy: 0.5, ringIndex: 1, isHit: true),
    LetterEvent(dx: 0.5, dy: -0.5, ringIndex: 1, isHit: false),
  ];

  FieldDetectionResult buildResult({
    List<LetterEvent> letterEvents = events,
    List<double> reactionTimesMs = const [100, 200, 300],
    int correctCount = 3,
    int missedCount = 2,
  }) {
    return FieldDetectionResult(
      config: FieldDetectionConfig.standard,
      patientName: 'Test',
      completedNaturally: true,
      startedAt: DateTime(2026, 1, 1, 10),
      finishedAt: DateTime(2026, 1, 1, 10, 5),
      totalLetrasShown: letterEvents.length,
      correctCount: correctCount,
      missedCount: missedCount,
      reactionTimesMs: reactionTimesMs,
      letterEvents: letterEvents,
      tiempoPorAnillo: const [1000, 2000],
      totalDurationMs: 300000,
    );
  }

  group('métricas globales', () {
    test('accuracy = aciertos / (aciertos + fallos)', () {
      expect(buildResult().accuracy, closeTo(0.6, 1e-9)); // 3/5
    });

    test('accuracy es 0 cuando no hay letras', () {
      final r = buildResult(
        letterEvents: const [],
        reactionTimesMs: const [],
        correctCount: 0,
        missedCount: 0,
      );
      expect(r.accuracy, 0);
    });

    test('tiempos de reacción medio/mejor/peor', () {
      final r = buildResult();
      expect(r.avgReactionTimeMs, closeTo(200, 1e-9));
      expect(r.bestReactionTimeMs, 100);
      expect(r.worstReactionTimeMs, 300);
    });

    test('tiempos de reacción son 0 sin aciertos', () {
      final r = buildResult(reactionTimesMs: const []);
      expect(r.avgReactionTimeMs, 0);
      expect(r.bestReactionTimeMs, 0);
      expect(r.worstReactionTimeMs, 0);
    });
  });

  group('métricas por anillo', () {
    test('hits/misses por anillo', () {
      final r = buildResult();
      expect(r.hitsByRing, {0: 1, 1: 2});
      expect(r.missesByRing, {0: 1, 1: 1});
    });

    test('accuracyByRing cubre todos los anillos del config (0 si vacío)', () {
      final acc = buildResult().accuracyByRing;
      expect(acc.length, FieldDetectionConfig.standard.numAnillos); // 5
      expect(acc[0], closeTo(0.5, 1e-9)); // 1/2
      expect(acc[1], closeTo(2 / 3, 1e-9));
      expect(acc[2], 0);
      expect(acc[4], 0);
    });

    test('avgRtByRing empareja tiempos a aciertos por orden', () {
      final rt = buildResult().avgRtByRing;
      expect(rt[0], closeTo(100, 1e-9)); // [100]
      expect(rt[1], closeTo(250, 1e-9)); // [200, 300]
      expect(rt[2], 0);
    });
  });

  group('métricas por cuadrante', () {
    test('quadrantOf clasifica por signo de dx/dy', () {
      expect(
        FieldDetectionResult.quadrantOf(
            const LetterEvent(dx: -0.1, dy: -0.1, ringIndex: 0, isHit: true)),
        FieldQuadrant.topLeft,
      );
      expect(
        FieldDetectionResult.quadrantOf(
            const LetterEvent(dx: 0.1, dy: -0.1, ringIndex: 0, isHit: true)),
        FieldQuadrant.topRight,
      );
      expect(
        FieldDetectionResult.quadrantOf(
            const LetterEvent(dx: -0.1, dy: 0.1, ringIndex: 0, isHit: true)),
        FieldQuadrant.bottomLeft,
      );
      expect(
        FieldDetectionResult.quadrantOf(
            const LetterEvent(dx: 0.1, dy: 0.1, ringIndex: 0, isHit: true)),
        FieldQuadrant.bottomRight,
      );
    });

    test('hits/misses por cuadrante', () {
      final r = buildResult();
      expect(r.hitsByQuadrant, {
        FieldQuadrant.topLeft: 1,
        FieldQuadrant.bottomLeft: 1,
        FieldQuadrant.bottomRight: 1,
      });
      expect(r.missesByQuadrant, {FieldQuadrant.topRight: 2});
    });

    test('accuracyByQuadrant cubre los 4 cuadrantes', () {
      final acc = buildResult().accuracyByQuadrant;
      expect(acc.length, 4);
      expect(acc[FieldQuadrant.topLeft], 1);
      expect(acc[FieldQuadrant.topRight], 0); // 0/2
      expect(acc[FieldQuadrant.bottomLeft], 1);
      expect(acc[FieldQuadrant.bottomRight], 1);
    });

    test('avgRtByQuadrant empareja tiempos a aciertos por orden', () {
      final rt = buildResult().avgRtByQuadrant;
      expect(rt[FieldQuadrant.topLeft], closeTo(100, 1e-9));
      expect(rt[FieldQuadrant.bottomLeft], closeTo(200, 1e-9));
      expect(rt[FieldQuadrant.bottomRight], closeTo(300, 1e-9));
      expect(rt[FieldQuadrant.topRight], 0); // sin aciertos
    });
  });
}
