# Settings Screen Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Settings screen with three preferences — theme, font size, and interface language — accessible from a gear icon in the dashboard header, with font scaling applied globally to the clinician UI but neutralized inside the three immersive clinical tests to preserve calibrated stimulus sizes.

**Architecture:** Three global `ValueNotifier`s in `main.dart` (theme — already exists; font scale and locale — new), persisted in `SharedPreferences`. `OptoViewApp` listens to all three and applies `textScaler` via a `MediaQuery` wrapper around the `home` widget, and sets `MaterialApp.locale`. Immersive test screens wrap their `build` root with `MediaQuery(textScaler: TextScaler.noScaling, ...)` to neutralize scaling inside the tests.

**Tech Stack:** Flutter (Dart), Material 3, `shared_preferences`, auto-generated `flutter_localizations` from `.arb` files.

**Environment note (user preferences):** This repo is on WSL2. All `flutter` and `dart` commands MUST be invoked via `cmd.exe /c "flutter ..."` (or `dart ...`). Git push (not needed for this plan) would similarly use `cmd.exe /c "git push ..."`.

**Testing strategy:** This project does not maintain a widget/unit test suite for UI (the one stale widget_test was removed in commit `d267b5c`). The plan therefore relies on `flutter analyze` for static verification plus a manual QA checklist (Task 9). Do **not** add widget tests for the settings screen — it would fight the existing project style.

---

## File Structure

**Create:**
- `lib/models/font_scale.dart` — enum `FontScale` with scale factor per value.
- `lib/screens/settings_screen.dart` — the new Settings screen.

**Modify:**
- `lib/main.dart` — add font scale and locale notifiers + loaders + savers; apply them in `OptoViewApp.build`.
- `lib/l10n/app_es.arb` — add 11 new strings (Spanish).
- `lib/l10n/app_en.arb` — add 11 new strings (English).
- `lib/screens/dashboard_screen.dart` — replace theme toggle icon with settings gear; remove theme import.
- `lib/screens/dynamic_periphery_test.dart` — wrap `build` with `MediaQuery(textScaler: TextScaler.noScaling)`.
- `lib/screens/localization_test.dart` — same.
- `lib/screens/macdonald_test.dart` — same.
- `pubspec.yaml` — bump version to `3.2.0+1`.

---

## Task 1: Add `FontScale` enum

**Files:**
- Create: `lib/models/font_scale.dart`

- [ ] **Step 1: Create the `FontScale` model file**

Create `lib/models/font_scale.dart`:

```dart
/// Discrete font scale factors applied to the clinician UI via
/// `MediaQuery.textScaler`. Scaling is intentionally coarse (3 steps)
/// and never applied inside the immersive clinical tests.
enum FontScale {
  normal(1.0, 'normal'),
  grande(1.15, 'grande'),
  muyGrande(1.30, 'muyGrande');

  const FontScale(this.scale, this.storageKey);

  final double scale;
  final String storageKey;

  static FontScale fromStorageKey(String? key) {
    for (final v in FontScale.values) {
      if (v.storageKey == key) return v;
    }
    return FontScale.normal;
  }
}
```

- [ ] **Step 2: Verify the file parses**

Run: `cmd.exe /c "flutter analyze lib/models/font_scale.dart"`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/models/font_scale.dart
git commit -m "feat(settings): add FontScale enum with storage keys"
```

---

## Task 2: Add font scale and locale notifiers in `main.dart`

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Replace `main.dart` contents**

Full new content of `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'models/font_scale.dart';
import 'screens/dashboard_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/opto_theme.dart';

/// Global theme notifier. Accessible from any screen.
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

/// Global font scale notifier for the clinician UI.
/// Neutralized inside immersive clinical tests.
final ValueNotifier<FontScale> fontScaleNotifier =
    ValueNotifier(FontScale.normal);

/// Global locale override. `null` means follow the system locale.
final ValueNotifier<Locale?> localeNotifier = ValueNotifier<Locale?>(null);

const _themeKey = 'app_theme_mode';
const _fontScaleKey = 'app_font_scale';
const _localeKey = 'app_locale';

Future<void> _loadPreferences() async {
  try {
    final prefs = await SharedPreferences.getInstance();

    final themeName = prefs.getString(_themeKey);
    if (themeName == 'light') themeNotifier.value = ThemeMode.light;

    fontScaleNotifier.value =
        FontScale.fromStorageKey(prefs.getString(_fontScaleKey));

    final localeCode = prefs.getString(_localeKey);
    if (localeCode == 'es') {
      localeNotifier.value = const Locale('es');
    } else if (localeCode == 'en') {
      localeNotifier.value = const Locale('en');
    } else {
      localeNotifier.value = null;
    }
  } catch (_) {}
}

Future<void> saveThemePreference(ThemeMode mode) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode == ThemeMode.light ? 'light' : 'dark');
  } catch (_) {}
}

Future<void> saveFontScalePreference(FontScale scale) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontScaleKey, scale.storageKey);
  } catch (_) {}
}

Future<void> saveLocalePreference(Locale? locale) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.setString(_localeKey, 'auto');
    } else {
      await prefs.setString(_localeKey, locale.languageCode);
    }
  } catch (_) {}
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _loadPreferences();
  runApp(const OptoViewApp());
}

class OptoViewApp extends StatefulWidget {
  const OptoViewApp({super.key});

  @override
  State<OptoViewApp> createState() => _OptoViewAppState();
}

class _OptoViewAppState extends State<OptoViewApp> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [themeNotifier, fontScaleNotifier, localeNotifier]),
      builder: (context, _) {
        final mode = themeNotifier.value;
        final scale = fontScaleNotifier.value.scale;
        final locale = localeNotifier.value;

        return MaterialApp(
          title: 'OptoView',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          darkTheme: OptoTheme.dark(),
          theme: OptoTheme.light(),
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('es'),
          ],
          builder: (context, child) {
            final mq = MediaQuery.of(context);
            return MediaQuery(
              data: mq.copyWith(textScaler: TextScaler.linear(scale)),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _showSplash
                ? SplashScreen(
                    key: const ValueKey('splash'),
                    onComplete: () => setState(() => _showSplash = false),
                  )
                : const DashboardScreen(key: ValueKey('dashboard')),
          ),
        );
      },
    );
  }
}
```

Key changes vs. the current `main.dart`:
- New `FontScale` import.
- New `fontScaleNotifier` and `localeNotifier`.
- `_loadThemePreference` renamed/extended to `_loadPreferences` (loads all three).
- New `saveFontScalePreference` and `saveLocalePreference`.
- `OptoViewApp.build` swaps the single `ValueListenableBuilder<ThemeMode>` for an `AnimatedBuilder` listening to all three notifiers; wraps the app with `MediaQuery(textScaler: ...)` via `MaterialApp.builder`; passes `locale` to `MaterialApp`.

Rationale for using `MaterialApp.builder` (not wrapping `home` directly): the `MediaQuery` must sit above everything, including dialogs and routes pushed from anywhere in the app. `MaterialApp.builder` injects exactly there.

- [ ] **Step 2: Verify compilation**

Run: `cmd.exe /c "flutter analyze lib/main.dart"`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/main.dart
git commit -m "feat(settings): add font scale + locale notifiers and apply globally"
```

---

## Task 3: Add new i18n strings (Spanish)

**Files:**
- Modify: `lib/l10n/app_es.arb`

- [ ] **Step 1: Append new keys to `app_es.arb` before the closing `}`**

Open `lib/l10n/app_es.arb` and locate the last existing key. Add a comma after it, then insert the following block immediately before the closing `}`:

```json
  "settingsTitle": "Ajustes",
  "settingsAppearance": "Apariencia",
  "settingsFontSize": "Tamaño de texto de la interfaz",
  "settingsFontSizeNormal": "Normal",
  "settingsFontSizeLarge": "Grande",
  "settingsFontSizeExtraLarge": "Muy grande",
  "settingsFontSizeHint": "No afecta al tamaño de las letras dentro de las pruebas clínicas.",
  "settingsFontSizePreview": "Aa",
  "settingsLanguage": "Idioma de la interfaz",
  "settingsLanguageAuto": "Automático",
  "settingsLanguageSpanish": "Español",
  "settingsLanguageEnglish": "Inglés"
```

Note: `themeLight` ("Modo día") and `themeDark` ("Modo noche") already exist and will be reused as the segmented-control labels for the theme selector — do NOT add new theme keys.

- [ ] **Step 2: Verify the file is valid JSON**

Run: `cmd.exe /c "dart --version"` (just confirms dart is reachable from WSL), then:
Run: `python3 -c "import json; json.load(open('lib/l10n/app_es.arb'))"`
Expected: no output (valid JSON). If it errors, the comma placement is wrong.

- [ ] **Step 3: Commit**

```bash
git add lib/l10n/app_es.arb
git commit -m "i18n(es): add settings screen strings"
```

---

## Task 4: Add new i18n strings (English)

**Files:**
- Modify: `lib/l10n/app_en.arb`

- [ ] **Step 1: Append new keys to `app_en.arb` before the closing `}`**

Same procedure as Task 3. Insert before the closing `}`:

```json
  "settingsTitle": "Settings",
  "settingsAppearance": "Appearance",
  "settingsFontSize": "Interface text size",
  "settingsFontSizeNormal": "Normal",
  "settingsFontSizeLarge": "Large",
  "settingsFontSizeExtraLarge": "Extra large",
  "settingsFontSizeHint": "Does not affect text size within clinical tests.",
  "settingsFontSizePreview": "Aa",
  "settingsLanguage": "Interface language",
  "settingsLanguageAuto": "Automatic",
  "settingsLanguageSpanish": "Spanish",
  "settingsLanguageEnglish": "English"
```

- [ ] **Step 2: Verify the file is valid JSON**

Run: `python3 -c "import json; json.load(open('lib/l10n/app_en.arb'))"`
Expected: no output (valid JSON).

- [ ] **Step 3: Regenerate localization Dart files**

Run: `cmd.exe /c "flutter gen-l10n"`
Expected: regenerates `lib/l10n/app_localizations.dart`, `app_localizations_es.dart`, `app_localizations_en.dart` with the new getters.

If `flutter gen-l10n` complains it can't find the config, alternatively run: `cmd.exe /c "flutter pub get"` — with `generate: true` in pubspec.yaml, it triggers generation.

- [ ] **Step 4: Verify new getters exist**

Run: `grep -n "settingsTitle\b" lib/l10n/app_localizations.dart`
Expected: a line showing `String get settingsTitle;` (the abstract declaration).

- [ ] **Step 5: Commit**

```bash
git add lib/l10n/
git commit -m "i18n(en): add settings screen strings and regenerate"
```

---

## Task 5: Create `SettingsScreen`

**Files:**
- Create: `lib/screens/settings_screen.dart`

- [ ] **Step 1: Create the file**

Create `lib/screens/settings_screen.dart`:

```dart
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../main.dart'
    show
        themeNotifier,
        saveThemePreference,
        fontScaleNotifier,
        saveFontScalePreference,
        localeNotifier,
        saveLocalePreference;
import '../models/font_scale.dart';
import '../theme/opto_spacing.dart';
import '../widgets/design_system/opto_card.dart';
import '../widgets/design_system/opto_section_header.dart';
import '../widgets/design_system/opto_segmented_control.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, l, colorScheme),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: OptoSpacing.md,
                  vertical: OptoSpacing.sm,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildAppearanceCard(l),
                        const SizedBox(height: OptoSpacing.md),
                        _buildFontSizeCard(l, colorScheme),
                        const SizedBox(height: OptoSpacing.md),
                        _buildLanguageCard(l),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: OptoSpacing.sm,
        vertical: OptoSpacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: OptoSpacing.xs),
          Text(
            l.settingsTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceCard(AppLocalizations l) {
    return OptoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OptoSectionHeader(title: l.settingsAppearance),
          const SizedBox(height: OptoSpacing.sm),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, _) {
              return OptoSegmentedControl<ThemeMode>(
                selected: mode == ThemeMode.light
                    ? ThemeMode.light
                    : ThemeMode.dark,
                items: [
                  OptoSegmentItem(
                    value: ThemeMode.light,
                    label: l.themeLight,
                    icon: Icons.light_mode,
                  ),
                  OptoSegmentItem(
                    value: ThemeMode.dark,
                    label: l.themeDark,
                    icon: Icons.dark_mode,
                  ),
                ],
                onSelected: (newMode) {
                  themeNotifier.value = newMode;
                  saveThemePreference(newMode);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFontSizeCard(AppLocalizations l, ColorScheme colorScheme) {
    return OptoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OptoSectionHeader(title: l.settingsFontSize),
          const SizedBox(height: OptoSpacing.sm),
          ValueListenableBuilder<FontScale>(
            valueListenable: fontScaleNotifier,
            builder: (context, scale, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OptoSegmentedControl<FontScale>(
                    selected: scale,
                    items: [
                      OptoSegmentItem(
                        value: FontScale.normal,
                        label: l.settingsFontSizeNormal,
                      ),
                      OptoSegmentItem(
                        value: FontScale.grande,
                        label: l.settingsFontSizeLarge,
                      ),
                      OptoSegmentItem(
                        value: FontScale.muyGrande,
                        label: l.settingsFontSizeExtraLarge,
                      ),
                    ],
                    onSelected: (newScale) {
                      fontScaleNotifier.value = newScale;
                      saveFontScalePreference(newScale);
                    },
                  ),
                  const SizedBox(height: OptoSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l.settingsFontSizeHint,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: OptoSpacing.md),
                      Text(
                        l.settingsFontSizePreview,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(AppLocalizations l) {
    return OptoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OptoSectionHeader(title: l.settingsLanguage),
          const SizedBox(height: OptoSpacing.sm),
          ValueListenableBuilder<Locale?>(
            valueListenable: localeNotifier,
            builder: (context, locale, _) {
              return OptoSegmentedControl<String>(
                selected: locale?.languageCode ?? 'auto',
                items: [
                  OptoSegmentItem(
                    value: 'auto',
                    label: l.settingsLanguageAuto,
                  ),
                  OptoSegmentItem(
                    value: 'es',
                    label: l.settingsLanguageSpanish,
                  ),
                  OptoSegmentItem(
                    value: 'en',
                    label: l.settingsLanguageEnglish,
                  ),
                ],
                onSelected: (code) {
                  final newLocale = code == 'auto' ? null : Locale(code);
                  localeNotifier.value = newLocale;
                  saveLocalePreference(newLocale);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
```

Notes:
- The language selector uses `String` as the generic type for `OptoSegmentedControl` because `Locale?` cannot be a valid segmented value (null comparison is awkward). The `'auto'` sentinel maps to `null` on the way into the notifier.
- The font-size preview "Aa" text is deliberately a plain `Text` widget so it inherits the live `textScaler` from the surrounding `MediaQuery` and previews the effect immediately.
- Header style mirrors `CreditsScreen`'s minimal pattern (no AppBar).

- [ ] **Step 2: Verify compilation**

Run: `cmd.exe /c "flutter analyze lib/screens/settings_screen.dart"`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/screens/settings_screen.dart
git commit -m "feat(settings): add SettingsScreen with theme, font size, and language"
```

---

## Task 6: Replace theme toggle with settings gear in dashboard

**Files:**
- Modify: `lib/screens/dashboard_screen.dart`

- [ ] **Step 1: Remove the theme import at the top**

In `lib/screens/dashboard_screen.dart` line 3, change:

```dart
import '../main.dart' show themeNotifier, saveThemePreference;
```

to (delete the whole line):

```dart
```

The import is no longer needed in this file.

- [ ] **Step 2: Add the settings import**

Insert after the other `screens/` imports (around line 17, right before the class `DashboardScreen`):

```dart
import 'settings_screen.dart';
```

- [ ] **Step 3: Replace the theme toggle `IconButton` with a settings gear**

In `_buildHeader`, locate this block (currently at lines 264-272):

```dart
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDark ? l.themeLight : l.themeDark,
            onPressed: () {
              final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
              themeNotifier.value = newMode;
              saveThemePreference(newMode);
            },
          ),
```

Replace with:

```dart
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l.settingsTitle,
            onPressed: () {
              Navigator.push(
                context,
                OptoPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
```

The info/credits `IconButton` immediately below stays unchanged.

- [ ] **Step 4: Remove the `isDark` local variable if it becomes unused**

In `_buildHeader`'s signature it receives `bool isDark`. After this change, verify whether `isDark` is still used elsewhere in the function body (e.g., for header background). If `flutter analyze` reports it unused, drop the parameter from both the signature and the caller on line ~187. If still used (e.g., conditional styling of the logo background), leave it.

Run: `cmd.exe /c "flutter analyze lib/screens/dashboard_screen.dart"`
Expected: either `No issues found!` or an `unused_element`/`unused_local_variable` on `isDark` — in that case remove it and re-run.

- [ ] **Step 5: Commit**

```bash
git add lib/screens/dashboard_screen.dart
git commit -m "feat(dashboard): replace theme toggle with settings gear in header"
```

---

## Task 7: Neutralize text scaling inside the three immersive tests

**Files:**
- Modify: `lib/screens/dynamic_periphery_test.dart`
- Modify: `lib/screens/localization_test.dart`
- Modify: `lib/screens/macdonald_test.dart`

**Rationale:** the three screens share `ImmersiveTestMixin`, but that mixin only controls system chrome (orientation + immersive UI). To neutralize `textScaler` we need to wrap each `build` return. Doing it at the top of each `build` is explicit and discoverable.

- [ ] **Step 1: Wrap `dynamic_periphery_test.dart` build**

Locate the `build` method starting at line 401. Current shape:

```dart
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final mediaSize = MediaQuery.of(context).size;
    final sizePx = _layoutSizePx(mediaSize);

    return Scaffold(
      body: BackgroundPattern(
        ...
      ),
    );
  }
```

Change the return to wrap the `Scaffold` in a `MediaQuery`:

```dart
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final mediaSize = MediaQuery.of(context).size;
    final sizePx = _layoutSizePx(mediaSize);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Scaffold(
        body: BackgroundPattern(
          ...
        ),
      ),
    );
  }
```

Leave everything inside `Scaffold` unchanged. Add the appropriate closing `)` for the new `MediaQuery` at the end.

- [ ] **Step 2: Wrap `localization_test.dart` build (line 597)**

Current shape:

```dart
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final sz = MediaQuery.of(context).size;
    final centerSizePx = _positioning.resolveStimulusSize(
            sz, widget.config.tamanoPorc) *
        1.3;

    return Scaffold(
      body: BackgroundPattern(
        ...
      ),
    );
  }
```

Change the return to:

```dart
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Scaffold(
        body: BackgroundPattern(
          ...
        ),
      ),
    );
```

Indent everything inside `Scaffold` one level deeper and add the matching closing `)` for the new `MediaQuery`.

- [ ] **Step 3: Wrap `macdonald_test.dart` build (line 821, inside `_MacDonaldTestState`)**

The file has two `build` methods:
- Line 821 inside `_MacDonaldTestState` (which mixes in `ImmersiveTestMixin`) → **this is the one to wrap**.
- Line ~958 inside an internal ring-item widget → leave alone; it's a child of the main test tree and will inherit the neutralized scaler automatically.

Current shape of the line-821 build:

```dart
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final sz = MediaQuery.of(context).size;
    final letterSizePx = sz.shortestSide * (widget.config.tamanoBase / 200);

    return Scaffold(
      body: Container(
        color: widget.config.fondo.baseColor,
        child: Stack(
          ...
        ),
      ),
    );
  }
```

Change the return to:

```dart
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Scaffold(
        body: Container(
          color: widget.config.fondo.baseColor,
          child: Stack(
            ...
          ),
        ),
      ),
    );
```

- [ ] **Step 4: Verify all three files compile**

Run: `cmd.exe /c "flutter analyze lib/screens/dynamic_periphery_test.dart lib/screens/localization_test.dart lib/screens/macdonald_test.dart"`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/screens/dynamic_periphery_test.dart lib/screens/localization_test.dart lib/screens/macdonald_test.dart
git commit -m "feat(tests): neutralize text scaling inside immersive clinical tests

Font scale from Settings must not affect the MacDonald chart letters or
any calibrated stimulus. Wraps each test screen's build with
MediaQuery(textScaler: noScaling) so the clinician's UI scaling is
ignored once inside a running test."
```

---

## Task 8: Bump version

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Bump version from `3.1.0+2` to `3.2.0+1`**

Open `pubspec.yaml` line 7:

Change:
```yaml
version: 3.1.0+2
```

To:
```yaml
version: 3.2.0+1
```

Rationale: new user-facing feature (settings screen) → minor bump.

- [ ] **Step 2: Commit**

```bash
git add pubspec.yaml
git commit -m "chore: bump version to 3.2.0+1 for settings screen"
```

---

## Task 9: Manual QA + final verification

- [ ] **Step 1: Full static analysis**

Run: `cmd.exe /c "flutter analyze"`
Expected: `No issues found!` across the whole project.

- [ ] **Step 2: Build & launch on device/emulator**

Run: `cmd.exe /c "flutter run -d <device-id>"` (landscape-capable Android tablet or emulator).

- [ ] **Step 3: QA scenario — scaling applies to clinician UI**

Procedure:
1. Dashboard → gear icon → Settings opens.
2. Font size → tap "Muy grande" (1.30×). "Aa" preview grows immediately.
3. Back to dashboard. Verify title, test cards, stat cards, activity list all scale up.
4. Open the Peripheral Config screen → titles, labels, and body scale.
5. Open CVS-Q questionnaire → all 16 question rows + labels scale.
6. Open History → list items scale.

Expected: all UI text scaled ~30% larger than "Normal".

- [ ] **Step 4: QA scenario — scaling NOT applied inside tests**

With "Muy grande" still active:
1. Start Peripheral Stimulation test. Any text stimulus is at its calibrated size (compare visually against same test at "Normal" scale).
2. Start Localization test — numbers/letters are calibrated size.
3. Start MacDonald chart — ring letters are calibrated (this is the critical clinical scenario).

Expected: inside all three tests, text matches the 1.0× size exactly.

- [ ] **Step 5: QA scenario — language switching**

1. Settings → Language → English. Back out. Dashboard strings are in English. Enter any screen and confirm translations.
2. Settings → Language → Automático. App reverts to system locale (Spanish on a Spanish-configured tablet).

- [ ] **Step 6: QA scenario — theme switching**

1. Settings → Appearance → Claro. Theme flips to light mode everywhere.
2. Settings → Appearance → Oscuro. Back to dark.

- [ ] **Step 7: QA scenario — persistence**

1. Set font to "Grande", language to English, theme to light.
2. Close the app fully (swipe out of recents).
3. Relaunch. All three preferences restored.

- [ ] **Step 8: QA scenario — first-run defaults**

1. Uninstall the app (clears SharedPreferences).
2. Reinstall & launch.

Expected: dark mode, Normal font size, Automático language.

- [ ] **Step 9: QA scenario — navigation from dashboard**

1. Dashboard header shows logo + "OptoView" title + gear icon + info icon. No theme toggle icon.
2. Tap gear → Settings opens with shared-axis transition.
3. Tap back arrow in Settings header → dashboard restored, preferences visible were retained.

- [ ] **Step 10: Final commit (if any QA fixes were made)**

If any QA issues surfaced, commit fixes with descriptive messages. Otherwise nothing more to commit.

---

## Completion criteria

- [ ] `cmd.exe /c "flutter analyze"` passes with no issues.
- [ ] All 10 QA scenarios in Task 9 pass.
- [ ] Git log shows logical, incremental commits matching the task list.
- [ ] `pubspec.yaml` on `3.2.0+1`.
- [ ] No regressions in existing flows (tests still work, cuestionarios still save, history still loads).
