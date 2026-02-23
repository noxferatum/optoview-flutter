import 'package:flutter/material.dart';
import '../models/test_config.dart';

/// Determina el color de outline adecuado para un estímulo
/// según su color y el fondo actual.
///
/// Retorna `null` si no se requiere outline.
Color? outlineColorForStimulus(EstimuloColor colorOption, Fondo fondo) {
  switch (colorOption) {
    case EstimuloColor.negro:
      if (fondo == Fondo.oscuro) return Colors.white;
      break;
    case EstimuloColor.blanco:
      if (fondo == Fondo.claro) return Colors.black;
      break;
    case EstimuloColor.azul:
      if (fondo == Fondo.azul) return Colors.black;
      break;
    default:
      break;
  }
  return null;
}
