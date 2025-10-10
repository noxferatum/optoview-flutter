import 'package:flutter/material.dart';
import '../models/test_config.dart';
import '../widgets/config/fixation_selector.dart';
import '../widgets/config/background_selector.dart';
import 'dynamic_periphery_test.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  TestConfig config = const TestConfig(
    lado: Lado.ambos,
    categoria: SimboloCategoria.formas,
    forma: Forma.circulo,
    velocidad: Velocidad.media,
    movimiento: Movimiento.fijo,
    duracionSegundos: 10,
    tamanoPorc: 50,
    distanciaPct: 100,
    distanciaModo: DistanciaModo.fijo,
    fijacion: Fijacion.punto,
    fondo: Fondo.oscuro,
    fondoDistractor: false,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración de la prueba')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FixationSelector(
              value: config.fijacion,
              onChanged: (v) => setState(() => config = config.copyWith(fijacion: v)),
            ),
            const SizedBox(height: 16),
            BackgroundSelector(
              fondo: config.fondo,
              distractor: config.fondoDistractor,
              onFondoChanged: (v) => setState(() => config = config.copyWith(fondo: v)),
              onDistractorChanged: (v) =>
                  setState(() => config = config.copyWith(fondoDistractor: v)),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DynamicPeripheryTest(config: config)),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Iniciar prueba'),
            ),
          ],
        ),
      ),
    );
  }
}
