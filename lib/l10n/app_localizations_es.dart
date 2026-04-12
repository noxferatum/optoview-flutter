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
  String get testPaused => 'Test en pausa';

  @override
  String get testPauseHint => 'El test se reanudará exactamente donde lo dejaste.';

  @override
  String get testStatRemaining => 'Restante';

  @override
  String get testStatElapsed => 'Transcurrido';

  @override
  String get testStatStimuli => 'Estímulos';

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
  String get summaryKeyInteraction => 'Interacción';

  @override
  String get summaryKeyVisualization => 'Visualización';

  @override
  String get summaryKeyDirection => 'Dirección';

  @override
  String get summaryKeyRings => 'Anillos';

  @override
  String get summaryKeyLettersPerRing => 'Letras/anillo';

  @override
  String get summaryKeyRandomLetters => 'Letras aleatorias';

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
  String get testMacdonaldTitle => 'Carta MacDonald';

  @override
  String get testMacdonaldSubtitle => 'Entrena la visión periférica con letras en anillos.';

  @override
  String get configMacdonaldTitle => 'Test Carta MacDonald';

  @override
  String get macInteractionTitle => 'Modo de interacción';

  @override
  String get macInteractionTouch => 'Tocar letras';

  @override
  String get macInteractionTouchDesc => 'Toca cada letra conforme la veas';

  @override
  String get macInteractionTimed => 'Lectura con tiempo';

  @override
  String get macInteractionTimedDesc => 'Lee en voz alta con cronómetro';

  @override
  String get macInteractionSequential => 'Lectura secuencial';

  @override
  String get macInteractionSequentialDesc => 'La app resalta letras una a una, tú las lees';

  @override
  String get macInteractionFieldDetection => 'Detección de campo';

  @override
  String get macInteractionFieldDetectionDesc => 'Las letras aparecen una a una en posiciones aleatorias. Toca cada letra antes de que desaparezca';

  @override
  String get macVisualizationTitle => 'Modo de visualización';

  @override
  String get macVisualizationComplete => 'Completa';

  @override
  String get macVisualizationCompleteDesc => 'Todas las letras visibles desde el inicio';

  @override
  String get macVisualizationProgressive => 'Progresiva';

  @override
  String get macVisualizationProgressiveDesc => 'Las letras aparecen una a una';

  @override
  String get macVisualizationByRings => 'Por anillos';

  @override
  String get macVisualizationByRingsDesc => 'Las letras aparecen anillo por anillo';

  @override
  String get macDirectionTitle => 'Dirección de lectura';

  @override
  String get macDirectionCenterOut => 'Centro → Afuera';

  @override
  String get macDirectionOutCenter => 'Afuera → Centro';

  @override
  String get macDirectionClockwise => 'Horario';

  @override
  String get macDirectionCounterClockwise => 'Antihorario';

  @override
  String get macContentTitle => 'Tipo de contenido';

  @override
  String get macContentLetters => 'Letras';

  @override
  String get macContentNumbers => 'Números';

  @override
  String get summaryKeyContent => 'Contenido';

  @override
  String get macRingsTitle => 'Número de anillos';

  @override
  String get macLettersPerRingTitle => 'Letras por anillo (primer anillo)';

  @override
  String get macRandomLetters => 'Letras aleatorias';

  @override
  String get macRandomLettersSubtitle => 'Si se desactiva, se usa la secuencia A-Z';

  @override
  String get macRevealSpeedTitle => 'Velocidad de revelado';

  @override
  String get resultsMacTitle => 'Resultados - Carta MacDonald';

  @override
  String get macStatsRingsCompleted => 'Anillos completados';

  @override
  String get macStatsTimePerRing => 'Tiempo por anillo';

  @override
  String get macStatsLettersShown => 'Letras mostradas';

  @override
  String get macStatsAvgPerRing => 'Promedio por anillo';

  @override
  String get presetMacStandardDesc => 'Por anillos, lectura con tiempo';

  @override
  String get presetMacEasyDesc => 'Tocar letras, todo visible, lento';

  @override
  String get presetMacAdvancedDesc => 'Secuencial, progresiva, rápido';

  @override
  String get presetMacFieldDetectionDesc => 'Detección de campo visual, toca letras';

  @override
  String get macHitMapTitle => 'Mapa de aciertos';

  @override
  String get macMissMapTitle => 'Mapa de fallos';

  @override
  String get macNextRing => 'Siguiente anillo';

  @override
  String macRingLabel(int number) {
    return 'Anillo $number';
  }

  @override
  String get patientName => 'Nombre del paciente';

  @override
  String get patientNameHint => 'Introduce el nombre del paciente';

  @override
  String get menuHistory => 'Historial';

  @override
  String get historyTitle => 'Historial de resultados';

  @override
  String get historyEmpty => 'Aún no hay resultados guardados.';

  @override
  String get historyClearAll => 'Borrar todo';

  @override
  String get historyClearAllTitle => 'Eliminar todos los resultados';

  @override
  String get historyClearAllMessage => 'Se eliminarán todos los resultados guardados de forma permanente. Esta acción no se puede deshacer.';

  @override
  String get historyClearAllConfirm => 'Eliminar todo';

  @override
  String get historyCancel => 'Cancelar';

  @override
  String get historyDelete => 'Eliminar';

  @override
  String get historyDeleteTitle => 'Eliminar resultado';

  @override
  String get historyDeleteMessage => '¿Seguro que quieres eliminar este resultado?';

  @override
  String get historyDetailTitle => 'Detalles del resultado';

  @override
  String get historyTestPeripheral => 'Estimulación periférica';

  @override
  String get historyTestLocalization => 'Localización periférica';

  @override
  String get historyTestMacdonald => 'Carta MacDonald';

  @override
  String get historySearchHint => 'Buscar por paciente o test...';

  @override
  String get historyNoResults => 'Sin resultados para esta búsqueda.';

  @override
  String get historyUnnamedPatient => 'Sin nombre';

  @override
  String historyResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resultados',
      one: '1 resultado',
    );
    return '$_temp0';
  }

  @override
  String get historyGroupByPatient => 'Por paciente';

  @override
  String get historyOrderByDate => 'Por fecha';

  @override
  String get themeDark => 'Modo noche';

  @override
  String get themeLight => 'Modo día';

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

  @override
  String get instructionsTitle => 'Instrucciones';

  @override
  String get instructionsStart => 'Empezar';

  @override
  String get showInstructions => 'Mostrar instrucciones';

  @override
  String get showInstructionsSubtitle => 'Muestra un texto explicativo antes de iniciar la prueba';

  @override
  String get instructFixation => 'Mantén la mirada en el punto de fijación central';

  @override
  String instructStimuliSide(String side) {
    return 'Los estímulos aparecerán en: $side';
  }

  @override
  String instructStimuliType(String type) {
    return 'Tipo de estímulo: $type';
  }

  @override
  String instructSpeed(String speed) {
    return 'Velocidad: $speed';
  }

  @override
  String instructDuration(int duration) {
    return 'Duración: $duration segundos';
  }

  @override
  String get instructLocTouchAll => 'Toca todos los estímulos que aparezcan';

  @override
  String get instructLocMatchCenter => 'Toca solo los que coincidan con el estímulo central';

  @override
  String get instructLocSameColor => 'Toca solo los del mismo color que el centro';

  @override
  String get instructLocSameShape => 'Toca solo los de la misma forma que el centro';

  @override
  String get instructLocFeedback => 'Verás un indicador visual de acierto o error al tocar';

  @override
  String instructLocSimultaneous(int count) {
    return 'Aparecerán $count estímulos a la vez';
  }

  @override
  String get instructMacTouch => 'Toca cada letra en el orden en que aparecen';

  @override
  String get instructMacTimed => 'Lee las letras en voz alta lo más rápido posible';

  @override
  String get instructMacSequential => 'Lee cada letra cuando se resalte en la pantalla';

  @override
  String get instructMacFieldDetection => 'Toca cada letra antes de que desaparezca. Aparecerán en posiciones aleatorias';

  @override
  String get instructMacVisComplete => 'Todas las letras serán visibles desde el inicio';

  @override
  String get instructMacVisProgressive => 'Las letras irán apareciendo una a una';

  @override
  String get instructMacVisByRings => 'Las letras aparecerán anillo por anillo';

  @override
  String instructMacContent(String content) {
    return 'Contenido: $content';
  }

  @override
  String get exportPdf => 'PDF';

  @override
  String get exportExcel => 'Excel';

  @override
  String get exportCsv => 'CSV';

  @override
  String get exportPatientSummary => 'Exportar resumen';

  @override
  String get exportSelectPatient => 'Selecciona un paciente';

  @override
  String get exportReportTitle => 'Informe OptoView';

  @override
  String exportReportGenerated(String date) {
    return 'Informe generado el $date';
  }

  @override
  String get exportNoResults => 'No hay resultados para exportar';

  @override
  String exportPatientReport(String name) {
    return 'Resumen del paciente: $name';
  }

  @override
  String get exportTestDate => 'Fecha';

  @override
  String get exportTestType => 'Tipo de test';

  @override
  String get exportAccuracy => 'Precisión';

  @override
  String get exportDuration => 'Duración';

  @override
  String get exportReactionTime => 'T. reacción';

  @override
  String get backupExport => 'Exportar backup';

  @override
  String get backupExportTooltip => 'Exportar todos los resultados como JSON';

  @override
  String get backupImport => 'Importar backup';

  @override
  String get backupImportTooltip => 'Importar resultados desde archivo JSON';

  @override
  String backupExportSuccess(int count) {
    return 'Backup exportado con $count resultados';
  }

  @override
  String backupImportSuccess(int count) {
    return 'Se importaron $count resultados nuevos';
  }

  @override
  String get backupImportNone => 'No se encontraron resultados nuevos para importar';

  @override
  String get backupImportError => 'Error al leer el archivo de backup';

  @override
  String get backupNoResults => 'No hay resultados para exportar';

  @override
  String get renameTitle => 'Renombrar paciente';

  @override
  String get renameHint => 'Nuevo nombre del paciente';

  @override
  String get renameSave => 'Guardar';

  @override
  String get renameSuccess => 'Nombre actualizado';
}
