import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'test_config.dart';

/// Modo de interacción del test Carta MacDonald
enum MacInteraccion {
  tocarLetras,
  lecturaConTiempo,
  lecturaSecuencial;
}

/// Modo de visualización del test Carta MacDonald
enum MacVisualizacion {
  completa,
  progresiva,
  porAnillos;
}

/// Dirección de lectura/revelado
enum MacDireccion {
  centroAfuera,
  afueraCentro,
  horario,
  antihorario;
}

/// Configuración completa del test Carta MacDonald
@immutable
class MacDonaldConfig {
  final MacInteraccion interaccion;
  final MacVisualizacion visualizacion;
  final MacDireccion direccion;
  final int numAnillos;
  final int letrasPorAnillo;
  final int duracionSegundos;
  final Fondo fondo;
  final Fijacion fijacion;
  final EstimuloColor colorLetras;
  final double tamanoBase;
  final Velocidad velocidadRevelado;
  final bool letrasAleatorias;

  const MacDonaldConfig({
    required this.interaccion,
    required this.visualizacion,
    required this.direccion,
    required this.numAnillos,
    required this.letrasPorAnillo,
    required this.duracionSegundos,
    required this.fondo,
    required this.fijacion,
    required this.colorLetras,
    required this.tamanoBase,
    required this.velocidadRevelado,
    this.letrasAleatorias = true,
  });

  MacDonaldConfig copyWith({
    MacInteraccion? interaccion,
    MacVisualizacion? visualizacion,
    MacDireccion? direccion,
    int? numAnillos,
    int? letrasPorAnillo,
    int? duracionSegundos,
    Fondo? fondo,
    Fijacion? fijacion,
    EstimuloColor? colorLetras,
    double? tamanoBase,
    Velocidad? velocidadRevelado,
    bool? letrasAleatorias,
  }) {
    return MacDonaldConfig(
      interaccion: interaccion ?? this.interaccion,
      visualizacion: visualizacion ?? this.visualizacion,
      direccion: direccion ?? this.direccion,
      numAnillos: numAnillos ?? this.numAnillos,
      letrasPorAnillo: letrasPorAnillo ?? this.letrasPorAnillo,
      duracionSegundos: duracionSegundos ?? this.duracionSegundos,
      fondo: fondo ?? this.fondo,
      fijacion: fijacion ?? this.fijacion,
      colorLetras: colorLetras ?? this.colorLetras,
      tamanoBase: tamanoBase ?? this.tamanoBase,
      velocidadRevelado: velocidadRevelado ?? this.velocidadRevelado,
      letrasAleatorias: letrasAleatorias ?? this.letrasAleatorias,
    );
  }

  Map<String, String> localizedSummary(AppLocalizations l) {
    final interLabel = switch (interaccion) {
      MacInteraccion.tocarLetras => l.macInteractionTouch,
      MacInteraccion.lecturaConTiempo => l.macInteractionTimed,
      MacInteraccion.lecturaSecuencial => l.macInteractionSequential,
    };
    final visLabel = switch (visualizacion) {
      MacVisualizacion.completa => l.macVisualizationComplete,
      MacVisualizacion.progresiva => l.macVisualizationProgressive,
      MacVisualizacion.porAnillos => l.macVisualizationByRings,
    };
    final dirLabel = switch (direccion) {
      MacDireccion.centroAfuera => l.macDirectionCenterOut,
      MacDireccion.afueraCentro => l.macDirectionOutCenter,
      MacDireccion.horario => l.macDirectionClockwise,
      MacDireccion.antihorario => l.macDirectionCounterClockwise,
    };
    final speedLabel = switch (velocidadRevelado) {
      Velocidad.lenta => l.speedSlow,
      Velocidad.media => l.speedMedium,
      Velocidad.rapida => l.speedFast,
    };
    final fixLabel = switch (fijacion) {
      Fijacion.cara => l.fixationFace,
      Fijacion.ojo => l.fixationEye,
      Fijacion.punto => l.fixationDot,
      Fijacion.trebol => l.fixationClover,
      Fijacion.cruz => l.fixationCross,
    };
    final bgLabel = switch (fondo) {
      Fondo.claro => l.backgroundLight,
      Fondo.oscuro => l.backgroundDark,
      Fondo.azul => l.backgroundBlue,
    };
    final colorLabel = switch (colorLetras) {
      EstimuloColor.rojo => l.colorRed,
      EstimuloColor.verde => l.colorGreen,
      EstimuloColor.azul => l.colorBlue,
      EstimuloColor.amarillo => l.colorYellow,
      EstimuloColor.blanco => l.colorWhite,
      EstimuloColor.morado => l.colorPurple,
      EstimuloColor.negro => l.colorBlack,
      EstimuloColor.aleatorio => l.colorRandom,
    };
    return {
      l.summaryKeyInteraction: interLabel,
      l.summaryKeyVisualization: visLabel,
      l.summaryKeyDirection: dirLabel,
      l.summaryKeyRings: '$numAnillos',
      l.summaryKeyLettersPerRing: '$letrasPorAnillo',
      l.summaryKeyDuration: '${duracionSegundos}s',
      l.summaryKeySize: '${tamanoBase.toStringAsFixed(0)}%',
      l.summaryKeySpeed: speedLabel,
      l.summaryKeyFixation: fixLabel,
      l.summaryKeyBackground: bgLabel,
      l.summaryKeyColor: colorLabel,
      l.summaryKeyRandomLetters: letrasAleatorias ? l.summaryYes : l.summaryNo,
    };
  }
}
