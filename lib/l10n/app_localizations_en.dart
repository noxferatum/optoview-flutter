// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get menuTitle => 'OptoView Menu';

  @override
  String get startTest => 'Start Test';

  @override
  String get configTitle => 'Test Configuration';

  @override
  String get selectSide => 'Stimulus side';

  @override
  String get left => 'Left';

  @override
  String get right => 'Right';

  @override
  String get both => 'Both';

  @override
  String get selectSpeed => 'Stimulus speed';

  @override
  String get slow => 'Slow';

  @override
  String get medium => 'Medium';

  @override
  String get fast => 'Fast';

  @override
  String get selectSymbol => 'Symbol type';

  @override
  String get symbolCircle => 'Circle';

  @override
  String get symbolLetter => 'Letter';

  @override
  String get symbolFace => 'Face';

  @override
  String get runTest => 'Run Test';

  @override
  String get testCompleted => 'Test Completed';

  @override
  String get correctTaps => 'Correct taps';
}
