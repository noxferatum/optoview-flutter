import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'macdonald_config.dart' show MacContenido;
import 'test_config.dart';

/// Configuración del test de Detección de Campo.
///
/// Es deliberadamente fija (constante `standard`) — no hay presets editables.
/// El test es estandarizado para que los resultados sean comparables entre
/// pacientes.
@immutable
class FieldDetectionConfig {
  final int numAnillos;
  final int letrasPorAnilloBase;
  final double tamanoBase;
  final Velocidad velocidad;
  final MacContenido contenido;
  final Fondo fondo;
  final Fijacion fijacion;
  final EstimuloColor colorLetras;
  final bool letrasAleatorias;

  const FieldDetectionConfig({
    required this.numAnillos,
    required this.letrasPorAnilloBase,
    required this.tamanoBase,
    required this.velocidad,
    required this.contenido,
    required this.fondo,
    required this.fijacion,
    required this.colorLetras,
    required this.letrasAleatorias,
  });

  /// Configuración estándar única del test.
  static const FieldDetectionConfig standard = FieldDetectionConfig(
    numAnillos: 4,
    letrasPorAnilloBase: 8,
    tamanoBase: 24,
    velocidad: Velocidad.lenta,
    contenido: MacContenido.letras,
    fondo: Fondo.oscuro,
    fijacion: Fijacion.punto,
    colorLetras: EstimuloColor.blanco,
    letrasAleatorias: true,
  );

  /// Total de letras que se mostrarán en el test (suma de letras por anillo).
  /// Cada anillo tiene `letrasPorAnilloBase + 2 * ringIndex` letras.
  int get totalLetras {
    int total = 0;
    for (int r = 0; r < numAnillos; r++) {
      total += letrasPorAnilloBase + 2 * r;
    }
    return total;
  }

  Map<String, String> localizedSummary(AppLocalizations l) {
    final speedLabel = switch (velocidad) {
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
    final contentLabel = switch (contenido) {
      MacContenido.letras => l.macContentLetters,
      MacContenido.numeros => l.macContentNumbers,
    };
    return {
      l.summaryKeyContent: contentLabel,
      l.summaryKeyRings: '$numAnillos',
      l.summaryKeyLettersPerRing: '$letrasPorAnilloBase',
      l.summaryKeySize: '${tamanoBase.toStringAsFixed(0)}%',
      l.summaryKeySpeed: speedLabel,
      l.summaryKeyFixation: fixLabel,
      l.summaryKeyBackground: bgLabel,
      l.summaryKeyColor: colorLabel,
    };
  }
}
