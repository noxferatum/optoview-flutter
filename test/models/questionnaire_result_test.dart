import 'package:flutter_test/flutter_test.dart';
import 'package:optoview_flutter/models/questionnaire_result.dart';

void main() {
  group('CvsqAnswer.score', () {
    test('score is 0 when frequency is never (intensity ignored)', () {
      const a = CvsqAnswer(frequency: CvsqFrequency.never, intensity: null);
      expect(a.score, 0);
      const b = CvsqAnswer(
        frequency: CvsqFrequency.never,
        intensity: CvsqIntensity.intense,
      );
      expect(b.score, 0);
    });

    test('score equals frequency * intensity when frequency > 0', () {
      const a = CvsqAnswer(
        frequency: CvsqFrequency.occasional,
        intensity: CvsqIntensity.moderate,
      );
      expect(a.score, 1);

      const b = CvsqAnswer(
        frequency: CvsqFrequency.occasional,
        intensity: CvsqIntensity.intense,
      );
      expect(b.score, 2);

      const c = CvsqAnswer(
        frequency: CvsqFrequency.habitual,
        intensity: CvsqIntensity.moderate,
      );
      expect(c.score, 2);

      const d = CvsqAnswer(
        frequency: CvsqFrequency.habitual,
        intensity: CvsqIntensity.intense,
      );
      expect(d.score, 4);
    });

    test('score is 0 when frequency > 0 but intensity is null', () {
      const a = CvsqAnswer(
        frequency: CvsqFrequency.occasional,
        intensity: null,
      );
      expect(a.score, 0);
    });
  });

  group('QuestionnaireResult.computeCvsqTotal', () {
    test('sums scores across 16 answers', () {
      final answers = List<CvsqAnswer>.generate(
        16,
        (_) => const CvsqAnswer(
          frequency: CvsqFrequency.habitual,
          intensity: CvsqIntensity.intense,
        ),
      );
      expect(QuestionnaireResult.computeCvsqTotal(answers), 16 * 4);
    });

    test('returns 0 when all are never', () {
      final answers = List<CvsqAnswer>.generate(
        16,
        (_) => const CvsqAnswer(
          frequency: CvsqFrequency.never,
          intensity: null,
        ),
      );
      expect(QuestionnaireResult.computeCvsqTotal(answers), 0);
    });
  });

  group('QuestionnaireResult JSON round-trip', () {
    test('preserves all fields', () {
      final q = QuestionnaireResult(
        id: 'test-id-1',
        patientName: 'Ana',
        completedAt: DateTime.utc(2026, 4, 17, 10, 30),
        cvsqAnswers: List<CvsqAnswer>.generate(
          16,
          (i) => CvsqAnswer(
            frequency: CvsqFrequency.values[i % 3],
            intensity: i % 3 == 0 ? null : CvsqIntensity.values[i % 2],
          ),
        ),
        fssAnswers: const [4, null, 7, 1, null],
        cvsqTotalScore: 12,
      );
      final clone = QuestionnaireResult.fromJson(q.toJson());
      expect(clone.id, q.id);
      expect(clone.patientName, q.patientName);
      expect(clone.completedAt, q.completedAt);
      expect(clone.cvsqAnswers.length, 16);
      expect(clone.cvsqAnswers.first.frequency, q.cvsqAnswers.first.frequency);
      expect(clone.cvsqAnswers.first.intensity, q.cvsqAnswers.first.intensity);
      expect(clone.fssAnswers, q.fssAnswers);
      expect(clone.cvsqTotalScore, q.cvsqTotalScore);
    });
  });
}
