# OptoView UI Improvements — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign OptoView's entire UI with a custom design system, new splash/dashboard, tabbed config with wizard, integrated heatmaps in results, master-detail history, and fix the timer race condition bug.

**Architecture:** Build a design system foundation (theme, spacing, components) first, then rebuild every screen on top of it. Screens are replaced one at a time, keeping the app functional at every commit. Navigation is rewired after the dashboard replaces the old menu.

**Tech Stack:** Flutter 3.8+, Material 3, `animations` package (SharedAxisTransition), `CustomPainter` (heatmaps), SharedPreferences (unchanged persistence layer).

**Environment:** WSL2 — use `cmd.exe /c "flutter ..."` for all Flutter/Dart commands. Git push via `cmd.exe /c "git push origin feature/ui-improvements"`.

**Spec:** `docs/superpowers/specs/2026-04-12-ui-improvements-design.md`
**Mockups:** `.superpowers/brainstorm/1427-1776003224/content/` (HTML files)

**Note on existing types:** The codebase already defines all enums (`Lado`, `SimboloCategoria`, `Forma`, `Velocidad`, `Movimiento`, `DistanciaModo`, `Fijacion`, `Fondo`, `EstimuloColor`) in `lib/models/test_config.dart`, presets in `lib/models/test_presets.dart`, color utilities in `lib/utils/stimulus_color_utils.dart`, and localization keys in `lib/l10n/app_en.arb`. The plan references these — it does not redefine them.

---

## Task 1: Fix Timer Race Condition in All Three Tests

**Files:**
- Modify: `lib/screens/dynamic_periphery_test.dart`
- Modify: `lib/screens/localization_test.dart`
- Modify: `lib/screens/macdonald_test.dart`

**Problem:** Each test creates both a `Timer.periodic` (1s countdown for UI) and a `Timer` one-shot (`_endTimer`) to end the test. The one-shot fires before the countdown reaches 0, ending the test prematurely.

**Fix:** Remove `_endTimer` entirely. The countdown timer terminates the test when `_remaining` reaches 0.

- [ ] **Step 1: Fix dynamic_periphery_test.dart**

In `_startTest()`, replace the countdown timer and remove the end timer. Find the section that creates `_countdownTimer` and `_endTimer` (around line 166-173) and replace with:

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

Remove the `_endTimer = Timer(Duration(seconds: _remaining), ...)` block entirely.

In `_cancelAllTimers()`, remove `_endTimer?.cancel();` and `_endTimer = null;`.

Remove the `Timer? _endTimer;` field declaration.

- [ ] **Step 2: Fix localization_test.dart**

Same fix in `_startTest()` (around line 270-277). Replace countdown timer with the version that checks `_remaining <= 0`. Remove `_endTimer` declaration, assignment, and cancel.

- [ ] **Step 3: Fix macdonald_test.dart**

Same fix in `_startTest()` (around line 318-326). Replace countdown timer, remove `_endTimer` everywhere.

- [ ] **Step 4: Verify the fix compiles**

```bash
cmd.exe /c "flutter analyze"
```

Expected: No errors related to `_endTimer`.

- [ ] **Step 5: Commit**

```bash
git add lib/screens/dynamic_periphery_test.dart lib/screens/localization_test.dart lib/screens/macdonald_test.dart
git commit -m "fix: remove timer race condition causing tests to end early

Removed _endTimer (one-shot) from all 3 tests. The countdown
Timer.periodic now terminates the test when _remaining reaches 0,
eliminating the race between the two timers."
```

---

## Task 2: Add `animations` Package and Create Design System Theme

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/theme/opto_theme.dart`
- Create: `lib/theme/opto_colors.dart`
- Create: `lib/theme/opto_spacing.dart`
- Modify: `lib/constants/app_constants.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1: Add animations dependency**

In `pubspec.yaml`, add under `dependencies:`:

```yaml
  animations: ^2.0.11
```

Run:
```bash
cmd.exe /c "flutter pub get"
```

- [ ] **Step 2: Create `lib/theme/opto_colors.dart`**

```dart
import 'package:flutter/material.dart';

abstract final class OptoColors {
  // Brand
  static const Color primary = Color(0xFF3F6FB2);
  static const Color primaryPattern = Color(0xFF8ABFF5);

  // Dark mode surfaces
  static const Color backgroundDark = Color(0xFF0F1216);
  static const Color surfaceDark = Color(0xFF1A1E24);
  static const Color surfaceVariantDark = Color(0xFF242930);

  // Dark mode text
  static const Color onSurfaceDark = Color(0xFFE8ECF0);
  static const Color onSurfaceVariantDark = Color(0xFF8A94A0);
  static const Color subtleDark = Color(0xFF5A6270);

  // Semantic
  static const Color success = Color(0xFF4CAF7D);
  static const Color warning = Color(0xFFE5A84B);
  static const Color error = Color(0xFFD4544E);

  // Test type accents
  static const Color peripheral = Color(0xFF5B8FD2);
  static const Color localization = Color(0xFF9B7BFF);
  static const Color macdonald = Color(0xFF4CAF7D);

  // Scrollbar
  static const Color scrollThumb = Color(0x803F6FB2); // primary @ 50%
}
```

- [ ] **Step 3: Create `lib/theme/opto_spacing.dart`**

```dart
abstract final class OptoSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;

  // Border radius
  static const double radiusCard = 12.0;
  static const double radiusChip = 8.0;
  static const double radiusPill = 10.0;
  static const double radiusLogo = 20.0;
}
```

- [ ] **Step 4: Create `lib/theme/opto_theme.dart`**

```dart
import 'package:flutter/material.dart';
import 'opto_colors.dart';
import 'opto_spacing.dart';

abstract final class OptoTheme {
  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: OptoColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      surface: OptoColors.surfaceDark,
      surfaceContainerHighest: OptoColors.surfaceVariantDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: OptoColors.backgroundDark,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OptoSpacing.radiusCard),
          side: BorderSide(color: OptoColors.surfaceVariantDark),
        ),
        color: OptoColors.surfaceDark,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: WidgetStatePropertyAll(3),
        radius: const Radius.circular(2),
        thumbColor: WidgetStatePropertyAll(OptoColors.scrollThumb),
        trackColor: WidgetStatePropertyAll(Colors.transparent),
        thumbVisibility: WidgetStatePropertyAll(false),
        interactive: true,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w300),
        headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: OptoColors.primary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OptoSpacing.radiusCard),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: WidgetStatePropertyAll(3),
        radius: const Radius.circular(2),
        thumbColor: WidgetStatePropertyAll(OptoColors.primary.withAlpha(128)),
        trackColor: WidgetStatePropertyAll(Colors.transparent),
        thumbVisibility: WidgetStatePropertyAll(false),
        interactive: true,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w300),
        headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Update `lib/main.dart` to use new theme**

Replace the `darkTheme:` and `theme:` lines in `MaterialApp` with:

```dart
import 'package:optoview_flutter/theme/opto_theme.dart';

// In MaterialApp:
theme: OptoTheme.light(),
darkTheme: OptoTheme.dark(),
```

Remove the old inline theme definitions that reference `AppConstants.optoviewBlue` for seeding.

- [ ] **Step 6: Verify it compiles and looks correct**

```bash
cmd.exe /c "flutter analyze"
```

- [ ] **Step 7: Commit**

```bash
git add pubspec.yaml lib/theme/ lib/main.dart
git commit -m "feat: add design system theme with custom colors, spacing, scrollbars

New files: opto_theme.dart, opto_colors.dart, opto_spacing.dart
- Custom dark/light themes with OptoView color palette
- Card theme with subtle borders (no elevation)
- Accent glow scrollbars (3px, blue, no track)
- Typography hierarchy matching spec
- Added animations package"
```

---

## Task 3: Create Design System Base Components

**Files:**
- Create: `lib/widgets/design_system/opto_card.dart`
- Create: `lib/widgets/design_system/opto_section_header.dart`
- Create: `lib/widgets/design_system/opto_chip_group.dart`
- Create: `lib/widgets/design_system/opto_segmented_control.dart`
- Create: `lib/widgets/design_system/opto_slider_field.dart`
- Create: `lib/widgets/design_system/opto_toggle_field.dart`
- Create: `lib/widgets/design_system/opto_action_button.dart`
- Create: `lib/widgets/design_system/opto_glass_panel.dart`

- [ ] **Step 1: Create `opto_card.dart`**

```dart
import 'package:flutter/material.dart';
import '../../theme/opto_colors.dart';
import '../../theme/opto_spacing.dart';

class OptoCard extends StatelessWidget {
  const OptoCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(OptoSpacing.md),
      decoration: BoxDecoration(
        color: OptoColors.surfaceDark,
        borderRadius: BorderRadius.circular(OptoSpacing.radiusCard),
        border: Border.all(color: OptoColors.surfaceVariantDark),
      ),
      child: child,
    );
  }
}
```

- [ ] **Step 2: Create `opto_section_header.dart`**

```dart
import 'package:flutter/material.dart';
import '../../theme/opto_colors.dart';
import '../../theme/opto_spacing.dart';

class OptoSectionHeader extends StatelessWidget {
  const OptoSectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.description,
  });

  final String title;
  final IconData? icon;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: OptoColors.onSurfaceVariantDark),
              const SizedBox(width: OptoSpacing.sm),
            ],
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: OptoColors.onSurfaceVariantDark,
              ),
            ),
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: OptoSpacing.xs),
          Text(
            description!,
            style: const TextStyle(
              fontSize: 12,
              color: OptoColors.onSurfaceVariantDark,
            ),
          ),
        ],
      ],
    );
  }
}
```

- [ ] **Step 3: Create `opto_chip_group.dart`**

```dart
import 'package:flutter/material.dart';
import '../../theme/opto_colors.dart';
import '../../theme/opto_spacing.dart';

class OptoChipItem<T> {
  const OptoChipItem({
    required this.value,
    required this.label,
    this.icon,
    this.color,
  });

  final T value;
  final String label;
  final IconData? icon;
  final Color? color;
}

class OptoChipGroup<T> extends StatelessWidget {
  const OptoChipGroup({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  final List<OptoChipItem<T>> items;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: items.map((item) {
        final isSelected = item.value == selected;
        return GestureDetector(
          onTap: () => onSelected(item.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? OptoColors.primary.withAlpha(38)
                  : OptoColors.surfaceVariantDark,
              borderRadius: BorderRadius.circular(OptoSpacing.radiusChip),
              border: Border.all(
                color: isSelected
                    ? OptoColors.primary.withAlpha(77)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.color != null) ...[
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                if (item.icon != null) ...[
                  Icon(
                    item.icon,
                    size: 14,
                    color: isSelected
                        ? OptoColors.peripheral
                        : OptoColors.onSurfaceVariantDark,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? OptoColors.peripheral
                        : OptoColors.onSurfaceVariantDark,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
```

- [ ] **Step 4: Create `opto_segmented_control.dart`**

```dart
import 'package:flutter/material.dart';
import '../../theme/opto_colors.dart';
import '../../theme/opto_spacing.dart';

class OptoSegmentItem<T> {
  const OptoSegmentItem({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

class OptoSegmentedControl<T> extends StatelessWidget {
  const OptoSegmentedControl({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  final List<OptoSegmentItem<T>> items;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: OptoColors.surfaceVariantDark,
        borderRadius: BorderRadius.circular(OptoSpacing.radiusChip),
      ),
      child: Row(
        children: items.map((item) {
          final isSelected = item.value == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(item.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected ? OptoColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.icon != null) ...[
                      Icon(
                        item.icon,
                        size: 14,
                        color: isSelected ? Colors.white : OptoColors.onSurfaceVariantDark,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      child: Text(
                        item.label,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : OptoColors.onSurfaceVariantDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
```

- [ ] **Step 5: Create `opto_slider_field.dart`**

```dart
import 'package:flutter/material.dart';
import '../../theme/opto_colors.dart';

class OptoSliderField extends StatelessWidget {
  const OptoSliderField({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.unit = '',
    this.formatValue,
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final int? divisions;
  final String unit;
  final String Function(double)? formatValue;

  @override
  Widget build(BuildContext context) {
    final display = formatValue?.call(value) ?? value.toStringAsFixed(0);
    return Row(
      children: [
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: OptoColors.primary,
              inactiveTrackColor: OptoColors.surfaceVariantDark,
              thumbColor: OptoColors.primary,
              overlayColor: OptoColors.primary.withAlpha(31),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 56,
          child: Text(
            '$display$unit',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: OptoColors.onSurfaceDark,
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 6: Create `opto_toggle_field.dart`**

```dart
import 'package:flutter/material.dart';
import '../../theme/opto_colors.dart';

class OptoToggleField extends StatelessWidget {
  const OptoToggleField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: OptoColors.onSurfaceDark,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: OptoColors.onSurfaceVariantDark,
                  ),
                ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: OptoColors.primary,
        ),
      ],
    );
  }
}
```

- [ ] **Step 7: Create `opto_action_button.dart`**

```dart
import 'package:flutter/material.dart';
import '../../theme/opto_colors.dart';
import '../../theme/opto_spacing.dart';

enum OptoButtonVariant { primary, secondary, danger }

class OptoActionButton extends StatefulWidget {
  const OptoActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = OptoButtonVariant.primary,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final OptoButtonVariant variant;

  @override
  State<OptoActionButton> createState() => _OptoActionButtonState();
}

class _OptoActionButtonState extends State<OptoActionButton> {
  bool _pressed = false;

  Color get _bg => switch (widget.variant) {
    OptoButtonVariant.primary => OptoColors.primary,
    OptoButtonVariant.secondary => OptoColors.surfaceVariantDark,
    OptoButtonVariant.danger => OptoColors.error.withAlpha(26),
  };

  Color get _fg => switch (widget.variant) {
    OptoButtonVariant.primary => Colors.white,
    OptoButtonVariant.secondary => OptoColors.onSurfaceVariantDark,
    OptoButtonVariant.danger => OptoColors.error,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(OptoSpacing.radiusChip),
            border: widget.variant == OptoButtonVariant.danger
                ? Border.all(color: OptoColors.error.withAlpha(77))
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 16, color: _fg),
                const SizedBox(width: 6),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 8: Create `opto_glass_panel.dart`**

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/opto_colors.dart';
import '../../theme/opto_spacing.dart';

class OptoGlassPanel extends StatelessWidget {
  const OptoGlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.blurSigma = 8.0,
    this.bgOpacity = 0.7,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double blurSigma;
  final double bgOpacity;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(OptoSpacing.radiusPill),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding ?? const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: OptoColors.backgroundDark.withAlpha((bgOpacity * 255).round()),
            borderRadius: BorderRadius.circular(OptoSpacing.radiusPill),
            border: Border.all(
              color: Colors.white.withAlpha(15),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
```

- [ ] **Step 9: Verify all components compile**

```bash
cmd.exe /c "flutter analyze"
```

- [ ] **Step 10: Commit**

```bash
git add lib/widgets/design_system/
git commit -m "feat: add design system base components

OptoCard, OptoSectionHeader, OptoChipGroup, OptoSegmentedControl,
OptoSliderField, OptoToggleField, OptoActionButton, OptoGlassPanel"
```

---

## Task 4: Create Splash Screen

**Files:**
- Create: `lib/screens/splash_screen.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1: Create `lib/screens/splash_screen.dart`**

```dart
import 'package:flutter/material.dart';
import '../theme/opto_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _taglineFade;
  late final Animation<Offset> _taglineSlide;
  late final Animation<double> _loaderFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Logo: 0-300ms, scale 0.8→1.0 + fade
    _logoScale = Tween(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.17, curve: Curves.easeOutCubic)),
    );
    _logoFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.17, curve: Curves.easeOutCubic)),
    );

    // Title: 200-400ms, fade + slide up 12px
    _titleFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.11, 0.22, curve: Curves.easeOutCubic)),
    );
    _titleSlide = Tween(begin: const Offset(0, 12), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.11, 0.22, curve: Curves.easeOutCubic)),
    );

    // Tagline: 350-550ms
    _taglineFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.19, 0.31, curve: Curves.easeOutCubic)),
    );
    _taglineSlide = Tween(begin: const Offset(0, 8), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.19, 0.31, curve: Curves.easeOutCubic)),
    );

    // Loader: 500-700ms
    _loaderFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.28, 0.39, curve: Curves.easeOutCubic)),
    );

    _controller.forward();

    // Navigate after 2 seconds
    Future.delayed(const Duration(seconds: 2), widget.onComplete);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.5, -0.8),
            end: Alignment(0.5, 0.8),
            colors: [
              Color(0xFF0F1216),
              Color(0xFF162033),
              Color(0xFF0F1216),
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Opacity(
                    opacity: _logoFade.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: OptoColors.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: OptoColors.primary.withAlpha(77),
                              blurRadius: 40,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title
                  Opacity(
                    opacity: _titleFade.value,
                    child: Transform.translate(
                      offset: _titleSlide.value,
                      child: const Text(
                        'OPTOVIEW',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 3,
                          color: OptoColors.onSurfaceDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Tagline
                  Opacity(
                    opacity: _taglineFade.value,
                    child: Transform.translate(
                      offset: _taglineSlide.value,
                      child: const Text(
                        'Neuro-Optometric Testing',
                        style: TextStyle(
                          fontSize: 12,
                          color: OptoColors.onSurfaceVariantDark,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Loader
                  Opacity(
                    opacity: _loaderFade.value,
                    child: SizedBox(
                      width: 120,
                      height: 2,
                      child: LinearProgressIndicator(
                        backgroundColor: OptoColors.surfaceVariantDark,
                        valueColor: const AlwaysStoppedAnimation(OptoColors.primary),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Wire splash into `lib/main.dart`**

Change `home:` in `MaterialApp` to use the splash screen that transitions to the current `MenuScreen` (we'll replace with Dashboard in the next task):

```dart
home: SplashScreen(
  onComplete: () {
    // Will be updated to DashboardScreen in Task 5
  },
),
```

Wrap the app in a `StatefulWidget` that manages the splash→main transition using `AnimatedSwitcher` or simple state flag. The simplest approach: make `OptoViewApp` a `StatefulWidget` with a `_showSplash` boolean.

- [ ] **Step 3: Verify splash works**

```bash
cmd.exe /c "flutter analyze"
```

- [ ] **Step 4: Commit**

```bash
git add lib/screens/splash_screen.dart lib/main.dart
git commit -m "feat: add splash screen with staggered entrance animations

Logo scale+fade, title slide, tagline slide, loader fade.
Transitions to main app after 2 seconds."
```

---

## Task 5: Create Dashboard Screen and Rewire Navigation

**Files:**
- Create: `lib/screens/dashboard_screen.dart`
- Modify: `lib/main.dart`
- Modify: `lib/screens/test_results_screen.dart` (update "home" navigation)
- Modify: `lib/screens/localization_results_screen.dart`
- Modify: `lib/screens/macdonald_results_screen.dart`

- [ ] **Step 1: Create `lib/screens/dashboard_screen.dart`**

Build the dashboard with:
- Header: logo (32px) + "OptoView" + icon buttons (language toggle, theme toggle, info/credits)
- Body in 2 columns (Row with Expanded):
  - Left (flex 1.2): "Tests disponibles" section label, 3 test cards (OptoCard with icon, name, description, arrow), optional "Repetir último test" card
  - Right (flex 1): Stats row (3 boxes: tests today, patients, total), Activity card (last 4 results)
- Data loaded from `ResultsStorage.loadAll()`
- Test cards navigate to config screens: `ConfigScreen()`, `LocalizationConfigScreen()`, `MacDonaldConfigScreen()`
- "Ver historial" navigates to `HistoryScreen()`
- Info button navigates to `CreditsScreen()`
- Theme toggle uses the global `themeNotifier`
- Empty state when no results: welcome message instead of stats

Use staggered entrance animations: each card fades+slides from below with 50ms delay.

The dashboard is ~250-300 lines. Key sections:

```dart
class DashboardScreen extends StatefulWidget { ... }

class _DashboardScreenState extends State<DashboardScreen> {
  List<SavedResult> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    final results = await ResultsStorage.loadAll();
    if (mounted) setState(() { _results = results; _isLoading = false; });
  }

  // Computed stats
  int get _testsToday => _results.where((r) =>
    DateUtils.isSameDay(r.startedAt, DateTime.now())).length;
  int get _uniquePatients => _results
    .where((r) => r.patientName.isNotEmpty)
    .map((r) => r.patientName).toSet().length;
  SavedResult? get _lastResult => _results.isEmpty ? null : _results.first;

  @override
  Widget build(BuildContext context) { ... }
}
```

For the test cards, use the test type colors from `OptoColors`:
- Peripheral: `OptoColors.peripheral` (#5B8FD2), icon `Icons.blur_circular`
- Localization: `OptoColors.localization` (#9B7BFF), icon `Icons.my_location`
- MacDonald: `OptoColors.macdonald` (#4CAF7D), icon `Icons.grid_view_rounded`

For the "Repetir último test" card, check `_lastResult` and build a card with gradient border using `OptoColors.primary`. Navigate to the appropriate config screen based on `_lastResult!.testType`.

For the activity list, show last 4 results with: colored dot, patient name, test type + relative time, status badge.

- [ ] **Step 2: Update `lib/main.dart` — splash transitions to dashboard**

After splash completes, show `DashboardScreen` instead of `MenuScreen`. Update the `OptoViewApp` to manage the transition:

```dart
home: _showSplash
    ? SplashScreen(onComplete: () => setState(() => _showSplash = false))
    : const DashboardScreen(),
```

Use `AnimatedSwitcher` with a `FadeTransition` (400ms) wrapping the above.

- [ ] **Step 3: Update results screens navigation**

In `test_results_screen.dart`, `localization_results_screen.dart`, and `macdonald_results_screen.dart`, update the "Home" / "Back to menu" button to pop back to the dashboard:

```dart
// Replace popUntil logic with:
Navigator.of(context).popUntil((route) => route.isFirst);
```

This pops back to the dashboard (which is now the first route).

- [ ] **Step 4: Verify navigation works**

```bash
cmd.exe /c "flutter analyze"
```

- [ ] **Step 5: Commit**

```bash
git add lib/screens/dashboard_screen.dart lib/main.dart lib/screens/test_results_screen.dart lib/screens/localization_results_screen.dart lib/screens/macdonald_results_screen.dart
git commit -m "feat: add dashboard screen replacing old menu

Two-column layout: test cards + quick repeat on left,
stats + recent activity on right. Splash transitions to
dashboard. Results screens navigate back to dashboard."
```

---

## Task 6: Redesign Test Overlay Widgets

**Files:**
- Modify: `lib/widgets/test_ui/test_timer_display.dart`
- Modify: `lib/widgets/test_ui/test_control_buttons.dart`
- Modify: `lib/widgets/test_ui/instruction_overlay.dart`
- Modify: `lib/widgets/test_ui/pause_overlay.dart`

- [ ] **Step 1: Redesign `test_timer_display.dart`**

Replace the current simple black-background text with a glass panel pill:

```dart
import 'package:flutter/material.dart';
import '../design_system/opto_glass_panel.dart';
import '../../theme/opto_colors.dart';

class TestTimerDisplay extends StatelessWidget {
  const TestTimerDisplay({
    super.key,
    required this.remainingSeconds,
    this.stimuliCount,
  });

  final int remainingSeconds;
  final int? stimuliCount;

  String get _formatted {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      left: 12,
      child: OptoGlassPanel(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer_outlined, size: 14, color: OptoColors.onSurfaceVariantDark),
            const SizedBox(width: 8),
            Text(
              _formatted,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: OptoColors.onSurfaceDark,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            if (stimuliCount != null) ...[
              Container(
                width: 1,
                height: 16,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: Colors.white.withAlpha(26),
              ),
              Text(
                '$stimuliCount est.',
                style: const TextStyle(
                  fontSize: 11,
                  color: OptoColors.onSurfaceVariantDark,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Redesign `test_control_buttons.dart`**

Replace with two separate glass pills:

```dart
import 'package:flutter/material.dart';
import '../design_system/opto_glass_panel.dart';
import '../../theme/opto_colors.dart';

class TestControlButtons extends StatelessWidget {
  const TestControlButtons({
    super.key,
    required this.isPaused,
    required this.onTogglePause,
    required this.onStop,
  });

  final bool isPaused;
  final VoidCallback onTogglePause;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      right: 12,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onTogglePause,
            child: OptoGlassPanel(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPaused ? Icons.play_arrow : Icons.pause,
                    size: 14,
                    color: OptoColors.warning,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isPaused ? 'Reanudar' : 'Pausa',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: OptoColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onStop,
            child: OptoGlassPanel(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stop, size: 14, color: OptoColors.error),
                  const SizedBox(width: 6),
                  const Text(
                    'Detener',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: OptoColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Redesign `instruction_overlay.dart`**

Replace with blurred overlay + structured card with numbered steps + countdown ring:

```dart
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/opto_colors.dart';
import '../../theme/opto_spacing.dart';

class InstructionOverlay extends StatefulWidget {
  const InstructionOverlay({
    super.key,
    required this.testTitle,
    required this.instructions,
    required this.onCountdownComplete,
  });

  final String testTitle;
  final List<String> instructions;
  final VoidCallback onCountdownComplete;

  @override
  State<InstructionOverlay> createState() => _InstructionOverlayState();
}

class _InstructionOverlayState extends State<InstructionOverlay>
    with SingleTickerProviderStateMixin {
  int _countdown = 3;
  late final AnimationController _ringController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..forward();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          t.cancel();
          widget.onCountdownComplete();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Positioned.fill(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            color: const Color(0xFF0F1216).withAlpha(230),
            alignment: Alignment.center,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: OptoColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: OptoColors.surfaceVariantDark),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: OptoColors.primary.withAlpha(31),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.info_outline, size: 18, color: OptoColors.peripheral),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.testTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            Text(l.instructionsTitle, style: const TextStyle(fontSize: 12, color: OptoColors.onSurfaceVariantDark)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Steps
                  ...widget.instructions.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                            color: OptoColors.primary.withAlpha(38),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text('${e.key + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: OptoColors.peripheral)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(e.value, style: const TextStyle(fontSize: 13, height: 1.5)),
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 12),
                  // Countdown ring
                  AnimatedBuilder(
                    animation: _ringController,
                    builder: (context, _) {
                      return Column(
                        children: [
                          SizedBox(
                            width: 72, height: 72,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: _ringController.value,
                                  strokeWidth: 3,
                                  backgroundColor: OptoColors.surfaceVariantDark,
                                  valueColor: const AlwaysStoppedAnimation(OptoColors.primary),
                                ),
                                Text(
                                  '$_countdown',
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w300,
                                    color: OptoColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l.instructionsStart,
                            style: const TextStyle(fontSize: 11, color: OptoColors.onSurfaceVariantDark),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

Note: Add `import 'package:flutter_gen/gen_l10n/app_localizations.dart';` at the top. The `InstructionOverlay` now handles its own countdown internally instead of the parent managing a separate pre-countdown timer. This simplifies the test screen code.

- [ ] **Step 4: Redesign `pause_overlay.dart`**

Replace with blurred overlay + info card with progress stats:

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/opto_colors.dart';
import '../../theme/opto_spacing.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({
    super.key,
    required this.remainingSeconds,
    required this.elapsedSeconds,
    required this.stimuliShown,
    required this.onResume,
    required this.onStop,
  });

  final int remainingSeconds;
  final int elapsedSeconds;
  final int stimuliShown;
  final VoidCallback onResume;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            color: const Color(0xFF0F1216).withAlpha(217),
            alignment: Alignment.center,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 340),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
              decoration: BoxDecoration(
                color: OptoColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: OptoColors.surfaceVariantDark),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pause icon
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: OptoColors.warning.withAlpha(31),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.pause, size: 24, color: OptoColors.warning),
                  ),
                  const SizedBox(height: 16),
                  const Text('Test en pausa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text(
                    'El test se reanudará exactamente donde lo dejaste.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: OptoColors.onSurfaceVariantDark),
                  ),
                  const SizedBox(height: 20),
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _PauseStat(value: '$remainingSeconds', label: 'Restante'),
                      _PauseStat(value: '$elapsedSeconds', label: 'Transcurrido'),
                      _PauseStat(value: '$stimuliShown', label: 'Estímulos'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: onStop,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: OptoColors.surfaceVariantDark,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.stop, size: 16, color: OptoColors.error),
                              SizedBox(width: 6),
                              Text('Terminar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: OptoColors.error)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: onResume,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: OptoColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.play_arrow, size: 16, color: Colors.white),
                              SizedBox(width: 6),
                              Text('Reanudar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PauseStat extends StatelessWidget {
  const _PauseStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: OptoColors.onSurfaceVariantDark, letterSpacing: 0.5)),
      ],
    );
  }
}
```

- [ ] **Step 5: Update test screens to pass new props to overlays**

In all 3 test screens, update the overlay widget calls to pass the new required parameters:

For `TestTimerDisplay`: change from `TestTimerDisplay(text: ...)` to:
```dart
TestTimerDisplay(
  remainingSeconds: _remaining,
  stimuliCount: _stimuliShown,
)
```

For `PauseOverlay`: add `elapsedSeconds` and `stimuliShown`:
```dart
PauseOverlay(
  remainingSeconds: _remaining,
  elapsedSeconds: widget.config.duracionSegundos - _remaining,
  stimuliShown: _stimuliShown,
  onResume: _togglePause,
  onStop: () => _finishTest(stoppedManually: true),
)
```

For `InstructionOverlay`: change to new API with `testTitle`, `instructions` (list), and `onCountdownComplete` (replaces `onStart`). Remove the separate `_preCountdown` and `_runPreCountdown()` logic from the test screens — the overlay now handles countdown internally.

- [ ] **Step 6: Verify overlays compile and display correctly**

```bash
cmd.exe /c "flutter analyze"
```

- [ ] **Step 7: Commit**

```bash
git add lib/widgets/test_ui/ lib/screens/dynamic_periphery_test.dart lib/screens/localization_test.dart lib/screens/macdonald_test.dart
git commit -m "feat: redesign test overlays with glass panels and blur

Timer pill with glass background shows time + stimuli count.
Control buttons as separate colored glass pills.
Instruction overlay with numbered steps + countdown ring.
Pause overlay with progress stats and blur backdrop."
```

---

## Task 7: Rebuild Config Screen with Tabs

**Files:**
- Create: `lib/screens/config/tabbed_config_screen.dart`
- Create: `lib/screens/config/tabs/general_tab.dart`
- Create: `lib/screens/config/tabs/stimulus_wizard_tab.dart`
- Create: `lib/screens/config/tabs/visual_tab.dart`
- Create: `lib/screens/config/tabs/time_tab.dart`
- Create: `lib/screens/config/config_bottom_bar.dart`
- Create: `lib/screens/config/stimulus_preview.dart`
- Modify: `lib/screens/config_screen.dart` (replace content)

This is the largest task. The config screen moves from a single ListView to a `DefaultTabController` with 4 tabs.

- [ ] **Step 1: Create `config_bottom_bar.dart`**

Fixed bottom bar showing config summary + start button:

```dart
import 'package:flutter/material.dart';
import '../../theme/opto_colors.dart';
import '../../theme/opto_spacing.dart';

class ConfigBottomBar extends StatelessWidget {
  const ConfigBottomBar({
    super.key,
    required this.summary,
    required this.onStart,
    required this.startLabel,
  });

  final String summary;
  final VoidCallback onStart;
  final String startLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: OptoColors.surfaceDark,
        border: const Border(top: BorderSide(color: OptoColors.surfaceVariantDark)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              summary,
              style: const TextStyle(fontSize: 11, color: OptoColors.onSurfaceVariantDark),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onStart,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: OptoColors.primary,
                borderRadius: BorderRadius.circular(OptoSpacing.radiusChip),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_arrow, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(startLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Create `stimulus_preview.dart`**

Live preview widget for the wizard:

```dart
import 'package:flutter/material.dart';
import '../../theme/opto_colors.dart';
import '../../theme/opto_spacing.dart';
import '../../models/test_config.dart';
import '../../utils/stimulus_color_utils.dart';

class StimulusPreview extends StatelessWidget {
  const StimulusPreview({
    super.key,
    required this.categoria,
    this.forma,
    required this.colorOption,
    required this.sizePercent,
  });

  final SimboloCategoria categoria;
  final Forma? forma;
  final EstimuloColor colorOption;
  final double sizePercent;

  @override
  Widget build(BuildContext context) {
    final color = StimulusColorUtils.resolve(colorOption);
    return Container(
      decoration: BoxDecoration(
        color: OptoColors.surfaceDark,
        borderRadius: BorderRadius.circular(OptoSpacing.radiusCard),
        border: Border.all(color: OptoColors.surfaceVariantDark),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'VISTA PREVIA',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: OptoColors.onSurfaceVariantDark),
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Container(
              decoration: BoxDecoration(
                color: OptoColors.backgroundDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Fixation point
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                  // Stimulus preview
                  Positioned(
                    right: 60,
                    top: 40,
                    child: _buildStimulus(color),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${categoria.name} · ${colorOption.name} · ${sizePercent.round()}%',
            style: const TextStyle(fontSize: 11, color: OptoColors.onSurfaceVariantDark),
          ),
        ],
      ),
    );
  }

  Widget _buildStimulus(Color color) {
    final size = 20 + (sizePercent / 100 * 30);
    if (categoria == SimboloCategoria.formas && forma != null) {
      return Container(
        width: size, height: size,
        decoration: BoxDecoration(
          color: color.withAlpha(204),
          shape: forma == Forma.circulo ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: forma != Forma.circulo ? BorderRadius.circular(4) : null,
        ),
      );
    }
    return Text(
      categoria == SimboloCategoria.letras ? 'K' : '7',
      style: TextStyle(fontSize: size, fontWeight: FontWeight.w700, color: color),
    );
  }
}
```

- [ ] **Step 3: Create `general_tab.dart`**

Two-column layout with patient, side, instructions, speed, movement, distance:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../models/test_config.dart';
import '../../../theme/opto_colors.dart';
import '../../../theme/opto_spacing.dart';
import '../../../widgets/design_system/opto_card.dart';
import '../../../widgets/design_system/opto_section_header.dart';
import '../../../widgets/design_system/opto_chip_group.dart';
import '../../../widgets/design_system/opto_segmented_control.dart';
import '../../../widgets/design_system/opto_slider_field.dart';
import '../../../widgets/design_system/opto_toggle_field.dart';

class GeneralTab extends StatelessWidget {
  const GeneralTab({
    super.key,
    required this.config,
    required this.patientController,
    required this.showInstructions,
    required this.onConfigChanged,
    required this.onInstructionsChanged,
  });

  final TestConfig config;
  final TextEditingController patientController;
  final bool showInstructions;
  final ValueChanged<TestConfig> onConfigChanged;
  final ValueChanged<bool> onInstructionsChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(OptoSpacing.md),
            children: [
              // Patient
              OptoCard(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const OptoSectionHeader(title: 'Paciente', icon: Icons.person_outline),
                  const SizedBox(height: OptoSpacing.sm),
                  TextField(
                    controller: patientController,
                    decoration: InputDecoration(
                      hintText: l.configPatientHint,
                      prefixIcon: const Icon(Icons.person, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(OptoSpacing.radiusChip)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      isDense: true,
                    ),
                  ),
                ],
              )),
              const SizedBox(height: OptoSpacing.sm),
              // Side
              OptoCard(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OptoSectionHeader(title: l.configSide),
                  const SizedBox(height: OptoSpacing.sm),
                  OptoChipGroup<Lado>(
                    items: Lado.values.map((s) => OptoChipItem(
                      value: s,
                      label: s.label, // Uses existing extension
                    )).toList(),
                    selected: config.lado,
                    onSelected: (v) => onConfigChanged(config.copyWith(lado: v)),
                  ),
                ],
              )),
              const SizedBox(height: OptoSpacing.sm),
              // Instructions toggle
              OptoCard(child: OptoToggleField(
                label: l.configShowInstructions,
                value: showInstructions,
                onChanged: onInstructionsChanged,
              )),
            ],
          ),
        ),
        const SizedBox(width: OptoSpacing.md),
        // Right column
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(OptoSpacing.md),
            children: [
              // Speed
              OptoCard(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OptoSectionHeader(title: l.configSpeed),
                  const SizedBox(height: OptoSpacing.sm),
                  OptoSegmentedControl<Velocidad>(
                    items: Velocidad.values.map((v) => OptoSegmentItem(value: v, label: v.label)).toList(),
                    selected: config.velocidad,
                    onSelected: (v) => onConfigChanged(config.copyWith(velocidad: v)),
                  ),
                ],
              )),
              const SizedBox(height: OptoSpacing.sm),
              // Movement
              OptoCard(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OptoSectionHeader(title: l.configMovement),
                  const SizedBox(height: OptoSpacing.sm),
                  OptoSegmentedControl<Movimiento>(
                    items: Movimiento.values.map((m) => OptoSegmentItem(value: m, label: m.label)).toList(),
                    selected: config.movimiento,
                    onSelected: (v) => onConfigChanged(config.copyWith(movimiento: v)),
                  ),
                ],
              )),
              const SizedBox(height: OptoSpacing.sm),
              // Distance
              OptoCard(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OptoSectionHeader(title: l.configDistance),
                  const SizedBox(height: OptoSpacing.sm),
                  OptoToggleField(
                    label: l.configDistanceRandom,
                    value: config.distanciaModo == DistanciaModo.aleatorio,
                    onChanged: (v) => onConfigChanged(config.copyWith(
                      distanciaModo: v ? DistanciaModo.aleatorio : DistanciaModo.fijo,
                    )),
                  ),
                  if (config.distanciaModo == DistanciaModo.fijo) ...[
                    const SizedBox(height: OptoSpacing.sm),
                    OptoSliderField(
                      value: config.distanciaPorcentaje,
                      min: 10, max: 100, divisions: 18,
                      unit: '%',
                      onChanged: (v) => onConfigChanged(config.copyWith(distanciaPorcentaje: v)),
                    ),
                  ],
                ],
              )),
            ],
          ),
        ),
      ],
    );
  }
}
```

Note: The `label` getter on enums (e.g., `Lado.label`) already exists in the codebase. If the localized versions are needed, use the `AppLocalizations` equivalent. Adapt based on existing enum extension patterns.

- [ ] **Step 4: Create `stimulus_wizard_tab.dart`**

Wizard with 3 steps (Category → Color → Size) + live preview:

This is a StatefulWidget with `_currentStep` (0, 1, 2). Layout: left side shows the current step content, right side shows `StimulusPreview`. Step indicator at top with circles + connecting lines. Previous/Next buttons at bottom.

Key structure:
```dart
class StimulusWizardTab extends StatefulWidget {
  const StimulusWizardTab({
    super.key,
    required this.config,
    required this.onConfigChanged,
  });
  final TestConfig config;
  final ValueChanged<TestConfig> onConfigChanged;
  // ...
}
```

Step 0 (Category): `OptoSegmentedControl<SimboloCategoria>` + conditional `OptoChipGroup<Forma>` if shapes selected.
Step 1 (Color): `OptoChipGroup<EstimuloColor>` with color dots.
Step 2 (Size): `OptoSliderField` (5-35%) + random toggle.

- [ ] **Step 5: Create `visual_tab.dart` and `time_tab.dart`**

`visual_tab.dart`: Two-column layout with background selector (Light/Dark/Blue segmented), fixation selector (5 options), distractor toggle, animation toggle.

`time_tab.dart`: Two-column layout with duration slider (10-300s, divisions 29) and size slider (5-35%) + random toggle.

Both follow the same pattern as `general_tab.dart` — accept `config` + `onConfigChanged` and use design system components.

- [ ] **Step 6: Create `tabbed_config_screen.dart`**

Main wrapper that assembles the tabs:

```dart
class TabbedConfigScreen extends StatefulWidget {
  const TabbedConfigScreen({super.key, this.initialConfig, required this.testType});
  final TestConfig? initialConfig;
  final String testType; // 'peripheral', 'localization', 'macdonald'
  // ...
}

class _TabbedConfigScreenState extends State<TabbedConfigScreen> {
  late TestConfig _config;
  bool _showInstructions = true;
  final _patientController = TextEditingController();
  String? _activePreset;

  // Preset handling: when a preset is selected, update _config and set _activePreset.
  // When any value changes manually, set _activePreset = null.

  void _onConfigChanged(TestConfig newConfig) {
    setState(() {
      _config = newConfig;
      _activePreset = null; // Deselect preset on manual change
    });
  }

  String get _summary {
    // Build one-line summary from config
    return '${_activePreset ?? "Personalizado"} · ${_config.lado.name} · ...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OptoColors.backgroundDark,
      body: Column(
        children: [
          // Top bar with back, title, preset pills
          _buildTopBar(),
          // Tab bar
          TabBar(tabs: [
            Tab(icon: Icon(Icons.settings), text: 'General'),
            Tab(icon: Icon(Icons.auto_awesome), text: 'Estímulo'),
            Tab(icon: Icon(Icons.visibility), text: 'Visual'),
            Tab(icon: Icon(Icons.timer), text: 'Tiempo'),
          ]),
          // Tab content
          Expanded(
            child: TabBarView(children: [
              GeneralTab(config: _config, ...),
              StimulusWizardTab(config: _config, ...),
              VisualTab(config: _config, ...),
              TimeTab(config: _config, ...),
            ]),
          ),
          // Bottom bar
          ConfigBottomBar(summary: _summary, onStart: _startTest, startLabel: l.configStart),
        ],
      ),
    );
  }
}
```

- [ ] **Step 7: Update `config_screen.dart` to use `TabbedConfigScreen`**

Replace the content of `ConfigScreen` to delegate to `TabbedConfigScreen`:

```dart
class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabbedConfigScreen(testType: 'peripheral');
  }
}
```

Do the same for `LocalizationConfigScreen` and `MacDonaldConfigScreen`, passing the appropriate `testType` and config model.

- [ ] **Step 8: Verify tabs compile and navigate correctly**

```bash
cmd.exe /c "flutter analyze"
```

- [ ] **Step 9: Commit**

```bash
git add lib/screens/config/ lib/screens/config_screen.dart lib/screens/localization_config_screen.dart lib/screens/macdonald_config_screen.dart
git commit -m "feat: rebuild config screens with tabs + stimulus wizard

4 tabs: General, Estímulo (wizard with live preview), Visual, Tiempo.
Fixed bottom bar with config summary + start button.
Preset pills in top bar. Two-column layouts in landscape."
```

---

## Task 8: Create In-App Heatmap Widget and Redesign Results Screen

**Files:**
- Create: `lib/widgets/visual_field_heatmap.dart`
- Modify: `lib/screens/test_results_screen.dart`
- Modify: `lib/screens/localization_results_screen.dart`
- Modify: `lib/screens/macdonald_results_screen.dart`

- [ ] **Step 1: Create `lib/widgets/visual_field_heatmap.dart`**

Interactive heatmap widget using `CustomPainter`:

```dart
import 'package:flutter/material.dart';
import '../theme/opto_colors.dart';
import '../theme/opto_spacing.dart';
import '../models/saved_result.dart';

class VisualFieldHeatmap extends StatelessWidget {
  const VisualFieldHeatmap({
    super.key,
    required this.hits,
    required this.misses,
    this.compact = false,
  });

  /// List of (x, y) normalized positions [0..1] for hits
  final List<Offset> hits;
  /// List of (x, y) normalized positions [0..1] for misses
  final List<Offset> misses;
  /// If true, renders smaller (for history detail panel)
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: OptoColors.surfaceDark,
        borderRadius: BorderRadius.circular(OptoSpacing.radiusCard),
        border: Border.all(color: OptoColors.surfaceVariantDark),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('MAPA DEL CAMPO VISUAL',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: OptoColors.onSurfaceVariantDark)),
              Row(children: [
                _LegendDot(color: OptoColors.success, label: 'Acierto'),
                const SizedBox(width: 12),
                _LegendDot(color: OptoColors.error, label: 'Fallo'),
              ]),
            ],
          ),
          const SizedBox(height: 12),
          // Heatmap area
          AspectRatio(
            aspectRatio: compact ? 2.0 : 16 / 10,
            child: Container(
              decoration: BoxDecoration(
                color: OptoColors.backgroundDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: CustomPaint(
                painter: _HeatmapPainter(hits: hits, misses: misses),
                size: Size.infinite,
              ),
            ),
          ),
          // Stats
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: OptoColors.surfaceVariantDark))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _HeatmapStat(value: '${hits.length}', label: 'Aciertos', color: OptoColors.success),
                _HeatmapStat(value: '${misses.length}', label: 'Fallos', color: OptoColors.error),
                _HeatmapStat(
                  value: hits.isEmpty && misses.isEmpty ? '-' : '${(hits.length / (hits.length + misses.length) * 100).round()}%',
                  label: 'Precisión',
                  color: OptoColors.peripheral,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  _HeatmapPainter({required this.hits, required this.misses});
  final List<Offset> hits;
  final List<Offset> misses;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()..color = OptoColors.surfaceVariantDark.withAlpha(204)..strokeWidth = 1;

    // Grid lines
    for (final f in [0.25, 0.5, 0.75]) {
      canvas.drawLine(Offset(0, size.height * f), Offset(size.width, size.height * f), gridPaint);
      canvas.drawLine(Offset(size.width * f, 0), Offset(size.width * f, size.height), gridPaint);
    }

    // Crosshair
    final center = Offset(size.width / 2, size.height / 2);
    final crossPaint = Paint()..color = Colors.white.withAlpha(77)..strokeWidth = 1;
    canvas.drawLine(Offset(center.dx - 6, center.dy), Offset(center.dx + 6, center.dy), crossPaint);
    canvas.drawLine(Offset(center.dx, center.dy - 6), Offset(center.dx, center.dy + 6), crossPaint);

    // Hits
    for (final p in hits) {
      final pos = Offset(p.dx * size.width, p.dy * size.height);
      canvas.drawCircle(pos, 5, Paint()..color = OptoColors.success.withAlpha(153));
      canvas.drawCircle(pos, 5, Paint()..color = OptoColors.success..style = PaintingStyle.stroke..strokeWidth = 1.5);
    }

    // Misses
    for (final p in misses) {
      final pos = Offset(p.dx * size.width, p.dy * size.height);
      canvas.drawCircle(pos, 4, Paint()..color = OptoColors.error.withAlpha(102));
      canvas.drawCircle(pos, 4, Paint()..color = OptoColors.error..style = PaintingStyle.stroke..strokeWidth = 1.5);
    }
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter old) =>
      old.hits != hits || old.misses != misses;
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: OptoColors.onSurfaceVariantDark)),
      ],
    );
  }
}

class _HeatmapStat extends StatelessWidget {
  const _HeatmapStat({required this.value, required this.label, required this.color});
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: OptoColors.onSurfaceVariantDark)),
      ],
    );
  }
}
```

- [ ] **Step 2: Redesign `test_results_screen.dart`**

Replace the current single-column layout with a 2-column layout:
- Left: status banner, patient info, stats grid (2×2 with progress bars + circular indicator), config tags
- Right: `VisualFieldHeatmap`
- Top bar: back + title + Exportar / Compartir / Repetir buttons

The stats grid uses `OptoCard` for each stat. The circular precision indicator uses `CircularProgressIndicator` with custom styling. Config tags displayed as a `Wrap` of small containers.

Extract stimulus positions from `TestResult` to generate hit/miss `Offset` lists for the heatmap. If position data is not available in the current `TestResult` model, the heatmap shows a placeholder message.

- [ ] **Step 3: Update localization and macdonald results screens**

Follow the same 2-column pattern. Localization adds reaction time stats. MacDonald replaces heatmap with a ring-based results table (using existing `LetterEvent` data and `_HitMapPainter` logic from history_screen.dart).

- [ ] **Step 4: Verify results display correctly**

```bash
cmd.exe /c "flutter analyze"
```

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/visual_field_heatmap.dart lib/screens/test_results_screen.dart lib/screens/localization_results_screen.dart lib/screens/macdonald_results_screen.dart
git commit -m "feat: redesign results screens with visual indicators + heatmap

Two-column layout: stats with progress bars and circular precision
indicator on left, integrated visual field heatmap on right.
Config shown as compact tags. Top bar with export/share/repeat."
```

---

## Task 9: Redesign History Screen — Master-Detail Layout

**Files:**
- Modify: `lib/screens/history_screen.dart`

This is a large refactor of the existing 900+ line file. The core logic (loading, filtering, exporting, deleting) stays the same. The UI changes from a single ListView to a master-detail layout.

- [ ] **Step 1: Restructure the build method**

The new layout:
```
Column
├── TopBar (back + "Historial")
├── FilterBar (search + type chips + view toggle + export/delete buttons)
└── Expanded Row
    ├── SizedBox(width: 380) → list panel with scroll
    └── Expanded → detail panel
```

Keep all existing state variables (`_results`, `_searchQuery`, `_viewMode`, `_selectionMode`, `_selectedIds`). Add:
```dart
String? _selectedResultId;
SavedResult? get _selectedResult => _selectedResultId == null
    ? null
    : _results.firstWhereOrNull((r) => r.id == _selectedResultId);
```

- [ ] **Step 2: Build the filter bar**

Row containing:
- Search `TextField` in a styled container (max-width 280px)
- Filter chips for test types (Todos, Periférica, Localización, MacDonald) using colored borders when active
- Spacer
- View toggle (date/patient icons)
- Export + Delete buttons

Use the existing `_searchQuery` and add a `_filterType` (null = all, or 'peripheral'/'localization'/'macdonald').

- [ ] **Step 3: Build the list panel**

Left panel (380px wide) with:
- Sticky date headers
- List items with: checkbox, colored dot, patient name, test type + time, status badge
- Selected item has left border accent
- Tap selects and shows detail on right
- Long press or checkbox enters selection mode

Reuse existing `_buildResultTile` logic but adapt the visual style to match the spec.

- [ ] **Step 4: Build the detail panel**

Right panel showing selected result:
- Header: test type label (colored) + patient name (18px) + date
- Action buttons: PDF / Excel / Repeat
- Mini stats row (4 boxes)
- Mini `VisualFieldHeatmap(compact: true)` 
- Config tags

When no item is selected, show a centered placeholder "Selecciona un resultado".

Animate detail panel changes with `AnimatedSwitcher` (200ms fade).

- [ ] **Step 5: Update selection mode**

When checkboxes are active, show a selection bar above the list with count + bulk export / delete buttons. Reuse existing `_bulkExport()` and delete methods.

- [ ] **Step 6: Verify history works end-to-end**

```bash
cmd.exe /c "flutter analyze"
```

- [ ] **Step 7: Commit**

```bash
git add lib/screens/history_screen.dart
git commit -m "feat: redesign history with master-detail layout

Left panel: filterable list with search, type chips, date grouping.
Right panel: selected result detail with stats + mini heatmap.
Selection mode for bulk export/delete. Animated transitions."
```

---

## Task 10: Redesign Credits Screen

**Files:**
- Modify: `lib/screens/credits_screen.dart`

- [ ] **Step 1: Rebuild credits with split layout**

Replace the current centered column with a Row of two panels:

Left panel (flex 1): Branding area with gradient background (same as splash), logo with glow, "OPTOVIEW", tagline, version badge.

Right panel (flex 1.2): Scrollable column with 3 `OptoCard` sections:
- "Equipo": Two rows with colored icons + name + role
  - Estefanía Rodríguez-Bobada Lillo — Optometrista
  - Rodrigo Melón Gutte — Desarrollo
- "Tecnología": Tags (Flutter 3.8, Dart, Material 3, Android) with colored dots
- "Legal": Copyright + disclaimer text

Back button at bottom of right panel.

Staggered entrance: left fades in, then cards slide from right.

- [ ] **Step 2: Verify**

```bash
cmd.exe /c "flutter analyze"
```

- [ ] **Step 3: Commit**

```bash
git add lib/screens/credits_screen.dart
git commit -m "feat: redesign credits with split branding + info layout

Left: gradient background with logo glow and version badge.
Right: team, technology, and legal cards with staggered entrance."
```

---

## Task 11: Add Screen Transitions and Staggered Animations

**Files:**
- Create: `lib/utils/page_transitions.dart`
- Modify: `lib/screens/dashboard_screen.dart` (staggered entrance)
- Modify: navigation calls across screens

- [ ] **Step 1: Create `page_transitions.dart`**

```dart
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class OptoPageRoute<T> extends PageRouteBuilder<T> {
  OptoPageRoute({required WidgetBuilder builder})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        );
}
```

- [ ] **Step 2: Replace `MaterialPageRoute` with `OptoPageRoute` in navigation calls**

Across all screens where `Navigator.push` is used with `MaterialPageRoute`, replace with `OptoPageRoute`. This gives all screen transitions the `SharedAxisTransition` effect.

Key locations:
- `dashboard_screen.dart`: test card taps, history link, credits link
- `config_screen.dart` (tabbed): start test navigation
- `test_results_screen.dart`: repeat test, home navigation

- [ ] **Step 3: Add staggered entrance to dashboard**

In `DashboardScreen`, use `AnimationController` + `Interval`s to stagger the entrance of each card. Each card gets a `SlideTransition` + `FadeTransition` with increasing delays (50ms apart).

- [ ] **Step 4: Verify transitions are smooth**

```bash
cmd.exe /c "flutter analyze"
```

- [ ] **Step 5: Commit**

```bash
git add lib/utils/page_transitions.dart lib/screens/
git commit -m "feat: add SharedAxisTransition page transitions and staggered entrances

All navigation uses horizontal shared axis transition (300ms).
Dashboard cards enter with staggered fade+slide animations."
```

---

## Task 12: Update Localization and Cleanup

**Files:**
- Modify: `lib/l10n/app_en.arb`
- Modify: `lib/l10n/app_es.arb` (if it exists as source, or the generated files)
- Delete: `lib/screens/menu_screen.dart`
- Delete: `lib/screens/test_menu_screen.dart`

- [ ] **Step 1: Add new localization keys**

Add keys to `app_en.arb` for new UI elements:

```json
"dashboardTitle": "OptoView",
"dashboardTestsAvailable": "Available Tests",
"dashboardRepeatLast": "Repeat last test",
"dashboardTestsToday": "Tests today",
"dashboardPatients": "Patients",
"dashboardTotalTests": "Total tests",
"dashboardRecentActivity": "Recent activity",
"dashboardViewHistory": "View history",
"dashboardWelcome": "Welcome to OptoView",
"dashboardWelcomeDesc": "Select a test to begin",
"configTabGeneral": "General",
"configTabStimulus": "Stimulus",
"configTabVisual": "Visual",
"configTabTime": "Time",
"wizardCategory": "Category",
"wizardColor": "Color",
"wizardSize": "Size",
"wizardPreview": "Preview",
"wizardPrevious": "Previous",
"wizardNext": "Next",
"testPausedTitle": "Test paused",
"testPausedDesc": "The test will resume exactly where you left off.",
"testPausedRemaining": "Remaining",
"testPausedElapsed": "Elapsed",
"testPausedStimuli": "Stimuli",
"testPausedEnd": "End",
"testPausedResume": "Resume",
"resultsHeatmapTitle": "Visual field map",
"resultsHeatmapHit": "Hit",
"resultsHeatmapMiss": "Miss",
"resultsExport": "Export",
"resultsShare": "Share",
"resultsRepeat": "Repeat",
"historyFilterAll": "All",
"historySelectCount": "{count} selected",
"historySelectResult": "Select a result",
"creditsTeam": "Team",
"creditsTechnology": "Technology",
"creditsLegal": "Legal",
"creditsBack": "Back to home"
```

Add corresponding Spanish translations to `app_es.arb`.

- [ ] **Step 2: Regenerate localizations**

```bash
cmd.exe /c "flutter gen-l10n"
```

- [ ] **Step 3: Delete old menu screens**

```bash
git rm lib/screens/menu_screen.dart lib/screens/test_menu_screen.dart
```

Remove any imports of these files from other files (check with `flutter analyze`).

- [ ] **Step 4: Add `.superpowers/` to `.gitignore` if not already there**

Already done in a previous commit. Verify:
```bash
grep ".superpowers/" .gitignore
```

- [ ] **Step 5: Final analysis**

```bash
cmd.exe /c "flutter analyze"
```

Fix any remaining issues.

- [ ] **Step 6: Commit**

```bash
git add lib/l10n/ lib/screens/
git commit -m "feat: update localization for new UI and remove old menu screens

Added EN/ES keys for dashboard, config tabs, wizard, pause overlay,
heatmap, history filters, and credits. Removed MenuScreen and
TestMenuScreen (replaced by DashboardScreen)."
```

---

## Task 13: Final Integration Test and Polish

**Files:**
- Various minor fixes across all modified files

- [ ] **Step 1: Run full app analysis**

```bash
cmd.exe /c "flutter analyze"
```

Fix any warnings or errors.

- [ ] **Step 2: Test the full flow on device/emulator**

Run the app:
```bash
cmd.exe /c "flutter run"
```

Verify each flow:
1. Splash → Dashboard (with stats if results exist, welcome if empty)
2. Dashboard → Config (peripheral) → tabs work, wizard works, preview updates, presets work → Start test
3. Test runs with new timer pill + glass controls → Pause (verify new overlay with stats) → Resume → Complete
4. Results screen shows stats + heatmap → Export → Repeat → Home (back to dashboard)
5. History: master-detail layout, search, filter by type, select item, detail shows, export, delete
6. Credits: split layout, branding, team, tech
7. Light/dark theme toggle works throughout
8. Language toggle works (if implemented in dashboard header)

- [ ] **Step 3: Fix any visual issues found during testing**

Adjust spacing, colors, or layout as needed. Common issues:
- Overflow on smaller tablets → add `Flexible` / `Expanded` wrappers
- Text overflow → add `overflow: TextOverflow.ellipsis`
- Colors not matching spec → verify against `OptoColors` values

- [ ] **Step 4: Commit any fixes**

```bash
git add -A
git commit -m "fix: polish UI details and fix layout issues from integration testing"
```

- [ ] **Step 5: Verify timer fix specifically**

Run a peripheral test with 30 seconds configured. Use a real stopwatch to verify it lasts approximately 30 real seconds (±1 second tolerance).

---

## Summary

| Task | Description | Estimated Steps |
|------|-------------|----------------|
| 1 | Fix timer race condition | 5 |
| 2 | Design system theme + colors + spacing | 7 |
| 3 | Design system base components (8 widgets) | 10 |
| 4 | Splash screen | 4 |
| 5 | Dashboard + navigation rewiring | 5 |
| 6 | Test overlay redesign (4 widgets) | 7 |
| 7 | Config screen with tabs + wizard | 9 |
| 8 | Heatmap widget + results redesign | 5 |
| 9 | History master-detail | 7 |
| 10 | Credits redesign | 3 |
| 11 | Screen transitions + staggered animations | 5 |
| 12 | Localization + cleanup | 6 |
| 13 | Integration test + polish | 5 |
| **Total** | | **78 steps** |
