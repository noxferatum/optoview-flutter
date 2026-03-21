import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../main.dart' show themeNotifier, saveThemePreference;
import 'credits_screen.dart';
import 'history_screen.dart';
import 'test_menu_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.menuTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDark ? l.themeLight : l.themeDark,
            onPressed: () {
              final newMode =
                  isDark ? ThemeMode.light : ThemeMode.dark;
              themeNotifier.value = newMode;
              saveThemePreference(newMode);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: FractionallySizedBox(
                widthFactor: 0.7,
                child: Image.asset('assets/images/logo.png'),
              ),
            ),
            const SizedBox(height: 48),
            Semantics(
              button: true,
              label: l.menuStart,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TestMenuScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: Text(l.menuStart),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              button: true,
              label: l.menuHistory,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  );
                },
                icon: const Icon(Icons.history),
                label: Text(l.menuHistory),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              button: true,
              label: l.menuCredits,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreditsScreen()),
                  );
                },
                icon: const Icon(Icons.info_outline),
                label: Text(l.menuCredits),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
