import 'package:flutter/material.dart';
import 'test_config.dart';

class PresetInfo {
  final String name;
  final String description;
  final IconData icon;
  final TestConfig config;

  const PresetInfo({
    required this.name,
    required this.description,
    required this.icon,
    required this.config,
  });
}

abstract final class TestPresets {
  static const TestConfig standard = TestConfig(
    lado: Lado.aleatorio,
    categoria: SimboloCategoria.formas,
    forma: null,
    velocidad: Velocidad.media,
    movimiento: Movimiento.fijo,
    duracionSegundos: 60,
    tamanoPorc: 15,
    tamanoAleatorio: false,
    distanciaPct: 80,
    distanciaModo: DistanciaModo.aleatorio,
    fijacion: Fijacion.punto,
    fondo: Fondo.oscuro,
    fondoDistractor: false,
    estimuloColor: EstimuloColor.blanco,
    fondoDistractorAnimado: false,
  );

  static const TestConfig easy = TestConfig(
    lado: Lado.aleatorio,
    categoria: SimboloCategoria.formas,
    forma: Forma.circulo,
    velocidad: Velocidad.lenta,
    movimiento: Movimiento.fijo,
    duracionSegundos: 30,
    tamanoPorc: 25,
    tamanoAleatorio: false,
    distanciaPct: 60,
    distanciaModo: DistanciaModo.fijo,
    fijacion: Fijacion.punto,
    fondo: Fondo.oscuro,
    fondoDistractor: false,
    estimuloColor: EstimuloColor.blanco,
    fondoDistractorAnimado: false,
  );

  static const TestConfig advanced = TestConfig(
    lado: Lado.aleatorio,
    categoria: SimboloCategoria.letras,
    forma: null,
    velocidad: Velocidad.rapida,
    movimiento: Movimiento.aleatorio,
    duracionSegundos: 120,
    tamanoPorc: 10,
    tamanoAleatorio: true,
    distanciaPct: 90,
    distanciaModo: DistanciaModo.aleatorio,
    fijacion: Fijacion.punto,
    fondo: Fondo.oscuro,
    fondoDistractor: true,
    estimuloColor: EstimuloColor.aleatorio,
    fondoDistractorAnimado: true,
  );

  static const List<PresetInfo> all = [
    PresetInfo(
      name: 'Estándar',
      description: 'Configuración equilibrada para uso general',
      icon: Icons.tune,
      config: standard,
    ),
    PresetInfo(
      name: 'Fácil',
      description: 'Estímulos grandes y lentos, ideal para inicio',
      icon: Icons.child_care,
      config: easy,
    ),
    PresetInfo(
      name: 'Avanzado',
      description: 'Estímulos rápidos, pequeños y con distractores',
      icon: Icons.speed,
      config: advanced,
    ),
  ];
}
