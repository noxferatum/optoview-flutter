import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'screens/menu_screen.dart';
import 'theme/opto_theme.dart';

/// Notificador global de tema. Accesible desde cualquier pantalla.
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

const _themeKey = 'app_theme_mode';

Future<void> _loadThemePreference() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_themeKey);
    if (name == 'light') themeNotifier.value = ThemeMode.light;
  } catch (_) {}
}

Future<void> saveThemePreference(ThemeMode mode) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode == ThemeMode.light ? 'light' : 'dark');
  } catch (_) {}
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _loadThemePreference();
  runApp(const OptoViewApp());
}

class OptoViewApp extends StatelessWidget {
  const OptoViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) => MaterialApp(
        title: 'OptoView',
        debugShowCheckedModeBanner: false,
        themeMode: mode,
        darkTheme: OptoTheme.dark(),
        theme: OptoTheme.light(),
        home: const MenuScreen(),
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
      ),
    );
  }
}
