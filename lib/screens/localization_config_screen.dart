import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/localization_config.dart';
import '../models/localization_presets.dart';
import '../services/config_storage.dart';

import '../widgets/config/side_selector.dart';
import '../widgets/config/symbol_selector.dart';
import '../widgets/config/speed_selector.dart';
import '../widgets/config/distance_selector.dart';
import '../widgets/config/fixation_selector.dart';
import '../widgets/config/background_selector.dart';
import '../widgets/config/section_card.dart';

import 'localization_test.dart';

class LocalizationConfigScreen extends StatefulWidget {
  const LocalizationConfigScreen({super.key});

  @override
  State<LocalizationConfigScreen> createState() =>
      _LocalizationConfigScreenState();
}

class _LocalizationConfigScreenState extends State<LocalizationConfigScreen> {
  LocalizationConfig config = LocalizationPresets.standard;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedConfig();
  }

  Future<void> _loadSavedConfig() async {
    final saved = await ConfigStorage.loadLocalizationConfig();
    if (mounted) {
      setState(() {
        if (saved != null) config = saved;
        _isLoading = false;
      });
    }
  }

  void _startTest() {
    ConfigStorage.saveLocalizationConfig(config);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocalizationTest(config: config),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Test de localización periférica')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Presets
            _PresetsRow(
              onPresetSelected: (preset) => setState(() {
                config = preset;
              }),
            ),
            const Divider(height: 24),

            // Modo de localización
            SectionCard(
              title: 'Modo de localización',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<LocalizationMode>(
                    segments: LocalizationMode.values
                        .map((m) => ButtonSegment(
                              value: m,
                              label: Text(m.label),
                            ))
                        .toList(),
                    selected: {config.modo},
                    onSelectionChanged: (s) => setState(() {
                      config = config.copyWith(modo: s.first);
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    config.modo.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Opciones de localización
            SectionCard(
              title: 'Opciones de interacción',
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: config.centroFijo,
                    onChanged: (v) => setState(() {
                      config = config.copyWith(centroFijo: v);
                    }),
                    title: const Text('Centro fijo'),
                    subtitle: Text(
                      config.centroFijo
                          ? 'El estímulo central no cambia durante la prueba'
                          : 'El estímulo central cambia cada ciclo',
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: config.feedbackVisual,
                    onChanged: (v) => setState(() {
                      config = config.copyWith(feedbackVisual: v);
                    }),
                    title: const Text('Feedback visual'),
                    subtitle: const Text(
                      'Mostrar indicación visual al tocar (acierto/error)',
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Desaparición del estímulo',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<DisappearMode>(
                    segments: DisappearMode.values
                        .map((m) => ButtonSegment(
                              value: m,
                              label: Text(m.label),
                            ))
                        .toList(),
                    selected: {config.desaparicion},
                    onSelectionChanged: (s) => setState(() {
                      config = config.copyWith(desaparicion: s.first);
                    }),
                  ),
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Estímulos simultáneos',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  Slider(
                    value: config.stimuliSimultaneos.toDouble(),
                    min: 1,
                    max: 4,
                    divisions: 3,
                    label: '${config.stimuliSimultaneos}',
                    onChanged: (v) => setState(() {
                      config = config.copyWith(stimuliSimultaneos: v.round());
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

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

            // Velocidad
            SpeedSelector(
              value: config.velocidad,
              onChanged: (v) => setState(() {
                config = config.copyWith(velocidad: v);
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
              onChanged: (v) => setState(() {
                config = config.copyWith(tamanoPorc: v);
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

            // Fondo
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

class _PresetsRow extends StatelessWidget {
  final ValueChanged<LocalizationConfig> onPresetSelected;

  const _PresetsRow({required this.onPresetSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Presets',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: LocalizationPresets.all.map((preset) {
            return ActionChip(
              avatar: Icon(preset.icon, size: 18),
              label: Text(preset.name),
              tooltip: preset.description,
              onPressed: () => onPresetSelected(preset.config),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
        Text(
          'Selecciona un preset o personaliza cada opción abajo.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
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
              min: AppConstants.minDurationSeconds.toDouble(),
              max: AppConstants.maxDurationSeconds.toDouble(),
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
    final double normalized =
        ((value - AppConstants.minSizePercent) /
                (AppConstants.maxSizePercent - AppConstants.minSizePercent))
            .clamp(0.0, 1.0);

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
              min: AppConstants.minSizePercent,
              max: AppConstants.maxSizePercent,
              divisions: 30,
              label: '${(normalized * 100).round()}%',
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
