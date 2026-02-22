import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

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

  /// Resumen legible de la configuración para pantalla de resultados
  Map<String, String> get summaryMap {
    final stimulusDesc = categoria == SimboloCategoria.formas
        ? '${categoria.label} (${forma?.label ?? "Aleatoria"})'
        : categoria.label;

    String fondoDesc = fondo.label;
    if (fondoDistractor) {
      fondoDesc += fondoDistractorAnimado
          ? ' + Distractor animado'
          : ' + Distractor';
    }

    return {
      'Lado': lado.label,
      'Estímulo': stimulusDesc,
      'Color': estimuloColor.label,
      'Velocidad': velocidad.label,
      'Movimiento': movimiento.label,
      'Distancia': distanciaModo == DistanciaModo.aleatorio
          ? 'Aleatoria'
          : '${distanciaPct.toStringAsFixed(0)}%',
      'Tamaño': tamanoAleatorio
          ? '~${tamanoPorc.toStringAsFixed(0)}% (aleatorio)'
          : '${tamanoPorc.toStringAsFixed(0)}%',
      'Duración': '${duracionSegundos}s',
      'Fijación': fijacion.label,
      'Fondo': fondoDesc,
    };
  }
}
