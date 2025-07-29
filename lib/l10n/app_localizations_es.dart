// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get menuTitle => 'Menú OptoView';

  @override
  String get startTest => 'Iniciar prueba';

  @override
  String get configTitle => 'Configuración de prueba';

  @override
  String get selectSide => 'Lado del estímulo';

  @override
  String get left => 'Izquierda';

  @override
  String get right => 'Derecha';

  @override
  String get both => 'Ambos';

  @override
  String get selectSpeed => 'Velocidad del estímulo';

  @override
  String get slow => 'Lenta';

  @override
  String get medium => 'Media';

  @override
  String get fast => 'Rápida';

  @override
  String get selectSymbol => 'Tipo de símbolo';

  @override
  String get symbolCircle => 'Círculo';

  @override
  String get symbolLetter => 'Letra';

  @override
  String get symbolFace => 'Cara';

  @override
  String get runTest => 'Ejecutar prueba';

  @override
  String get testCompleted => 'Prueba completada';

  @override
  String get correctTaps => 'Toques correctos';
}
