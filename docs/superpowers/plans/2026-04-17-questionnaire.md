# CVS-Q Questionnaire Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an independent CVS-Q questionnaire (16 symptoms + 5 FSS items) accessible from the Dashboard, persisted locally, surfaced in History, and exportable to PDF/Excel/CSV.

**Architecture:** Separate model (`QuestionnaireResult`) + separate storage (`QuestionnaireStorage`), unified in History via `List<Object>` with `is` type checks. No shared abstraction with `SavedResult`. Compute CVS-Q total score at save time; FSS answers stored raw (1–7 or null). Support ES + EN via `AppLocalizations`.

**Tech Stack:** Flutter 3.8, Material 3, SharedPreferences (existing `ConfigStorage`/`ResultsStorage` patterns), `pdf`, `excel`, `share_plus`, new deps `uuid` and `archive`.

**WSL reminder:** All Flutter/Dart CLI commands run via `cmd.exe /c "flutter ..."` (Windows-side credentials).

---

## Task 1: Dependencies

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Check current `pubspec.yaml` for `uuid` and `archive`**

Run:
```bash
grep -E "^\s*(uuid|archive):" pubspec.yaml
```

- [ ] **Step 2: Add missing deps to `pubspec.yaml` under `dependencies:`**

Add any that were missing from step 1:
```yaml
  uuid: ^4.4.0
  archive: ^3.6.1
```

- [ ] **Step 3: Install**

Run: `cmd.exe /c "flutter pub get"`
Expected: "Got dependencies!" with no errors.

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add uuid and archive deps for questionnaire feature"
```

---

## Task 2: Data model + scoring

**Files:**
- Create: `lib/models/questionnaire_result.dart`
- Create: `test/models/questionnaire_result_test.dart`

- [ ] **Step 1: Write the failing score tests**

Create `test/models/questionnaire_result_test.dart`:
```dart
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
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cmd.exe /c "flutter test test/models/questionnaire_result_test.dart"`
Expected: FAIL with "target of URI doesn't exist" / compile errors.

- [ ] **Step 3: Create the model file**

Create `lib/models/questionnaire_result.dart`:
```dart
import 'package:flutter/foundation.dart';

enum CvsqFrequency {
  never(0),
  occasional(1),
  habitual(2);

  const CvsqFrequency(this.value);
  final int value;
}

enum CvsqIntensity {
  moderate(1),
  intense(2);

  const CvsqIntensity(this.value);
  final int value;
}

enum CvsqItem {
  burning,
  itching,
  foreignBody,
  tearing,
  excessiveBlinking,
  redEye,
  eyePain,
  heavyEyelids,
  dryness,
  blurredVision,
  doubleVision,
  nearFocusDifficulty,
  lightSensitivity,
  colorHalos,
  worseningVision,
  headache,
}

enum FssItem {
  fatigueLevel,
  motivationLevel,
  stressLevel,
  fatigueInterferes,
  sleepHours,
}

@immutable
class CvsqAnswer {
  const CvsqAnswer({required this.frequency, required this.intensity});

  final CvsqFrequency frequency;
  final CvsqIntensity? intensity;

  int get score {
    if (frequency == CvsqFrequency.never) return 0;
    if (intensity == null) return 0;
    return frequency.value * intensity!.value;
  }

  CvsqAnswer copyWith({
    CvsqFrequency? frequency,
    CvsqIntensity? intensity,
    bool clearIntensity = false,
  }) {
    return CvsqAnswer(
      frequency: frequency ?? this.frequency,
      intensity: clearIntensity ? null : (intensity ?? this.intensity),
    );
  }

  Map<String, dynamic> toJson() => {
        'frequency': frequency.name,
        'intensity': intensity?.name,
      };

  factory CvsqAnswer.fromJson(Map<String, dynamic> json) => CvsqAnswer(
        frequency: CvsqFrequency.values.byName(json['frequency'] as String),
        intensity: json['intensity'] == null
            ? null
            : CvsqIntensity.values.byName(json['intensity'] as String),
      );
}

@immutable
class QuestionnaireResult {
  const QuestionnaireResult({
    required this.id,
    required this.patientName,
    required this.completedAt,
    required this.cvsqAnswers,
    required this.fssAnswers,
    required this.cvsqTotalScore,
  });

  final String id;
  final String patientName;
  final DateTime completedAt;
  final List<CvsqAnswer> cvsqAnswers; // length 16, CvsqItem.values order
  final List<int?> fssAnswers;        // length 5, each 1..7 or null
  final int cvsqTotalScore;

  static int computeCvsqTotal(List<CvsqAnswer> answers) =>
      answers.fold(0, (sum, a) => sum + a.score);

  QuestionnaireResult copyWith({
    String? id,
    String? patientName,
    DateTime? completedAt,
    List<CvsqAnswer>? cvsqAnswers,
    List<int?>? fssAnswers,
    int? cvsqTotalScore,
  }) {
    return QuestionnaireResult(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      completedAt: completedAt ?? this.completedAt,
      cvsqAnswers: cvsqAnswers ?? this.cvsqAnswers,
      fssAnswers: fssAnswers ?? this.fssAnswers,
      cvsqTotalScore: cvsqTotalScore ?? this.cvsqTotalScore,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientName': patientName,
        'completedAt': completedAt.toIso8601String(),
        'cvsqAnswers': cvsqAnswers.map((a) => a.toJson()).toList(),
        'fssAnswers': fssAnswers,
        'cvsqTotalScore': cvsqTotalScore,
      };

  factory QuestionnaireResult.fromJson(Map<String, dynamic> json) =>
      QuestionnaireResult(
        id: json['id'] as String,
        patientName: json['patientName'] as String,
        completedAt: DateTime.parse(json['completedAt'] as String),
        cvsqAnswers: (json['cvsqAnswers'] as List)
            .map((e) => CvsqAnswer.fromJson(e as Map<String, dynamic>))
            .toList(),
        fssAnswers: (json['fssAnswers'] as List)
            .map((e) => e == null ? null : (e as num).toInt())
            .toList(),
        cvsqTotalScore: (json['cvsqTotalScore'] as num).toInt(),
      );
}
```

- [ ] **Step 4: Add JSON round-trip test**

Append to `test/models/questionnaire_result_test.dart`:
```dart
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
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `cmd.exe /c "flutter test test/models/questionnaire_result_test.dart"`
Expected: All tests pass.

- [ ] **Step 6: Commit**

```bash
git add lib/models/questionnaire_result.dart test/models/questionnaire_result_test.dart
git commit -m "feat: add QuestionnaireResult model with CVS-Q scoring"
```

---

## Task 3: Storage service

**Files:**
- Create: `lib/services/questionnaire_storage.dart`
- Create: `test/services/questionnaire_storage_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/services/questionnaire_storage_test.dart`:
```dart
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cmd.exe /c "flutter test test/services/questionnaire_storage_test.dart"`
Expected: FAIL with compile error (storage not found).

- [ ] **Step 3: Implement storage**

Create `lib/services/questionnaire_storage.dart`:
```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/questionnaire_result.dart';
import 'app_logger.dart';

abstract final class QuestionnaireStorage {
  static const _key = 'questionnaires';

  static Future<List<QuestionnaireResult>> loadAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => QuestionnaireResult.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      AppLogger.error('QuestionnaireStorage.loadAll failed',
          error: e, stackTrace: st);
      return [];
    }
  }

  static Future<void> saveAll(List<QuestionnaireResult> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(items.map((q) => q.toJson()).toList());
      await prefs.setString(_key, raw);
    } catch (e, st) {
      AppLogger.error('QuestionnaireStorage.saveAll failed',
          error: e, stackTrace: st);
    }
  }

  static Future<void> addOrUpdate(QuestionnaireResult q) async {
    final current = await loadAll();
    final idx = current.indexWhere((x) => x.id == q.id);
    if (idx >= 0) {
      current[idx] = q;
    } else {
      current.insert(0, q);
    }
    await saveAll(current);
  }

  static Future<void> delete(String id) async {
    final current = await loadAll();
    current.removeWhere((x) => x.id == id);
    await saveAll(current);
  }

  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e, st) {
      AppLogger.error('QuestionnaireStorage.clear failed',
          error: e, stackTrace: st);
    }
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cmd.exe /c "flutter test test/services/questionnaire_storage_test.dart"`
Expected: All 5 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/services/questionnaire_storage.dart test/services/questionnaire_storage_test.dart
git commit -m "feat: add QuestionnaireStorage with SharedPreferences backing"
```

---

## Task 4: Localization keys

**Files:**
- Modify: `lib/l10n/app_es.arb`
- Modify: `lib/l10n/app_en.arb`

- [ ] **Step 1: Append new keys to `lib/l10n/app_es.arb` (before closing `}`)**

Use this JSON block (merge as siblings of existing keys):
```json
  "questionnaireMenuTitle": "Cuestionario CVS-Q",
  "questionnaireMenuSubtitle": "Evaluación de síntomas visuales",
  "questionnaireFormTitle": "Cuestionario CVS-Q",
  "questionnaireCvsqSection": "Síntomas visuales (CVS-Q)",
  "questionnaireFssSection": "Fatiga y motivación — opcional",
  "questionnaireAnsweredCount": "{answered}/16 respondidas",
  "@questionnaireAnsweredCount": {
    "placeholders": { "answered": { "type": "int" } }
  },
  "questionnaireScoreLabel": "Score CVS-Q",
  "questionnaireSaveButton": "Guardar",
  "questionnaireSavedSnack": "Cuestionario guardado",
  "questionnairePatientLabel": "Nombre del paciente",
  "cvsqFreqHeader": "Frecuencia",
  "cvsqIntHeader": "Intensidad",
  "cvsqFreqNever": "Nunca",
  "cvsqFreqOccasional": "Ocasionalmente",
  "cvsqFreqHabitual": "Habitualmente o siempre",
  "cvsqIntModerate": "Moderado",
  "cvsqIntIntense": "Intenso",
  "cvsqItem1": "Quemazón",
  "cvsqItem2": "Picor",
  "cvsqItem3": "Sensación de cuerpo extraño",
  "cvsqItem4": "Lagrimeo",
  "cvsqItem5": "Parpadeo excesivo",
  "cvsqItem6": "Ojo rojo",
  "cvsqItem7": "Dolor ocular",
  "cvsqItem8": "Párpados pesados",
  "cvsqItem9": "Sequedad",
  "cvsqItem10": "Visión borrosa",
  "cvsqItem11": "Visión doble",
  "cvsqItem12": "Dificultad de enfocar en cerca",
  "cvsqItem13": "Elevada sensibilidad a la luz",
  "cvsqItem14": "Halos de colores alrededor de las luces",
  "cvsqItem15": "Siente que ha empeorado la visión",
  "cvsqItem16": "Dolor de cabeza",
  "fssItem1": "Grado de fatiga",
  "fssItem2": "Grado de motivación",
  "fssItem3": "Grado de estrés",
  "fssItem4": "La fatiga me dificulta la realización de tareas",
  "fssItem5": "Horas de sueño",
  "fssAnchorAgree": "Acuerdo",
  "fssAnchorDisagree": "Desacuerdo",
  "historyTestQuestionnaire": "Cuestionario",
  "questionnaireHistorySubtitle": "CVS-Q · Score: {score}",
  "@questionnaireHistorySubtitle": {
    "placeholders": { "score": { "type": "int" } }
  },
  "exportQuestionnaireTitle": "Cuestionario CVS-Q",
  "exportQuestionnaireBulkTitle": "Cuestionarios",
  "exportItemNumber": "#",
  "exportItemName": "Ítem",
  "exportFrequency": "Frecuencia",
  "exportIntensity": "Intensidad",
  "exportScore": "Score",
  "exportValueScale": "Valor (1-7)"
```

- [ ] **Step 2: Append matching keys to `lib/l10n/app_en.arb`**

Use this block:
```json
  "questionnaireMenuTitle": "CVS-Q Questionnaire",
  "questionnaireMenuSubtitle": "Visual symptoms assessment",
  "questionnaireFormTitle": "CVS-Q Questionnaire",
  "questionnaireCvsqSection": "Visual symptoms (CVS-Q)",
  "questionnaireFssSection": "Fatigue and motivation — optional",
  "questionnaireAnsweredCount": "{answered}/16 answered",
  "@questionnaireAnsweredCount": {
    "placeholders": { "answered": { "type": "int" } }
  },
  "questionnaireScoreLabel": "CVS-Q Score",
  "questionnaireSaveButton": "Save",
  "questionnaireSavedSnack": "Questionnaire saved",
  "questionnairePatientLabel": "Patient name",
  "cvsqFreqHeader": "Frequency",
  "cvsqIntHeader": "Intensity",
  "cvsqFreqNever": "Never",
  "cvsqFreqOccasional": "Occasionally",
  "cvsqFreqHabitual": "Habitually or always",
  "cvsqIntModerate": "Moderate",
  "cvsqIntIntense": "Intense",
  "cvsqItem1": "Burning sensation",
  "cvsqItem2": "Itching",
  "cvsqItem3": "Foreign body sensation",
  "cvsqItem4": "Tearing",
  "cvsqItem5": "Excessive blinking",
  "cvsqItem6": "Red eye",
  "cvsqItem7": "Eye pain",
  "cvsqItem8": "Heavy eyelids",
  "cvsqItem9": "Dryness",
  "cvsqItem10": "Blurred vision",
  "cvsqItem11": "Double vision",
  "cvsqItem12": "Difficulty focusing near",
  "cvsqItem13": "Increased light sensitivity",
  "cvsqItem14": "Colored halos around lights",
  "cvsqItem15": "Feeling that vision has worsened",
  "cvsqItem16": "Headache",
  "fssItem1": "Fatigue level",
  "fssItem2": "Motivation level",
  "fssItem3": "Stress level",
  "fssItem4": "Fatigue interferes with task performance",
  "fssItem5": "Hours of sleep",
  "fssAnchorAgree": "Agree",
  "fssAnchorDisagree": "Disagree",
  "historyTestQuestionnaire": "Questionnaire",
  "questionnaireHistorySubtitle": "CVS-Q · Score: {score}",
  "@questionnaireHistorySubtitle": {
    "placeholders": { "score": { "type": "int" } }
  },
  "exportQuestionnaireTitle": "CVS-Q Questionnaire",
  "exportQuestionnaireBulkTitle": "Questionnaires",
  "exportItemNumber": "#",
  "exportItemName": "Item",
  "exportFrequency": "Frequency",
  "exportIntensity": "Intensity",
  "exportScore": "Score",
  "exportValueScale": "Value (1-7)"
```

- [ ] **Step 3: Regenerate localizations**

Run: `cmd.exe /c "flutter gen-l10n"`
Expected: No errors; files under `lib/l10n/` regenerated.

- [ ] **Step 4: Sanity check compile**

Run: `cmd.exe /c "flutter analyze lib/l10n/"`
Expected: `No issues found`.

- [ ] **Step 5: Commit**

```bash
git add lib/l10n/app_es.arb lib/l10n/app_en.arb lib/l10n/app_localizations*.dart
git commit -m "i18n: add CVS-Q questionnaire strings (es/en)"
```

---

## Task 5: Questionnaire form screen — UI

**Files:**
- Create: `lib/screens/questionnaire_form_screen.dart`

- [ ] **Step 1: Create the screen skeleton with AppBar, patient field, CVS-Q grid, FSS grid, footer**

Create `lib/screens/questionnaire_form_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../l10n/app_localizations.dart';
import '../models/questionnaire_result.dart';
import '../services/questionnaire_storage.dart';
import '../theme/opto_colors.dart';
import '../theme/opto_spacing.dart';
import '../widgets/design_system/opto_action_button.dart';
import '../widgets/design_system/opto_card.dart';
import '../widgets/design_system/opto_section_header.dart';
import '../widgets/design_system/opto_segmented_control.dart';

class QuestionnaireFormScreen extends StatefulWidget {
  const QuestionnaireFormScreen({super.key});

  @override
  State<QuestionnaireFormScreen> createState() =>
      _QuestionnaireFormScreenState();
}

class _QuestionnaireFormScreenState extends State<QuestionnaireFormScreen> {
  final TextEditingController _patientCtrl = TextEditingController();

  late List<CvsqAnswer?> _cvsq;
  late List<int?> _fss;

  @override
  void initState() {
    super.initState();
    _cvsq = List<CvsqAnswer?>.filled(16, null);
    _fss = List<int?>.filled(5, null);
  }

  @override
  void dispose() {
    _patientCtrl.dispose();
    super.dispose();
  }

  int get _answeredCount => _cvsq.where((a) => a != null).length;
  bool get _canSave => _answeredCount == 16;
  int get _liveScore => _cvsq.whereType<CvsqAnswer>().fold(0, (s, a) => s + a.score);

  Future<void> _save(AppLocalizations l) async {
    if (!_canSave) return;
    final answers = _cvsq.whereType<CvsqAnswer>().toList(growable: false);
    final q = QuestionnaireResult(
      id: const Uuid().v4(),
      patientName: _patientCtrl.text.trim(),
      completedAt: DateTime.now(),
      cvsqAnswers: answers,
      fssAnswers: List<int?>.unmodifiable(_fss),
      cvsqTotalScore: QuestionnaireResult.computeCvsqTotal(answers),
    );
    await QuestionnaireStorage.addOrUpdate(q);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.questionnaireSavedSnack)),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(l, colorScheme),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(OptoSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPatientField(l, colorScheme),
                    const SizedBox(height: OptoSpacing.md),
                    OptoSectionHeader(title: l.questionnaireCvsqSection),
                    const SizedBox(height: OptoSpacing.sm),
                    _buildCvsqGrid(l, colorScheme),
                    const SizedBox(height: OptoSpacing.md),
                    OptoSectionHeader(title: l.questionnaireFssSection),
                    const SizedBox(height: OptoSpacing.sm),
                    _buildFssGrid(l, colorScheme),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            _buildFooter(l, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(AppLocalizations l, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: cs.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l.questionnaireFormTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ),
          Text(
            l.questionnaireAnsweredCount(_answeredCount),
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildPatientField(AppLocalizations l, ColorScheme cs) {
    return OptoCard(
      child: Row(
        children: [
          Icon(Icons.person_outline, size: 20, color: cs.onSurfaceVariant),
          const SizedBox(width: OptoSpacing.sm),
          Expanded(
            child: TextField(
              controller: _patientCtrl,
              style: TextStyle(color: cs.onSurface),
              decoration: InputDecoration(
                hintText: l.questionnairePatientLabel,
                hintStyle: TextStyle(color: cs.onSurfaceVariant),
                border: InputBorder.none,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCvsqGrid(AppLocalizations l, ColorScheme cs) {
    return OptoCard(
      padding: const EdgeInsets.all(OptoSpacing.sm),
      child: Column(
        children: List.generate(CvsqItem.values.length, (i) {
          return _buildCvsqRow(i, l, cs);
        }),
      ),
    );
  }

  Widget _buildCvsqRow(int i, AppLocalizations l, ColorScheme cs) {
    final label = _cvsqItemLabel(i, l);
    final answer = _cvsq[i];
    final freq = answer?.frequency;
    final inten = answer?.intensity;
    final intensityDisabled = freq == CvsqFrequency.never;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 220,
            child: Text(
              '${i + 1}. $label',
              style: TextStyle(fontSize: 13, color: cs.onSurface),
            ),
          ),
          const SizedBox(width: OptoSpacing.sm),
          Expanded(
            flex: 3,
            child: OptoSegmentedControl<CvsqFrequency?>(
              items: [
                OptoSegmentItem(value: CvsqFrequency.never, label: l.cvsqFreqNever),
                OptoSegmentItem(value: CvsqFrequency.occasional, label: l.cvsqFreqOccasional),
                OptoSegmentItem(value: CvsqFrequency.habitual, label: l.cvsqFreqHabitual),
              ],
              selected: freq,
              onSelected: (f) => _setFrequency(i, f!),
            ),
          ),
          const SizedBox(width: OptoSpacing.sm),
          Expanded(
            flex: 2,
            child: Opacity(
              opacity: intensityDisabled ? 0.4 : 1.0,
              child: IgnorePointer(
                ignoring: intensityDisabled,
                child: OptoSegmentedControl<CvsqIntensity?>(
                  items: [
                    OptoSegmentItem(value: CvsqIntensity.moderate, label: l.cvsqIntModerate),
                    OptoSegmentItem(value: CvsqIntensity.intense, label: l.cvsqIntIntense),
                  ],
                  selected: inten,
                  onSelected: (v) => _setIntensity(i, v!),
                ),
              ),
            ),
          ),
          const SizedBox(width: OptoSpacing.sm),
          SizedBox(
            width: 36,
            child: Text(
              '${answer?.score ?? "-"}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setFrequency(int idx, CvsqFrequency f) {
    setState(() {
      final current = _cvsq[idx];
      if (f == CvsqFrequency.never) {
        _cvsq[idx] = const CvsqAnswer(frequency: CvsqFrequency.never, intensity: null);
      } else {
        _cvsq[idx] = CvsqAnswer(frequency: f, intensity: current?.intensity);
      }
    });
  }

  void _setIntensity(int idx, CvsqIntensity v) {
    setState(() {
      final current = _cvsq[idx];
      if (current == null || current.frequency == CvsqFrequency.never) return;
      _cvsq[idx] = current.copyWith(intensity: v);
    });
  }

  Widget _buildFssGrid(AppLocalizations l, ColorScheme cs) {
    return OptoCard(
      padding: const EdgeInsets.all(OptoSpacing.sm),
      child: Column(
        children: List.generate(FssItem.values.length, (i) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: cs.outlineVariant)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 260,
                  child: Text(
                    _fssItemLabel(i, l),
                    style: TextStyle(fontSize: 13, color: cs.onSurface),
                  ),
                ),
                const SizedBox(width: OptoSpacing.sm),
                Text(l.fssAnchorAgree, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                const SizedBox(width: 4),
                Expanded(
                  child: OptoSegmentedControl<int?>(
                    items: List.generate(
                      7,
                      (n) => OptoSegmentItem(value: n + 1, label: '${n + 1}'),
                    ),
                    selected: _fss[i],
                    onSelected: (v) => _setFss(i, v),
                  ),
                ),
                const SizedBox(width: 4),
                Text(l.fssAnchorDisagree, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _setFss(int idx, int? v) {
    setState(() {
      if (_fss[idx] == v) {
        _fss[idx] = null; // tap-again to clear
      } else {
        _fss[idx] = v;
      }
    });
  }

  Widget _buildFooter(AppLocalizations l, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${l.questionnaireScoreLabel}: $_liveScore · ${l.questionnaireAnsweredCount(_answeredCount)}',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ),
          OptoActionButton(
            label: l.questionnaireSaveButton,
            icon: Icons.save,
            onPressed: _canSave ? () => _save(l) : () {},
          ),
        ],
      ),
    );
  }

  String _cvsqItemLabel(int i, AppLocalizations l) {
    switch (i) {
      case 0: return l.cvsqItem1;
      case 1: return l.cvsqItem2;
      case 2: return l.cvsqItem3;
      case 3: return l.cvsqItem4;
      case 4: return l.cvsqItem5;
      case 5: return l.cvsqItem6;
      case 6: return l.cvsqItem7;
      case 7: return l.cvsqItem8;
      case 8: return l.cvsqItem9;
      case 9: return l.cvsqItem10;
      case 10: return l.cvsqItem11;
      case 11: return l.cvsqItem12;
      case 12: return l.cvsqItem13;
      case 13: return l.cvsqItem14;
      case 14: return l.cvsqItem15;
      case 15: return l.cvsqItem16;
      default: throw StateError('invalid CVS-Q index $i');
    }
  }

  String _fssItemLabel(int i, AppLocalizations l) {
    switch (i) {
      case 0: return l.fssItem1;
      case 1: return l.fssItem2;
      case 2: return l.fssItem3;
      case 3: return l.fssItem4;
      case 4: return l.fssItem5;
      default: throw StateError('invalid FSS index $i');
    }
  }
}
```

Note: `OptoColors` import is unused in this file (all colors are theme-driven). If `flutter analyze` warns, remove the import.

- [ ] **Step 2: Verify compile**

Run: `cmd.exe /c "flutter analyze lib/screens/questionnaire_form_screen.dart"`
Expected: `No issues found`. If `OptoColors` is flagged unused, remove the import line and rerun.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/questionnaire_form_screen.dart
git commit -m "feat: add QuestionnaireFormScreen with CVS-Q and FSS sections"
```

---

## Task 6: Dashboard card

**Files:**
- Modify: `lib/screens/dashboard_screen.dart`

- [ ] **Step 1: Add questionnaire import and navigation**

At the top of `lib/screens/dashboard_screen.dart`, add:
```dart
import 'questionnaire_form_screen.dart';
```

- [ ] **Step 2: Bump animation item count and add the card**

Modify the `_totalAnimItems` constant (currently 8) to accommodate the new card. Update `_buildLeftColumn` in `lib/screens/dashboard_screen.dart` to add a new animated item after the repeat card. Find the `if (_lastResult != null) ...[ ... _buildRepeatCard ... ]` block and insert after its closing `]`:

```dart
          const SizedBox(height: OptoSpacing.sm),
          _animatedItem(
            4,
            _buildQuestionnaireCard(l, colorScheme),
          ),
```

Shift any subsequent `_animatedItem` index in `_buildRightColumn` so indices stay unique and within `_totalAnimItems`. Update `_totalAnimItems = 9`.

- [ ] **Step 3: Implement `_buildQuestionnaireCard`**

Add inside `_DashboardScreenState`:
```dart
  Widget _buildQuestionnaireCard(AppLocalizations l, ColorScheme colorScheme) {
    return OptoCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            OptoPageRoute(builder: (_) => const QuestionnaireFormScreen()),
          ).then((_) => _refreshData());
        },
        borderRadius: BorderRadius.circular(OptoSpacing.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(OptoSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: OptoColors.primary.withAlpha(38),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.assignment, color: OptoColors.primary, size: 22),
              ),
              const SizedBox(width: OptoSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.questionnaireMenuTitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.questionnaireMenuSubtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
```

- [ ] **Step 4: Run app and verify**

Run: `cmd.exe /c "flutter run -d chrome"` then navigate to Dashboard.
Expected: New "Cuestionario CVS-Q" card appears below tests (and below repeat card if present). Tapping it opens the form.

- [ ] **Step 5: Commit**

```bash
git add lib/screens/dashboard_screen.dart
git commit -m "feat: add questionnaire card to dashboard"
```

---

## Task 7: History — load both lists

**Files:**
- Modify: `lib/screens/history_screen.dart`

- [ ] **Step 1: Add imports**

At the top:
```dart
import '../models/questionnaire_result.dart';
import '../services/questionnaire_storage.dart';
```

- [ ] **Step 2: Change state field types and loader**

In `_HistoryScreenState`, replace `_results` (which was `List<SavedResult>`) with:
```dart
  List<Object> _items = []; // SavedResult OR QuestionnaireResult
```

Update everywhere `_results` was referenced; rename to `_items`. Update `_loadData` to:
```dart
  Future<void> _loadData() async {
    final results = await ResultsStorage.loadAll();
    final questionnaires = await QuestionnaireStorage.loadAll();
    final combined = <Object>[...results, ...questionnaires];
    combined.sort((a, b) => _dateOf(b).compareTo(_dateOf(a)));
    if (!mounted) return;
    setState(() {
      _items = combined;
      _isLoading = false;
    });
  }

  DateTime _dateOf(Object item) {
    if (item is SavedResult) return item.startedAt;
    if (item is QuestionnaireResult) return item.completedAt;
    throw StateError('unknown item type $item');
  }

  String _idOf(Object item) {
    if (item is SavedResult) return item.id;
    if (item is QuestionnaireResult) return item.id;
    throw StateError('unknown item type $item');
  }

  String _patientOf(Object item) {
    if (item is SavedResult) return item.patientName;
    if (item is QuestionnaireResult) return item.patientName;
    throw StateError('unknown item type $item');
  }
```

- [ ] **Step 3: Update `_filteredResults` getter to handle mixed items**

Rename to `_filteredItems`, update return type to `List<Object>`, and update existing filter logic to handle both types:
```dart
  List<Object> get _filteredItems {
    Iterable<Object> items = _items;
    // existing test-type filter: apply only to SavedResult; questionnaires pass or fail depending on filter
    // (implementation depends on current filter state — preserve existing logic, adding a branch for QuestionnaireResult)
    // existing search filter: match against patient name from either type
    return items.toList();
  }
```

Adjust all call sites of `_filteredResults` → `_filteredItems`. Where existing code iterates `SavedResult` properties directly, wrap in a type check and keep the existing path for `SavedResult`.

- [ ] **Step 4: Compile**

Run: `cmd.exe /c "flutter analyze lib/screens/history_screen.dart"`
Expected: `No issues found`. Fix any type errors by adding `is SavedResult` / `is QuestionnaireResult` branches.

- [ ] **Step 5: Commit**

```bash
git add lib/screens/history_screen.dart
git commit -m "feat(history): load questionnaires alongside test results"
```

---

## Task 8: History — filter chip

**Files:**
- Modify: `lib/screens/history_screen.dart`

- [ ] **Step 1: Add questionnaire filter chip**

Find the test-type filter chip group and add a fourth option using `l.historyTestQuestionnaire`. Use the same `OptoChipItem<String>` pattern with `value: 'questionnaire'`.

- [ ] **Step 2: Update filter logic in `_filteredItems`**

When filter == 'questionnaire', keep only `QuestionnaireResult` items. When filter == 'peripheral'|'localization'|'macdonald', keep only `SavedResult` with matching `testType`. When filter is 'all'/empty, keep everything.

- [ ] **Step 3: Run app and verify**

Navigate to History, toggle the new "Cuestionario" chip, confirm it isolates questionnaires.

- [ ] **Step 4: Commit**

```bash
git add lib/screens/history_screen.dart
git commit -m "feat(history): add questionnaire filter chip"
```

---

## Task 9: History — tile and detail dispatcher

**Files:**
- Modify: `lib/screens/history_screen.dart`

- [ ] **Step 1: Add dispatcher helpers and questionnaire tile**

In `_HistoryScreenState`, add:
```dart
  Widget _buildItemTile(Object item, ColorScheme cs, AppLocalizations l) {
    if (item is SavedResult) return _buildTile(item, cs); // existing method
    if (item is QuestionnaireResult) return _buildQuestionnaireTile(item, cs, l);
    throw StateError('unknown item type');
  }

  Widget _buildQuestionnaireTile(QuestionnaireResult q, ColorScheme cs, AppLocalizations l) {
    final isSelected = _selectedIds.contains(q.id);
    final isDetailSelected = q.id == _selectedResultId;
    return Container(
      decoration: BoxDecoration(
        color: isDetailSelected ? OptoColors.primary.withAlpha(26) : null,
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      child: InkWell(
        onTap: _selectionMode
            ? () => _toggleSelectionById(q.id)
            : () => setState(() => _selectedResultId = q.id),
        child: Padding(
          padding: const EdgeInsets.all(OptoSpacing.md),
          child: Row(
            children: [
              if (_selectionMode)
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => _toggleSelectionById(q.id),
                ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: OptoColors.primary.withAlpha(38),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.assignment, color: OptoColors.primary, size: 18),
              ),
              const SizedBox(width: OptoSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q.patientName.isNotEmpty ? q.patientName : l.questionnaireFormTitle,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: cs.onSurface),
                    ),
                    Text(
                      l.questionnaireHistorySubtitle(q.cvsqTotalScore),
                      style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 18),
            ],
          ),
        ),
      ),
    );
  }
```

Also add a helper `_toggleSelectionById(String id)` that toggles by id directly (since `_toggleSelection` currently takes a `SavedResult`).

- [ ] **Step 2: Swap the list builder to use dispatcher**

Replace the `itemBuilder` in the main history `ListView` to call `_buildItemTile(_filteredItems[i], cs, l)`.

- [ ] **Step 3: Compile + manual verify**

Run: `cmd.exe /c "flutter analyze lib/screens/history_screen.dart"` → no issues.
Run the app, create a questionnaire, verify it shows in history.

- [ ] **Step 4: Commit**

```bash
git add lib/screens/history_screen.dart
git commit -m "feat(history): render questionnaire tiles in mixed list"
```

---

## Task 10: History — questionnaire detail panel

**Files:**
- Modify: `lib/screens/history_screen.dart`

- [ ] **Step 1: Add detail panel dispatcher and questionnaire detail**

In `_HistoryScreenState`, wrap the existing `_buildDetailPanel` (which assumes `SavedResult`) with a dispatcher:
```dart
  Widget _buildDetailPanelFor(Object item, ColorScheme cs, AppLocalizations l) {
    if (item is SavedResult) return _buildDetailPanel(item, cs, l);
    if (item is QuestionnaireResult) return _buildQuestionnaireDetailPanel(item, cs, l);
    return const SizedBox.shrink();
  }
```

Add `_buildQuestionnaireDetailPanel`:
```dart
  Widget _buildQuestionnaireDetailPanel(
    QuestionnaireResult q,
    ColorScheme cs,
    AppLocalizations l,
  ) {
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm'); // add import for intl if missing
    return SingleChildScrollView(
      padding: const EdgeInsets.all(OptoSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: patient + date + score
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q.patientName.isNotEmpty ? q.patientName : l.questionnaireFormTitle,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface),
                    ),
                    Text(
                      dateFmt.format(q.completedAt),
                      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(l.questionnaireScoreLabel,
                      style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                  Text('${q.cvsqTotalScore}',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: cs.onSurface)),
                ],
              ),
            ],
          ),
          const SizedBox(height: OptoSpacing.md),

          // Export + delete buttons
          Row(
            children: [
              OptoActionButton(
                label: 'PDF',
                icon: Icons.picture_as_pdf,
                onPressed: () => ExportService.exportQuestionnairePdf(context, q, l),
              ),
              const SizedBox(width: 8),
              OptoActionButton(
                label: 'Excel',
                icon: Icons.table_chart,
                onPressed: () => ExportService.exportQuestionnaireExcel(q, l),
              ),
              const SizedBox(width: 8),
              OptoActionButton(
                label: 'CSV',
                icon: Icons.description,
                onPressed: () => ExportService.exportQuestionnaireCsv(q, l),
              ),
              const Spacer(),
              OptoActionButton(
                label: l.actionDelete, // assumes existing key; if not, add in l10n or reuse existing delete label
                icon: Icons.delete,
                variant: OptoButtonVariant.danger,
                onPressed: () async {
                  await QuestionnaireStorage.delete(q.id);
                  _loadData();
                  if (mounted) setState(() => _selectedResultId = null);
                },
              ),
            ],
          ),
          const SizedBox(height: OptoSpacing.lg),

          // CVS-Q section
          Text(l.questionnaireCvsqSection,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface)),
          const SizedBox(height: OptoSpacing.sm),
          ...List.generate(q.cvsqAnswers.length, (i) {
            final a = q.cvsqAnswers[i];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(width: 24, child: Text('${i + 1}.', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant))),
                  Expanded(child: Text(_cvsqItemText(i, l), style: TextStyle(fontSize: 12, color: cs.onSurface))),
                  Text(_freqLabel(a.frequency, l),
                      style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                  const SizedBox(width: 8),
                  Text(a.intensity == null ? '—' : _intLabel(a.intensity!, l),
                      style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                  const SizedBox(width: 8),
                  SizedBox(width: 24, child: Text('${a.score}', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface))),
                ],
              ),
            );
          }),
          const SizedBox(height: OptoSpacing.md),

          // FSS section
          Text(l.questionnaireFssSection,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface)),
          const SizedBox(height: OptoSpacing.sm),
          ...List.generate(q.fssAnswers.length, (i) {
            final v = q.fssAnswers[i];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(child: Text(_fssItemText(i, l), style: TextStyle(fontSize: 12, color: cs.onSurface))),
                  Text(v == null ? '—' : '$v / 7',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _freqLabel(CvsqFrequency f, AppLocalizations l) => switch (f) {
        CvsqFrequency.never => l.cvsqFreqNever,
        CvsqFrequency.occasional => l.cvsqFreqOccasional,
        CvsqFrequency.habitual => l.cvsqFreqHabitual,
      };

  String _intLabel(CvsqIntensity i, AppLocalizations l) => switch (i) {
        CvsqIntensity.moderate => l.cvsqIntModerate,
        CvsqIntensity.intense => l.cvsqIntIntense,
      };

  String _cvsqItemText(int i, AppLocalizations l) {
    // Same switch as QuestionnaireFormScreen._cvsqItemLabel; duplicated here to avoid cross-file coupling.
    switch (i) {
      case 0: return l.cvsqItem1;
      case 1: return l.cvsqItem2;
      case 2: return l.cvsqItem3;
      case 3: return l.cvsqItem4;
      case 4: return l.cvsqItem5;
      case 5: return l.cvsqItem6;
      case 6: return l.cvsqItem7;
      case 7: return l.cvsqItem8;
      case 8: return l.cvsqItem9;
      case 9: return l.cvsqItem10;
      case 10: return l.cvsqItem11;
      case 11: return l.cvsqItem12;
      case 12: return l.cvsqItem13;
      case 13: return l.cvsqItem14;
      case 14: return l.cvsqItem15;
      case 15: return l.cvsqItem16;
      default: throw StateError('invalid CVS-Q index $i');
    }
  }

  String _fssItemText(int i, AppLocalizations l) {
    switch (i) {
      case 0: return l.fssItem1;
      case 1: return l.fssItem2;
      case 2: return l.fssItem3;
      case 3: return l.fssItem4;
      case 4: return l.fssItem5;
      default: throw StateError('invalid FSS index $i');
    }
  }
```

- [ ] **Step 2: Route the detail rendering through the dispatcher**

Find where the detail panel builds currently from `_selectedResult` (a `SavedResult`). Change to locate the selected item in `_items`:
```dart
  Object? get _selectedItem =>
      _selectedResultId == null
          ? null
          : _items.firstWhere(
              (i) => _idOf(i) == _selectedResultId,
              orElse: () => null as Object,
            );
```
Then build the panel as `_buildDetailPanelFor(_selectedItem!, cs, l)`.

If `l.actionDelete` doesn't exist, reuse an existing delete label in `app_es.arb`/`app_en.arb` (search for "delete" / "eliminar"); otherwise add the key in this task.

- [ ] **Step 3: Compile**

Run: `cmd.exe /c "flutter analyze lib/screens/history_screen.dart"`
Expected: `No issues found`.

- [ ] **Step 4: Commit**

```bash
git add lib/screens/history_screen.dart
git commit -m "feat(history): add detail panel for questionnaires"
```

---

## Task 11: Export — individual questionnaire

**Files:**
- Modify: `lib/services/export_service.dart`

- [ ] **Step 1: Add import**

At the top of `export_service.dart`:
```dart
import '../models/questionnaire_result.dart';
```

- [ ] **Step 2: Add `exportQuestionnairePdf`**

Append inside the `ExportService` class, after the existing per-test PDF methods:
```dart
  static Future<void> exportQuestionnairePdf(
    BuildContext context,
    QuestionnaireResult q,
    AppLocalizations l,
  ) async {
    AppLogger.info('exportQuestionnairePdf: inicio (id=${q.id})');
    final doc = pw.Document();
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      maxPages: 10,
      build: (ctx) => [
        pw.Text(l.exportQuestionnaireTitle,
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        if (q.patientName.isNotEmpty)
          pw.Text('${l.patientName}: ${q.patientName}',
              style: const pw.TextStyle(fontSize: 12)),
        pw.Text(_dateFmt.format(q.completedAt),
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.SizedBox(height: 8),
        pw.Text('${l.questionnaireScoreLabel}: ${q.cvsqTotalScore}',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Divider(),
        pw.SizedBox(height: 8),

        // CVS-Q table
        pw.Text(l.questionnaireCvsqSection,
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400)),
          ),
          child: pw.Row(children: [
            pw.SizedBox(width: 20, child: pw.Text(l.exportItemNumber, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 5, child: pw.Text(l.exportItemName, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 3, child: pw.Text(l.exportFrequency, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text(l.exportIntensity, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
            pw.SizedBox(width: 30, child: pw.Text(l.exportScore, textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
          ]),
        ),
        ...List.generate(q.cvsqAnswers.length, (i) {
          final a = q.cvsqAnswers[i];
          return pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 3),
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
            ),
            child: pw.Row(children: [
              pw.SizedBox(width: 20, child: pw.Text('${i + 1}', style: const pw.TextStyle(fontSize: 9))),
              pw.Expanded(flex: 5, child: pw.Text(_cvsqItemPdfLabel(i, l), style: const pw.TextStyle(fontSize: 9))),
              pw.Expanded(flex: 3, child: pw.Text(_freqPdfLabel(a.frequency, l), style: const pw.TextStyle(fontSize: 9))),
              pw.Expanded(flex: 2, child: pw.Text(a.intensity == null ? '-' : _intPdfLabel(a.intensity!, l), style: const pw.TextStyle(fontSize: 9))),
              pw.SizedBox(width: 30, child: pw.Text('${a.score}', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 9))),
            ]),
          );
        }),

        pw.SizedBox(height: 16),
        pw.Text(l.questionnaireFssSection,
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400)),
          ),
          child: pw.Row(children: [
            pw.Expanded(flex: 5, child: pw.Text(l.exportItemName, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
            pw.Expanded(flex: 2, child: pw.Text(l.exportValueScale, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
          ]),
        ),
        ...List.generate(q.fssAnswers.length, (i) {
          final v = q.fssAnswers[i];
          return pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 3),
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
            ),
            child: pw.Row(children: [
              pw.Expanded(flex: 5, child: pw.Text(_fssItemPdfLabel(i, l), style: const pw.TextStyle(fontSize: 9))),
              pw.Expanded(flex: 2, child: pw.Text(v == null ? '-' : '$v / 7', style: const pw.TextStyle(fontSize: 9))),
            ]),
          );
        }),
      ],
    ));
    final bytes = await doc.save();
    await _shareFile(bytes, 'OptoView_cuestionario_${q.id}.pdf', 'application/pdf');
    AppLogger.info('exportQuestionnairePdf: OK');
  }

  // Private helpers (put them at end of ExportService alongside _testTypeLabel):
  static String _cvsqItemPdfLabel(int i, AppLocalizations l) {
    switch (i) {
      case 0: return l.cvsqItem1; case 1: return l.cvsqItem2;
      case 2: return l.cvsqItem3; case 3: return l.cvsqItem4;
      case 4: return l.cvsqItem5; case 5: return l.cvsqItem6;
      case 6: return l.cvsqItem7; case 7: return l.cvsqItem8;
      case 8: return l.cvsqItem9; case 9: return l.cvsqItem10;
      case 10: return l.cvsqItem11; case 11: return l.cvsqItem12;
      case 12: return l.cvsqItem13; case 13: return l.cvsqItem14;
      case 14: return l.cvsqItem15; case 15: return l.cvsqItem16;
      default: throw StateError('invalid CVS-Q index $i');
    }
  }

  static String _fssItemPdfLabel(int i, AppLocalizations l) {
    switch (i) {
      case 0: return l.fssItem1; case 1: return l.fssItem2;
      case 2: return l.fssItem3; case 3: return l.fssItem4;
      case 4: return l.fssItem5;
      default: throw StateError('invalid FSS index $i');
    }
  }

  static String _freqPdfLabel(CvsqFrequency f, AppLocalizations l) => switch (f) {
        CvsqFrequency.never => l.cvsqFreqNever,
        CvsqFrequency.occasional => l.cvsqFreqOccasional,
        CvsqFrequency.habitual => l.cvsqFreqHabitual,
      };

  static String _intPdfLabel(CvsqIntensity i, AppLocalizations l) => switch (i) {
        CvsqIntensity.moderate => l.cvsqIntModerate,
        CvsqIntensity.intense => l.cvsqIntIntense,
      };
```

- [ ] **Step 3: Add `exportQuestionnaireExcel`**

```dart
  static Future<void> exportQuestionnaireExcel(
    QuestionnaireResult q,
    AppLocalizations l,
  ) async {
    final excel = xl.Excel.createExcel();
    final sheet = excel['Cuestionario'];
    if (excel.sheets.containsKey('Sheet1')) excel.delete('Sheet1');

    int row = 0;
    void set(int c, int r, String v) =>
        sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r)).value = xl.TextCellValue(v);

    set(0, row, l.patientName); set(1, row, q.patientName); row++;
    set(0, row, l.exportTestDate); set(1, row, _dateFmt.format(q.completedAt)); row++;
    set(0, row, l.questionnaireScoreLabel); set(1, row, '${q.cvsqTotalScore}'); row++;
    row++;
    set(0, row, l.questionnaireCvsqSection); row++;
    set(0, row, l.exportItemNumber); set(1, row, l.exportItemName);
    set(2, row, l.exportFrequency); set(3, row, l.exportIntensity); set(4, row, l.exportScore);
    row++;
    for (int i = 0; i < q.cvsqAnswers.length; i++) {
      final a = q.cvsqAnswers[i];
      set(0, row, '${i + 1}');
      set(1, row, _cvsqItemPdfLabel(i, l));
      set(2, row, _freqPdfLabel(a.frequency, l));
      set(3, row, a.intensity == null ? '-' : _intPdfLabel(a.intensity!, l));
      set(4, row, '${a.score}');
      row++;
    }
    row++;
    set(0, row, l.questionnaireFssSection); row++;
    set(0, row, l.exportItemName); set(1, row, l.exportValueScale);
    row++;
    for (int i = 0; i < q.fssAnswers.length; i++) {
      final v = q.fssAnswers[i];
      set(0, row, _fssItemPdfLabel(i, l));
      set(1, row, v == null ? '-' : '$v / 7');
      row++;
    }

    final bytes = excel.encode();
    if (bytes == null) return;
    await _shareFile(Uint8List.fromList(bytes),
        'OptoView_cuestionario_${q.id}.xlsx',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
  }
```

- [ ] **Step 4: Add `exportQuestionnaireCsv`**

```dart
  static Future<void> exportQuestionnaireCsv(
    QuestionnaireResult q,
    AppLocalizations l,
  ) async {
    final buf = StringBuffer();
    buf.writeln('${l.patientName};${q.patientName}');
    buf.writeln('${l.exportTestDate};${_dateFmt.format(q.completedAt)}');
    buf.writeln('${l.questionnaireScoreLabel};${q.cvsqTotalScore}');
    buf.writeln();
    buf.writeln(l.questionnaireCvsqSection);
    buf.writeln([l.exportItemNumber, l.exportItemName, l.exportFrequency, l.exportIntensity, l.exportScore].join(';'));
    for (int i = 0; i < q.cvsqAnswers.length; i++) {
      final a = q.cvsqAnswers[i];
      buf.writeln([
        i + 1,
        _cvsqItemPdfLabel(i, l),
        _freqPdfLabel(a.frequency, l),
        a.intensity == null ? '-' : _intPdfLabel(a.intensity!, l),
        a.score,
      ].join(';'));
    }
    buf.writeln();
    buf.writeln(l.questionnaireFssSection);
    buf.writeln([l.exportItemName, l.exportValueScale].join(';'));
    for (int i = 0; i < q.fssAnswers.length; i++) {
      final v = q.fssAnswers[i];
      buf.writeln([_fssItemPdfLabel(i, l), v == null ? '-' : '$v / 7'].join(';'));
    }
    await _shareFile(
      Uint8List.fromList(buf.toString().codeUnits),
      'OptoView_cuestionario_${q.id}.csv',
      'text/csv',
    );
  }
```

- [ ] **Step 5: Compile**

Run: `cmd.exe /c "flutter analyze lib/services/export_service.dart"`
Expected: `No issues found`.

- [ ] **Step 6: Commit**

```bash
git add lib/services/export_service.dart
git commit -m "feat(export): add individual questionnaire export (pdf/excel/csv)"
```

---

## Task 12: Export — patient summary + bulk handle mixed lists

**Files:**
- Modify: `lib/services/export_service.dart`
- Modify: `lib/screens/history_screen.dart` (call sites)

- [ ] **Step 1: Change bulk/patient method signatures to `List<Object>`**

In `export_service.dart`, update `exportBulkPdf`, `exportBulkExcel`, `exportBulkCsv`, `exportPatientSummaryPdf`, `exportPatientSummaryExcel`, `exportPatientSummaryCsv` so the list parameter becomes `List<Object>`.

Inside each method, partition:
```dart
    final tests = items.whereType<SavedResult>().toList();
    final questionnaires = items.whereType<QuestionnaireResult>().toList();
```

Then:
- PDF: emit existing test section unchanged if `tests.isNotEmpty`; add a new questionnaire section if `questionnaires.isNotEmpty`, using columns `Fecha, Paciente, Score CVS-Q, Ítems respondidos`.
- Excel: single workbook with a sheet "Tests" (existing content) when `tests.isNotEmpty`, and a second sheet "Cuestionarios" when `questionnaires.isNotEmpty`.
- CSV: if both non-empty, produce a ZIP via `package:archive/archive_io.dart` with `tests.csv` + `cuestionarios.csv`; else fall back to a single CSV as today.

Example CSV zip logic:
```dart
import 'package:archive/archive.dart';
// inside exportBulkCsv:
if (tests.isNotEmpty && questionnaires.isNotEmpty) {
  final testsCsv = _buildTestsBulkCsv(tests, l);
  final qCsv = _buildQuestionnaireBulkCsv(questionnaires, l);
  final archive = Archive();
  archive.addFile(ArchiveFile('tests.csv', testsCsv.length, testsCsv.codeUnits));
  archive.addFile(ArchiveFile('cuestionarios.csv', qCsv.length, qCsv.codeUnits));
  final zipBytes = ZipEncoder().encode(archive);
  if (zipBytes == null) return;
  final now = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
  await _shareFile(Uint8List.fromList(zipBytes), 'OptoView_seleccion_$now.zip', 'application/zip');
  return;
}
// Otherwise, if only questionnaires: write single CSV via _buildQuestionnaireBulkCsv.
// Otherwise, if only tests: existing behavior preserved.
```

Implement the private helpers:
```dart
static String _buildTestsBulkCsv(List<SavedResult> tests, AppLocalizations l) { /* existing body extracted */ }

static String _buildQuestionnaireBulkCsv(List<QuestionnaireResult> qs, AppLocalizations l) {
  final buf = StringBuffer();
  buf.writeln([l.exportTestDate, l.patientName, l.questionnaireScoreLabel, '16/16'].join(';'));
  for (final q in qs) {
    buf.writeln([_dateFmt.format(q.completedAt), q.patientName, q.cvsqTotalScore, '16/16'].join(';'));
  }
  return buf.toString();
}
```

- [ ] **Step 2: Patient summary methods — include both types**

Inside each `exportPatientSummary{Pdf,Excel,Csv}`, after partitioning, emit an existing tests block and (if present) a questionnaires block with the same table columns as the bulk export. Do not split into separate files; keep a single PDF/XLSX/CSV per patient.

- [ ] **Step 3: Update history screen call sites**

In `lib/screens/history_screen.dart`, where the bulk export buttons pass `_selectedResults` (currently `List<SavedResult>`) to `ExportService.exportBulkPdf/...`, change the getter to return `List<Object>`:
```dart
  List<Object> get _selectedItems =>
      _items.where((i) => _selectedIds.contains(_idOf(i))).toList()
        ..sort((a, b) => _dateOf(b).compareTo(_dateOf(a)));
```
and update the export callbacks to pass `_selectedItems`.

- [ ] **Step 4: Compile**

Run: `cmd.exe /c "flutter analyze lib/services/export_service.dart lib/screens/history_screen.dart"`
Expected: `No issues found`.

- [ ] **Step 5: Commit**

```bash
git add lib/services/export_service.dart lib/screens/history_screen.dart
git commit -m "feat(export): support mixed tests+questionnaires in bulk/patient exports"
```

---

## Task 13: Widget tests for questionnaire form

**Files:**
- Create: `test/screens/questionnaire_form_screen_test.dart`

- [ ] **Step 1: Write the tests**

Create `test/screens/questionnaire_form_screen_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optoview_flutter/l10n/app_localizations.dart';
import 'package:optoview_flutter/screens/questionnaire_form_screen.dart';

Widget _harness(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('es'),
    home: child,
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Save button disabled until 16 CVS-Q items are answered', (tester) async {
    await tester.pumpWidget(_harness(const QuestionnaireFormScreen()));
    await tester.pumpAndSettle();

    // Tap save; should do nothing (button disabled no-op)
    final saveFinder = find.text('Guardar');
    expect(saveFinder, findsOneWidget);
    await tester.tap(saveFinder);
    await tester.pumpAndSettle();
    // Still on the same screen
    expect(find.text('Cuestionario CVS-Q'), findsWidgets);
  });

  testWidgets('Selecting "Nunca" disables intensity control visually', (tester) async {
    await tester.pumpWidget(_harness(const QuestionnaireFormScreen()));
    await tester.pumpAndSettle();

    // Tap the first row's "Nunca" chip.
    await tester.tap(find.text('Nunca').first);
    await tester.pumpAndSettle();

    // The intensity control on that row should now be wrapped in IgnorePointer (ignoring=true).
    // Find an IgnorePointer widget whose child tree contains "Moderado".
    final ignorePointer = find
        .ancestor(
          of: find.text('Moderado').first,
          matching: find.byType(IgnorePointer),
        )
        .first;
    final ip = tester.widget<IgnorePointer>(ignorePointer);
    expect(ip.ignoring, isTrue);
  });
}
```

- [ ] **Step 2: Run tests**

Run: `cmd.exe /c "flutter test test/screens/questionnaire_form_screen_test.dart"`
Expected: Both tests pass.

- [ ] **Step 3: Commit**

```bash
git add test/screens/questionnaire_form_screen_test.dart
git commit -m "test: widget tests for QuestionnaireFormScreen"
```

---

## Task 14: Manual verification + README of the feature

**No code — manual checklist:**

- [ ] **Step 1: Launch app in Chrome**

Run: `cmd.exe /c "flutter run -d chrome"`.

- [ ] **Step 2: Fill and save a questionnaire**

On Dashboard, tap "Cuestionario CVS-Q". Fill patient name "Test paciente", answer all 16 CVS-Q items (mix of Nunca / Ocasional+Moderado / Habitual+Intenso). Fill 3 of 5 FSS items, leave 2 blank. Confirm the footer score updates live. Save.

- [ ] **Step 3: Verify it appears in history**

Go to Historial. Confirm the questionnaire appears at top with `Icons.assignment` icon, correct patient name, correct score. Select it — detail panel shows all 16 answers with correct scores and the 3 FSS values + 2 dashes.

- [ ] **Step 4: Verify filter chip**

Tap "Cuestionario" filter chip — only questionnaires visible. Toggle off — all items visible again.

- [ ] **Step 5: Verify exports**

From detail panel, tap PDF → file shared. Open it and verify both tables render correctly.
Tap Excel → verify two tables on one sheet.
Tap CSV → verify two labeled sections.

- [ ] **Step 6: Verify bulk mixed export**

Select one test + one questionnaire via multi-select. Tap bulk Excel → two sheets. Tap bulk CSV → ZIP with two files. Tap bulk PDF → one document with two sections.

- [ ] **Step 7: Verify light-mode theme**

Toggle light mode. Form, History tile, detail panel all render with light surfaces. No hardcoded dark remnants in the new code.

- [ ] **Step 8: Final commit of any polish**

If any polish needed, fix and commit. Otherwise ensure tree is clean:
```bash
git status
```

---

## Self-Review Summary

- **Spec coverage**: All 8 spec sections (Context, Goals, Non-Goals, Data Model, Storage, Screens, History Integration, Export, Localization, UI polish, Testing, Dependencies, Rollout) have corresponding tasks.
- **Type consistency**: `QuestionnaireResult.cvsqAnswers` is `List<CvsqAnswer>` (non-null, length 16) throughout. `fssAnswers` is `List<int?>` (length 5). `_items` in History is `List<Object>`. Checked.
- **Scoring rule** appears consistently: `freq == never → 0; else freq.value * (intensity?.value ?? 0)`. Tests cover all branches.
- **FSS semantics**: stored as `List<int?>`, null = unanswered, `1..7` valid; tap-selected-again to clear. Documented in form screen and tests.
- **Dependencies**: `uuid` + `archive` added in Task 1 before they're used (Tasks 5, 12).

---

## Dependencies between tasks

- T1 → T2 (uuid needed in T5 via T2 touching the form; `uuid` is imported in T5)
- T2 → T3 (Storage imports model)
- T2, T3 → T5 (form uses model + storage)
- T4 → T5 (form uses l10n keys)
- T5 → T6 (dashboard navigates to form)
- T2, T3 → T7 (history loads questionnaires)
- T7 → T8, T9, T10 (filter + tile + detail on mixed list)
- T2 → T11 (export uses model)
- T11 → T12 (bulk/patient export reuses helpers)
- T5 + T11 sufficient for T13 (widget test compiles when form exists)
- T14 manual runs after everything
