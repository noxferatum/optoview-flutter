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
