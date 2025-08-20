// lib/models/test_config.dart
enum Lado { izquierda, derecha, arriba, abajo, ambos }

enum SimboloCategoria { letras, numeros, formas }

enum Forma {
  circulo,
  cuadrado,
  corazon,
  triangulo,
  trebol,
}

enum Velocidad { lenta, media, rapida }

/// Tipo de movimiento del estímulo.
/// Nota: Si se elige 'vertical' y el lado es ARRIBA/ABAJO,
/// el movimiento se aplicará en horizontal (auto-eje).
enum Movimiento { fijo, vertical }

class TestConfig {
  final Lado lado;
  final SimboloCategoria categoria;
  final Forma? forma; // solo se usa si categoria == formas; null = aleatoria
  final Velocidad velocidad;
  final Movimiento movimiento;
  final int duracionSegundos;
  final double tamanoPorc;

  const TestConfig({
    required this.lado,
    required this.categoria,
    this.forma,
    required this.velocidad,
    required this.movimiento,
    required this.duracionSegundos,
    required this.tamanoPorc,
  });

  TestConfig copyWith({
    Lado? lado,
    SimboloCategoria? categoria,
    Forma? forma,
    Velocidad? velocidad,
    Movimiento? movimiento,
    int? duracionSegundos,
    double? tamanoPorc,
  }) {
    return TestConfig(
      lado: lado ?? this.lado,
      categoria: categoria ?? this.categoria,
      forma: forma ?? this.forma,
      velocidad: velocidad ?? this.velocidad,
      movimiento: movimiento ?? this.movimiento,
      duracionSegundos: duracionSegundos ?? this.duracionSegundos,
      tamanoPorc: tamanoPorc ?? this.tamanoPorc,
    );
  }

  @override
  String toString() =>
      'TestConfig(lado: $lado, categoria: $categoria, forma: $forma, '
      'velocidad: $velocidad, movimiento: $movimiento, '
      'duracionSegundos: $duracionSegundos, tamanoPorc: $tamanoPorc)';
}
