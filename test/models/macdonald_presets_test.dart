import 'package:flutter_test/flutter_test.dart';
import 'package:optoview_flutter/models/macdonald_config.dart';
import 'package:optoview_flutter/models/macdonald_presets.dart';

void main() {
  group('MacDonaldPresets', () {
    test('easy/standard/advanced escalan en anillos, letras y duración', () {
      expect(MacDonaldPresets.easy.numAnillos, 2);
      expect(MacDonaldPresets.standard.numAnillos, 3);
      expect(MacDonaldPresets.advanced.numAnillos, 4);

      expect(MacDonaldPresets.easy.letrasPorAnillo, 4);
      expect(MacDonaldPresets.standard.letrasPorAnillo, 6);
      expect(MacDonaldPresets.advanced.letrasPorAnillo, 8);

      expect(MacDonaldPresets.easy.duracionSegundos, 60);
      expect(MacDonaldPresets.standard.duracionSegundos, 90);
      expect(MacDonaldPresets.advanced.duracionSegundos, 120);
    });

    test('standard usa lectura con tiempo y visualización por anillos', () {
      expect(MacDonaldPresets.standard.interaccion,
          MacInteraccion.lecturaConTiempo);
      expect(MacDonaldPresets.standard.visualizacion,
          MacVisualizacion.porAnillos);
    });
  });
}
