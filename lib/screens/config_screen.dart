// lib/screens/config_screen.dart
import 'package:flutter/material.dart';
import '../models/test_config.dart';
import '../widgets/config/side_selector.dart';
import '../widgets/config/symbol_selector.dart';
import '../widgets/config/speed_selector.dart';
import '../widgets/config/movement_selector.dart';
import '../widgets/config/distance_selector.dart';
import 'dynamic_periphery_test.dart';

class ConfigScreen extends StatefulWidget {
  final TestConfig? initial;

  const ConfigScreen({super.key, this.initial});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  late TestConfig _config;

  @override
  void initState() {
    super.initState();
    _config = widget.initial ??
        const TestConfig(
          lado: Lado.ambos,
          categoria: SimboloCategoria.letras,
          forma: null,
          velocidad: Velocidad.media,
          movimiento: Movimiento.fijo,
          duracionSegundos: 60,
          tamanoPorc: 20,
          // Por defecto ahora al 100%
          distanciaPct: 100,
          distanciaModo: DistanciaModo.controlada,
        );
  }

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      SideSelector(
        value: _config.lado,
        onChanged: (v) => setState(() => _config = _config.copyWith(lado: v)),
      ),
      SymbolSelector(
        categoria: _config.categoria,
        forma: _config.forma,
        onCategoriaChanged: (c) =>
            setState(() => _config = _config.copyWith(categoria: c)),
        onFormaChanged: (f) =>
            setState(() => _config = _config.copyWith(forma: f)),
      ),
      SpeedSelector(
        value: _config.velocidad,
        onChanged: (v) =>
            setState(() => _config = _config.copyWith(velocidad: v)),
      ),
      MovementSelector(
        value: _config.movimiento,
        onChanged: (m) =>
            setState(() => _config = _config.copyWith(movimiento: m)),
      ),
      DistanceSelector(
        modo: _config.distanciaModo,
        distanciaPct: _config.distanciaPct,
        onModoChanged: (m) =>
            setState(() => _config = _config.copyWith(distanciaModo: m)),
        onDistChanged: (d) =>
            setState(() => _config = _config.copyWith(distanciaPct: d)),
      ),
      _DurationCard(
        value: _config.duracionSegundos,
        onChanged: (v) =>
            setState(() => _config = _config.copyWith(duracionSegundos: v)),
      ),
      _SizeCard(
        value: _config.tamanoPorc,
        onChanged: (v) =>
            setState(() => _config = _config.copyWith(tamanoPorc: v)),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración de la prueba')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: cards.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (_, i) => cards[i],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Iniciar'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DynamicPeripheryTest(config: _config),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationCard extends StatelessWidget {
  final int value; // segundos
  final ValueChanged<int> onChanged;
  const _DurationCard({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
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
              label: '${value}s',
              onChanged: (v) => onChanged(v.round()),
            ),
          ],
        ),
      ),
    );
  }
}

class _SizeCard extends StatelessWidget {
  final double value; // %
  final ValueChanged<double> onChanged;
  const _SizeCard({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
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
