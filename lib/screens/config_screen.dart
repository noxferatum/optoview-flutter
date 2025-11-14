import 'package:flutter/material.dart';
import '../models/test_config.dart';

// Selectores existentes
import '../widgets/config/side_selector.dart';
import '../widgets/config/symbol_selector.dart';
import '../widgets/config/speed_selector.dart';
import '../widgets/config/movement_selector.dart';
import '../widgets/config/distance_selector.dart';

// Nuevos selectores
import '../widgets/config/fixation_selector.dart';
import '../widgets/config/background_selector.dart';
import '../widgets/config/stimulus_color_selector.dart';

// Pantalla del test
import 'dynamic_periphery_test.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  TestConfig config = const TestConfig(
    lado: Lado.aleatorio,
    categoria: SimboloCategoria.formas,
    forma: null, // Aleatoria por defecto
    velocidad: Velocidad.media,
    movimiento: Movimiento.aleatorio,
    duracionSegundos: 60,
    tamanoPorc: 15,
    tamanoAleatorio: true,
    distanciaPct: 80,
    distanciaModo: DistanciaModo.aleatorio,
    fijacion: Fijacion.punto,
    fondo: Fondo.oscuro,
    fondoDistractor: true,
    fondoDistractorAnimado: true,
    estimuloColor: EstimuloColor.aleatorio,
  );

  void _startTest() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DynamicPeripheryTest(config: config),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test de estimulación periférica')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Lado
            SideSelector(
              value: config.lado,
              onChanged: (v) => setState(() {
                config = config.copyWith(lado: v);
              }),
            ),
            const SizedBox(height: 16),

            // Símbolo
            SymbolSelector(
              categoria: config.categoria,
              forma: config.forma,
              onCategoriaChanged: (c) => setState(() {
                config = config.copyWith(categoria: c);
              }),
              onFormaChanged: (f) => setState(() {
                if (f == null) {
                  config = config.copyWith(formaSetNull: true);
                } else {
                  config = config.copyWith(forma: f);
                }
              }),
              onFormaClear: () => setState(() {
                config = config.copyWith(formaSetNull: true);
              }),
            ),
            const SizedBox(height: 16),

            // Color del estímulo
            StimulusColorSelector(
              value: config.estimuloColor,
              onChanged: (value) => setState(() {
                config = config.copyWith(estimuloColor: value);
              }),
            ),
            const SizedBox(height: 16),

            // Velocidad
            SpeedSelector(
              value: config.velocidad,
              onChanged: (v) => setState(() {
                config = config.copyWith(velocidad: v);
              }),
            ),
            const SizedBox(height: 16),

            // Movimiento
            MovementSelector(
              value: config.movimiento,
              onChanged: (m) => setState(() {
                config = config.copyWith(movimiento: m);
              }),
            ),
            const SizedBox(height: 16),

            // Distancia
            DistanceSelector(
              modo: config.distanciaModo,
              distanciaPct: config.distanciaPct,
              onModoChanged: (m) => setState(() {
                config = config.copyWith(distanciaModo: m);
              }),
              onDistChanged: (d) => setState(() {
                config = config.copyWith(distanciaPct: d);
              }),
            ),
            const SizedBox(height: 16),

            // Duración
            _DurationCard(
              value: config.duracionSegundos,
              onChanged: (v) => setState(() {
                config = config.copyWith(duracionSegundos: v);
              }),
            ),
            const SizedBox(height: 16),

            // Tamaño
            _SizeCard(
              value: config.tamanoPorc,
              isRandom: config.tamanoAleatorio,
              onChanged: (v) => setState(() {
                config = config.copyWith(tamanoPorc: v);
              }),
              onRandomChanged: (enabled) => setState(() {
                config = config.copyWith(tamanoAleatorio: enabled);
              }),
            ),

            const Divider(height: 32),

            // Punto de fijación
            FixationSelector(
              value: config.fijacion,
              onChanged: (v) => setState(() {
                config = config.copyWith(fijacion: v);
              }),
            ),
            const SizedBox(height: 16),

            // Fondo + distractor + animación
            BackgroundSelector(
              fondo: config.fondo,
              distractor: config.fondoDistractor,
              animado: config.fondoDistractorAnimado,
              onFondoChanged: (v) => setState(() {
                config = config.copyWith(fondo: v);
              }),
              onDistractorChanged: (v) => setState(() {
                config = config.copyWith(fondoDistractor: v);
              }),
              onAnimadoChanged: (v) => setState(() {
                config = config.copyWith(fondoDistractorAnimado: v);
              }),
            ),

            const SizedBox(height: 24),

            // Iniciar
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _startTest,
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

// ---- Widgets internos ----

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
  final bool isRandom;
  final ValueChanged<double> onChanged;
  final ValueChanged<bool> onRandomChanged;
  const _SizeCard({
    required this.value,
    required this.isRandom,
    required this.onChanged,
    required this.onRandomChanged,
  });

  @override
  Widget build(BuildContext context) {
    const double minPct = 5;
    const double maxPct = 35;
    final double normalized =
        ((value - minPct) / (maxPct - minPct)).clamp(0.0, 1.0);

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
              min: minPct,
              max: maxPct,
              divisions: 30,
              label: '${(normalized * 100).round()}%',
              onChanged: isRandom ? null : onChanged,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: isRandom,
              onChanged: onRandomChanged,
              title: const Text('Variar tamaño aleatoriamente'),
              subtitle: const Text(
                'Si se activa, cada estímulo ajustará su tamaño alrededor del valor configurado.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

