// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'OptoView';

  @override
  String get menuTitle => 'OptoViewApp - Menú';

  @override
  String get menuStart => 'Iniciar';

  @override
  String get menuCredits => 'Créditos';

  @override
  String get testMenuTitle => 'Elige un ejercicio';

  @override
  String get testPeripheralTitle => 'Estimulación periférica';

  @override
  String get testPeripheralSubtitle => 'Entrena la percepción periférica dinámica.';

  @override
  String get testLocalizationTitle => 'Localización periférica';

  @override
  String get testLocalizationSubtitle => 'Entrena la localización periférica.';

  @override
  String get testComingSoonTitle => 'Próximamente más';

  @override
  String get testComingSoonSubtitle => 'Nuevos protocolos de evaluación.';

  @override
  String get testComingSoonSnackbar => 'Estamos trabajando en más tests especializados.';

  @override
  String get configPeripheralTitle => 'Test de estimulación periférica';

  @override
  String get configLocalizationTitle => 'Test de localización periférica';

  @override
  String get startTest => 'Iniciar prueba';

  @override
  String get presetsTitle => 'Presets';

  @override
  String get presetsHint => 'Selecciona un preset o personaliza cada opción abajo.';

  @override
  String get presetStandard => 'Estándar';

  @override
  String get presetStandardDesc => 'Configuración equilibrada para uso general';

  @override
  String get presetEasy => 'Fácil';

  @override
  String get presetEasyDesc => 'Estímulos grandes y lentos, ideal para inicio';

  @override
  String get presetAdvanced => 'Avanzado';

  @override
  String get presetAdvancedDesc => 'Estímulos rápidos, pequeños y con distractores';

  @override
  String get presetLocStandardDesc => 'Igualar centro, velocidad media';

  @override
  String get presetLocEasyDesc => 'Tocar todos, lento, con feedback';

  @override
  String get presetLocAdvancedDesc => 'Misma forma, rápido, sin feedback, 3 estímulos';

  @override
  String get sideTitle => 'Lado de estimulación';

  @override
  String get sideLeft => 'Izquierda';

  @override
  String get sideRight => 'Derecha';

  @override
  String get sideTop => 'Arriba';

  @override
  String get sideBottom => 'Abajo';

  @override
  String get sideBoth => 'Ambos';

  @override
  String get sideRandom => 'Aleatorio';

  @override
  String get sideDescLeft => 'Los estímulos aparecerán únicamente en el lado izquierdo de la pantalla.';

  @override
  String get sideDescRight => 'Los estímulos aparecerán únicamente en el lado derecho de la pantalla.';

  @override
  String get sideDescTop => 'Los estímulos aparecerán únicamente en la parte superior.';

  @override
  String get sideDescBottom => 'Los estímulos aparecerán únicamente en la parte inferior.';

  @override
  String get sideDescBoth => 'Los estímulos podrán aparecer en ambos lados.';

  @override
  String get sideDescRandom => 'El lado de aparición de los estímulos será aleatorio en cada ciclo.';

  @override
  String get symbolTitle => 'Tipo de estímulo';

  @override
  String get symbolLetters => 'Letras';

  @override
  String get symbolNumbers => 'Números';

  @override
  String get symbolShapes => 'Formas';

  @override
  String get symbolFormTitle => 'Forma (opcional)';

  @override
  String get symbolFormRandom => 'Aleatoria';

  @override
  String get formaCircle => 'Círculo';

  @override
  String get formaSquare => 'Cuadrado';

  @override
  String get formaHeart => 'Corazón';

  @override
  String get formaTriangle => 'Triángulo';

  @override
  String get formaClover => 'Trébol';

  @override
  String get colorTitle => 'Color del estímulo';

  @override
  String get colorRed => 'Rojo';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorBlue => 'Azul';

  @override
  String get colorYellow => 'Amarillo';

  @override
  String get colorWhite => 'Blanco';

  @override
  String get colorPurple => 'Morado';

  @override
  String get colorBlack => 'Negro';

  @override
  String get colorRandom => 'Aleatorio';

  @override
  String get speedTitle => 'Velocidad';

  @override
  String get speedSlow => 'Lenta';

  @override
  String get speedMedium => 'Media';

  @override
  String get speedFast => 'Rápida';

  @override
  String get movementTitle => 'Movimiento del estímulo';

  @override
  String get movementFixed => 'Fijo';

  @override
  String get movementHorizontal => 'Horizontal';

  @override
  String get movementVertical => 'Vertical';

  @override
  String get movementRandom => 'Aleatorio';

  @override
  String get movementDescFixed => 'El estímulo permanece estático en su posición.';

  @override
  String get movementDescHorizontal => 'El estímulo se desliza de izquierda a derecha o viceversa.';

  @override
  String get movementDescVertical => 'El estímulo se desliza de arriba a abajo o viceversa.';

  @override
  String get movementDescRandom => 'El estímulo cambia aleatoriamente entre desplazamiento horizontal y vertical.';

  @override
  String get distanceTitle => 'Distancia al centro';

  @override
  String get distanceRandom => 'Aleatoria';

  @override
  String get distanceRandomSubtitle => 'Cambia aleatoriamente la distancia del estímulo';

  @override
  String get distanceFixed => 'Fija';

  @override
  String distanceCurrent(String pct) {
    return 'Distancia actual: $pct%';
  }

  @override
  String get durationTitle => 'Duración (segundos)';

  @override
  String durationLabel(int value) {
    return '$value s';
  }

  @override
  String get sizeTitle => 'Tamaño (%)';

  @override
  String get sizeRandomToggle => 'Variar tamaño aleatoriamente';

  @override
  String get sizeRandomSubtitle => 'Si se activa, cada estímulo ajustará su tamaño alrededor del valor configurado.';

  @override
  String get fixationTitle => 'Punto de fijación';

  @override
  String get fixationFace => 'Cara';

  @override
  String get fixationEye => 'Ojo';

  @override
  String get fixationDot => 'Punto';

  @override
  String get fixationClover => 'Trébol';

  @override
  String get fixationCross => 'Cruz';

  @override
  String get backgroundTitle => 'Fondo y distractor';

  @override
  String get backgroundLight => 'Claro';

  @override
  String get backgroundDark => 'Oscuro';

  @override
  String get backgroundBlue => 'Azul';

  @override
  String get backgroundDistractor => 'Fondo distractor';

  @override
  String get backgroundDistractorSubtitle => 'Añade un patrón suave de baja intensidad.';

  @override
  String get backgroundAnimate => 'Animar distractor';

  @override
  String get backgroundAnimateSubtitle => 'Activa un movimiento leve del patrón para aumentar la dificultad visual.';

  @override
  String get locModeTitle => 'Modo de localización';

  @override
  String get locModeTouchAll => 'Tocar todos';

  @override
  String get locModeMatchCenter => 'Igualar centro';

  @override
  String get locModeSameColor => 'Mismo color';

  @override
  String get locModeSameShape => 'Misma forma';

  @override
  String get locModeTouchAllDesc => 'Toca todos los estímulos que aparezcan';

  @override
  String get locModeMatchCenterDesc => 'Solo toca los que coincidan con el centro';

  @override
  String get locModeSameColorDesc => 'Solo toca los del mismo color que el centro';

  @override
  String get locModeSameShapeDesc => 'Solo toca los de la misma forma que el centro';

  @override
  String get locInteractionTitle => 'Opciones de interacción';

  @override
  String get locCenterFixed => 'Centro fijo';

  @override
  String get locCenterFixedOn => 'El estímulo central no cambia durante la prueba';

  @override
  String get locCenterFixedOff => 'El estímulo central cambia cada ciclo';

  @override
  String get locFeedback => 'Feedback visual';

  @override
  String get locFeedbackSubtitle => 'Mostrar indicación visual al tocar (acierto/error)';

  @override
  String get locDisappearTitle => 'Desaparición del estímulo';

  @override
  String get locDisappearByTime => 'Por tiempo';

  @override
  String get locDisappearWaitTouch => 'Esperar toque';

  @override
  String get locSimultaneousTitle => 'Estímulos simultáneos';

  @override
  String testTimeRemaining(int seconds) {
    return 'Tiempo restante: $seconds s';
  }

  @override
  String testTimeAndHits(int seconds, int hits) {
    return 'Tiempo: $seconds s  |  Aciertos: $hits';
  }

  @override
  String get testPause => 'Pausar';

  @override
  String get testResume => 'Reanudar';

  @override
  String get testStop => 'Terminar';

  @override
  String get testPaused => 'PRUEBA EN PAUSA';

  @override
  String get countdownReady => '¡Prepárate!';

  @override
  String get resultsTitle => 'Resultados de la prueba';

  @override
  String get resultsLocTitle => 'Resultados - Localización';

  @override
  String get resultsCompleted => 'Prueba completada';

  @override
  String get resultsStopped => 'Prueba detenida';

  @override
  String get statsTitle => 'Estadísticas';

  @override
  String get statsActualDuration => 'Duración real';

  @override
  String get statsConfigDuration => 'Duración configurada';

  @override
  String get statsStimuliShown => 'Estímulos mostrados';

  @override
  String get statsStimuliPerMinute => 'Estímulos/minuto';

  @override
  String get accuracyTitle => 'Precisión';

  @override
  String get accuracyCorrect => 'Aciertos';

  @override
  String get accuracyErrors => 'Errores';

  @override
  String get accuracyMissed => 'Omisiones';

  @override
  String get accuracyPercent => '% de acierto';

  @override
  String get reactionTitle => 'Tiempo de reacción';

  @override
  String get reactionAvg => 'Promedio';

  @override
  String get reactionBest => 'Mejor';

  @override
  String get reactionWorst => 'Peor';

  @override
  String get configUsedTitle => 'Configuración usada';

  @override
  String get resultsRepeat => 'Repetir prueba';

  @override
  String get resultsHome => 'Volver al menú';

  @override
  String get summaryKeySide => 'Lado';

  @override
  String get summaryKeyStimulus => 'Estímulo';

  @override
  String get summaryKeyColor => 'Color';

  @override
  String get summaryKeySpeed => 'Velocidad';

  @override
  String get summaryKeyMovement => 'Movimiento';

  @override
  String get summaryKeyDistance => 'Distancia';

  @override
  String get summaryKeySize => 'Tamaño';

  @override
  String get summaryKeyDuration => 'Duración';

  @override
  String get summaryKeyFixation => 'Fijación';

  @override
  String get summaryKeyBackground => 'Fondo';

  @override
  String get summaryKeyMode => 'Modo';

  @override
  String get summaryKeyCenter => 'Centro';

  @override
  String get summaryKeyFeedback => 'Feedback';

  @override
  String get summaryKeyDisappear => 'Desaparición';

  @override
  String get summaryKeySimultaneous => 'Estímulos simultáneos';

  @override
  String get summaryDistRandom => 'Aleatoria';

  @override
  String summarySizeRandom(String pct) {
    return '~$pct% (aleatorio)';
  }

  @override
  String get summaryDistractorAnimated => ' + Distractor animado';

  @override
  String get summaryDistractor => ' + Distractor';

  @override
  String get summaryCenterFixed => 'Fijo';

  @override
  String get summaryCenterChanging => 'Cambiante';

  @override
  String get summaryYes => 'Sí';

  @override
  String get summaryNo => 'No';

  @override
  String get creditsTitle => 'Créditos';

  @override
  String get creditsAppName => 'Optoview';

  @override
  String get creditsDescription => 'Esta aplicación ha sido desarrollada con la ayuda de la optometrista titulada experta en terapia visual\nEstefanía Rodríguez-Bobada Lillo.';

  @override
  String get creditsCompany => 'Empresa';

  @override
  String get creditsYear => 'Año';

  @override
  String get creditsVersion => 'Versión';

  @override
  String get creditsBack => 'Volver';
}
