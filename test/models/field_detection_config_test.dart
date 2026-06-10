import 'package:flutter_test/flutter_test.dart';
import 'package:optoview_flutter/models/field_detection_config.dart';
import 'package:optoview_flutter/models/macdonald_config.dart' show MacContenido;
import 'package:optoview_flutter/models/test_config.dart';

void main() {
  group('FieldDetectionConfig.standard', () {
    test('es la configuración estandarizada esperada (5 anillos, 12 base)', () {
      const c = FieldDetectionConfig.standard;
      expect(c.numAnillos, 5);
      expect(c.letrasPorAnilloBase, 12);
      expect(c.contenido, MacContenido.letras);
      expect(c.fondo, Fondo.oscuro);
      expect(c.fijacion, Fijacion.punto);
      expect(c.letrasAleatorias, isTrue);
    });

    test('totalLetras suma 80 (12+14+16+18+20)', () {
      expect(FieldDetectionConfig.standard.totalLetras, 80);
    });
  });

  group('FieldDetectionConfig.totalLetras', () {
    test('progresión +2 por anillo desde la base', () {
      const c = FieldDetectionConfig(
        numAnillos: 3,
        letrasPorAnilloBase: 8,
        tamanoBase: 24,
        velocidad: Velocidad.lenta,
        contenido: MacContenido.letras,
        fondo: Fondo.oscuro,
        fijacion: Fijacion.punto,
        colorLetras: EstimuloColor.blanco,
        letrasAleatorias: true,
      );
      // 8 + 10 + 12 = 30
      expect(c.totalLetras, 30);
    });

    test('un solo anillo equivale a la base', () {
      const c = FieldDetectionConfig(
        numAnillos: 1,
        letrasPorAnilloBase: 6,
        tamanoBase: 24,
        velocidad: Velocidad.lenta,
        contenido: MacContenido.letras,
        fondo: Fondo.oscuro,
        fijacion: Fijacion.punto,
        colorLetras: EstimuloColor.blanco,
        letrasAleatorias: true,
      );
      expect(c.totalLetras, 6);
    });
  });
}
