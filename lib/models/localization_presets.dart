import 'package:flutter/material.dart';
import 'test_config.dart';
import 'localization_config.dart';

class LocPresetInfo {
  final String name;
  final String description;
  final IconData icon;
  final LocalizationConfig config;

  const LocPresetInfo({
    required this.name,
    required this.description,
    required this.icon,
    required this.config,
  });
}

abstract final class LocalizationPresets {
  static const LocalizationConfig easy = LocalizationConfig(
    lado: Lado.aleatorio,
    categoria: SimboloCategoria.formas,
    forma: Forma.circulo,
    velocidad: Velocidad.lenta,
    duracionSegundos: 30,
    tamanoPorc: 25,
    distanciaPct: 60,
    distanciaModo: DistanciaModo.fijo,

    fondo: Fondo.oscuro,
    fondoDistractor: false,
    modo: LocalizationMode.tocarTodos,
    centroFijo: true,
    feedbackVisual: true,
    desaparicion: DisappearMode.esperarToque,
    stimuliSimultaneos: 1,
  );

  static const LocalizationConfig standard = LocalizationConfig(
    lado: Lado.aleatorio,
    categoria: SimboloCategoria.formas,
    forma: null,
    velocidad: Velocidad.media,
    duracionSegundos: 60,
    tamanoPorc: 15,
    distanciaPct: 80,
    distanciaModo: DistanciaModo.aleatorio,

    fondo: Fondo.oscuro,
    fondoDistractor: false,
    modo: LocalizationMode.igualarCentro,
    centroFijo: true,
    feedbackVisual: true,
    desaparicion: DisappearMode.porTiempo,
    stimuliSimultaneos: 1,
  );

  static const LocalizationConfig advanced = LocalizationConfig(
    lado: Lado.aleatorio,
    categoria: SimboloCategoria.formas,
    forma: null,
    velocidad: Velocidad.rapida,
    duracionSegundos: 120,
    tamanoPorc: 10,
    distanciaPct: 90,
    distanciaModo: DistanciaModo.aleatorio,

    fondo: Fondo.oscuro,
    fondoDistractor: true,
    fondoDistractorAnimado: true,
    modo: LocalizationMode.mismaForma,
    centroFijo: false,
    feedbackVisual: false,
    desaparicion: DisappearMode.porTiempo,
    stimuliSimultaneos: 3,
  );

  static const List<LocPresetInfo> all = [
    LocPresetInfo(
      name: 'Estándar',
      description: 'Igualar centro, velocidad media',
      icon: Icons.tune,
      config: standard,
    ),
    LocPresetInfo(
      name: 'Fácil',
      description: 'Tocar todos, lento, con feedback',
      icon: Icons.child_care,
      config: easy,
    ),
    LocPresetInfo(
      name: 'Avanzado',
      description: 'Misma forma, rápido, sin feedback, 3 estímulos',
      icon: Icons.speed,
      config: advanced,
    ),
  ];
}
