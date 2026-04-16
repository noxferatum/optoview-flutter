# CVS-Q Questionnaire — Design Spec

**Date:** 2026-04-17
**Author:** Rodrigo Melón Gutte (with Claude)
**Status:** Approved, ready for implementation plan

## Context

OptoView is a clinical neuro-optometric testing app with three tests (Peripheral Stimulation, Peripheral Localization, MacDonald Chart). Results are stored via `SavedResult` + `ResultsStorage` and shown in a unified `HistoryScreen`.

The clinician wants to add a standalone **CVS-Q questionnaire** (Computer Vision Syndrome, 16 items) with an appended **FSS-style section** (5 items, 1-7 scale) for fatigue/motivation context. This is a validated clinical tool; answers must be captured faithfully per the reference form.

## Goals

- Add a questionnaire feature accessible from the Dashboard (independent of tests).
- Persist answers locally with the same patient name as tests (free text, no patient entity).
- Compute and display the CVS-Q total score (no classification threshold shown).
- Surface questionnaires in the existing History screen alongside test results.
- Export to PDF/Excel/CSV (individual, by patient, bulk) consistent with tests.
- Support ES + EN.

## Non-Goals

- Patient entity with unique IDs (stays as free-text `patientName`).
- CVS-Q classification ("Positive/Negative for CVS") — only the total score is shown.
- FSS scoring/interpretation — answers are stored raw.
- Making the FSS section mandatory.
- Network sync / multi-device sharing.

## Architecture Overview

The feature follows OptoView's existing patterns:

- Immutable model classes with `@immutable` + `copyWith` + `toJson`/`fromJson`.
- SharedPreferences storage via an `abstract final class` service.
- `setState()` for UI state, `Navigator.push()` for navigation.
- Localized strings via `AppLocalizations`.

Questionnaires and tests remain **separate types** with no shared abstraction. The History screen loads both lists, merges them by date, and dispatches UI rendering with simple `is` type checks.

## Data Model

### `lib/models/questionnaire_result.dart`

```dart
@immutable
class QuestionnaireResult {
  final String id;                   // UUID v4
  final String patientName;          // free text, may be empty
  final DateTime completedAt;
  final List<CvsqAnswer> cvsqAnswers; // length = 16, in CvsqItem order
  final List<int?> fssAnswers;        // length = 5, each 1..7 or null (optional)
  final int cvsqTotalScore;           // precomputed sum of answer scores

  // copyWith, toJson, fromJson
}

@immutable
class CvsqAnswer {
  final CvsqFrequency frequency;
  final CvsqIntensity? intensity;    // null iff frequency == never

  int get score =>
      frequency == CvsqFrequency.never
          ? 0
          : frequency.value * (intensity?.value ?? 0);
}

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
  burning,           // 1 Quemazón
  itching,           // 2 Picor
  foreignBody,       // 3 Sensación de cuerpo extraño
  tearing,           // 4 Lagrimeo
  excessiveBlinking, // 5 Parpadeo excesivo
  redEye,            // 6 Ojo rojo
  eyePain,           // 7 Dolor ocular
  heavyEyelids,      // 8 Párpados pesados
  dryness,           // 9 Sequedad
  blurredVision,     // 10 Visión borrosa
  doubleVision,      // 11 Visión doble
  nearFocusDifficulty, // 12 Dificultad de enfocar en cerca
  lightSensitivity,  // 13 Elevada sensibilidad a la luz
  colorHalos,        // 14 Halos de colores alrededor de las luces
  worseningVision,   // 15 Siente que ha empeorado la visión
  headache,          // 16 Dolor de cabeza
}

enum FssItem {
  fatigueLevel,       // Grado de fatiga
  motivationLevel,    // Grado de motivación
  stressLevel,        // Grado de estrés
  fatigueInterferes,  // La fatiga me dificulta la realización de tareas
  sleepHours,         // Horas de sueño
}
```

**Scoring rule (per item):** if `frequency == never`, score = 0; otherwise `frequency.value × intensity.value`. `cvsqTotalScore` is the sum across the 16 items. The app **does not** show a "positive/negative for CVS" classification.

**FSS answers:** stored as raw 1–7 integers with `null` meaning "unanswered". No aggregate computed.

## Storage

### `lib/services/questionnaire_storage.dart`

```dart
abstract final class QuestionnaireStorage {
  static Future<void> saveAll(List<QuestionnaireResult> items);
  static Future<List<QuestionnaireResult>> loadAll();
  static Future<void> addOrUpdate(QuestionnaireResult q);
  static Future<void> delete(String id);
  static Future<void> clear();
}
```

- Key: `questionnaires` in `SharedPreferences`
- Payload: JSON array of `QuestionnaireResult.toJson()`
- Same defensive `try/catch` pattern as `ConfigStorage` / `ResultsStorage`
- Errors logged via `AppLogger`

## Screens

### Dashboard — new card

In `lib/screens/dashboard_screen.dart`, add a new card in the "left column" after the three test cards (and after the "Repetir último test" card when present):

- Icon: `Icons.assignment`
- Label (l10n): "Cuestionario CVS-Q" / "CVS-Q Questionnaire"
- Subtitle: "Evaluación de síntomas visuales" / "Visual symptoms assessment"
- Tap → `Navigator.push` to `QuestionnaireFormScreen` via `OptoPageRoute`
- Included in the existing staggered entrance animation (becomes animation item index 4; shift subsequent indices)

### `lib/screens/questionnaire_form_screen.dart`

Structure:

1. **Custom AppBar** (`Container` row, matching existing config screens): back button, title, `OptoActionButton` "Guardar" (disabled until the 16 CVS-Q items are answered).
2. **Scroll body**:
   - `OptoTextField` "Nombre del paciente" (optional, same semantics as tests).
   - `OptoSectionHeader("CVS-Q")` + live counter chip "X/16 respondidas".
   - **CVS-Q grid**: for each `CvsqItem`:
     - Item label + number.
     - `OptoSegmentedControl<CvsqFrequency>` with 3 options.
     - `OptoSegmentedControl<CvsqIntensity>` with 2 options, **disabled and visually dimmed** when frequency == never.
     - Small "Score: N" indicator on the right.
   - `OptoSectionHeader("Fatiga y motivación — opcional")`.
   - **FSS grid**: for each `FssItem`:
     - Label on the left.
     - `OptoSegmentedControl<int>` with 7 buttons labeled 1–7, plus "Acuerdo"/"Desacuerdo" anchor labels at the ends.
     - Row value is `null` until first tap. Tapping the currently selected button a second time clears the answer back to `null`.
3. **Footer** — `ConfigBottomBar`-style sticky bar: "CVS-Q: {score} · {answered}/16" + "Guardar".

On Save:
- Generate `id` (UUID via `package:uuid`, which is already a transitive dep; if not present, add it to `pubspec.yaml`).
- Set `completedAt = DateTime.now()`.
- Compute `cvsqTotalScore`.
- `await QuestionnaireStorage.addOrUpdate(...)`.
- Show snackbar "Cuestionario guardado" / "Questionnaire saved".
- `Navigator.pop(context)` back to Dashboard.

## History Integration

Changes to `lib/screens/history_screen.dart`:

1. **Load both lists in parallel** in `_loadData`:
   ```dart
   final (tests, qs) = await (ResultsStorage.loadAll(), QuestionnaireStorage.loadAll()).wait;
   _items = [...tests, ...qs]..sort((a, b) => _dateOf(b).compareTo(_dateOf(a)));
   ```
   where `_items` is `List<Object>` and `_dateOf` returns `startedAt` or `completedAt`.

2. **Filter chips**: the existing test-type filter gains a fourth chip "Cuestionario" / "Questionnaire" that keeps only `QuestionnaireResult` items.

3. **List tile rendering**: a `_buildTile(item)` dispatcher returns either the existing `SavedResult` tile or a new `_buildQuestionnaireTile(q)`:
   - Icon `Icons.assignment`, color `OptoColors.primary`
   - Line 1: patient name (or "Cuestionario CVS-Q" if blank)
   - Line 2: "CVS-Q · Score: {score} · {relativeTime}"
   - No "Detenido/Completo" badge; questionnaires only exist if saved complete (16 items).

4. **Detail panel** for questionnaires:
   - Header: patient + absolute date + large total score
   - Section "Síntomas (CVS-Q)" (scrollable): 16 rows with item label, frequency label, intensity label, score
   - Section "Fatiga (FSS)": 5 rows with value 1–7 or "—" if null
   - Export buttons (PDF/Excel/CSV) and Delete button in the detail header, same affordances as `SavedResult`

5. **Selection / bulk actions**: the existing `_selectedIds` set accepts IDs from either source; export dispatches per-type in `ExportService`.

6. **Patient grouping view**: the grouped-by-patient mode merges both types under the same patient; questionnaires appear in the same group sorted by date alongside tests.

## Export

### New methods in `lib/services/export_service.dart`

- `exportQuestionnairePdf(BuildContext ctx, QuestionnaireResult q, AppLocalizations l)`
- `exportQuestionnaireExcel(QuestionnaireResult q, AppLocalizations l)`
- `exportQuestionnaireCsv(QuestionnaireResult q, AppLocalizations l)`

**PDF layout** (A4, portrait, via `pdf` package):
- Header: title "Cuestionario CVS-Q", patient, date, total score (prominent).
- Table 1 "Síntomas visuales": columns `#`, `Item`, `Frecuencia`, `Intensidad`, `Score`. 16 rows.
- Table 2 "Fatiga y motivación": columns `Item`, `Valor (1-7)`. 5 rows. Blank cells if skipped.
- Footer: app version + generated-at timestamp.

**Excel layout**: single sheet "Cuestionario" with two labeled tables stacked vertically. Header row styling via existing `xl.Excel` patterns.

**CSV layout**: single file, sections separated by blank line + header row. Use `;` as separator (consistent with existing exports).

### Bulk / multi-item exports

`exportBulkPdf/Excel/Csv(List<Object>, AppLocalizations)` — argument becomes `List<Object>` (mixed `SavedResult` and `QuestionnaireResult`). Behavior:

- **PDF**: one document with two sections: "Tests" (existing logic) and "Cuestionarios" (new bulk table with columns `Fecha`, `Paciente`, `Score CVS-Q`, `Ítems respondidos`). Each section omitted if empty.
- **Excel**: two sheets, `Tests` and `Cuestionarios`. Sheets omitted if empty.
- **CSV mixed case**: produce a **ZIP** with two files `tests.csv` + `cuestionarios.csv`. Use `package:archive` (add if absent). Zip omitted in the single-type case (single CSV as today).

### Patient-summary exports

`exportPatientSummaryPdf/Excel/Csv(patientName, List<Object>, AppLocalizations)` — same mixed handling as bulk; each export includes both tests and questionnaires for that patient.

## Localization

Add to `lib/l10n/app_es.arb` and `app_en.arb`:

**Screen labels**
- `questionnaireMenuTitle` — dashboard card title
- `questionnaireMenuSubtitle`
- `questionnaireFormTitle` — AppBar title
- `questionnaireCvsqSection`
- `questionnaireFssSection`
- `questionnaireFssOptionalHint`
- `questionnaireAnsweredCount` — "{count}/16 respondidas" with plural
- `questionnaireScoreLabel` — "Score CVS-Q"
- `questionnaireSaveButton`
- `questionnaireSavedSnack`
- `questionnaireSkipButton`

**CVS-Q items** (16 keys): `cvsqItem1`..`cvsqItem16`. Spanish strings match the reference form exactly. English strings are faithful translations (e.g., "Quemazón" → "Burning sensation"). For clinically validated use the Spanish form is canonical; the English is a convenience translation.

**CVS-Q frequency / intensity labels**
- `cvsqFreqNever`, `cvsqFreqOccasional`, `cvsqFreqHabitual`
- `cvsqIntModerate`, `cvsqIntIntense`
- `cvsqFreqHeader` ("Frecuencia"), `cvsqIntHeader` ("Intensidad")

**FSS items** (5 keys): `fssItem1`..`fssItem5`.
**FSS anchors**: `fssAnchorAgree` ("Acuerdo"), `fssAnchorDisagree` ("Desacuerdo").

**History**
- `historyTestQuestionnaire` — chip filter label
- `questionnaireHistoryLabel` — tile subtitle fragment

**Export**
- `exportQuestionnaireTitle`, `exportQuestionnaireBulkTitle`
- Table headers: `exportItemNumber`, `exportItemName`, `exportFrequency`, `exportIntensity`, `exportScore`, `exportValueScale`

## UI polish notes

- The dashboard card uses the same `OptoCard` as the test cards (theme-aware after the recent light-mode refactor) — no special styling beyond icon+label.
- Frequency "Nunca" chip, when selected, causes the intensity segmented control to fade to 40% opacity and become non-interactive. This is the only disabled-state UI subtlety in the form.
- Footer summary updates live as the user answers (keep a simple `setState` recount; 16 items is trivial).

## Testing

- Unit tests for `CvsqAnswer.score` covering all frequency×intensity combos including `never` → 0.
- Unit tests for `QuestionnaireStorage` round-trip (save → load → equals).
- Widget tests for `QuestionnaireFormScreen`:
  - Save button disabled until 16 CVS-Q items answered.
  - Intensity control disabled when frequency == never.
  - FSS rows independently toggleable and clearable.
- History screen test: mixed list sorts by date; filter "Questionnaire" isolates questionnaires.

## Dependencies

- `package:uuid` — used for generating IDs. The implementation must check `pubspec.yaml`; if not already declared, add it under `dependencies`.
- `package:archive` — for zipped CSV bulk export when the selection contains both tests and questionnaires. Add to `pubspec.yaml` unless already present.

## Rollout

Single branch, single PR. No feature flag — functionality is additive and gated behind the new dashboard card. Existing tests and flows are untouched.

## Open questions resolved during brainstorming

- **When filled** → Independent of tests, from Dashboard button (option C).
- **Patient identity** → Keep free-text `patientName` (option A).
- **Scoring** → Save answers + compute CVS-Q total, no classification shown (option B).
- **History** → Mixed into existing History with a new filter chip (option A).
- **Languages** → ES + EN with our own translations (option B).
- **Export** → Full parity with tests: PDF/Excel/CSV individual + per-patient + bulk (option A).
- **FSS** → Optional (can save without answering FSS section).
