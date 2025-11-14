import 'package:flutter/material.dart';

/// Enumeraciones principales de la prueba
enum Lado { izquierda, derecha, arriba, abajo, ambos, aleatorio }

enum SimboloCategoria { letras, numeros, formas }

enum Forma { circulo, cuadrado, corazon, triangulo, trebol }

enum Velocidad { lenta, media, rapida }

/// Modos de movimiento soportados
enum Movimiento { fijo, horizontal, vertical, aleatorio }

enum DistanciaModo { fijo, aleatorio }

enum Fijacion { cara, ojo, punto, trebol, cruz }

enum Fondo { claro, oscuro, azul }

enum EstimuloColor { rojo, verde, azul, amarillo, blanco, morado, negro, aleatorio }

const Color _optoviewBlue = Color(0xFF3F6FB2);
const Color _optoviewBluePattern = Color(0xFF8ABFF5);

extension FondoTheme on Fondo {
  Color get baseColor {
    switch (this) {
      case Fondo.claro:
        return Colors.white;
      case Fondo.oscuro:
        return Colors.black;
      case Fondo.azul:
        return _optoviewBlue;
    }
  }

  Color get patternColor {
    switch (this) {
      case Fondo.claro:
        return Colors.black;
      case Fondo.oscuro:
        return Colors.white;
      case Fondo.azul:
        return _optoviewBluePattern;
    }
  }

  bool get isDark => this == Fondo.oscuro || this == Fondo.azul;
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

  Color get color {
    switch (this) {
      case EstimuloColor.rojo:
        return Colors.redAccent;
      case EstimuloColor.verde:
        return Colors.lightGreenAccent;
      case EstimuloColor.azul:
        return _optoviewBlue;
      case EstimuloColor.amarillo:
        return Colors.amberAccent;
      case EstimuloColor.blanco:
        return Colors.white;
      case EstimuloColor.morado:
        return Colors.purpleAccent;
      case EstimuloColor.negro:
        return Colors.black;
      case EstimuloColor.aleatorio:
        return Colors.deepPurpleAccent;
    }
  }

  String get label {
    switch (this) {
      case EstimuloColor.rojo:
        return 'Rojo';
      case EstimuloColor.verde:
        return 'Verde';
      case EstimuloColor.azul:
        return 'Azul';
      case EstimuloColor.amarillo:
        return 'Amarillo';
      case EstimuloColor.blanco:
        return 'Blanco';
      case EstimuloColor.morado:
        return 'Morado';
      case EstimuloColor.negro:
        return 'Negro';
      case EstimuloColor.aleatorio:
        return 'Aleatorio';
    }
  }
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
}
