import 'package:flutter/material.dart';
import '../models/test_config.dart';

// Selectores ya existentes
import '../widgets/config/side_selector.dart';
import '../widgets/config/symbol_selector.dart';
import '../widgets/config/speed_selector.dart';
import '../widgets/config/movement_selector.dart';
import '../widgets/config/distance_selector.dart';

// Nuevos selectores
import '../widgets/config/fixation_selector.dart';
import '../widgets/config/background_selector.dart';

// Pantalla del test
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
    duracionSegundos: 60,
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
      appBar: AppBar(
        title: const Text('Configuración de la prueba'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // 🔹 Lado de estimulación
            SideSelector(
              value: config.lado,
              onChanged: (v) => setState(() => config = config.copyWith(lado: v)),
            ),
            const SizedBox(height: 16),

            // 🔹 Tipo de símbolo
            SymbolSelector(
              categoria: config.categoria,
              forma: config.forma,
              onCategoriaChanged: (c) =>
                  setState(() => config = config.copyWith(categoria: c)),
              onFormaChanged: (f) =>
                  setState(() => config = config.copyWith(forma: f)),
            ),
            const SizedBox(height: 16),

            // 🔹 Velocidad
            SpeedSelector(
              value: config.velocidad,
              onChanged: (v) =>
                  setState(() => config = config.copyWith(velocidad: v)),
            ),
            const SizedBox(height: 16),

            // 🔹 Movimiento
            MovementSelector(
              value: config.movimiento,
              onChanged: (v) =>
                  setState(() => config = config.copyWith(movimiento: v)),
            ),
            const SizedBox(height: 16),

            // 🔹 Distancia al centro
            DistanceSelector(
              modo: config.distanciaModo,
              distanciaPct: config.distanciaPct,
              onModoChanged: (m) =>
                  setState(() => config = config.copyWith(distanciaModo: m)),
              onDistChanged: (d) =>
                  setState(() => config = config.copyWith(distanciaPct: d)),
            ),
            const SizedBox(height: 16),

            // 🔹 Duración
            _DurationCard(
              value: config.duracionSegundos,
              onChanged: (v) =>
                  setState(() => config = config.copyWith(duracionSegundos: v)),
            ),
            const SizedBox(height: 16),

            // 🔹 Tamaño del estímulo
            _SizeCard(
              value: config.tamanoPorc,
              onChanged: (v) =>
                  setState(() => config = config.copyWith(tamanoPorc: v)),
            ),
            const Divider(height: 32, thickness: 1),

            // 🔹 Nuevo: punto de fijación
            FixationSelector(
              value: config.fijacion,
              onChanged: (v) =>
                  setState(() => config = config.copyWith(fijacion: v)),
            ),
            const SizedBox(height: 16),

            // 🔹 Nuevo: fondo claro/oscuro y distractor
            BackgroundSelector(
              fondo: config.fondo,
              distractor: config.fondoDistractor,
              onFondoChanged: (v) =>
                  setState(() => config = config.copyWith(fondo: v)),
              onDistractorChanged: (v) =>
                  setState(() => config = config.copyWith(fondoDistractor: v)),
            ),
            const SizedBox(height: 32),

            // 🔹 Botón de inicio
            Center(
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DynamicPeripheryTest(config: config),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Iniciar prueba'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationCard extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _DurationCard({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Duración (segundos)',
                style: TextStyle(fontWeight: FontWeight.w600)),
            Slider(
              value: value.toDouble(),
              min: 10,
              max: 300,
              divisions: 29,
              label: '$value s',
              onChanged: (v) => onChanged(v.round()),
            ),
          ],
        ),
      ),
    );
  }
}

class _SizeCard extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  const _SizeCard({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Tamaño (%)',
                style: TextStyle(fontWeight: FontWeight.w600)),
            Slider(
              value: value,
              min: 5,
              max: 100,
              divisions: 95,
              label: '${value.toStringAsFixed(0)}%',
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
