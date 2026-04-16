import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optoview_flutter/models/questionnaire_result.dart';
import 'package:optoview_flutter/services/questionnaire_storage.dart';

QuestionnaireResult _makeQ(String id) => QuestionnaireResult(
      id: id,
      patientName: 'Test $id',
      completedAt: DateTime.utc(2026, 4, 17, 10, 30),
      cvsqAnswers: List<CvsqAnswer>.generate(
        16,
        (_) => const CvsqAnswer(
          frequency: CvsqFrequency.occasional,
          intensity: CvsqIntensity.moderate,
        ),
      ),
      fssAnswers: const [3, 3, 3, 3, 3],
      cvsqTotalScore: 16,
    );

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('empty store returns empty list', () async {
    expect(await QuestionnaireStorage.loadAll(), isEmpty);
  });

  test('saveAll then loadAll round-trips', () async {
    final items = [_makeQ('a'), _makeQ('b')];
    await QuestionnaireStorage.saveAll(items);
    final loaded = await QuestionnaireStorage.loadAll();
    expect(loaded.length, 2);
    expect(loaded.map((q) => q.id).toSet(), {'a', 'b'});
  });

  test('addOrUpdate inserts new and replaces existing by id', () async {
    await QuestionnaireStorage.addOrUpdate(_makeQ('x'));
    await QuestionnaireStorage.addOrUpdate(_makeQ('y'));
    expect((await QuestionnaireStorage.loadAll()).length, 2);

    final updated = _makeQ('x').copyWith(patientName: 'Updated');
    await QuestionnaireStorage.addOrUpdate(updated);
    final loaded = await QuestionnaireStorage.loadAll();
    expect(loaded.length, 2);
    expect(
      loaded.firstWhere((q) => q.id == 'x').patientName,
      'Updated',
    );
  });

  test('delete removes by id', () async {
    await QuestionnaireStorage.saveAll([_makeQ('a'), _makeQ('b')]);
    await QuestionnaireStorage.delete('a');
    final loaded = await QuestionnaireStorage.loadAll();
    expect(loaded.length, 1);
    expect(loaded.first.id, 'b');
  });

  test('clear empties the store', () async {
    await QuestionnaireStorage.saveAll([_makeQ('a')]);
    await QuestionnaireStorage.clear();
    expect(await QuestionnaireStorage.loadAll(), isEmpty);
  });
}
