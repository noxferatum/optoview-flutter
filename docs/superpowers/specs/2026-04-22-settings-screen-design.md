# Settings Screen — Design Spec

**Fecha:** 2026-04-22
**Autor:** Brainstorming con Claude
**Estado:** Aprobado por el usuario — listo para plan de implementación

## Objetivo

Añadir al proyecto una pantalla de **Ajustes** con tres preferencias globales:

1. **Tema** (claro / oscuro) — ya existe como toggle en el header; se mueve dentro de Ajustes.
2. **Tamaño de letra de la interfaz** (Normal / Grande / Muy grande) — nuevo.
3. **Idioma de la interfaz** (Automático / Español / English) — nuevo.

El acceso a la pantalla será un nuevo icono de engranaje en el header del dashboard que sustituye al icono actual de toggle de tema. El icono de info/créditos se mantiene.

## Motivación

- Un clínico puede necesitar texto más grande según sus condiciones visuales o la distancia de trabajo con la tablet. Actualmente los tamaños son fijos (`lib/theme/opto_theme.dart`).
- El idioma se detecta automáticamente del sistema. En tablets compartidas entre clínicas o cuando el sistema está en un idioma distinto al deseado, debe poderse forzar ES o EN manualmente.
- Reorganizar las preferencias en una única pantalla deja sitio para futuras opciones sin saturar el header del dashboard.

## Alcance

### Dentro
- Nueva pantalla `lib/screens/settings_screen.dart`.
- Tres notifiers globales en `main.dart`, persistidos en `SharedPreferences`.
- Aplicación del escalado de texto a toda la interfaz del clínico (dashboard, config screens, results, historial, cuestionarios, Ajustes, créditos).
- Neutralización explícita del escalado dentro de las tres pantallas de test inmersivo.
- Cambio de icono en el header del dashboard.
- Nuevas cadenas en los ficheros ARB (`lib/l10n/app_es.arb` y `lib/l10n/app_en.arb`); los ficheros `app_localizations*.dart` se regeneran automáticamente.

### Fuera
- Cualquier otra opción de configuración (p. ej. densidad, exportar/importar datos, backup). Si aparece más tarde se añade como nueva sección en la misma pantalla.
- Cambio del criterio de escala por pantalla (todo el escalado es global).
- Escalado dentro de los tests (se neutraliza con `TextScaler.noScaling` para preservar la validez clínica).

## Decisiones clave

| Pregunta | Decisión | Razón |
|---|---|---|
| ¿Cuántos tamaños de letra? | 3 discretos: Normal / Grande / Muy grande (1.0× / 1.15× / 1.30×) | Contexto clínico, legibilidad es prioridad; sin "pequeño" |
| ¿Cómo se elige el tamaño? | `OptoSegmentedControl` con 3 opciones | Consistente con el resto de selectores de la app |
| ¿Opciones de idioma? | Automático / Español / English | `Automático` sigue el locale del sistema; útil para tablets compartidas |
| ¿Acceso a Ajustes? | Icono de engranaje que sustituye al toggle de tema en el header | Header más limpio; tema se mueve dentro de Ajustes |
| ¿Escalado dentro de tests? | **Neutralizado** (`TextScaler.noScaling`) | Preservar validez clínica (carta MacDonald, estímulos) |
| ¿Mecanismo de escalado? | `MediaQuery(textScaler: TextScaler.linear(k))` envolviendo el `home` del `MaterialApp` | API oficial de Flutter; escala todo el `TextTheme` sin tocar cada `Text()` |
| ¿Guardado? | Inmediato al cambiar selección; sin botón "Guardar" | Mismo patrón que el toggle de tema actual |

## Arquitectura

### Estado global (`main.dart`)

Tres `ValueNotifier` globales en `main.dart`:

```dart
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark); // ya existe
final ValueNotifier<FontScale> fontScaleNotifier = ValueNotifier(FontScale.normal); // nuevo
final ValueNotifier<Locale?> localeNotifier = ValueNotifier<Locale?>(null); // nuevo; null = seguir sistema
```

Un nuevo modelo enum:

```dart
enum FontScale {
  normal(1.0),
  grande(1.15),
  muyGrande(1.30);

  const FontScale(this.scale);
  final double scale;
}
```

Tres funciones de guardado asíncronas (`saveThemePreference`, `saveFontScalePreference`, `saveLocalePreference`). Una función de carga única (`_loadPreferences`) que lee las tres claves antes de `runApp`.

Claves en `SharedPreferences`:
- `app_theme_mode` → `"light"` | `"dark"`
- `app_font_scale` → `"normal"` | `"grande"` | `"muyGrande"`
- `app_locale` → `"auto"` | `"es"` | `"en"`

### `OptoViewApp` — aplicar los tres notifiers

`OptoViewApp` escucha los tres notifiers mediante `Listenable.merge([...])` envuelto en un `AnimatedBuilder` (o alternativamente anidando `ValueListenableBuilder`s). El `MaterialApp` recibe:

- `themeMode: themeNotifier.value`
- `locale: localeNotifier.value` (`null` → Flutter aplica el del sistema automáticamente)

El árbol bajo `home` se envuelve con:

```dart
MediaQuery(
  data: MediaQuery.of(context).copyWith(
    textScaler: TextScaler.linear(fontScaleNotifier.value.scale),
  ),
  child: ...,
)
```

Esto aplica el escalado a toda la app por defecto.

### Neutralización del escalado en los tests

Las tres pantallas `dynamic_periphery_test.dart`, `localization_test.dart`, `macdonald_test.dart` comparten el `ImmersiveTestMixin`. Se añade al mixin (o al `build` de esas pantallas) un wrapper:

```dart
MediaQuery(
  data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
  child: ...,
)
```

Esto garantiza que:
- La carta MacDonald mantenga los tamaños calibrados clínicamente.
- Los números/letras del test de localización mantengan su tamaño.
- Cualquier estímulo textual futuro quede automáticamente protegido.

**Contrapartida asumida:** los controles de UI dentro del test (botón de pausa/stop, timer overlay) no escalan. Se considera aceptable porque son predominantemente iconos y el clínico opera de cerca.

## Componentes

### `SettingsScreen` (`lib/screens/settings_screen.dart`)

Nueva pantalla. Estructura:

- Header con flecha de retroceso + título localizado ("Ajustes" / "Settings").
- Contenido en una única columna centrada, ancho máximo ~720 px (patrón de `config_screen.dart`).
- Tres `OptoCard` apilados verticalmente con `OptoSectionHeader` cada uno:

  **Tarjeta 1 — Apariencia**
  - `OptoSegmentedControl` con dos opciones: `Claro` / `Oscuro`.
  - Escucha `themeNotifier`; al cambiar, actualiza el notifier y llama a `saveThemePreference`.

  **Tarjeta 2 — Tamaño de texto de la interfaz**
  - `OptoSegmentedControl` con tres opciones: `Normal` / `Grande` / `Muy grande`.
  - Texto de ayuda pequeño debajo: "No afecta al tamaño de las letras dentro de las pruebas clínicas."
  - Bloque de vista previa "Aa" que usa `MediaQuery.textScalerOf(context)` para mostrar el efecto inmediato.
  - Escucha `fontScaleNotifier`; al cambiar, actualiza el notifier y llama a `saveFontScalePreference`.

  **Tarjeta 3 — Idioma de la interfaz**
  - `OptoSegmentedControl` con tres opciones: `Automático` / `Español` / `English`.
  - Escucha `localeNotifier`; al cambiar, actualiza el notifier y llama a `saveLocalePreference`.

**Navegación:** se abre desde el dashboard con `Navigator.push` y `OptoPageRoute`, mismo patrón que `CreditsScreen`.

### Cambios en `dashboard_screen.dart`

En `_buildHeader` (actualmente en `dashboard_screen.dart:228-286`):

- **Eliminar** el `IconButton` del toggle de tema (líneas 264-272).
- **Añadir** un `IconButton` con `Icons.settings` y tooltip localizado (`l.settingsTitle`), que haga `Navigator.push` a `SettingsScreen`.
- **Mantener** el `IconButton` de info/créditos.
- **Eliminar** el import `import '../main.dart' show themeNotifier, saveThemePreference;` (ya no se usa en este fichero).

## i18n — nuevas cadenas

Añadir a los ficheros ARB (`lib/l10n/app_es.arb` y `lib/l10n/app_en.arb`); los ficheros `app_localizations.dart`, `app_localizations_es.dart` y `app_localizations_en.dart` se regeneran automáticamente al compilar.

| Clave | ES | EN |
|---|---|---|
| `settingsTitle` | Ajustes | Settings |
| `settingsAppearance` | Apariencia | Appearance |
| `settingsThemeLabel` | Tema | Theme |
| `settingsThemeLight` | Claro | Light |
| `settingsThemeDark` | Oscuro | Dark |
| `settingsFontSize` | Tamaño de texto de la interfaz | Interface text size |
| `settingsFontSizeNormal` | Normal | Normal |
| `settingsFontSizeLarge` | Grande | Large |
| `settingsFontSizeExtraLarge` | Muy grande | Extra large |
| `settingsFontSizeHint` | No afecta al tamaño de las letras dentro de las pruebas clínicas. | Does not affect text size within clinical tests. |
| `settingsLanguage` | Idioma de la interfaz | Interface language |
| `settingsLanguageAuto` | Automático | Automatic |
| `settingsLanguageSpanish` | Español | Spanish |
| `settingsLanguageEnglish` | Inglés | English |

## QA manual

Tras implementar, recorrer:

1. **Escalado aplicado a la UI del clínico:** cambiar a "Muy grande" y verificar que escalan el título del dashboard, las tarjetas de tests, el texto de los cuestionarios (CVS-Q, FSS), las pantallas de configuración (peripheric, localization, macdonald), la pantalla de historial y la pantalla de resultados.
2. **Escalado NO aplicado a los tests:** con "Muy grande" activo, entrar en las tres pruebas inmersivas y confirmar que letras MacDonald y números/letras de localización mantienen su tamaño calibrado (comparar visualmente contra 1.0×).
3. **Cambio de idioma:** cambiar a English → todas las cadenas cambian. Cambiar a Automático → vuelve al idioma del sistema.
4. **Cambio de tema:** toggle claro/oscuro desde Ajustes → cambio inmediato en todas las pantallas abiertas.
5. **Persistencia:** cerrar y reabrir la app → las tres preferencias se restauran.
6. **Navegación:** desde dashboard abrir Ajustes, modificar preferencias, volver atrás. Verificar que los cambios se reflejan inmediatamente en el dashboard.
7. **Primer arranque:** borrar datos de la app, arrancar → usa valores por defecto (oscuro, normal, automático).

## Fuera del alcance / futuras mejoras

- Reiniciar la app si cambiar de idioma en caliente provoca algún glitch (hasta ahora Flutter lo soporta bien con rebuild de `MaterialApp`).
- Export/import de preferencias junto con los datos clínicos.
- Escalas adicionales (pequeño, enorme).
- Fuentes con mayor soporte de accesibilidad (dislexia-friendly, etc.).
