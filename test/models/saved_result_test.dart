import 'package:flutter_test/flutter_test.dart';
import 'package:optoview_flutter/models/macdonald_result.dart' show LetterEvent;
import 'package:optoview_flutter/models/saved_result.dart';

void main() {
  group('LetterEvent JSON', () {
    test('round-trip conserva los campos', () {
      const e = LetterEvent(dx: -0.25, dy: 0.75, ringIndex: 2, isHit: true);
      final back = LetterEvent.fromJson(e.toJson());
      expect(back.dx, e.dx);
      expect(back.dy, e.dy);
      expect(back.ringIndex, e.ringIndex);
      expect(back.isHit, e.isHit);
    });
  });

  group('SavedResult JSON', () {
    test('round-trip completo (campos opcionales + listas)', () {
      final original = SavedResult(
        id: '1700000000000',
        testType: 'field_detection',
        patientName: 'Ana',
        startedAt: DateTime(2026, 6, 10, 9, 30),
        finishedAt: DateTime(2026, 6, 10, 9, 35),
        durationActualSeconds: 300,
        completedNaturally: true,
        totalStimuliShown: 80,
        correctTouches: 70,
        incorrectTouches: 0,
        missedStimuli: 10,
        accuracy: 0.875,
        avgReactionTimeMs: 420.5,
        bestReactionTimeMs: 180,
        worstReactionTimeMs: 900,
        anillosCompletados: 5,
        tiempoPorAnillo: const [1000, 2000, 3000, 4000, 5000],
        letterEvents: const [
          LetterEvent(dx: -0.1, dy: -0.2, ringIndex: 0, isHit: true),
          LetterEvent(dx: 0.3, dy: 0.4, ringIndex: 1, isHit: false),
        ],
        configSummary: const {'Anillos': '5', 'Letras': '80'},
      );

      final back = SavedResult.fromJson(original.toJson());

      expect(back.id, original.id);
      expect(back.testType, original.testType);
      expect(back.patientName, original.patientName);
      expect(back.startedAt, original.startedAt);
      expect(back.finishedAt, original.finishedAt);
      expect(back.durationActualSeconds, original.durationActualSeconds);
      expect(back.completedNaturally, original.completedNaturally);
      expect(back.totalStimuliShown, original.totalStimuliShown);
      expect(back.correctTouches, original.correctTouches);
      expect(back.missedStimuli, original.missedStimuli);
      expect(back.accuracy, original.accuracy);
      expect(back.avgReactionTimeMs, original.avgReactionTimeMs);
      expect(back.bestReactionTimeMs, original.bestReactionTimeMs);
      expect(back.worstReactionTimeMs, original.worstReactionTimeMs);
      expect(back.anillosCompletados, original.anillosCompletados);
      expect(back.tiempoPorAnillo, original.tiempoPorAnillo);
      expect(back.letterEvents!.length, 2);
      expect(back.letterEvents![1].isHit, isFalse);
      expect(back.configSummary, original.configSummary);
    });

    test('campos nulos se omiten del JSON y vuelven como null', () {
      final minimal = SavedResult(
        id: '42',
        testType: 'peripheral',
        patientName: '',
        startedAt: DateTime(2026, 1, 1),
        finishedAt: DateTime(2026, 1, 1, 0, 1),
        durationActualSeconds: 60,
        completedNaturally: false,
        totalStimuliShown: 12,
        configSummary: const {},
      );

      final json = minimal.toJson();
      expect(json.containsKey('accuracy'), isFalse);
      expect(json.containsKey('letterEvents'), isFalse);
      expect(json.containsKey('tiempoPorAnillo'), isFalse);

      final back = SavedResult.fromJson(json);
      expect(back.accuracy, isNull);
      expect(back.letterEvents, isNull);
      expect(back.tiempoPorAnillo, isNull);
      expect(back.correctTouches, isNull);
    });
  });
}
