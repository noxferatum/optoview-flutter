
// Enums existentes
enum Lado { izquierda, derecha, ambos, arriba, abajo }
enum SimboloCategoria { letras, numeros, formas }
enum Forma { circulo, cuadrado, corazon, triangulo, trebol }
enum Velocidad { lenta, media, rapida }
enum Movimiento { fijo, movimiento }
enum DistanciaModo { fijo, aleatorio }

// 🔹 Nuevo enum para punto de fijación
enum Fijacion { cara, ojo, punto, trebol, cruz }

// 🔹 Nuevo enum para fondo
enum Fondo { claro, oscuro }

class TestConfig {
  final Lado lado;
  final SimboloCategoria categoria;
  final Forma? forma;
  final Velocidad velocidad;
  final Movimiento movimiento;
  final int duracionSegundos;
  final double tamanoPorc;
  final double distanciaPct;
  final DistanciaModo distanciaModo;
  final Fijacion fijacion;
  final Fondo fondo;
  final bool fondoDistractor;

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
    required this.fijacion,
    required this.fondo,
    required this.fondoDistractor,
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
    Fijacion? fijacion,
    Fondo? fondo,
    bool? fondoDistractor,
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
      fijacion: fijacion ?? this.fijacion,
      fondo: fondo ?? this.fondo,
      fondoDistractor: fondoDistractor ?? this.fondoDistractor,
    );
  }
}
