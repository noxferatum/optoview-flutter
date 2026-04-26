# Test de Detección de Campo — Diseño

**Fecha**: 2026-04-27
**Autor**: Rodrigo Melón Gutte
**Estado**: Diseño aprobado, pendiente de plan de implementación

## Contexto

Actualmente "Detección de campo" existe como un modo de interacción (`MacInteraccion.deteccionCampo`) y un preset (`fieldDetection`) dentro del test MacDonald. En el commit `111dd59` se cambió a "se repite hasta que se acabe el tiempo", pero el comportamiento basado en cronómetro no encaja con la naturaleza clínica de la prueba: el examinador quiere una prueba estandarizada que termine cuando se hayan presentado todas las letras, no por agotamiento de tiempo.

## Objetivo

Convertir "Detección de campo" en un cuarto test independiente del dashboard, con configuración fija (estandarizada para comparar pacientes) y sin dependencia de tiempo: la prueba acaba cuando se han mostrado todas las letras de los 4 anillos. Adicionalmente, corregir las etiquetas de anclaje de la escala FSS del cuestionario, que actualmente son "Acuerdo / Desacuerdo" pero los items son cantidades.

## Alcance

### Qué se construye

Un test nuevo, independiente, con:
- Pantalla de configuración informativa (sólo lectura)
- Pantalla de test inmersiva (landscape)
- Pantalla de resultados con métricas por anillo y cuadrante
- Persistencia en `SavedResult` con `testType: 'field_detection'`
- Integración con dashboard, historial y exportación

### Qué se elimina

- `MacInteraccion.deteccionCampo` (modo dentro de MacDonald)
- Preset `fieldDetection` en `macdonald_presets.dart`
- Strings i18n: `macInteractionFieldDetection`, `presetMacFieldDetectionDesc`, `instructMacFieldDetection`
- Lógica de `_revealNextFieldLetter`, `_fieldLetterTimer`, `_startFieldDetection` y branches asociados en `macdonald_test.dart`

### Qué cambia adicionalmente

- Etiquetas de anclaje de la escala FSS del cuestionario:
  - `fssAnchorAgree`: "Acuerdo" → **"Bastante"** (EN: "Agree" → "A lot")
  - `fssAnchorDisagree`: "Desacuerdo" → **"Poco o nada"** (EN: "Disagree" → "Little or none")

## Configuración fija (estandarizada)

| Parámetro | Valor |
|---|---|
| Anillos | 4 |
| Letras por anillo (base) | 8 (8/10/12/14 → 44 letras totales) |
| Tamaño base | 24% |
| Velocidad por letra | Lenta (`Velocidad.lenta` = 2500 ms) |
| Contenido | Letras |
| Fondo | Oscuro |
| Fijación | Punto |
| Color de letras | Blanco |
| Letras aleatorias | Sí |

No hay presets editables: el examinador no puede modificar estos valores. El objetivo es que todos los pacientes hagan exactamente la misma prueba para que los resultados sean comparables.

## Arquitectura

### Modelo nuevo y aislado

Patrón consistente con el resto del proyecto (cada test tiene su propio `*_config.dart`, `*_result.dart`, `*_test.dart`, `*_results_screen.dart`, `*_config_screen.dart`):

#### `lib/models/field_detection_config.dart`

Clase inmutable con los 9 campos fijos. Constante única `FieldDetectionConfig.standard`. Método `localizedSummary(AppLocalizations l)` para mostrar en pantallas y exportes.

```dart
@immutable
class FieldDetectionConfig {
  final int numAnillos;          // 4
  final int letrasPorAnillo;     // 8 (base)
  final double tamanoBase;       // 24
  final Velocidad velocidad;     // Velocidad.lenta
  final MacContenido contenido;  // letras
  final Fondo fondo;             // oscuro
  final Fijacion fijacion;       // punto
  final EstimuloColor colorLetras; // blanco
  final bool letrasAleatorias;   // true

  const FieldDetectionConfig({...});

  static const FieldDetectionConfig standard = FieldDetectionConfig(
    numAnillos: 4,
    letrasPorAnillo: 8,
    tamanoBase: 24,
    velocidad: Velocidad.lenta,
    contenido: MacContenido.letras,
    fondo: Fondo.oscuro,
    fijacion: Fijacion.punto,
    colorLetras: EstimuloColor.blanco,
    letrasAleatorias: true,
  );

  Map<String, String> localizedSummary(AppLocalizations l) {...}
}
```

Reutiliza enums existentes (`Velocidad`, `MacContenido`, `Fondo`, `Fijacion`, `EstimuloColor`) — no se duplican.

#### `lib/models/field_detection_result.dart`

```dart
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

  // Getters calculados
  double get accuracy;
  double get avgReactionTimeMs;
  double get bestReactionTimeMs;
  double get worstReactionTimeMs;
  Map<int, int> get hitsByRing;
  Map<int, int> get missesByRing;
  Map<int, double> get accuracyByRing;
  Map<int, double> get avgRtByRing;
  Map<FieldQuadrant, int> get hitsByQuadrant;
  Map<FieldQuadrant, int> get missesByQuadrant;
  Map<FieldQuadrant, double> get accuracyByQuadrant;
  Map<FieldQuadrant, double> get avgRtByQuadrant;
}
```

`LetterEvent` ya existe (en `macdonald_result.dart`); se importa y reutiliza.

### Pantallas

#### `lib/screens/field_detection_config_screen.dart`

Layout informativo (sólo lectura), patrón `ConfigBottomBar`:
- Header con título y descripción del test
- Tabla resumen con `FieldDetectionConfig.standard.localizedSummary(l)`
- Campo nombre del paciente (opcional, mismo widget que MacDonald)
- Botón "Empezar" en bottom bar → push a `FieldDetectionTest`

#### `lib/screens/field_detection_test.dart`

Inmersiva (landscape forzado vía `ImmersiveTestMixin`).

**Estado:**
```dart
final List<_FieldLetterData> _allLetters = [];
late List<int> _revealOrder; // shuffled
int _revealIndex = 0;
Timer? _letterTimer;
bool _isPaused = false;
bool _testStarted = false;
final List<LetterEvent> _letterEvents = [];
final List<double> _reactionTimesMs = [];
int _correctCount = 0;
int _missedCount = 0;
final List<double> _tiempoPorAnillo = [];
DateTime? _ringStartedAt;
int? _currentRingIndex;
DateTime _startedAt = DateTime.now();
```

**Generación de la carta** (`_generateChart(Size sz)`):
1. Centro de pantalla = origen.
2. Para cada anillo `r` en `[0..3]`:
   - `lettersInRing = 8 + 2*r` (8/10/12/14)
   - `ringRadius = maxRadius * (r+1) / 4`
   - Para cada `i` en `[0..lettersInRing)`: `angle = 2π*i/lettersInRing - π/2`, posición `(centro + ringRadius*cos/sin)`
   - Letra aleatoria del alfabeto A-Z
3. `_revealOrder = List.generate(44, identity).shuffled(_rand)`

**Bucle principal** (`_revealNextLetter()`):
1. Si `_revealIndex >= _revealOrder.length` → `_finishTest(stoppedManually: false)`.
2. `idx = _revealOrder[_revealIndex]`; `letter = _allLetters[idx]`.
3. Si cambia de anillo respecto al anterior → `_recordRingTransition(letter.ringIndex)`.
4. `setState`: `letter.isRevealed = true`; `letter.revealedAt = now`; `_totalLetrasShown++`.
5. `_letterTimer = Timer(velocidad.milliseconds, _onLetterTimeout)`.

**Toque** (`_onLetterTapped(idx)`):
1. Si `idx != _revealOrder[_revealIndex]` o `!letter.isRevealed` → ignorar.
2. Cancela `_letterTimer`.
3. `reactionMs = now - revealedAt`.
4. `_correctCount++`; `_reactionTimesMs.add(reactionMs)`.
5. `_letterEvents.add(LetterEvent(dx, dy, ringIndex, isHit: true))`.
6. `letter.isRevealed = false`; `_revealIndex++`; `_revealNextLetter()`.

**Timeout** (`_onLetterTimeout()`):
1. `_missedCount++`.
2. `_letterEvents.add(LetterEvent(dx, dy, ringIndex, isHit: false))`.
3. `letter.isRevealed = false`; `_revealIndex++`; `_revealNextLetter()`.

**Pausa/reanudar:** mismo patrón que MacDonald (cancela timers, al reanudar reinicia con el índice actual).

**UI:**
- Sin `TestTimerDisplay` (no hay tiempo total). Mostrar contador "X de 44" en su lugar.
- `CenterFixation` con tipo `Fijacion.punto`.
- `TestControlButtons` (pausa, stop).
- `PauseOverlay` con métricas parciales.
- Sin `Next ring button`.
- Sin instrucciones overlay separado: usar `InstructionOverlay` pre-test (mismo patrón).

#### `lib/screens/field_detection_results_screen.dart`

Layout landscape, secciones (top a bottom, en columnas donde aplique):

1. Header: nombre paciente, fecha, "Completo/Detenido", duración total (`totalDurationMs`).
2. Tarjetas stats (fila): Aciertos, Fallos, % aciertos, RT medio.
3. Heatmap del campo visual: reusa `VisualFieldHeatmap` con `letterEvents`.
4. Tabla por anillo: 4 filas, columnas = Aciertos, Fallos, % Aciertos, RT medio (ms).
5. Tabla por cuadrante: 4 filas (TL/TR/BL/BR), mismas columnas.
6. Resumen de configuración: `localizedSummary` en bloque.
7. Botones: Volver, Repetir, Exportar.

### Persistencia

#### `lib/models/saved_result.dart`

Añadir factory:

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
    incorrectTouches: 0, // no hay falsos positivos
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

`SavedResult` no requiere campos nuevos; `stimuliPerMinute` queda `null` por no aplicar.

### Integración con UI existente

#### `lib/screens/dashboard_screen.dart`

- Añadir constante nueva `OptoColors.fieldDetection` (sugerencia: tono ámbar/dorado para distinguirlo de los azulados existentes — valor a fijar en implementación).
- 4ª card en `_buildLeftColumn` (icono `Icons.visibility`, color `OptoColors.fieldDetection`).
- `_navigateToConfig`: añadir caso `'field_detection' → FieldDetectionConfigScreen`.
- `_testTypeLabel`, `_testTypeColor`: añadir caso.
- Ajustar `_totalAnimItems` y reasignar los índices de las animaciones que sigan a la nueva card (la card nueva ocupa el índice 3, desplazando "Repetir último test" al 4 y el cuestionario al 5).

#### `lib/screens/history_screen.dart`

- `_testTypeLabel`: añadir `'field_detection' → l.historyTestFieldDetection`.
- `_testTypeIcon`: `'field_detection' → Icons.visibility`.
- `_testTypeColor`: añadir caso.
- Filtro: añadir chip "Detección de campo" junto a los existentes.

#### `lib/services/export_service.dart`

- `_testTypeLabel` interno: añadir caso `'field_detection' → l.historyTestFieldDetection`.
- El resto del export debería funcionar tal cual: usa `configSummary` (Map<String,String>) para el bloque de configuración, y los campos comunes de `SavedResult`.

## Localización

### Strings nuevas (ES + EN)

| Key | ES | EN |
|---|---|---|
| `testFieldDetectionTitle` | Detección de campo | Field detection |
| `testFieldDetectionSubtitle` | Detección de letras periféricas, sin tiempo | Peripheral letter detection, untimed |
| `historyTestFieldDetection` | Detección de campo | Field detection |
| `configFieldDetectionTitle` | Detección de campo | Field detection |
| `configFieldDetectionDescription` | Test estandarizado: aparecen 44 letras de una en una en 4 anillos. Toca cada letra antes de que desaparezca. | Standardized test: 44 letters appear one at a time across 4 rings. Tap each letter before it disappears. |
| `instructFieldDetection` | Mantén la mirada en el centro y toca cada letra que aparezca lo más rápido posible. | Keep your gaze on the center and tap each letter as it appears as fast as possible. |
| `instructFieldDetectionRings` | Aparecerán 44 letras en total distribuidas en 4 anillos. | 44 letters will appear distributed across 4 rings. |
| `fieldDetectionResultsTitle` | Resultados — Detección de campo | Results — Field detection |
| `fieldDetectionByRing` | Por anillo | By ring |
| `fieldDetectionByQuadrant` | Por cuadrante | By quadrant |
| `fieldDetectionRing` (param `n`) | Anillo {n} | Ring {n} |
| `fieldDetectionQuadrantTL` | Sup-Izq | Top-Left |
| `fieldDetectionQuadrantTR` | Sup-Der | Top-Right |
| `fieldDetectionQuadrantBL` | Inf-Izq | Bottom-Left |
| `fieldDetectionQuadrantBR` | Inf-Der | Bottom-Right |
| `fieldDetectionLetterCounter` (param `i`, `n`) | {i} de {n} | {i} of {n} |

### Strings cambiadas

| Key | ES (antes → después) | EN (antes → después) |
|---|---|---|
| `fssAnchorAgree` | Acuerdo → **Bastante** | Agree → **A lot** |
| `fssAnchorDisagree` | Desacuerdo → **Poco o nada** | Disagree → **Little or none** |

### Strings eliminadas

- `macInteractionFieldDetection`
- `presetMacFieldDetectionDesc`
- `instructMacFieldDetection`

Tras cambios, regenerar con `cmd.exe /c "flutter gen-l10n"`.

## Resumen de archivos

### Nuevos
- `lib/models/field_detection_config.dart`
- `lib/models/field_detection_result.dart`
- `lib/screens/field_detection_config_screen.dart`
- `lib/screens/field_detection_test.dart`
- `lib/screens/field_detection_results_screen.dart`

### Modificados
- `lib/models/saved_result.dart` — añade factory
- `lib/models/macdonald_config.dart` — elimina enum value
- `lib/models/macdonald_presets.dart` — elimina preset
- `lib/screens/macdonald_test.dart` — elimina rama de detección de campo
- `lib/screens/dashboard_screen.dart` — añade 4ª card
- `lib/screens/history_screen.dart` — añade caso `'field_detection'`
- `lib/services/export_service.dart` — añade caso `'field_detection'`
- `lib/theme/opto_colors.dart` — añade `OptoColors.fieldDetection`
- `lib/l10n/app_en.arb` y `lib/l10n/app_es.arb` — strings nuevas, cambiadas y eliminadas (regenera con `flutter gen-l10n`)

### Eliminados
Ninguno.

## Plan de pruebas (informal, manual)

- **Smoke**: lanzar test desde dashboard → ver instrucciones → countdown → primera letra aparece → tocar → siguiente letra → … → al completar 44 letras: pantalla de resultados.
- **Velocidad rápida del paciente**: tocar todas correctamente sin perder ninguna; la prueba acaba cuando se han mostrado 44, **no antes** ni rebarajándose.
- **Velocidad nula del paciente**: dejar pasar todas; al cabo de ~88 s (44 × 2 s), la prueba acaba con `accuracy = 0`.
- **Pausa**: pausar a mitad; reanudar; comportamiento correcto, sin doble timer ni saltos.
- **Stop manual**: detener tras N letras → resultados parciales (`completedNaturally = false`).
- **Persistencia**: completar test → ver en historial con filtro "Detección de campo" → exportar a PDF/Excel/CSV.
- **MacDonald**: verificar que el test MacDonald sigue funcionando con los 3 modos restantes (`tocarLetras`, `lecturaConTiempo`, `lecturaSecuencial`) y los 3 presets (easy/standard/advanced); el preset "Detección de campo" ya no aparece.
- **Cuestionario**: verificar que la sección FSS muestra ahora "Bastante" / "Poco o nada".

## Riesgos y consideraciones

- **Layout en pantallas pequeñas**: 4 anillos con 14 letras en el más externo + tamaño 24% puede saturar tablets pequeñas. Validar visualmente en el dispositivo objetivo (Android landscape). Si se solapan, ajustar `tamanoBase` antes de cerrar implementación.
- **Anillo más externo recortado**: el cálculo `maxRadius = min(width, height) * 0.42` (heredado de MacDonald) deja margen para evitar recorte por bordes. Validar también.
- **Reaction time muy bajo**: si el paciente toca por adelantado (anticipa), el RT puede ser <100ms. No es problema funcional, pero conviene reflejarlo en la métrica (no filtrar; el clínico interpreta).
- **i18n strings eliminados**: hay que asegurarse de que ningún sitio fuera de los listados aún usa `macInteractionFieldDetection` u otros eliminados, antes de borrarlos. Buscar con grep antes del cambio.

## Fuera de alcance

- Cambiar la estructura del CVS-Q (mantiene 3 niveles de frecuencia y 2 de intensidad).
- Modificar el comportamiento de los otros 3 tests existentes.
- Añadir presets editables al test de detección de campo (es deliberadamente fijo).
- Añadir métricas adicionales más allá de las definidas (accuracy/RT global, por anillo, por cuadrante, heatmap).
