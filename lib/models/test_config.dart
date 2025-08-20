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
/// Si es 'fijo', no hay animación.
/// Si es 'vertical', el eje de animación se adapta:
/// - Lado Izq./Der. -> movimiento vertical (arriba<->abajo)
/// - Lado Arriba/Abajo -> movimiento horizontal (izq.<->der.)
enum Movimiento { fijo, vertical }

/// Modo de distancia respecto al centro
enum DistanciaModo { controlada, aleatoria }

class TestConfig {
  final Lado lado;
  final SimboloCategoria categoria;
  final Forma? forma; // si categoria == formas; null = aleatoria
  final Velocidad velocidad;
  final Movimiento movimiento;
  final int duracionSegundos;
  final double tamanoPorc;

  /// Distancia desde el centro (0–100%). 0 = centro; 100 = máximo hacia el borde.
  final double distanciaPct;

  /// Si es aleatoria, en cada aparición se ignora distanciaPct y se elige aleatoriamente 0–100%.
  final DistanciaModo distanciaModo;

  const TestConfig({
    required this.lado,
    required this.categoria,
    this.forma,
    required this.velocidad,
    required this.movimiento,
    required this.duracionSegundos,
    required this.tamanoPorc,
    required this.distanciaPct,
    required this.distanciaModo,
  });

  TestConfig copyWith({
    Lado? lado,
    SimboloCategoria? categoria,
    Forma? forma,
    Velocidad? velocidad,
    Movimiento? movimiento,
    int? duracionSegundos,
    double? tamanoPorc,
    double? distanciaPct,
    DistanciaModo? distanciaModo,
  }) {
    return TestConfig(
      lado: lado ?? this.lado,
      categoria: categoria ?? this.categoria,
      forma: forma ?? this.forma,
      velocidad: velocidad ?? this.velocidad,
      movimiento: movimiento ?? this.movimiento,
      duracionSegundos: duracionSegundos ?? this.duracionSegundos,
      tamanoPorc: tamanoPorc ?? this.tamanoPorc,
      distanciaPct: distanciaPct ?? this.distanciaPct,
      distanciaModo: distanciaModo ?? this.distanciaModo,
    );
  }

  @override
  String toString() =>
      'TestConfig(lado: $lado, categoria: $categoria, forma: $forma, '
      'velocidad: $velocidad, movimiento: $movimiento, '
      'duracionSegundos: $duracionSegundos, tamanoPorc: $tamanoPorc, '
      'distanciaPct: $distanciaPct, distanciaModo: $distanciaModo)';
}
