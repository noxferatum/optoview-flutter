import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optoview_flutter/l10n/app_localizations.dart';
import 'package:optoview_flutter/screens/questionnaire_form_screen.dart';

Widget _harness(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('es'),
    home: child,
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Form renders with title and save button', (tester) async {
    await tester.pumpWidget(_harness(const QuestionnaireFormScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Cuestionario CVS-Q'), findsWidgets);
    expect(find.text('Guardar'), findsOneWidget);
  });

  testWidgets('Save button is a no-op until 16 CVS-Q items are answered', (tester) async {
    await tester.pumpWidget(_harness(const QuestionnaireFormScreen()));
    await tester.pumpAndSettle();
    // Tap save; nothing changes, no snackbar.
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Cuestionario guardado'), findsNothing);
  });

  testWidgets('Selecting "Nunca" disables intensity control via IgnorePointer', (tester) async {
    await tester.pumpWidget(_harness(const QuestionnaireFormScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nunca').first);
    await tester.pumpAndSettle();

    // Find the first IgnorePointer that is an ancestor of the first "Moderado" label.
    final ignorePointer = find
        .ancestor(
          of: find.text('Moderado').first,
          matching: find.byType(IgnorePointer),
        )
        .first;
    final ip = tester.widget<IgnorePointer>(ignorePointer);
    expect(ip.ignoring, isTrue);
  });
}
