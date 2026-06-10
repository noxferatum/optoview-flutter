import 'package:flutter_test/flutter_test.dart';
import 'package:optoview_flutter/models/macdonald_presets.dart';
import 'package:optoview_flutter/models/macdonald_result.dart';

void main() {
  MacDonaldResult build({
    int correctTouches = 8,
    int missedLetras = 2,
    List<double> reactionTimesMs = const [50, 150, 250],
  }) {
    return MacDonaldResult(
      config: MacDonaldPresets.standard,
      patientName: 'Test',
      completedNaturally: true,
      durationActualSeconds: 90,
      startedAt: DateTime(2026, 1, 1, 10),
      finishedAt: DateTime(2026, 1, 1, 10, 1, 30),
      totalLetrasShown: 18,
      correctTouches: correctTouches,
      incorrectTouches: 1,
      missedLetras: missedLetras,
      reactionTimesMs: reactionTimesMs,
      anillosCompletados: 3,
      tiempoPorAnillo: const [1000, 2000, 3000],
    );
  }

  test('accuracy = correctTouches / (correctTouches + missedLetras)', () {
    expect(build().accuracy, closeTo(0.8, 1e-9)); // 8 / 10
  });

  test('accuracy es 0 cuando no hay objetivos', () {
    expect(build(correctTouches: 0, missedLetras: 0).accuracy, 0);
  });

  test('tiempos de reacción medio/mejor/peor', () {
    final r = build();
    expect(r.avgReactionTimeMs, closeTo(150, 1e-9));
    expect(r.bestReactionTimeMs, 50);
    expect(r.worstReactionTimeMs, 250);
  });

  test('tiempos de reacción son 0 sin lista', () {
    final r = build(reactionTimesMs: const []);
    expect(r.avgReactionTimeMs, 0);
    expect(r.bestReactionTimeMs, 0);
    expect(r.worstReactionTimeMs, 0);
  });
}
