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
