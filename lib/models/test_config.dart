import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../l10n/app_localizations.dart';

/// Enumeraciones principales de la prueba
enum Lado {
  izquierda,
  derecha,
  arriba,
  abajo,
  ambos,
  aleatorio;

  String get label => switch (this) {
        izquierda => 'Izquierda',
        derecha => 'Derecha',
        arriba => 'Arriba',
        abajo => 'Abajo',
        ambos => 'Ambos',
        aleatorio => 'Aleatorio',
      };
}

enum SimboloCategoria {
  letras,
  numeros,
  formas;

  String get label => switch (this) {
        letras => 'Letras',
        numeros => 'Números',
        formas => 'Formas',
      };
}

enum Forma {
  circulo,
  cuadrado,
  corazon,
  triangulo,
  trebol;

  String get label => switch (this) {
        circulo => 'Círculo',
        cuadrado => 'Cuadrado',
        corazon => 'Corazón',
        triangulo => 'Triángulo',
        trebol => 'Trébol',
      };
}

enum Velocidad {
  lenta,
  media,
  rapida;

  String get label => switch (this) {
        lenta => 'Lenta',
        media => 'Media',
        rapida => 'Rápida',
      };

  int get milliseconds => switch (this) {
        lenta => 2500,
        media => 1800,
        rapida => 1200,
      };
}

/// Modos de movimiento soportados
enum Movimiento {
  fijo,
  horizontal,
  vertical,
  aleatorio;

  String get label => switch (this) {
        fijo => 'Fijo',
        horizontal => 'Horizontal',
        vertical => 'Vertical',
        aleatorio => 'Aleatorio',
      };
}

enum DistanciaModo {
  fijo,
  aleatorio;

  String get label => switch (this) {
        fijo => 'Fija',
        aleatorio => 'Aleatoria',
      };
}

enum Fijacion {
  cara,
  ojo,
  punto,
  trebol,
  cruz;

  String get label => switch (this) {
        cara => 'Cara',
        ojo => 'Ojo',
        punto => 'Punto',
        trebol => 'Trébol',
        cruz => 'Cruz',
      };
}

enum Fondo {
  claro,
  oscuro,
  azul;

  String get label => switch (this) {
        claro => 'Claro',
        oscuro => 'Oscuro',
        azul => 'Azul',
      };
}

extension FondoTheme on Fondo {
  Color get baseColor => switch (this) {
        Fondo.claro => Colors.white,
        Fondo.oscuro => Colors.black,
        Fondo.azul => AppConstants.optoviewBlue,
      };

  Color get patternColor => switch (this) {
        Fondo.claro => Colors.black,
        Fondo.oscuro => Colors.white,
        Fondo.azul => AppConstants.optoviewBluePattern,
      };

  bool get isDark => this == Fondo.oscuro || this == Fondo.azul;
}

enum EstimuloColor {
  rojo,
  verde,
  azul,
  amarillo,
  blanco,
  morado,
  negro,
  aleatorio;

  String get label => switch (this) {
        rojo => 'Rojo',
        verde => 'Verde',
        azul => 'Azul',
        amarillo => 'Amarillo',
        blanco => 'Blanco',
        morado => 'Morado',
        negro => 'Negro',
        aleatorio => 'Aleatorio',
      };
}

extension EstimuloColorTheme on EstimuloColor {
  static const List<EstimuloColor> solidColors = [
    EstimuloColor.rojo,
    EstimuloColor.verde,
    EstimuloColor.azul,
    EstimuloColor.amarillo,
    EstimuloColor.blanco,
    EstimuloColor.morado,
    EstimuloColor.negro,
  ];

  bool get isRandom => this == EstimuloColor.aleatorio;

  Color get color => switch (this) {
        EstimuloColor.rojo => Colors.redAccent,
        EstimuloColor.verde => Colors.lightGreenAccent,
        EstimuloColor.azul => AppConstants.optoviewBlue,
        EstimuloColor.amarillo => Colors.amberAccent,
        EstimuloColor.blanco => Colors.white,
        EstimuloColor.morado => Colors.purpleAccent,
        EstimuloColor.negro => Colors.black,
        EstimuloColor.aleatorio => Colors.deepPurpleAccent,
      };
}

/// Configuracion completa de la prueba
@immutable
class TestConfig {
  final Lado lado;
  final SimboloCategoria categoria;
  final Forma? forma; // null = aleatoria
  final Velocidad velocidad;
  final Movimiento movimiento;
  final int duracionSegundos;
  final double tamanoPorc;
  final bool tamanoAleatorio;
  final double distanciaPct;
  final DistanciaModo distanciaModo;
  final Fijacion fijacion;
  final Fondo fondo;
  final bool fondoDistractor;
  final bool fondoDistractorAnimado;
  final EstimuloColor estimuloColor;

  const TestConfig({
    required this.lado,
    required this.categoria,
    this.forma,
    required this.velocidad,
    required this.movimiento,
    required this.duracionSegundos,
    required this.tamanoPorc,
    this.tamanoAleatorio = false,
    required this.distanciaPct,
    required this.distanciaModo,
    required this.fijacion,
    required this.fondo,
    required this.fondoDistractor,
    required this.estimuloColor,
    this.fondoDistractorAnimado = false,
  });

  /// Crea una copia modificada de la configuracion actual
  TestConfig copyWith({
    Lado? lado,
    SimboloCategoria? categoria,
    Forma? forma,
    bool formaSetNull = false,
    Velocidad? velocidad,
    Movimiento? movimiento,
    int? duracionSegundos,
    double? tamanoPorc,
    bool? tamanoAleatorio,
    double? distanciaPct,
    DistanciaModo? distanciaModo,
    Fijacion? fijacion,
    Fondo? fondo,
    bool? fondoDistractor,
    bool? fondoDistractorAnimado,
    EstimuloColor? estimuloColor,
  }) {
    return TestConfig(
      lado: lado ?? this.lado,
      categoria: categoria ?? this.categoria,
      forma: formaSetNull ? null : (forma ?? this.forma),
      velocidad: velocidad ?? this.velocidad,
      movimiento: movimiento ?? this.movimiento,
      duracionSegundos: duracionSegundos ?? this.duracionSegundos,
      tamanoPorc: tamanoPorc ?? this.tamanoPorc,
      tamanoAleatorio: tamanoAleatorio ?? this.tamanoAleatorio,
      distanciaPct: distanciaPct ?? this.distanciaPct,
      distanciaModo: distanciaModo ?? this.distanciaModo,
      fijacion: fijacion ?? this.fijacion,
      fondo: fondo ?? this.fondo,
      fondoDistractor: fondoDistractor ?? this.fondoDistractor,
      fondoDistractorAnimado:
          fondoDistractorAnimado ?? this.fondoDistractorAnimado,
      estimuloColor: estimuloColor ?? this.estimuloColor,
    );
  }

  /// Resumen localizado de la configuración para pantalla de resultados
  Map<String, String> localizedSummary(AppLocalizations l) {
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
    final colorLabel = switch (estimuloColor) {
      EstimuloColor.rojo => l.colorRed,
      EstimuloColor.verde => l.colorGreen,
      EstimuloColor.azul => l.colorBlue,
      EstimuloColor.amarillo => l.colorYellow,
      EstimuloColor.blanco => l.colorWhite,
      EstimuloColor.morado => l.colorPurple,
      EstimuloColor.negro => l.colorBlack,
      EstimuloColor.aleatorio => l.colorRandom,
    };
    final speedLabel = switch (velocidad) {
      Velocidad.lenta => l.speedSlow,
      Velocidad.media => l.speedMedium,
      Velocidad.rapida => l.speedFast,
    };
    final movLabel = switch (movimiento) {
      Movimiento.fijo => l.movementFixed,
      Movimiento.horizontal => l.movementHorizontal,
      Movimiento.vertical => l.movementVertical,
      Movimiento.aleatorio => l.movementRandom,
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
    String fondoDesc = bgLabel;
    if (fondoDistractor) {
      fondoDesc += fondoDistractorAnimado
          ? l.summaryDistractorAnimated
          : l.summaryDistractor;
    }

    return {
      l.summaryKeySide: ladoLabel,
      l.summaryKeyStimulus: stimulusDesc,
      l.summaryKeyColor: colorLabel,
      l.summaryKeySpeed: speedLabel,
      l.summaryKeyMovement: movLabel,
      l.summaryKeyDistance: distanciaModo == DistanciaModo.aleatorio
          ? l.summaryDistRandom
          : '${distanciaPct.toStringAsFixed(0)}%',
      l.summaryKeySize: tamanoAleatorio
          ? l.summarySizeRandom(tamanoPorc.toStringAsFixed(0))
          : '${tamanoPorc.toStringAsFixed(0)}%',
      l.summaryKeyDuration: '${duracionSegundos}s',
      l.summaryKeyFixation: fixLabel,
      l.summaryKeyBackground: fondoDesc,
    };
  }
}
