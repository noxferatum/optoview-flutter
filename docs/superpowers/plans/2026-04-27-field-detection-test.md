# Test de Detección de Campo — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Crear un cuarto test independiente "Detección de Campo" con configuración fija (44 letras en 4 anillos, sin tiempo, termina al completarse) sacándolo de los modos del test MacDonald, y corregir las etiquetas de la escala FSS del cuestionario.

**Architecture:** Modelo aislado siguiendo el patrón del resto de tests (`field_detection_config.dart` + `field_detection_result.dart` + 3 pantallas dedicadas). Reutiliza los enums compartidos (`Velocidad`, `MacContenido`, `Fondo`, `Fijacion`, `EstimuloColor`) y la clase `LetterEvent`. Persistencia mediante factory en el `SavedResult` existente — no requiere cambios de esquema. Limpieza posterior del modo `deteccionCampo` en MacDonald.

**Tech Stack:** Flutter (Dart) ^3.8.0, Material 3, `shared_preferences`, `flutter_localizations` desde `.arb`, `intl`.

**Environment note (user preferences):** Repo en WSL2. Todos los comandos `flutter` y `dart` deben ejecutarse vía `cmd.exe /c "flutter ..."`.

**Testing strategy:** Este proyecto no mantiene suite de widget/unit tests (ver plan `2026-04-22-settings-screen.md`). Verificación = `flutter analyze` + checklist QA manual al final (Task 13). **No** añadir widget tests para este test — rompe el patrón del proyecto.

---

## File Structure

**Crear:**
- `lib/models/field_detection_config.dart` — config inmutable con valores fijos.
- `lib/models/field_detection_result.dart` — resultado con métricas globales, por anillo y por cuadrante.
- `lib/screens/field_detection_config_screen.dart` — pantalla informativa pre-test.
- `lib/screens/field_detection_test.dart` — test inmersivo.
- `lib/screens/field_detection_results_screen.dart` — pantalla de resultados.

**Modificar:**
- `lib/theme/opto_colors.dart` — añadir constante `fieldDetection`.
- `lib/models/saved_result.dart` — añadir factory `fromFieldDetectionResult`.
- `lib/screens/dashboard_screen.dart` — 4ª card.
- `lib/screens/history_screen.dart` — soporte `'field_detection'` en label/icon/color/filtro.
- `lib/services/export_service.dart` — soporte `'field_detection'` en label.
- `lib/models/macdonald_config.dart` — eliminar `MacInteraccion.deteccionCampo`.
- `lib/models/macdonald_presets.dart` — eliminar preset `fieldDetection`.
- `lib/screens/macdonald_test.dart` — eliminar lógica de detección de campo.
- `lib/screens/macdonald_config_screen.dart` — eliminar caso del switch.
- `lib/screens/macdonald_results_screen.dart` — eliminar referencia a `deteccionCampo`.
- `lib/l10n/app_es.arb` y `lib/l10n/app_en.arb` — strings nuevas, fix FSS, eliminar obsoletas.
- `pubspec.yaml` — bump versión.

---

## Task 1: Añadir color de marca para el nuevo test

**Files:**
- Modify: `lib/theme/opto_colors.dart:23-26`

- [ ] **Step 1: Añadir constante `fieldDetection` al bloque "Test type accents"**

Editar `lib/theme/opto_colors.dart`. Localizar:

```dart
  // Test type accents
  static const Color peripheral = Color(0xFF5B8FD2);
  static const Color localization = Color(0xFF9B7BFF);
  static const Color macdonald = Color(0xFF4CAF7D);
```

Reemplazar por:

```dart
  // Test type accents
  static const Color peripheral = Color(0xFF5B8FD2);
  static const Color localization = Color(0xFF9B7BFF);
  static const Color macdonald = Color(0xFF4CAF7D);
  static const Color fieldDetection = Color(0xFFE5A84B);
```

(Tono ámbar/dorado, mismo valor que `OptoColors.warning` — distingue visualmente del trío azul/violeta/verde existente.)

- [ ] **Step 2: Verificar análisis estático**

Run: `cmd.exe /c "flutter analyze lib/theme/opto_colors.dart"`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/theme/opto_colors.dart
git commit -m "feat: añadir color OptoColors.fieldDetection"
```

---

## Task 2: Crear `FieldDetectionConfig`

**Files:**
- Create: `lib/models/field_detection_config.dart`

- [ ] **Step 1: Crear el archivo de config**

Create `lib/models/field_detection_config.dart`:

```dart
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'macdonald_config.dart' show MacContenido;
import 'test_config.dart';

/// Configuración del test de Detección de Campo.
///
/// Es deliberadamente fija (constante `standard`) — no hay presets editables.
/// El test es estandarizado para que los resultados sean comparables entre
/// pacientes.
@immutable
class FieldDetectionConfig {
  final int numAnillos;
  final int letrasPorAnilloBase;
  final double tamanoBase;
  final Velocidad velocidad;
  final MacContenido contenido;
  final Fondo fondo;
  final Fijacion fijacion;
  final EstimuloColor colorLetras;
  final bool letrasAleatorias;

  const FieldDetectionConfig({
    required this.numAnillos,
    required this.letrasPorAnilloBase,
    required this.tamanoBase,
    required this.velocidad,
    required this.contenido,
    required this.fondo,
    required this.fijacion,
    required this.colorLetras,
    required this.letrasAleatorias,
  });

  /// Configuración estándar única del test.
  static const FieldDetectionConfig standard = FieldDetectionConfig(
    numAnillos: 4,
    letrasPorAnilloBase: 8,
    tamanoBase: 24,
    velocidad: Velocidad.lenta,
    contenido: MacContenido.letras,
    fondo: Fondo.oscuro,
    fijacion: Fijacion.punto,
    colorLetras: EstimuloColor.blanco,
    letrasAleatorias: true,
  );

  /// Total de letras que se mostrarán en el test (suma de letras por anillo).
  /// Cada anillo tiene `letrasPorAnilloBase + 2 * ringIndex` letras.
  int get totalLetras {
    int total = 0;
    for (int r = 0; r < numAnillos; r++) {
      total += letrasPorAnilloBase + 2 * r;
    }
    return total;
  }

  Map<String, String> localizedSummary(AppLocalizations l) {
    final speedLabel = switch (velocidad) {
      Velocidad.lenta => l.speedSlow,
      Velocidad.media => l.speedMedium,
      Velocidad.rapida => l.speedFast,
    };
    final fixLabel = switch (fijacion) {
      Fijacion.cara => l.fixationFace,
      Fijacion.ojo => l.fixationEye,
      Fijacion.punto => l.fixationDot,
      Fijacion.trebol => l.fixationClover,
      Fijacion.cruz => l.fixationCross,
    };
    final bgLabel = switch (fondo) {
      Fondo.claro => l.backgroundLight,
      Fondo.oscuro => l.backgroundDark,
      Fondo.azul => l.backgroundBlue,
    };
    final colorLabel = switch (colorLetras) {
      EstimuloColor.rojo => l.colorRed,
      EstimuloColor.verde => l.colorGreen,
      EstimuloColor.azul => l.colorBlue,
      EstimuloColor.amarillo => l.colorYellow,
      EstimuloColor.blanco => l.colorWhite,
      EstimuloColor.morado => l.colorPurple,
      EstimuloColor.negro => l.colorBlack,
      EstimuloColor.aleatorio => l.colorRandom,
    };
    final contentLabel = switch (contenido) {
      MacContenido.letras => l.macContentLetters,
      MacContenido.numeros => l.macContentNumbers,
    };
    return {
      l.summaryKeyContent: contentLabel,
      l.summaryKeyRings: '$numAnillos',
      l.summaryKeyLettersPerRing: '$letrasPorAnilloBase',
      l.summaryKeySize: '${tamanoBase.toStringAsFixed(0)}%',
      l.summaryKeySpeed: speedLabel,
      l.summaryKeyFixation: fixLabel,
      l.summaryKeyBackground: bgLabel,
      l.summaryKeyColor: colorLabel,
    };
  }
}
```

- [ ] **Step 2: Verificar análisis estático**

Run: `cmd.exe /c "flutter analyze lib/models/field_detection_config.dart"`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/models/field_detection_config.dart
git commit -m "feat: añadir modelo FieldDetectionConfig con preset standard fijo"
```

---

## Task 3: Crear `FieldDetectionResult`

**Files:**
- Create: `lib/models/field_detection_result.dart`

- [ ] **Step 1: Crear el archivo de resultado**

Create `lib/models/field_detection_result.dart`:

```dart
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
    final times = <int, List<double>>{};
    for (int i = 0; i < letterEvents.length; i++) {
      final e = letterEvents[i];
      if (!e.isHit) continue;
      // Asumimos `reactionTimesMs[k]` corresponde al k-ésimo acierto en orden.
      // Para mapearlo al anillo, recorremos eventos y usamos un índice paralelo.
    }
    // Implementación correcta: contar hits por orden de aparición
    final hitTimesByRing = <int, List<double>>{};
    int hitIdx = 0;
    for (final e in letterEvents) {
      if (e.isHit) {
        if (hitIdx < reactionTimesMs.length) {
          hitTimesByRing.putIfAbsent(e.ringIndex, () => []).add(reactionTimesMs[hitIdx]);
        }
        hitIdx++;
      }
    }
    final out = <int, double>{};
    for (int r = 0; r < config.numAnillos; r++) {
      final list = hitTimesByRing[r];
      if (list == null || list.isEmpty) {
        out[r] = 0;
      } else {
        out[r] = list.reduce((a, b) => a + b) / list.length;
      }
    }
    return out;
    // Variable `times` arriba quedó no usada; eliminar al limpiar.
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
```

**Nota:** la implementación de `avgRtByRing` arriba contiene una variable `times` declarada y no usada — **bórrala** antes de continuar (líneas que dicen "Variable `times` arriba quedó no usada"). El cuerpo correcto empieza en `final hitTimesByRing = ...`.

- [ ] **Step 2: Verificar análisis estático**

Run: `cmd.exe /c "flutter analyze lib/models/field_detection_result.dart"`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/models/field_detection_result.dart
git commit -m "feat: añadir modelo FieldDetectionResult con métricas por anillo y cuadrante"
```

---

## Task 4: Strings i18n — añadir nuevas, cambiar FSS, eliminar obsoletas

**Files:**
- Modify: `lib/l10n/app_es.arb`
- Modify: `lib/l10n/app_en.arb`

- [ ] **Step 1: Cambiar etiquetas FSS en `app_es.arb`**

Editar `lib/l10n/app_es.arb`. Localizar (línea ~467):

```json
  "fssAnchorAgree": "Acuerdo",
  "fssAnchorDisagree": "Desacuerdo",
```

Reemplazar por:

```json
  "fssAnchorAgree": "Bastante",
  "fssAnchorDisagree": "Poco o nada",
```

- [ ] **Step 2: Cambiar etiquetas FSS en `app_en.arb`**

Editar `lib/l10n/app_en.arb`. Localizar (línea ~467):

```json
  "fssAnchorAgree": "Agree",
  "fssAnchorDisagree": "Disagree",
```

Reemplazar por:

```json
  "fssAnchorAgree": "A lot",
  "fssAnchorDisagree": "Little or none",
```

- [ ] **Step 3: Eliminar strings obsoletas en ambos `.arb`**

Eliminar de `app_es.arb` y `app_en.arb` las claves siguientes (junto con sus líneas `@`-metadata si existen):
- `macInteractionFieldDetection`
- `presetMacFieldDetectionDesc`
- `instructMacFieldDetection`

Para localizarlas:

Run: `grep -n "macInteractionFieldDetection\|presetMacFieldDetectionDesc\|instructMacFieldDetection" lib/l10n/app_es.arb lib/l10n/app_en.arb`

Eliminar exactamente esas líneas (cuidado con la coma final del campo previo si la última clave de un grupo se borra).

- [ ] **Step 4: Añadir strings nuevas en `app_es.arb`**

Añadir antes de la `}` final de `app_es.arb` (mantener orden alfabético-temático ahí donde encajen mejor; si no, pegar al final con coma en la línea anterior):

```json
  "testFieldDetectionTitle": "Detección de campo",
  "testFieldDetectionSubtitle": "Detección de letras periféricas, sin tiempo",
  "historyTestFieldDetection": "Detección de campo",
  "configFieldDetectionTitle": "Detección de campo",
  "configFieldDetectionDescription": "Test estandarizado: aparecen 44 letras de una en una en 4 anillos. Toca cada letra antes de que desaparezca.",
  "instructFieldDetection": "Mantén la mirada en el centro y toca cada letra que aparezca lo más rápido posible.",
  "instructFieldDetectionRings": "Aparecerán 44 letras en total distribuidas en 4 anillos.",
  "fieldDetectionResultsTitle": "Resultados — Detección de campo",
  "fieldDetectionByRing": "Por anillo",
  "fieldDetectionByQuadrant": "Por cuadrante",
  "fieldDetectionRing": "Anillo {n}",
  "@fieldDetectionRing": {
    "placeholders": { "n": { "type": "int" } }
  },
  "fieldDetectionQuadrantTL": "Sup-Izq",
  "fieldDetectionQuadrantTR": "Sup-Der",
  "fieldDetectionQuadrantBL": "Inf-Izq",
  "fieldDetectionQuadrantBR": "Inf-Der",
  "fieldDetectionLetterCounter": "{i} de {n}",
  "@fieldDetectionLetterCounter": {
    "placeholders": {
      "i": { "type": "int" },
      "n": { "type": "int" }
    }
  }
```

- [ ] **Step 5: Añadir strings nuevas en `app_en.arb`**

Mismas claves, traducciones EN:

```json
  "testFieldDetectionTitle": "Field detection",
  "testFieldDetectionSubtitle": "Peripheral letter detection, untimed",
  "historyTestFieldDetection": "Field detection",
  "configFieldDetectionTitle": "Field detection",
  "configFieldDetectionDescription": "Standardized test: 44 letters appear one at a time across 4 rings. Tap each letter before it disappears.",
  "instructFieldDetection": "Keep your gaze on the center and tap each letter as it appears as fast as possible.",
  "instructFieldDetectionRings": "44 letters will appear distributed across 4 rings.",
  "fieldDetectionResultsTitle": "Results — Field detection",
  "fieldDetectionByRing": "By ring",
  "fieldDetectionByQuadrant": "By quadrant",
  "fieldDetectionRing": "Ring {n}",
  "@fieldDetectionRing": {
    "placeholders": { "n": { "type": "int" } }
  },
  "fieldDetectionQuadrantTL": "Top-Left",
  "fieldDetectionQuadrantTR": "Top-Right",
  "fieldDetectionQuadrantBL": "Bottom-Left",
  "fieldDetectionQuadrantBR": "Bottom-Right",
  "fieldDetectionLetterCounter": "{i} of {n}",
  "@fieldDetectionLetterCounter": {
    "placeholders": {
      "i": { "type": "int" },
      "n": { "type": "int" }
    }
  }
```

- [ ] **Step 6: Regenerar localizaciones**

Run: `cmd.exe /c "flutter gen-l10n"`
Expected: regenera `lib/l10n/app_localizations.dart`, `_es.dart`, `_en.dart` sin errores.

- [ ] **Step 7: Verificar análisis estático global**

Run: `cmd.exe /c "flutter analyze"`
Expected: errores en archivos que aún usan las claves eliminadas (`macInteractionFieldDetection`, `presetMacFieldDetectionDesc`, `instructMacFieldDetection`). Estos son esperados aquí y se resolverán en Tasks 11-12. **Anótalos pero no commitees aún si hay errores en otros archivos.**

Si hay errores **distintos** a esos (p.ej. typos en las claves nuevas), corregir antes de continuar.

- [ ] **Step 8: Commit**

```bash
git add lib/l10n/app_es.arb lib/l10n/app_en.arb lib/l10n/app_localizations.dart lib/l10n/app_localizations_es.dart lib/l10n/app_localizations_en.dart
git commit -m "feat: i18n strings de Detección de Campo + fix etiquetas FSS"
```

(Errores temporales en archivos MacDonald son esperados; se resuelven en Tasks 11-12.)

---

## Task 5: Pantalla de configuración informativa

**Files:**
- Create: `lib/screens/field_detection_config_screen.dart`

- [ ] **Step 1: Crear la pantalla**

Create `lib/screens/field_detection_config_screen.dart`:

```dart
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/field_detection_config.dart';
import '../services/config_storage.dart';
import '../theme/opto_colors.dart';
import '../theme/opto_spacing.dart';
import '../utils/page_transitions.dart';
import '../widgets/config_shared/config_bottom_bar.dart';
import '../widgets/design_system/opto_card.dart';
import '../widgets/design_system/opto_section_header.dart';
import 'field_detection_test.dart';

class FieldDetectionConfigScreen extends StatefulWidget {
  const FieldDetectionConfigScreen({super.key});

  @override
  State<FieldDetectionConfigScreen> createState() =>
      _FieldDetectionConfigScreenState();
}

class _FieldDetectionConfigScreenState
    extends State<FieldDetectionConfigScreen> {
  final _patientController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPatientName();
  }

  @override
  void dispose() {
    _patientController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientName() async {
    final name = await ConfigStorage.loadPatientName();
    if (mounted) {
      setState(() => _patientController.text = name);
    }
  }

  void _startTest() {
    ConfigStorage.savePatientName(_patientController.text.trim());
    Navigator.push(
      context,
      OptoPageRoute(
        builder: (_) => FieldDetectionTest(
          config: FieldDetectionConfig.standard,
          patientName: _patientController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final summary = FieldDetectionConfig.standard.localizedSummary(l);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.configFieldDetectionTitle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(OptoSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Descripción
                    OptoCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: OptoColors.fieldDetection.withAlpha(38),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.visibility,
                              color: OptoColors.fieldDetection,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: OptoSpacing.md),
                          Expanded(
                            child: Text(
                              l.configFieldDetectionDescription,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: OptoSpacing.md),

                    // Resumen de configuración
                    OptoSectionHeader(text: l.summarySectionTitle),
                    const SizedBox(height: OptoSpacing.sm),
                    OptoCard(
                      child: Column(
                        children: summary.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: OptoSpacing.xs,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    entry.key,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    entry.value,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: OptoSpacing.md),

                    // Nombre del paciente
                    OptoSectionHeader(text: l.patientNameLabel),
                    const SizedBox(height: OptoSpacing.sm),
                    TextField(
                      controller: _patientController,
                      decoration: InputDecoration(
                        hintText: l.patientNameHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            OptoSpacing.radiusInput,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom bar con botón Empezar
            ConfigBottomBar(
              onStart: _startTest,
            ),
          ],
        ),
      ),
    );
  }
}
```

**Nota:** verificar antes de pegar que las claves usadas (`l.summarySectionTitle`, `l.patientNameLabel`, `l.patientNameHint`, `OptoSpacing.radiusInput`, `OptoSectionHeader`) existen en el proyecto. Si alguna no existe, comprobar el equivalente en `lib/screens/macdonald_config_screen.dart` y ajustar el código a las claves/widgets reales del proyecto **sin inventar nuevas**.

Run: `grep -n "summarySectionTitle\|patientNameLabel\|patientNameHint\|radiusInput\|OptoSectionHeader" lib/l10n/app_es.arb lib/theme/opto_spacing.dart lib/widgets/design_system/opto_section_header.dart`

Si alguna no existe, sustituir por la equivalente real (consultar `macdonald_config_screen.dart`).

- [ ] **Step 2: Verificar análisis estático**

Run: `cmd.exe /c "flutter analyze lib/screens/field_detection_config_screen.dart"`
Expected: errores temporales sólo si `field_detection_test.dart` no existe (creará en Task 6). Anotar.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/field_detection_config_screen.dart
git commit -m "feat: añadir FieldDetectionConfigScreen (informativa, sólo lectura)"
```

---

## Task 6: Pantalla del test inmersivo

**Files:**
- Create: `lib/screens/field_detection_test.dart`

- [ ] **Step 1: Crear la pantalla del test**

Create `lib/screens/field_detection_test.dart`:

```dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../mixins/immersive_test_mixin.dart';
import '../models/field_detection_config.dart';
import '../models/field_detection_result.dart';
import '../models/macdonald_result.dart' show LetterEvent;
import '../models/test_config.dart';
import '../services/config_storage.dart';
import '../utils/page_transitions.dart';
import '../widgets/center_fixation.dart';
import '../widgets/test_ui/instruction_overlay.dart';
import '../widgets/test_ui/pause_overlay.dart';
import '../widgets/test_ui/test_control_buttons.dart';
import 'field_detection_results_screen.dart';

class FieldDetectionTest extends StatefulWidget {
  final FieldDetectionConfig config;
  final String patientName;

  const FieldDetectionTest({
    super.key,
    required this.config,
    required this.patientName,
  });

  @override
  State<FieldDetectionTest> createState() => _FieldDetectionTestState();
}

class _FieldLetterData {
  final String letter;
  final int ringIndex;
  final int posIndex;
  final Offset position;
  bool isRevealed = false;
  DateTime? revealedAt;

  _FieldLetterData({
    required this.letter,
    required this.ringIndex,
    required this.posIndex,
    required this.position,
  });
}

class _FieldDetectionTestState extends State<FieldDetectionTest>
    with WidgetsBindingObserver, ImmersiveTestMixin {
  Timer? _letterTimer;
  Timer? _preCountdownTimer;

  // Estado de pre-test
  bool _showingInstructions = false;
  int _preCountdown = 3;
  bool _testStarted = false;

  // Letras
  final List<_FieldLetterData> _allLetters = [];
  Offset _chartCenter = Offset.zero;
  double _maxRadius = 1;
  late List<int> _revealOrder;
  int _revealIndex = 0;

  // Métricas
  int _totalLetrasShown = 0;
  int _correctCount = 0;
  int _missedCount = 0;
  final List<double> _reactionTimesMs = [];
  final List<LetterEvent> _letterEvents = [];
  final List<double> _tiempoPorAnillo = [];
  int? _currentRingIndex;
  DateTime? _ringStartedAt;

  bool _isPaused = false;
  late DateTime _startedAt;
  DateTime? _firstLetterAt;
  final _rand = Random();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initImmersiveMode();
    _startedAt = DateTime.now();
    _checkInstructions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelAllTimers();
    disposeImmersiveMode();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (!_isPaused && _testStarted) _pauseTest();
    }
  }

  // --- Instrucciones / countdown ---

  Future<void> _checkInstructions() async {
    final show = await ConfigStorage.loadShowInstructions();
    if (!mounted) return;
    if (show) {
      setState(() => _showingInstructions = true);
    } else {
      _runPreCountdown();
    }
  }

  void _handleInstructionsComplete() {
    setState(() {
      _showingInstructions = false;
      _testStarted = true;
    });
    _startedAt = DateTime.now();
    _startTestAfterLayout();
  }

  List<String> _buildInstructions(AppLocalizations l) {
    return [
      l.instructFixation,
      l.instructFieldDetection,
      l.instructFieldDetectionRings,
    ];
  }

  void _runPreCountdown() {
    _preCountdown = 3;
    _preCountdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _preCountdown--;
        if (_preCountdown <= 0) {
          t.cancel();
          _testStarted = true;
          _startedAt = DateTime.now();
          _startTestAfterLayout();
        }
      });
    });
  }

  void _startTestAfterLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final sz = MediaQuery.of(context).size;
      _generateChart(sz);
      setState(() {});
      _revealNextLetter();
    });
  }

  // --- Generación de la carta ---

  void _generateChart(Size screenSize) {
    _allLetters.clear();
    final center = Offset(screenSize.width / 2, screenSize.height / 2);
    _chartCenter = center;
    final maxRadius = min(screenSize.width, screenSize.height) * 0.42;
    _maxRadius = maxRadius;
    final numRings = widget.config.numAnillos;
    final base = widget.config.letrasPorAnilloBase;

    final chars = widget.config.contenido.toString().endsWith('numeros')
        ? '0123456789'
        : 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    int letterIdx = 0;
    for (int ring = 0; ring < numRings; ring++) {
      final lettersInRing = base + 2 * ring;
      final ringRadius = maxRadius * (ring + 1) / numRings;
      for (int i = 0; i < lettersInRing; i++) {
        final angle = (2 * pi * i / lettersInRing) - pi / 2;
        final x = center.dx + ringRadius * cos(angle);
        final y = center.dy + ringRadius * sin(angle);
        final letter = widget.config.letrasAleatorias
            ? chars[_rand.nextInt(chars.length)]
            : chars[letterIdx % chars.length];
        letterIdx++;
        _allLetters.add(_FieldLetterData(
          letter: letter,
          ringIndex: ring,
          posIndex: i,
          position: Offset(x, y),
        ));
      }
    }

    _revealOrder = List<int>.generate(_allLetters.length, (i) => i)
      ..shuffle(_rand);
  }

  // --- Bucle principal ---

  void _revealNextLetter() {
    if (!mounted || _isPaused) return;
    if (_revealIndex >= _revealOrder.length) {
      _finishTest(stoppedManually: false);
      return;
    }

    final idx = _revealOrder[_revealIndex];
    final letter = _allLetters[idx];

    // Track ring transitions
    if (_currentRingIndex == null) {
      _currentRingIndex = letter.ringIndex;
      _ringStartedAt = DateTime.now();
    } else if (letter.ringIndex != _currentRingIndex) {
      _recordRingDuration();
      _currentRingIndex = letter.ringIndex;
      _ringStartedAt = DateTime.now();
    }

    setState(() {
      letter.isRevealed = true;
      letter.revealedAt = DateTime.now();
      _firstLetterAt ??= letter.revealedAt;
      _totalLetrasShown++;
    });

    final periodMs = widget.config.velocidad.milliseconds;
    _letterTimer?.cancel();
    _letterTimer = Timer(Duration(milliseconds: periodMs), () {
      if (!mounted || _isPaused) return;
      // Timeout: missed
      _missedCount++;
      _letterEvents.add(LetterEvent(
        dx: (letter.position.dx - _chartCenter.dx) / _maxRadius,
        dy: (letter.position.dy - _chartCenter.dy) / _maxRadius,
        ringIndex: letter.ringIndex,
        isHit: false,
      ));
      setState(() {
        letter.isRevealed = false;
      });
      _revealIndex++;
      _revealNextLetter();
    });
  }

  void _onLetterTapped(int idx) {
    if (_isPaused || _revealIndex >= _revealOrder.length) return;
    if (idx != _revealOrder[_revealIndex]) return;

    final letter = _allLetters[idx];
    if (!letter.isRevealed) return;

    _letterTimer?.cancel();
    _letterTimer = null;

    final reactionMs = letter.revealedAt != null
        ? DateTime.now().difference(letter.revealedAt!).inMicroseconds / 1000.0
        : 0.0;

    _correctCount++;
    _reactionTimesMs.add(reactionMs);
    _letterEvents.add(LetterEvent(
      dx: (letter.position.dx - _chartCenter.dx) / _maxRadius,
      dy: (letter.position.dy - _chartCenter.dy) / _maxRadius,
      ringIndex: letter.ringIndex,
      isHit: true,
    ));

    setState(() {
      letter.isRevealed = false;
    });

    _revealIndex++;
    _revealNextLetter();
  }

  void _recordRingDuration() {
    if (_ringStartedAt != null) {
      final elapsed =
          DateTime.now().difference(_ringStartedAt!).inMilliseconds.toDouble();
      _tiempoPorAnillo.add(elapsed);
    }
  }

  // --- Pausa / reanudar / stop ---

  void _togglePause() {
    if (_isPaused) {
      setState(() => _isPaused = false);
      _revealNextLetter(); // re-mostrar la letra actual
    } else {
      _pauseTest();
    }
  }

  void _pauseTest() {
    _letterTimer?.cancel();
    _letterTimer = null;
    setState(() {
      _isPaused = true;
      // ocultar la letra actual mientras está en pausa
      if (_revealIndex < _revealOrder.length) {
        _allLetters[_revealOrder[_revealIndex]].isRevealed = false;
      }
    });
  }

  void _finishTest({required bool stoppedManually}) {
    if (!mounted) return;
    _cancelAllTimers();
    _recordRingDuration();

    final finishedAt = DateTime.now();
    final totalDurationMs = _firstLetterAt != null
        ? finishedAt.difference(_firstLetterAt!).inMilliseconds
        : 0;

    final result = FieldDetectionResult(
      config: widget.config,
      patientName: widget.patientName,
      completedNaturally: !stoppedManually,
      startedAt: _startedAt,
      finishedAt: finishedAt,
      totalLetrasShown: _totalLetrasShown,
      correctCount: _correctCount,
      missedCount: _missedCount,
      reactionTimesMs: List.unmodifiable(_reactionTimesMs),
      letterEvents: List.unmodifiable(_letterEvents),
      tiempoPorAnillo: List.unmodifiable(_tiempoPorAnillo),
      totalDurationMs: totalDurationMs,
    );

    Navigator.of(context).pushReplacement(
      OptoPageRoute(
        builder: (_) => FieldDetectionResultsScreen(result: result),
      ),
    );
  }

  void _cancelAllTimers() {
    _letterTimer?.cancel();
    _letterTimer = null;
    _preCountdownTimer?.cancel();
    _preCountdownTimer = null;
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final sz = MediaQuery.of(context).size;
    final letterSizePx = sz.shortestSide * (widget.config.tamanoBase / 200);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Scaffold(
        body: Container(
          color: widget.config.fondo.baseColor,
          child: Stack(
            children: [
              // Fijación central
              CenterFixation(
                tipo: widget.config.fijacion,
                fondo: widget.config.fondo,
              ),

              // Letras
              if (_testStarted)
                ..._allLetters.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final letter = entry.value;
                  if (!letter.isRevealed) return const SizedBox.shrink();
                  return Positioned(
                    left: letter.position.dx - letterSizePx / 2,
                    top: letter.position.dy - letterSizePx / 2,
                    child: GestureDetector(
                      onTap: () => _onLetterTapped(idx),
                      child: SizedBox(
                        width: letterSizePx,
                        height: letterSizePx,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            letter.letter,
                            style: TextStyle(
                              color: widget.config.colorLetras.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 100,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),

              // Contador X de N (en lugar de timer global)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    l.fieldDetectionLetterCounter(
                      _revealIndex.clamp(0, _revealOrder.length),
                      _revealOrder.isEmpty
                          ? widget.config.totalLetras
                          : _revealOrder.length,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              // Botones de control
              TestControlButtons(
                isPaused: _isPaused,
                onTogglePause: _togglePause,
                onStop: () => _finishTest(stoppedManually: true),
              ),

              // Pause overlay
              if (_isPaused)
                PauseOverlay(
                  remainingSeconds: 0,
                  elapsedSeconds: 0,
                  stimuliShown: _totalLetrasShown,
                  onResume: _togglePause,
                  onStop: () => _finishTest(stoppedManually: true),
                ),

              // Pre-test countdown
              if (!_testStarted && !_showingInstructions)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.8),
                    child: Center(
                      child: Text(
                        '$_preCountdown',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 120,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

              if (_showingInstructions)
                InstructionOverlay(
                  testTitle: l.configFieldDetectionTitle,
                  instructions: _buildInstructions(l),
                  onCountdownComplete: _handleInstructionsComplete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Notas de verificación antes de pegar:**
- `widget.config.fondo.baseColor`, `widget.config.colorLetras.color`, `widget.config.velocidad.milliseconds` — estos getters existen en `lib/models/test_config.dart`. Confirmar.
- `widget.config.contenido.toString().endsWith('numeros')` — usar la comparación real con `MacContenido.numeros` en lugar de string match. Es decir, sustituir la línea `final chars = widget.config.contenido.toString().endsWith('numeros')` por:
  ```dart
  import '../models/macdonald_config.dart' show MacContenido;
  final chars = widget.config.contenido == MacContenido.numeros
      ? '0123456789'
      : 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  ```
  Y añadir el import correspondiente en la cabecera (`import '../models/macdonald_config.dart' show MacContenido;`).
- `TestControlButtons`, `PauseOverlay`, `InstructionOverlay`, `CenterFixation`, `ImmersiveTestMixin` — todos existen ya y los usa MacDonald.
- `l.instructFixation` — verificar existencia: `grep "instructFixation" lib/l10n/app_es.arb`. Si no existe, sustituir por una de las strings existentes equivalentes que use MacDonald (ver `_buildInstructions` en `macdonald_test.dart`).

- [ ] **Step 2: Verificar análisis estático**

Run: `cmd.exe /c "flutter analyze lib/screens/field_detection_test.dart"`
Expected: errores sólo si `field_detection_results_screen.dart` no existe (se crea en Task 7). Anotar.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/field_detection_test.dart
git commit -m "feat: añadir FieldDetectionTest (test inmersivo, sin tiempo)"
```

---

## Task 7: Pantalla de resultados

**Files:**
- Create: `lib/screens/field_detection_results_screen.dart`

- [ ] **Step 1: Crear la pantalla de resultados**

Create `lib/screens/field_detection_results_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/field_detection_result.dart';
import '../models/saved_result.dart';
import '../services/results_storage.dart';
import '../theme/opto_colors.dart';
import '../theme/opto_spacing.dart';
import '../utils/page_transitions.dart';
import '../widgets/design_system/opto_card.dart';
import '../widgets/design_system/opto_section_header.dart';
import '../widgets/visual_field_heatmap.dart';
import 'field_detection_config_screen.dart';

class FieldDetectionResultsScreen extends StatefulWidget {
  final FieldDetectionResult result;

  const FieldDetectionResultsScreen({super.key, required this.result});

  @override
  State<FieldDetectionResultsScreen> createState() =>
      _FieldDetectionResultsScreenState();
}

class _FieldDetectionResultsScreenState
    extends State<FieldDetectionResultsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l = AppLocalizations.of(context)!;
      final saved = SavedResult.fromFieldDetectionResult(widget.result, l);
      ResultsStorage.save(saved);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final r = widget.result;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(l.fieldDetectionResultsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.replay),
            tooltip: l.repeatTestLabel,
            onPressed: () {
              Navigator.of(context).pushReplacement(
                OptoPageRoute(
                  builder: (_) => const FieldDetectionConfigScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(OptoSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              OptoCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.patientName.isEmpty
                                ? l.unnamedPatient
                                : r.patientName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: OptoSpacing.xs),
                          Text(
                            dateFmt.format(r.startedAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: OptoSpacing.md,
                        vertical: OptoSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: r.completedNaturally
                            ? OptoColors.success.withAlpha(31)
                            : OptoColors.warning.withAlpha(31),
                        borderRadius: BorderRadius.circular(
                          OptoSpacing.radiusChip,
                        ),
                      ),
                      child: Text(
                        r.completedNaturally
                            ? l.statusComplete
                            : l.statusStopped,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: r.completedNaturally
                              ? OptoColors.success
                              : OptoColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: OptoSpacing.md),

              // Stats principales
              Row(
                children: [
                  Expanded(
                    child: _statBox(
                      colorScheme,
                      label: l.statHits,
                      value: '${r.correctCount}',
                    ),
                  ),
                  const SizedBox(width: OptoSpacing.sm),
                  Expanded(
                    child: _statBox(
                      colorScheme,
                      label: l.statMisses,
                      value: '${r.missedCount}',
                    ),
                  ),
                  const SizedBox(width: OptoSpacing.sm),
                  Expanded(
                    child: _statBox(
                      colorScheme,
                      label: l.statAccuracy,
                      value: '${(r.accuracy * 100).toStringAsFixed(0)}%',
                    ),
                  ),
                  const SizedBox(width: OptoSpacing.sm),
                  Expanded(
                    child: _statBox(
                      colorScheme,
                      label: l.statAvgRt,
                      value: r.reactionTimesMs.isEmpty
                          ? '—'
                          : '${r.avgReactionTimeMs.toStringAsFixed(0)} ms',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: OptoSpacing.md),

              // Heatmap
              if (r.letterEvents.isNotEmpty) ...[
                OptoSectionHeader(text: l.heatmapTitle),
                const SizedBox(height: OptoSpacing.sm),
                OptoCard(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: VisualFieldHeatmap(events: r.letterEvents),
                  ),
                ),
                const SizedBox(height: OptoSpacing.md),
              ],

              // Por anillo
              OptoSectionHeader(text: l.fieldDetectionByRing),
              const SizedBox(height: OptoSpacing.sm),
              _ringTable(l, colorScheme, r),
              const SizedBox(height: OptoSpacing.md),

              // Por cuadrante
              OptoSectionHeader(text: l.fieldDetectionByQuadrant),
              const SizedBox(height: OptoSpacing.sm),
              _quadrantTable(l, colorScheme, r),
              const SizedBox(height: OptoSpacing.md),

              // Configuración usada
              OptoSectionHeader(text: l.summarySectionTitle),
              const SizedBox(height: OptoSpacing.sm),
              OptoCard(
                child: Column(
                  children: r.config.localizedSummary(l).entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: OptoSpacing.xs,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              e.key,
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              e.value,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statBox(
    ColorScheme colorScheme, {
    required String label,
    required String value,
  }) {
    return OptoCard(
      padding: const EdgeInsets.symmetric(
        vertical: OptoSpacing.md,
        horizontal: OptoSpacing.sm,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: OptoSpacing.xs),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ringTable(
    AppLocalizations l,
    ColorScheme colorScheme,
    FieldDetectionResult r,
  ) {
    return OptoCard(
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Expanded(flex: 2, child: _th(l.colRing, colorScheme)),
              Expanded(child: _th(l.statHits, colorScheme)),
              Expanded(child: _th(l.statMisses, colorScheme)),
              Expanded(child: _th('%', colorScheme)),
              Expanded(flex: 2, child: _th(l.statAvgRt, colorScheme)),
            ],
          ),
          const Divider(height: 12),
          ...List.generate(r.config.numAnillos, (idx) {
            final hits = r.hitsByRing[idx] ?? 0;
            final misses = r.missesByRing[idx] ?? 0;
            final acc = r.accuracyByRing[idx] ?? 0;
            final rt = r.avgRtByRing[idx] ?? 0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(l.fieldDetectionRing(idx + 1)),
                  ),
                  Expanded(child: Text('$hits')),
                  Expanded(child: Text('$misses')),
                  Expanded(child: Text('${(acc * 100).toStringAsFixed(0)}%')),
                  Expanded(
                    flex: 2,
                    child: Text(rt > 0 ? '${rt.toStringAsFixed(0)} ms' : '—'),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _quadrantTable(
    AppLocalizations l,
    ColorScheme colorScheme,
    FieldDetectionResult r,
  ) {
    String labelFor(FieldQuadrant q) => switch (q) {
          FieldQuadrant.topLeft => l.fieldDetectionQuadrantTL,
          FieldQuadrant.topRight => l.fieldDetectionQuadrantTR,
          FieldQuadrant.bottomLeft => l.fieldDetectionQuadrantBL,
          FieldQuadrant.bottomRight => l.fieldDetectionQuadrantBR,
        };

    return OptoCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(flex: 2, child: _th(l.colQuadrant, colorScheme)),
              Expanded(child: _th(l.statHits, colorScheme)),
              Expanded(child: _th(l.statMisses, colorScheme)),
              Expanded(child: _th('%', colorScheme)),
              Expanded(flex: 2, child: _th(l.statAvgRt, colorScheme)),
            ],
          ),
          const Divider(height: 12),
          ...FieldQuadrant.values.map((q) {
            final hits = r.hitsByQuadrant[q] ?? 0;
            final misses = r.missesByQuadrant[q] ?? 0;
            final acc = r.accuracyByQuadrant[q] ?? 0;
            final rt = r.avgRtByQuadrant[q] ?? 0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text(labelFor(q))),
                  Expanded(child: Text('$hits')),
                  Expanded(child: Text('$misses')),
                  Expanded(child: Text('${(acc * 100).toStringAsFixed(0)}%')),
                  Expanded(
                    flex: 2,
                    child: Text(rt > 0 ? '${rt.toStringAsFixed(0)} ms' : '—'),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _th(String s, ColorScheme cs) => Text(
        s,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: cs.onSurfaceVariant,
        ),
      );
}
```

**Notas de verificación antes de pegar:**
- `l.repeatTestLabel`, `l.unnamedPatient`, `l.statusComplete`, `l.statusStopped`, `l.statHits`, `l.statMisses`, `l.statAccuracy`, `l.statAvgRt`, `l.heatmapTitle`, `l.colRing`, `l.colQuadrant`, `l.summarySectionTitle` — verificar existencia con grep en `lib/l10n/app_es.arb`. Si alguna no existe, copiar el equivalente que usa `macdonald_results_screen.dart` (Read del archivo y mirar qué claves usa).
- `VisualFieldHeatmap` API — verificar la firma real del constructor en `lib/widgets/visual_field_heatmap.dart` y ajustar.
- `OptoSpacing.radiusChip` — verificar.

- [ ] **Step 2: Verificar análisis estático**

Run: `cmd.exe /c "flutter analyze lib/screens/field_detection_results_screen.dart"`
Expected: errores sólo por `SavedResult.fromFieldDetectionResult` que aún no existe (se añade en Task 8). Anotar.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/field_detection_results_screen.dart
git commit -m "feat: añadir FieldDetectionResultsScreen con heatmap y métricas por anillo/cuadrante"
```

---

## Task 8: Persistencia — añadir factory en `SavedResult`

**Files:**
- Modify: `lib/models/saved_result.dart`

- [ ] **Step 1: Añadir import**

Editar `lib/models/saved_result.dart`. Localizar (línea 5):

```dart
import 'macdonald_result.dart';
```

Añadir justo debajo:

```dart
import 'field_detection_result.dart';
```

- [ ] **Step 2: Añadir factory**

Localizar el final de la factory `fromMacDonaldResult` (línea ~126, justo después de la `}` que la cierra y antes de `SavedResult copyWith(...)`).

Insertar:

```dart
  factory SavedResult.fromFieldDetectionResult(
      FieldDetectionResult result, AppLocalizations l) {
    return SavedResult(
      id: '${result.startedAt.millisecondsSinceEpoch}',
      testType: 'field_detection',
      patientName: result.patientName,
      startedAt: result.startedAt,
      finishedAt: result.finishedAt,
      durationActualSeconds: (result.totalDurationMs / 1000).round(),
      completedNaturally: result.completedNaturally,
      totalStimuliShown: result.totalLetrasShown,
      correctTouches: result.correctCount,
      incorrectTouches: 0,
      missedStimuli: result.missedCount,
      accuracy: result.accuracy,
      avgReactionTimeMs:
          result.reactionTimesMs.isNotEmpty ? result.avgReactionTimeMs : null,
      bestReactionTimeMs:
          result.reactionTimesMs.isNotEmpty ? result.bestReactionTimeMs : null,
      worstReactionTimeMs:
          result.reactionTimesMs.isNotEmpty ? result.worstReactionTimeMs : null,
      anillosCompletados: result.config.numAnillos,
      tiempoPorAnillo: result.tiempoPorAnillo.isNotEmpty
          ? List.unmodifiable(result.tiempoPorAnillo)
          : null,
      letterEvents: result.letterEvents.isNotEmpty
          ? List.unmodifiable(result.letterEvents)
          : null,
      configSummary: result.config.localizedSummary(l),
    );
  }
```

- [ ] **Step 3: Verificar análisis estático**

Run: `cmd.exe /c "flutter analyze lib/models/saved_result.dart lib/screens/field_detection_results_screen.dart lib/screens/field_detection_test.dart"`
Expected: `No issues found!` en estos tres archivos.

- [ ] **Step 4: Commit**

```bash
git add lib/models/saved_result.dart
git commit -m "feat: añadir SavedResult.fromFieldDetectionResult factory"
```

---

## Task 9: Dashboard — 4ª card

**Files:**
- Modify: `lib/screens/dashboard_screen.dart`

- [ ] **Step 1: Añadir import**

Editar `lib/screens/dashboard_screen.dart`. Localizar (cerca de línea 14):

```dart
import 'localization_config_screen.dart';
import 'macdonald_config_screen.dart';
```

Añadir entre ellos:

```dart
import 'field_detection_config_screen.dart';
```

- [ ] **Step 2: Subir el contador de ítems animados**

Localizar (línea 35):

```dart
  static const int _totalAnimItems = 9;
```

Cambiar a:

```dart
  static const int _totalAnimItems = 10;
```

- [ ] **Step 3: Añadir caso al switch `_navigateToConfig`**

Localizar (línea ~150):

```dart
  void _navigateToConfig(String testType) {
    Widget screen;
    switch (testType) {
      case 'peripheral':
        screen = const ConfigScreen();
        break;
      case 'localization':
        screen = const LocalizationConfigScreen();
        break;
      case 'macdonald':
        screen = const MacDonaldConfigScreen();
        break;
      default:
        return;
    }
```

Reemplazar por:

```dart
  void _navigateToConfig(String testType) {
    Widget screen;
    switch (testType) {
      case 'peripheral':
        screen = const ConfigScreen();
        break;
      case 'localization':
        screen = const LocalizationConfigScreen();
        break;
      case 'macdonald':
        screen = const MacDonaldConfigScreen();
        break;
      case 'field_detection':
        screen = const FieldDetectionConfigScreen();
        break;
      default:
        return;
    }
```

- [ ] **Step 4: Añadir caso a `_testTypeLabel`**

Localizar (línea ~123):

```dart
  String _testTypeLabel(String testType) {
    switch (testType) {
      case 'peripheral':
        return 'Periférico';
      case 'localization':
        return 'Localización';
      case 'macdonald':
        return 'MacDonald';
      default:
        return testType;
    }
  }
```

Añadir caso:

```dart
      case 'field_detection':
        return 'Detección de campo';
```

- [ ] **Step 5: Añadir caso a `_testTypeColor`**

Localizar (línea ~136):

```dart
  Color _testTypeColor(String testType) {
    switch (testType) {
      case 'peripheral':
        return OptoColors.peripheral;
      case 'localization':
        return OptoColors.localization;
      case 'macdonald':
        return OptoColors.macdonald;
      default:
        return OptoColors.primary;
    }
  }
```

Añadir caso:

```dart
      case 'field_detection':
        return OptoColors.fieldDetection;
```

- [ ] **Step 6: Añadir 4ª card en `_buildLeftColumn`**

Localizar (línea ~322-334) la card de MacDonald:

```dart
          _animatedItem(
            2,
            _buildTestCard(
              icon: Icons.grid_view_rounded,
              color: OptoColors.macdonald,
              name: l.testMacdonaldTitle,
              description: l.testMacdonaldSubtitle,
              onTap: () => _navigateToConfig('macdonald'),
              colorScheme: colorScheme,
            ),
          ),
```

Justo **después** de ese bloque (antes del bloque `if (_lastResult != null) ...`), añadir:

```dart
          const SizedBox(height: OptoSpacing.sm),
          _animatedItem(
            3,
            _buildTestCard(
              icon: Icons.visibility,
              color: OptoColors.fieldDetection,
              name: l.testFieldDetectionTitle,
              description: l.testFieldDetectionSubtitle,
              onTap: () => _navigateToConfig('field_detection'),
              colorScheme: colorScheme,
            ),
          ),
```

- [ ] **Step 7: Renumerar índices subsiguientes**

Tras el bloque insertado, los índices `3, 4, 5, 6` siguientes deben pasar a `4, 5, 6, 7`. Localizar:

- `_animatedItem(3, _buildRepeatCard(...))` → `_animatedItem(4, _buildRepeatCard(...))`
- `_animatedItem(4, _buildQuestionnaireCard(...))` → `_animatedItem(5, _buildQuestionnaireCard(...))`

Y en `_buildRightColumn`:
- `_animatedItem(5, _buildStatsRow(...))` → `_animatedItem(6, _buildStatsRow(...))`
- `_animatedItem(6, _buildActivityCard(...))` → `_animatedItem(7, _buildActivityCard(...))`

- [ ] **Step 8: Repetir el último test — añadir caso para `field_detection`**

`_navigateToConfig` ya soporta el nuevo `'field_detection'` por el switch añadido en Step 3, así que `_buildRepeatCard` funciona automáticamente al pasar `last.testType`.

- [ ] **Step 9: Verificar análisis estático**

Run: `cmd.exe /c "flutter analyze lib/screens/dashboard_screen.dart"`
Expected: `No issues found!`

- [ ] **Step 10: Commit**

```bash
git add lib/screens/dashboard_screen.dart
git commit -m "feat: añadir 4ª card de Detección de Campo al dashboard"
```

---

## Task 10: Historial y exportación

**Files:**
- Modify: `lib/screens/history_screen.dart`
- Modify: `lib/services/export_service.dart`

- [ ] **Step 1: `history_screen.dart` — añadir caso a `_testTypeLabel`**

Localizar (línea ~514):

```dart
  String _testTypeLabel(String type, AppLocalizations l) => switch (type) {
        'peripheral' => l.historyTestPeripheral,
        'localization' => l.historyTestLocalization,
        'macdonald' => l.historyTestMacdonald,
        _ => type,
      };
```

Reemplazar por:

```dart
  String _testTypeLabel(String type, AppLocalizations l) => switch (type) {
        'peripheral' => l.historyTestPeripheral,
        'localization' => l.historyTestLocalization,
        'macdonald' => l.historyTestMacdonald,
        'field_detection' => l.historyTestFieldDetection,
        _ => type,
      };
```

- [ ] **Step 2: `history_screen.dart` — añadir caso a `_testTypeIcon`**

Localizar (línea ~521):

```dart
  IconData _testTypeIcon(String type) => switch (type) {
        'peripheral' => Icons.blur_on,
        'localization' => Icons.touch_app,
        'macdonald' => Icons.grid_on,
        _ => Icons.help_outline,
      };
```

Añadir caso `'field_detection' => Icons.visibility,`.

- [ ] **Step 3: `history_screen.dart` — añadir caso a `_testTypeColor`**

Localizar (línea ~528):

```dart
  Color _testTypeColor(String type) => switch (type) {
        'peripheral' => OptoColors.peripheral,
        'localization' => OptoColors.localization,
        'macdonald' => OptoColors.macdonald,
        _ => OptoColors.primary,
      };
```

Añadir caso `'field_detection' => OptoColors.fieldDetection,`.

- [ ] **Step 4: `history_screen.dart` — añadir chip de filtro**

Localizar (línea ~803-810) el chip de filtro de MacDonald:

```dart
                FilterChip(
                  label: Text(l.historyTestMacdonald),
                  selected: _activeFilter == 'macdonald',
                  onSelected: (_) => setState(() => _activeFilter = 'macdonald'),
                ),
```

Justo después, añadir:

```dart
                const SizedBox(width: OptoSpacing.xs),
                FilterChip(
                  label: Text(l.historyTestFieldDetection),
                  selected: _activeFilter == 'field_detection',
                  onSelected: (_) =>
                      setState(() => _activeFilter = 'field_detection'),
                ),
```

(Si la separación entre chips se hace con otro widget, usar el mismo patrón que ya está en uso entre los demás chips.)

- [ ] **Step 5: `export_service.dart` — añadir caso a `_testTypeLabel`**

Editar `lib/services/export_service.dart`. Localizar (línea ~31):

```dart
  static String _testTypeLabel(String type, AppLocalizations l) => switch (type) {
        'peripheral' => l.historyTestPeripheral,
        'localization' => l.historyTestLocalization,
        'macdonald' => l.historyTestMacdonald,
        _ => type,
      };
```

Añadir caso `'field_detection' => l.historyTestFieldDetection,`.

- [ ] **Step 6: Verificar análisis estático**

Run: `cmd.exe /c "flutter analyze lib/screens/history_screen.dart lib/services/export_service.dart"`
Expected: `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add lib/screens/history_screen.dart lib/services/export_service.dart
git commit -m "feat: integrar Detección de Campo en historial y exportación"
```

---

## Task 11: Eliminar `MacInteraccion.deteccionCampo` del modelo y presets

**Files:**
- Modify: `lib/models/macdonald_config.dart`
- Modify: `lib/models/macdonald_presets.dart`
- Modify: `lib/screens/macdonald_config_screen.dart`
- Modify: `lib/screens/macdonald_results_screen.dart`

- [ ] **Step 1: Eliminar valor del enum**

Editar `lib/models/macdonald_config.dart`. Localizar (línea ~6-11):

```dart
enum MacInteraccion {
  tocarLetras,
  lecturaConTiempo,
  lecturaSecuencial,
  deteccionCampo;
}
```

Reemplazar por:

```dart
enum MacInteraccion {
  tocarLetras,
  lecturaConTiempo,
  lecturaSecuencial;
}
```

- [ ] **Step 2: Eliminar caso de `localizedSummary`**

En el mismo archivo, localizar (línea ~100-105):

```dart
    final interLabel = switch (interaccion) {
      MacInteraccion.tocarLetras => l.macInteractionTouch,
      MacInteraccion.lecturaConTiempo => l.macInteractionTimed,
      MacInteraccion.lecturaSecuencial => l.macInteractionSequential,
      MacInteraccion.deteccionCampo => l.macInteractionFieldDetection,
    };
```

Eliminar la línea de `deteccionCampo`. Resultado:

```dart
    final interLabel = switch (interaccion) {
      MacInteraccion.tocarLetras => l.macInteractionTouch,
      MacInteraccion.lecturaConTiempo => l.macInteractionTimed,
      MacInteraccion.lecturaSecuencial => l.macInteractionSequential,
    };
```

- [ ] **Step 3: Eliminar preset `fieldDetection`**

Editar `lib/models/macdonald_presets.dart`. Localizar (líneas 53-66):

```dart
  static const MacDonaldConfig fieldDetection = MacDonaldConfig(
    interaccion: MacInteraccion.deteccionCampo,
    ...
  );
```

Eliminar todo el bloque (de `static const MacDonaldConfig fieldDetection` hasta su `);` final).

- [ ] **Step 4: Eliminar el `PresetEntry` de `fieldDetection`**

En el mismo archivo, localizar (líneas ~87-92):

```dart
    PresetEntry(
      name: l.macInteractionFieldDetection,
      description: l.presetMacFieldDetectionDesc,
      icon: Icons.visibility,
      config: fieldDetection,
    ),
```

Eliminar esa entrada (incluyendo la coma final). Cuidado de no dejar coma colgando antes de `]`.

- [ ] **Step 5: `macdonald_config_screen.dart` — eliminar caso del switch**

Editar `lib/screens/macdonald_config_screen.dart`. Localizar (línea ~74-80):

```dart
  String _interactionLabel(AppLocalizations l, MacInteraccion mode) =>
      switch (mode) {
        MacInteraccion.tocarLetras => l.macInteractionTouch,
        MacInteraccion.lecturaConTiempo => l.macInteractionTimed,
        MacInteraccion.lecturaSecuencial => l.macInteractionSequential,
        MacInteraccion.deteccionCampo => l.macInteractionFieldDetection,
      };
```

Eliminar la línea de `deteccionCampo`.

- [ ] **Step 6: `macdonald_results_screen.dart` — eliminar referencias**

Editar `lib/screens/macdonald_results_screen.dart`. Localizar (línea ~41-46):

```dart
    final isTouchMode =
        result.config.interaccion == MacInteraccion.tocarLetras ||
        result.config.interaccion == MacInteraccion.deteccionCampo;
    final isFieldDetection =
        result.config.interaccion == MacInteraccion.deteccionCampo;
```

Reemplazar por:

```dart
    final isTouchMode =
        result.config.interaccion == MacInteraccion.tocarLetras;
```

(Eliminamos `isFieldDetection` y la rama de `deteccionCampo`.)

A continuación, localizar cualquier uso de `isFieldDetection` en el archivo (`grep -n "isFieldDetection" lib/screens/macdonald_results_screen.dart`) y eliminar las ramas/condicionales correspondientes. Si la variable se usa para mostrar un bloque distinto (p.ej. heatmap específico), simplificar el `if (isFieldDetection) ... else ...` quedándose con la rama del `else`.

- [ ] **Step 7: Verificar análisis estático**

Run: `cmd.exe /c "flutter analyze lib/models/macdonald_config.dart lib/models/macdonald_presets.dart lib/screens/macdonald_config_screen.dart lib/screens/macdonald_results_screen.dart"`
Expected: `No issues found!`

- [ ] **Step 8: Commit**

```bash
git add lib/models/macdonald_config.dart lib/models/macdonald_presets.dart lib/screens/macdonald_config_screen.dart lib/screens/macdonald_results_screen.dart
git commit -m "refactor: eliminar MacInteraccion.deteccionCampo de MacDonald"
```

---

## Task 12: Eliminar lógica de detección de campo de `macdonald_test.dart`

**Files:**
- Modify: `lib/screens/macdonald_test.dart`

- [ ] **Step 1: Eliminar `_fieldLetterTimer`**

Editar `lib/screens/macdonald_test.dart`. Localizar (línea ~55):

```dart
  Timer? _fieldLetterTimer;
```

Eliminar esa línea.

- [ ] **Step 2: Eliminar branch en `_buildInstructions`**

Localizar (línea ~270 aprox.):

```dart
    final interactionInstruction = switch (c.interaccion) {
      MacInteraccion.tocarLetras => l.instructMacTouch,
      MacInteraccion.lecturaConTiempo => l.instructMacTimed,
      MacInteraccion.lecturaSecuencial => l.instructMacSequential,
      MacInteraccion.deteccionCampo => l.instructMacFieldDetection,
    };
```

Eliminar la línea de `deteccionCampo`.

A continuación, en la misma función, localizar:

```dart
      if (c.interaccion != MacInteraccion.deteccionCampo) ...[
        switch (c.visualizacion) { ... },
      ],
```

Sustituir por (sin el guard):

```dart
      switch (c.visualizacion) {
        MacVisualizacion.completa => l.instructMacVisComplete,
        MacVisualizacion.progresiva => l.instructMacVisProgressive,
        MacVisualizacion.porAnillos => l.instructMacVisByRings,
      },
```

- [ ] **Step 3: Eliminar branch en `_generateChart`**

Localizar (línea ~167-170):

```dart
        final isRevealed =
            widget.config.visualizacion == MacVisualizacion.completa &&
            widget.config.interaccion != MacInteraccion.deteccionCampo;
```

Sustituir por:

```dart
        final isRevealed =
            widget.config.visualizacion == MacVisualizacion.completa;
```

Y a continuación (líneas ~183-187):

```dart
    _totalLetrasShown =
        (widget.config.visualizacion == MacVisualizacion.completa &&
                widget.config.interaccion != MacInteraccion.deteccionCampo)
            ? _allLetters.length
            : 0;
```

Sustituir por:

```dart
    _totalLetrasShown =
        widget.config.visualizacion == MacVisualizacion.completa
            ? _allLetters.length
            : 0;
```

- [ ] **Step 4: Eliminar branch en `_startModeLogic`**

Localizar (línea ~339):

```dart
  void _startModeLogic() {
    final vis = widget.config.visualizacion;
    final inter = widget.config.interaccion;

    if (inter == MacInteraccion.deteccionCampo) {
      _revealOrder.shuffle(_rand);
      _startFieldDetection();
      return;
    }
```

Eliminar todo el `if (inter == MacInteraccion.deteccionCampo) { ... }`.

- [ ] **Step 5: Eliminar métodos `_startFieldDetection` y `_revealNextFieldLetter`**

Localizar (líneas ~362-410): los dos métodos completos. Eliminarlos por completo.

- [ ] **Step 6: Eliminar branch en `_resumeModeLogic`**

Localizar (línea ~728-735):

```dart
    if (inter == MacInteraccion.deteccionCampo) {
      if (_revealIndex < _revealOrder.length) {
        _revealNextFieldLetter();
      }
      return;
    }
```

Eliminar todo el bloque.

- [ ] **Step 7: Eliminar branch en `_onLetterTapped`**

Localizar (línea ~603-633):

```dart
    // Field detection mode: any visible letter can be touched
    if (inter == MacInteraccion.deteccionCampo) {
      ...
      _revealIndex++;
      _revealNextFieldLetter();
      return;
    }
```

Eliminar todo el bloque.

- [ ] **Step 8: Eliminar `_fieldLetterTimer` de `_cancelAllTimers`**

Localizar (línea ~810-817):

```dart
  void _cancelAllTimers() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _revealTimer?.cancel();
    _revealTimer = null;
    _fieldLetterTimer?.cancel();
    _fieldLetterTimer = null;
  }
```

Eliminar las dos líneas de `_fieldLetterTimer`.

- [ ] **Step 9: Eliminar branch del `onTap` de `_ChartLetter` en el build**

Localizar (línea ~858-863):

```dart
                      onTap: (widget.config.interaccion ==
                                  MacInteraccion.tocarLetras ||
                              widget.config.interaccion ==
                                  MacInteraccion.deteccionCampo)
                          ? () => _onLetterTapped(idx)
                          : null,
```

Reemplazar por:

```dart
                      onTap: widget.config.interaccion ==
                              MacInteraccion.tocarLetras
                          ? () => _onLetterTapped(idx)
                          : null,
```

- [ ] **Step 10: Verificar análisis estático**

Run: `cmd.exe /c "flutter analyze lib/screens/macdonald_test.dart"`
Expected: `No issues found!`

- [ ] **Step 11: Verificar análisis global**

Run: `cmd.exe /c "flutter analyze"`
Expected: `No issues found!` en todo el proyecto. Si hay errores residuales (referencias a `instructMacFieldDetection`, etc.), localizarlas y eliminarlas.

- [ ] **Step 12: Commit**

```bash
git add lib/screens/macdonald_test.dart
git commit -m "refactor: eliminar lógica de detección de campo de MacDonaldTest"
```

---

## Task 13: Bump de versión y QA manual

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Bump versión**

Editar `pubspec.yaml`. Localizar:

```yaml
version: 3.2.1+4
```

Cambiar a:

```yaml
version: 3.3.0+5
```

(Minor bump por nueva feature.)

- [ ] **Step 2: Build de prueba**

Run: `cmd.exe /c "flutter analyze"`
Expected: `No issues found!`

Run: `cmd.exe /c "flutter pub get"`
Expected: dependencias resueltas sin errores.

- [ ] **Step 3: QA manual — checklist en el dispositivo objetivo (tablet Android landscape)**

Probar y verificar:

**Smoke / golden path:**
- [ ] Abrir app → dashboard muestra 4 cards (Estim. periférica, Localización, MacDonald, Detección de campo).
- [ ] La 4ª card tiene icono `visibility`, color ámbar/dorado, título "Detección de campo" y subtítulo "Detección de letras periféricas, sin tiempo".
- [ ] Tap → pantalla de configuración informativa con resumen de los 8 parámetros fijos + nombre paciente + botón Empezar.
- [ ] Tap Empezar → instrucciones (si están activadas) → countdown 3-2-1 → primera letra aparece.
- [ ] Tocar la letra antes de que desaparezca → siguiente letra aparece.
- [ ] Continuar hasta completar las 44 letras → llega a pantalla de resultados.
- [ ] Pantalla resultados muestra: nombre paciente, fecha, banner "Completo", 4 stats, heatmap, tabla por anillo (4 filas), tabla por cuadrante (4 filas), resumen de configuración.

**Velocidad rápida del paciente:**
- [ ] Tocar todas las letras correctamente sin perder ninguna → la prueba acaba al completar las 44, **NO** se rebaraja.

**Velocidad nula del paciente:**
- [ ] Dejar pasar todas las letras (no tocar ninguna) → tras ~110 s (44 × 2.5 s), la prueba acaba con `accuracy = 0%`.

**Pausa:**
- [ ] Tocar botón pausa a mitad del test → letra desaparece, overlay de pausa aparece.
- [ ] Reanudar → la letra que estaba en pantalla aparece de nuevo, timer arranca.
- [ ] Comportamiento normal hasta el final.

**Stop manual:**
- [ ] A mitad del test, tap stop → resultados parciales se guardan con `completedNaturally = false` y banner "Detenido".

**Persistencia / historial / exportación:**
- [ ] Resultado aparece en historial con nombre paciente y badge "Detección de campo".
- [ ] Filtro de tipo "Detección de campo" muestra sólo este tipo.
- [ ] Tap en resultado → ver detalle (reusa la vista del historial).
- [ ] Exportar a PDF → archivo válido con título y métricas correctas.
- [ ] Exportar a Excel → archivo válido.
- [ ] Exportar a CSV → archivo válido.

**MacDonald no roto:**
- [ ] Abrir test MacDonald → preset "Detección de campo" YA NO aparece.
- [ ] Los 3 presets restantes (Fácil/Estándar/Avanzado) y los 3 modos restantes (Tocar/Tiempo/Secuencial) funcionan.
- [ ] Test MacDonald completo → resultados correctos.

**Cuestionario FSS:**
- [ ] Abrir cuestionario CVS-Q → llegar a la sección FSS al final.
- [ ] Las anclas de la escala 1-7 muestran "Bastante" (alto) y "Poco o nada" (bajo) en español; "A lot" / "Little or none" en inglés.

**Repetir último test:**
- [ ] Tras hacer un test de detección de campo, en el dashboard aparece la card "Repetir último test" referenciando "Detección de campo".
- [ ] Tap → vuelve a la pantalla de configuración del test de detección de campo.

**Layout:**
- [ ] En la tablet objetivo, los 4 anillos caben sin recortarse en los bordes.
- [ ] Las letras del anillo más externo (14 letras, tamaño 24%) no se solapan con sus vecinas. Si se solapan: anotar y considerar bajar `tamanoBase` antes de cerrar el plan.

- [ ] **Step 4: Commit y tag de versión**

```bash
git add pubspec.yaml
git commit -m "chore: bump version a 3.3.0+5 para Detección de Campo"
```

(Tag opcional según convención del repo.)

---

## Self-Review

Tras escribir este plan, revisión rápida con vista fresca:

### Cobertura del spec

- ✅ "Convertir Detección de Campo en cuarto test independiente" → Tasks 2, 3, 5, 6, 7
- ✅ "Configuración fija estandarizada" → Task 2 (`FieldDetectionConfig.standard`)
- ✅ "Sin tiempo, termina al completar las 44 letras" → Task 6 (`_finishTest` cuando `_revealIndex >= _revealOrder.length`)
- ✅ "Métricas globales, por anillo y por cuadrante" → Tasks 3 y 7
- ✅ "Heatmap" → Task 7 (reusa `VisualFieldHeatmap`)
- ✅ "Persistencia en `SavedResult`" → Task 8
- ✅ "Integración con dashboard" → Task 9
- ✅ "Integración con historial" → Task 10
- ✅ "Integración con export" → Task 10
- ✅ "Color nuevo" → Task 1
- ✅ "i18n" → Task 4
- ✅ "Eliminar `MacInteraccion.deteccionCampo`" → Tasks 11, 12
- ✅ "Fix etiquetas FSS" → Task 4 (Steps 1-2)
- ✅ "Bump de versión" → Task 13
- ✅ "QA manual" → Task 13

### Placeholder scan

Las "Notas de verificación antes de pegar" en Tasks 5, 6, 7 piden al ejecutor que verifique nombres de claves i18n / widgets antes de copiar. Esto es deliberado: claves i18n del proyecto no se inventan; si una falta, hay que reusar la equivalente real. **No son TODOs sin resolver**, son guard-rails para evitar referencias inexistentes.

Task 3 (modelo de resultado) tiene una nota explícita de borrar una variable `times` no usada. El cuerpo correcto está claramente delimitado en el comentario "Implementación correcta".

### Consistencia de tipos

- `FieldDetectionConfig.totalLetras` definido en Task 2, usado en Task 6 (UI) y referenciado por contador en Task 6.
- `FieldDetectionResult` constructor / getters definidos en Task 3, consumidos en Tasks 6, 7, 8.
- `LetterEvent` reutilizado de `macdonald_result.dart` (no duplicado).
- `'field_detection'` como `testType` consistente en Tasks 8, 9, 10.

### Notas finales

Todas las tareas tienen commits frecuentes. Todas las modificaciones de archivos existentes referencian línea aproximada para que el ejecutor encuentre el bloque rápido. La tarea de QA manual al final reemplaza a una suite de tests que el proyecto deliberadamente no mantiene para UI.
