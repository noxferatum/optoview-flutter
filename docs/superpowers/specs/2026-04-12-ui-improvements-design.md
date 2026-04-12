# OptoView UI Improvements — Design Spec

**Fecha:** 2026-04-12
**Rama:** `feature/ui-improvements`
**Enfoque:** Sistema de diseño + reconstrucción sistemática (clínico-profesional)

---

## 1. OptoView Design System

### 1.1 Paleta de colores

**Dark mode (por defecto):**

| Token | Uso | Valor |
|-------|-----|-------|
| `primary` | Acciones principales, acentos | `#3F6FB2` (OptoView Blue) |
| `surface` | Fondo de cards/paneles | `#1A1E24` |
| `background` | Fondo de pantalla | `#0F1216` |
| `surfaceVariant` | Secciones secundarias, bordes | `#242930` |
| `onSurface` | Texto principal | `#E8ECF0` |
| `onSurfaceVariant` | Texto secundario, labels | `#8A94A0` |
| `success` | Completado, aciertos | `#4CAF7D` |
| `warning` | Alertas, detenido temprano | `#E5A84B` |
| `error` | Errores, fallos | `#D4544E` |

Light mode: variantes claras invertidas equivalentes, generadas con `ColorScheme.fromSeed()`.

### 1.2 Tipografía

| Nivel | Uso | Tamaño | Weight |
|-------|-----|--------|--------|
| Display | Splash, branding | 32px | 300 (light) |
| Headline | Títulos de pantalla | 22px | 600 |
| Title | Títulos de sección/card | 16px | 600 |
| Body | Contenido | 14px | 400 |
| Label | Etiquetas, valores, tags | 12px | 500, letter-spacing 0.5 |

### 1.3 Espaciado (sistema de 4px)

| Token | Valor | Uso |
|-------|-------|-----|
| `xs` | 4px | Separación mínima intra-componente |
| `sm` | 8px | Entre elementos relacionados |
| `md` | 16px | Padding de cards, gap entre secciones |
| `lg` | 24px | Entre grupos de secciones |
| `xl` | 32px | Márgenes de pantalla |

### 1.4 Elevación y bordes

- Cards: elevation 0, borde 1px `surfaceVariant`. Sin sombras.
- Border radius: 12px para cards, 8px para chips/botones, 10px para pills.
- Divisores: 1px `surfaceVariant` con 0.5 opacidad.

### 1.5 Scrollbars (accent glow)

- Ancho: 3px
- Color: `primary` al 50% opacidad (`rgba(63,111,178,0.5)`)
- Glow: `box-shadow: 0 0 6px rgba(63,111,178,0.3)`
- Sin track visible (solo thumb)
- Aparecen solo al interactuar, desaparecen tras 1.5s de inactividad (fade 300ms)
- Border radius: 2px
- Implementación: `ScrollbarThemeData` global en el tema

### 1.6 Animaciones

| Tipo | Curva | Duración |
|------|-------|----------|
| Transiciones entre pantallas | `SharedAxisTransition` (eje X) | 300ms |
| Entrada de elementos | Staggered fade+slide desde abajo | 200ms + 50ms delay entre elementos |
| Micro-interacciones (press) | Scale 0.97 | 150ms |
| Fade in/out | `Curves.easeOutCubic` | 200ms |
| Overlays (appear/dismiss) | `Curves.easeOutCubic` | 300ms |

### 1.7 Componentes base reutilizables

Crear en `lib/widgets/design_system/`:

| Componente | Descripción |
|------------|-------------|
| `OptoCard` | Card con borde sutil 1px, border-radius 12px, padding `md` |
| `OptoSectionHeader` | Icono + título (label uppercase, letter-spacing) + descripción opcional |
| `OptoChipGroup` | Selector de chips con animación de selección, single o multi-select |
| `OptoSegmentedControl` | Segmented button con estilo propio (fondo `surfaceVariant`, seleccionado `primary`) |
| `OptoSliderField` | Slider con label, valor actual, y unidad |
| `OptoToggleField` | Switch con título y subtítulo |
| `OptoActionButton` | Botón primario/secundario con estado de press animado (scale 0.97) |
| `OptoGlassPanel` | Panel translúcido con blur para overlays del test |

---

## 2. Splash Screen

### Comportamiento
- Duración: 1.5-2 segundos
- Transición al dashboard: fade cruzado (400ms)

### Layout
- Pantalla completa con gradiente sutil (0F1216 → 162033 → 0F1216, 160deg)
- Centrado vertical: logo → nombre → tagline → loader

### Elementos
1. **Logo**: Icono de la app (80px), border-radius 20px, glow sutil (`box-shadow: 0 0 40px primary@0.3`)
2. **Nombre**: "OPTOVIEW", 28px weight 300, letter-spacing 3px
3. **Tagline**: "Neuro-Optometric Testing", 12px, `onSurfaceVariant`, letter-spacing 1px
4. **Loader**: Barra de 120px × 2px, animación de progreso indeterminado

### Animación de entrada
1. Logo: scale 0.8→1.0 + fade (300ms, easeOutCubic)
2. Nombre: fade + slide up 12px (200ms, 200ms delay)
3. Tagline: fade + slide up 8px (200ms, 350ms delay)
4. Loader: fade (200ms, 500ms delay)

---

## 3. Dashboard

### Layout
- Header: logo pequeño (32px) + "OptoView" + botones derecha (idioma, tema, info)
- Body en 2 columnas (landscape):
  - **Izquierda (flex 1.2)**: Tests disponibles + acción rápida
  - **Derecha (flex 1)**: Estadísticas + actividad reciente

### Columna izquierda — Tests

3 cards de test, cada una con:
- Icono de color en cuadrado redondeado (40px, color del test al 15% opacidad)
- Nombre del test (13px, weight 600)
- Descripción breve (11px, `onSurfaceVariant`)
- Flecha derecha
- Hover/press: borde cambia a `primary`

Colores por test:
- Periférica: `#5B8FD2` (azul)
- Localización: `#9B7BFF` (morado)
- MacDonald: `#4CAF7D` (verde)

**Acción rápida "Repetir último test":**
- Card con borde y fondo sutil de `primary` (gradiente al 12%→5%)
- Icono de replay + nombre del test + paciente + tiempo relativo
- Solo aparece si hay al menos un test previo

### Columna derecha — Stats + Actividad

**Fila de estadísticas** (3 boxes):
- Tests hoy, Pacientes, Total tests
- Valor grande (20px, weight 600) + label pequeño (10px uppercase)
- Datos calculados en tiempo real desde `ResultsStorage`

**Card de actividad reciente:**
- Header: "Actividad reciente" + link "Ver historial >"
- Lista de últimos 4 resultados:
  - Punto de color del tipo de test
  - Nombre del paciente (12px, weight 500)
  - Tipo + tiempo relativo (10px)
  - Badge de estado (Completo verde / Detenido amarillo)
- "Ver historial" navega al HistoryScreen

### Estado vacío (primer uso)
Si no hay historial, la columna derecha muestra un mensaje de bienvenida con instrucciones para empezar, en lugar de stats vacías.

### Animación de entrada
Cards aparecen staggered desde abajo (fade + slide 16px, 50ms delay entre cada una).

---

## 4. Pantallas de Configuración

### Estructura: Tabs + Wizard

**Barra superior:**
- Botón back + título del test + preset pills (Fácil / Estándar / Avanzado)
- Seleccionar un preset rellena todos los tabs
- Modificar cualquier valor deselecciona el preset (pasa a "Personalizado")

**Tab bar (4 tabs):**

| Tab | Icono | Contenido |
|-----|-------|-----------|
| General | Engranaje | Paciente, lado, instrucciones, velocidad, movimiento, distancia |
| Estímulo | Estrella | **Wizard**: Categoría → Color → Tamaño (con preview en vivo) |
| Visual | Círculo | Fondo, punto de fijación, distractores, animación de fondo |
| Tiempo | Reloj | Duración (slider 10-300s), tamaño del estímulo (slider + aleatorio) |

**Tabs General, Visual, Tiempo — Layout normal:**
- 2 columnas en landscape
- Cada sección dentro de un `OptoCard` con `OptoSectionHeader`
- Widgets específicos: `OptoChipGroup`, `OptoSegmentedControl`, `OptoSliderField`, `OptoToggleField`

**Tab Estímulo — Wizard (3 pasos):**

| Paso | Contenido |
|------|-----------|
| 1. Categoría | Letras / Números / Formas → si Formas: selector de forma específica |
| 2. Color | 8 chips de color con preview de punto |
| 3. Tamaño | Slider 5-35% + toggle aleatorio |

- Indicador de pasos arriba: círculos numerados + líneas de conexión (done = verde, active = azul, pending = gris)
- Navegación: botones "Anterior" / "Siguiente" abajo
- Click en cualquier círculo del indicador para saltar
- **Preview en vivo** a la derecha: mini campo visual (16:10) que muestra el estímulo con la configuración actual (categoría + color + tamaño). Se actualiza en tiempo real

**Barra inferior fija:**
- Resumen compacto de la configuración actual (texto de una línea)
- Botón "Iniciar test" (primario, siempre visible)
- El resumen se actualiza en tiempo real al cambiar cualquier opción

### Adaptación por test
Las 3 pantallas de config (Periférica, Localización, MacDonald) usan la misma estructura de tabs. Las tabs y su contenido varían según las opciones disponibles para cada test. El wizard de "Estímulo" aplica a Periférica y Localización; MacDonald tiene su propia configuración de contenido (letras vs números, `MacContenido`).

---

## 5. Test Execution — Overlays Rediseñados

### 5.1 Timer + Controles (estado normal)

**Timer pill (arriba izquierda):**
- `OptoGlassPanel`: fondo `rgba(15,18,22,0.7)` + `BackdropFilter.blur(8)`
- Borde: 1px `rgba(255,255,255,0.06)`
- Border-radius: 10px
- Contenido: icono reloj + tiempo restante (16px, weight 600, tabular-nums) + divisor vertical + conteo de estímulos (11px)

**Control pills (arriba derecha):**
- 2 pills separadas con el mismo estilo glass
- Pausa: icono + texto en `warning` (#E5A84B)
- Detener: icono + texto en `error` (#D4544E)
- Press: scale 0.97 (150ms)

### 5.2 Overlay de Instrucciones (pre-test)

- Fondo: `rgba(15,18,22,0.9)` + blur 12px
- Card centrada (max-width 480px):
  - Header: icono info en cuadrado azul + nombre del test + "Instrucciones para el paciente"
  - Pasos numerados (1, 2, 3): círculo azul + texto con negritas en conceptos clave
  - Countdown: anillo de progreso circular (72px) con número grande (40px, weight 300, primary)
  - Label: "El test comenzará automáticamente"
- El anillo se completa en 3 segundos y el test arranca automáticamente
- Las instrucciones varían por tipo de test

### 5.3 Overlay de Pausa

- Fondo: `rgba(15,18,22,0.85)` + blur 12px (el test se ve difuminado)
- Card centrada:
  - Icono de pausa en círculo amarillo (56px)
  - "Test en pausa" (18px, weight 600)
  - "El test se reanudará exactamente donde lo dejaste" (13px, secondary)
  - Stats del progreso: tiempo restante, tiempo transcurrido, estímulos mostrados
  - Botones: "Terminar" (secundario, rojo) + "Reanudar" (primario, azul)

---

## 6. Pantalla de Resultados

### Layout (2 columnas, landscape)

**Columna izquierda:**

1. **Status banner**: Icono + texto de estado en card coloreada
   - Completado: fondo verde al 8%, borde verde al 20%, icono check verde
   - Detenido: fondo amarillo al 8%, borde amarillo al 20%, icono stop amarillo

2. **Info del paciente**: Avatar con iniciales (28px) + nombre + fecha/hora

3. **Grid de estadísticas** (2×2):
   - Duración real: valor grande + unidad + barra de progreso verde
   - Estímulos mostrados: valor + barra de progreso azul
   - Frecuencia: valor + "est/min"
   - Precisión: indicador circular (ring al 82%) + fracción "28 de 34"

4. **Configuración usada**: Tags compactos en fila (wrap) — "Estándar", "Derecho", "Letras", "Azul", etc.

**Columna derecha:**

5. **Heatmap del campo visual** (ocupa toda la columna):
   - Header: "Mapa del campo visual" + leyenda (acierto verde / fallo rojo)
   - Área de visualización: fondo `background`, rejilla sutil, etiquetas de zona (Sup/Inf/Izq/Der), cruz de fijación central
   - Puntos de acierto: círculos verdes (borde `success`, fondo `success@0.6`)
   - Puntos de fallo: círculos rojos (borde `error`, fondo `error@0.4`)
   - Stats debajo: Aciertos (verde) | Fallos (rojo) | Precisión (azul)

**Barra superior**: Botón back + "Resultados del test" + Exportar / Compartir / Repetir (primario)

### Adaptación por test
- **Localización**: Añade "Tiempo medio de reacción" y "Precisión táctil" a los stats
- **MacDonald**: Reemplaza heatmap por tabla de aciertos por anillo/nivel

---

## 7. Historial — Master-Detail

### Layout

**Barra de filtros:**
- Búsqueda por nombre de paciente (input con icono)
- Chips de filtro por tipo de test (coloreados: azul periférica, morado localización, verde MacDonald)
- Toggle vista: por fecha / por paciente
- Botones: Exportar (primario) / Borrar (danger)

**Panel izquierdo — Lista (380px fijo):**
- Scroll independiente con scrollbar accent glow
- Agrupada por fechas con headers sticky ("Hoy", "Ayer", fecha)
- Cada item:
  - Checkbox (para selección múltiple)
  - Punto de color del tipo de test
  - Nombre del paciente (13px, weight 500, ellipsis)
  - Tipo de test + hora (11px)
  - Badge de estado (Completo verde / Detenido amarillo)
- Item seleccionado: borde izquierdo 3px `primary`, fondo sutil

**Panel derecho — Detalle:**
- Header: tipo de test (label uppercase coloreado) + nombre del paciente (18px) + fecha
- Acciones: PDF / Excel / Repetir (primario)
- Mini stats (4 boxes en fila): duración, estímulos, precisión, aciertos
- Mini heatmap del campo visual
- Tags de configuración

**Vista por paciente:**
Headers de grupo con nombre del paciente + número de tests. Items dentro del grupo muestran el tipo de test y fecha.

**Selección múltiple:**
Al activar checkboxes, aparece barra superior con "N seleccionados" + Exportar masivo + Borrar.

**Animación:**
El panel derecho hace fade al cambiar de item seleccionado (200ms).

---

## 8. Pantalla de Créditos

### Layout split (2 paneles)

**Izquierda — Branding:**
- Mismo estilo que el splash: gradiente sutil de fondo
- Logo (72px) con glow
- "OPTOVIEW" (24px, weight 300, letter-spacing 3px)
- "Neuro-Optometric Testing" (12px)
- Badge de versión ("v2.2.0+5")

**Derecha — Información:**
- Sección "Equipo": card con filas para cada persona (icono coloreado + nombre + rol)
- Sección "Tecnología": tags con punto de color (Flutter 3.8, Dart, Material 3, Android)
- Sección "Legal": disclaimer en texto pequeño
- Link "Volver al inicio" abajo

**Animación:**
Izquierda fade-in primero, luego cards de la derecha staggered desde la derecha.

---

## 9. Bug Fix: Timer de los Tests

### Problema
Los 3 tests tienen una condición de carrera entre dos timers paralelos:
- `_countdownTimer` (Timer.periodic, 1s): decrementa `_remaining` para la UI
- `_endTimer` (Timer one-shot): termina el test tras `Duration(seconds: _remaining)`

El `_endTimer` se ejecuta antes de que el countdown visual llegue a 0, terminando el test prematuramente. El drift del Timer.periodic acumula ~5-10ms por tick.

### Archivos afectados
- `lib/screens/dynamic_periphery_test.dart`
- `lib/screens/localization_test.dart`
- `lib/screens/macdonald_test.dart`

### Solución
Eliminar `_endTimer` en los 3 tests. El countdown timer se encarga de terminar el test:

```dart
_countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
  if (!mounted) return;
  setState(() {
    _remaining = max(0, _remaining - 1);
    if (_remaining <= 0) {
      t.cancel();
      _finishTest(stoppedManually: false);
    }
  });
});
```

Eliminar toda referencia a `_endTimer` (declaración, asignación, cancel en `_cancelAllTimers()`).

---

## 10. Dependencias Nuevas

| Paquete | Uso |
|---------|-----|
| `animations` (Flutter official) | `SharedAxisTransition` para transiciones entre pantallas |

No se añaden paquetes de charting. El heatmap se implementa con `CustomPainter` (ya existe la base en `hit_map_renderer.dart`). Los indicadores circulares y barras de progreso se implementan con widgets de Flutter nativos (`CircularProgressIndicator`, `LinearProgressIndicator` o `CustomPainter`).

---

## 11. Pantallas que NO Cambian

- **Test execution** (campo visual durante el test): Los 3 tests mantienen su lógica actual. Solo cambian los overlays (timer, controles, pausa, instrucciones) y se corrige el bug del timer.
- **BackgroundPattern / CenterFixation / PeripheralStimulus**: Sin cambios funcionales. Estos widgets ya están bien implementados.

---

## 12. Resumen de Pantallas

| Pantalla | Acción |
|----------|--------|
| MenuScreen | **Eliminar** — reemplazado por Dashboard |
| TestMenuScreen | **Eliminar** — integrado en Dashboard |
| Dashboard (nuevo) | **Crear** — splash + panel informativo |
| ConfigScreen | **Reconstruir** — tabs + wizard |
| LocalizationConfigScreen | **Reconstruir** — mismo patrón |
| MacDonaldConfigScreen | **Reconstruir** — mismo patrón |
| TestResultsScreen | **Reconstruir** — stats visuales + heatmap |
| LocalizationResultsScreen | **Reconstruir** — mismo patrón |
| MacDonaldResultsScreen | **Reconstruir** — mismo patrón |
| HistoryScreen | **Reconstruir** — master-detail |
| CreditsScreen | **Reconstruir** — layout split |
| Test overlays (4 widgets) | **Reconstruir** — glass panels |
| Widgets de config (12+) | **Reconstruir** — usando design system |
| Design system (nuevo) | **Crear** — componentes base en `lib/widgets/design_system/` |
| SplashScreen (nuevo) | **Crear** |

---

## Mockups de Referencia

Los mockups HTML interactivos están en `.superpowers/brainstorm/` para referencia visual durante la implementación:
- `splash-and-dashboard.html` — Splash + Dashboard
- `config-screens.html` — Configuración con tabs y wizard
- `results-screen.html` — Resultados con heatmap
- `history-screen.html` — Historial master-detail
- `scrollbar-comparison.html` — Comparativa de scrollbars (elegida: accent glow)
- `credits-and-overlays.html` — Créditos + overlays del test
