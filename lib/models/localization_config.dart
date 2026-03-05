import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'test_config.dart';

/// Modo de juego del test de localización periférica
enum LocalizationMode {
  tocarTodos,
  igualarCentro,
  mismoColor,
  mismaForma;

  String get label => switch (this) {
        tocarTodos => 'Tocar todos',
        igualarCentro => 'Igualar centro',
        mismoColor => 'Mismo color',
        mismaForma => 'Misma forma',
      };

  String get description => switch (this) {
        tocarTodos => 'Toca todos los estímulos que aparezcan',
        igualarCentro => 'Solo toca los que coincidan con el centro',
        mismoColor => 'Solo toca los del mismo color que el centro',
        mismaForma => 'Solo toca los de la misma forma que el centro',
      };
}

/// Modo de desaparición del estímulo
enum DisappearMode {
  porTiempo,
  esperarToque;

  String get label => switch (this) {
        porTiempo => 'Por tiempo',
        esperarToque => 'Esperar toque',
      };
}

/// Configuración completa del test de localización periférica
@immutable
class LocalizationConfig {
  // Compartidos con TestConfig
  final Lado lado;
  final SimboloCategoria categoria;
  final Forma? forma;
  final Velocidad velocidad;
  final int duracionSegundos;
  final double tamanoPorc;
  final double distanciaPct;
  final DistanciaModo distanciaModo;
  final Fondo fondo;
  final bool fondoDistractor;
  final bool fondoDistractorAnimado;

  // Específicos de localización
  final LocalizationMode modo;
  final bool centroFijo;
  final bool feedbackVisual;
  final DisappearMode desaparicion;
  final int stimuliSimultaneos;

  const LocalizationConfig({
    required this.lado,
    required this.categoria,
    this.forma,
    required this.velocidad,
    required this.duracionSegundos,
    required this.tamanoPorc,
    required this.distanciaPct,
    required this.distanciaModo,
    required this.fondo,
    required this.fondoDistractor,
    this.fondoDistractorAnimado = false,
    required this.modo,
    this.centroFijo = true,
    this.feedbackVisual = true,
    this.desaparicion = DisappearMode.porTiempo,
    this.stimuliSimultaneos = 1,
  }) : assert(stimuliSimultaneos >= 1 && stimuliSimultaneos <= 4);

  LocalizationConfig copyWith({
    Lado? lado,
    SimboloCategoria? categoria,
    Forma? forma,
    bool formaSetNull = false,
    Velocidad? velocidad,
    int? duracionSegundos,
    double? tamanoPorc,
    double? distanciaPct,
    DistanciaModo? distanciaModo,
    Fondo? fondo,
    bool? fondoDistractor,
    bool? fondoDistractorAnimado,
    LocalizationMode? modo,
    bool? centroFijo,
    bool? feedbackVisual,
    DisappearMode? desaparicion,
    int? stimuliSimultaneos,
  }) {
    return LocalizationConfig(
      lado: lado ?? this.lado,
      categoria: categoria ?? this.categoria,
      forma: formaSetNull ? null : (forma ?? this.forma),
      velocidad: velocidad ?? this.velocidad,
      duracionSegundos: duracionSegundos ?? this.duracionSegundos,
      tamanoPorc: tamanoPorc ?? this.tamanoPorc,
      distanciaPct: distanciaPct ?? this.distanciaPct,
      distanciaModo: distanciaModo ?? this.distanciaModo,
      fondo: fondo ?? this.fondo,
      fondoDistractor: fondoDistractor ?? this.fondoDistractor,
      fondoDistractorAnimado:
          fondoDistractorAnimado ?? this.fondoDistractorAnimado,
      modo: modo ?? this.modo,
      centroFijo: centroFijo ?? this.centroFijo,
      feedbackVisual: feedbackVisual ?? this.feedbackVisual,
      desaparicion: desaparicion ?? this.desaparicion,
      stimuliSimultaneos: stimuliSimultaneos ?? this.stimuliSimultaneos,
    );
  }

  /// Resumen localizado de la configuración para pantalla de resultados
  Map<String, String> localizedSummary(AppLocalizations l) {
    final modeLabel = switch (modo) {
      LocalizationMode.tocarTodos => l.locModeTouchAll,
      LocalizationMode.igualarCentro => l.locModeMatchCenter,
      LocalizationMode.mismoColor => l.locModeSameColor,
      LocalizationMode.mismaForma => l.locModeSameShape,
    };
    final ladoLabel = switch (lado) {
      Lado.izquierda => l.sideLeft,
      Lado.derecha => l.sideRight,
      Lado.arriba => l.sideTop,
      Lado.abajo => l.sideBottom,
      Lado.ambos => l.sideBoth,
      Lado.aleatorio => l.sideRandom,
    };
    final catLabel = switch (categoria) {
      SimboloCategoria.letras => l.symbolLetters,
      SimboloCategoria.numeros => l.symbolNumbers,
      SimboloCategoria.formas => l.symbolShapes,
    };
    final formaLabel = switch (forma) {
      Forma.circulo => l.formaCircle,
      Forma.cuadrado => l.formaSquare,
      Forma.corazon => l.formaHeart,
      Forma.triangulo => l.formaTriangle,
      Forma.trebol => l.formaClover,
      null => l.symbolFormRandom,
    };
    final stimulusDesc = categoria == SimboloCategoria.formas
        ? '$catLabel ($formaLabel)'
        : catLabel;
    final speedLabel = switch (velocidad) {
      Velocidad.lenta => l.speedSlow,
      Velocidad.media => l.speedMedium,
      Velocidad.rapida => l.speedFast,
    };
    final bgLabel = switch (fondo) {
      Fondo.claro => l.backgroundLight,
      Fondo.oscuro => l.backgroundDark,
      Fondo.azul => l.backgroundBlue,
    };
    String fondoDesc = bgLabel;
    if (fondoDistractor) {
      fondoDesc += fondoDistractorAnimado
          ? l.summaryDistractorAnimated
          : l.summaryDistractor;
    }
    final disappearLabel = switch (desaparicion) {
      DisappearMode.porTiempo => l.locDisappearByTime,
      DisappearMode.esperarToque => l.locDisappearWaitTouch,
    };

    return {
      l.summaryKeyMode: modeLabel,
      l.summaryKeySide: ladoLabel,
      l.summaryKeyStimulus: stimulusDesc,
      l.summaryKeySpeed: speedLabel,
      l.summaryKeyDistance: distanciaModo == DistanciaModo.aleatorio
          ? l.summaryDistRandom
          : '${distanciaPct.toStringAsFixed(0)}%',
      l.summaryKeySize: '${tamanoPorc.toStringAsFixed(0)}%',
      l.summaryKeyDuration: '${duracionSegundos}s',
      l.summaryKeyBackground: fondoDesc,
      l.summaryKeyCenter: centroFijo ? l.summaryCenterFixed : l.summaryCenterChanging,
      l.summaryKeyFeedback: feedbackVisual ? l.summaryYes : l.summaryNo,
      l.summaryKeyDisappear: disappearLabel,
      l.summaryKeySimultaneous: '$stimuliSimultaneos',
    };
  }
}
