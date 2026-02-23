import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/test_config.dart';
import '../models/test_presets.dart';
import '../services/config_storage.dart';

import '../widgets/config/side_selector.dart';
import '../widgets/config/symbol_selector.dart';
import '../widgets/config/speed_selector.dart';
import '../widgets/config/movement_selector.dart';
import '../widgets/config/distance_selector.dart';
import '../widgets/config/fixation_selector.dart';
import '../widgets/config/background_selector.dart';
import '../widgets/config/stimulus_color_selector.dart';
import '../widgets/config/duration_card.dart';
import '../widgets/config/size_card.dart';
import '../widgets/config/presets_row.dart';

import 'dynamic_periphery_test.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  TestConfig config = TestPresets.standard;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedConfig();
  }

  Future<void> _loadSavedConfig() async {
    final saved = await ConfigStorage.loadConfig();
    if (mounted) {
      setState(() {
        if (saved != null) config = saved;
        _isLoading = false;
      });
    }
  }

  void _startTest() {
    ConfigStorage.saveConfig(config);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DynamicPeripheryTest(config: config),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.configPeripheralTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              // Presets
              PresetsRow<TestConfig>(
              presets: TestPresets.all,
              onPresetSelected: (preset) => setState(() {
                config = preset;
              }),
            ),
            const Divider(height: 24),

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
            DurationCard(
              value: config.duracionSegundos,
              onChanged: (v) => setState(() {
                config = config.copyWith(duracionSegundos: v);
              }),
            ),
            const SizedBox(height: 16),

            // Tamaño
            SizeCard(
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
                label: Text(l.startTest),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}
