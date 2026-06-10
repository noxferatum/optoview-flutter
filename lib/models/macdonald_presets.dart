import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/config/presets_row.dart';
import 'test_config.dart';
import 'macdonald_config.dart';

abstract final class MacDonaldPresets {
  static const MacDonaldConfig easy = MacDonaldConfig(
    interaccion: MacInteraccion.tocarLetras,
    visualizacion: MacVisualizacion.completa,
    direccion: MacDireccion.centroAfuera,
    numAnillos: 2,
    letrasPorAnillo: 4,
    duracionSegundos: 60,
    fondo: Fondo.oscuro,
    fijacion: Fijacion.punto,
    colorLetras: EstimuloColor.blanco,
    tamanoBase: 20,
    velocidadRevelado: Velocidad.lenta,
    letrasAleatorias: true,
  );

  static const MacDonaldConfig standard = MacDonaldConfig(
    interaccion: MacInteraccion.lecturaConTiempo,
    visualizacion: MacVisualizacion.porAnillos,
    direccion: MacDireccion.centroAfuera,
    numAnillos: 3,
    letrasPorAnillo: 6,
    duracionSegundos: 90,
    fondo: Fondo.oscuro,
    fijacion: Fijacion.punto,
    colorLetras: EstimuloColor.blanco,
    tamanoBase: 15,
    velocidadRevelado: Velocidad.media,
    letrasAleatorias: true,
  );

  static const MacDonaldConfig advanced = MacDonaldConfig(
    interaccion: MacInteraccion.lecturaSecuencial,
    visualizacion: MacVisualizacion.progresiva,
    direccion: MacDireccion.horario,
    numAnillos: 4,
    letrasPorAnillo: 8,
    duracionSegundos: 120,
    fondo: Fondo.oscuro,
    fijacion: Fijacion.punto,
    colorLetras: EstimuloColor.blanco,
    tamanoBase: 12,
    velocidadRevelado: Velocidad.rapida,
    letrasAleatorias: true,
  );

  static List<PresetEntry<MacDonaldConfig>> all(AppLocalizations l) => [
    PresetEntry(
      name: l.presetStandard,
      description: l.presetMacStandardDesc,
      icon: Icons.tune,
      config: standard,
    ),
    PresetEntry(
      name: l.presetEasy,
      description: l.presetMacEasyDesc,
      icon: Icons.child_care,
      config: easy,
    ),
    PresetEntry(
      name: l.presetAdvanced,
      description: l.presetMacAdvancedDesc,
      icon: Icons.speed,
      config: advanced,
    ),
  ];
}
