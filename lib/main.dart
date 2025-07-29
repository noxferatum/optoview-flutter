import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'screens/menu_screen.dart';

void main() {
  runApp(const OptoViewApp());
}

class OptoViewApp extends StatelessWidget {
  const OptoViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OptoView',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
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
    );
  }
}
