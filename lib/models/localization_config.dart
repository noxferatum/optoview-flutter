import 'package:flutter/material.dart';
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
  final Fijacion fijacion;
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
    required this.fijacion,
    required this.fondo,
    required this.fondoDistractor,
    this.fondoDistractorAnimado = false,
    required this.modo,
    this.centroFijo = true,
    this.feedbackVisual = true,
    this.desaparicion = DisappearMode.porTiempo,
    this.stimuliSimultaneos = 1,
  });

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
    Fijacion? fijacion,
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
      fijacion: fijacion ?? this.fijacion,
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
      'Modo': modo.label,
      'Lado': lado.label,
      'Estímulo': stimulusDesc,
      'Velocidad': velocidad.label,
      'Distancia': distanciaModo == DistanciaModo.aleatorio
          ? 'Aleatoria'
          : '${distanciaPct.toStringAsFixed(0)}%',
      'Tamaño': '${tamanoPorc.toStringAsFixed(0)}%',
      'Duración': '${duracionSegundos}s',
      'Fijación': fijacion.label,
      'Fondo': fondoDesc,
      'Centro': centroFijo ? 'Fijo' : 'Cambiante',
      'Feedback': feedbackVisual ? 'Sí' : 'No',
      'Desaparición': desaparicion.label,
      'Estímulos simultáneos': '$stimuliSimultaneos',
    };
  }
}
