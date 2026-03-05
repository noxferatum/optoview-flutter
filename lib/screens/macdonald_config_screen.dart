import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/test_config.dart';
import '../models/macdonald_config.dart';
import '../models/macdonald_presets.dart';
import '../services/config_storage.dart';

import '../widgets/config/speed_selector.dart';
import '../widgets/config/section_card.dart';
import '../widgets/config/duration_card.dart';
import '../widgets/config/size_card.dart';
import '../widgets/config/fixation_selector.dart';
import '../widgets/config/stimulus_color_selector.dart';
import '../widgets/config/presets_row.dart';

import 'macdonald_test.dart';

class MacDonaldConfigScreen extends StatefulWidget {
  const MacDonaldConfigScreen({super.key});

  @override
  State<MacDonaldConfigScreen> createState() => _MacDonaldConfigScreenState();
}

class _MacDonaldConfigScreenState extends State<MacDonaldConfigScreen> {
  MacDonaldConfig config = MacDonaldPresets.standard;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedConfig();
  }

  Future<void> _loadSavedConfig() async {
    final saved = await ConfigStorage.loadMacDonaldConfig();
    if (mounted) {
      setState(() {
        if (saved != null) config = saved;
        _isLoading = false;
      });
    }
  }

  void _startTest() {
    ConfigStorage.saveMacDonaldConfig(config);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MacDonaldTest(config: config),
      ),
    );
  }

  String _interactionLabel(AppLocalizations l, MacInteraccion mode) =>
      switch (mode) {
        MacInteraccion.tocarLetras => l.macInteractionTouch,
        MacInteraccion.lecturaConTiempo => l.macInteractionTimed,
        MacInteraccion.lecturaSecuencial => l.macInteractionSequential,
      };

  String _interactionDesc(AppLocalizations l, MacInteraccion mode) =>
      switch (mode) {
        MacInteraccion.tocarLetras => l.macInteractionTouchDesc,
        MacInteraccion.lecturaConTiempo => l.macInteractionTimedDesc,
        MacInteraccion.lecturaSecuencial => l.macInteractionSequentialDesc,
      };

  String _visualizationLabel(AppLocalizations l, MacVisualizacion mode) =>
      switch (mode) {
        MacVisualizacion.completa => l.macVisualizationComplete,
        MacVisualizacion.progresiva => l.macVisualizationProgressive,
        MacVisualizacion.porAnillos => l.macVisualizationByRings,
      };

  String _visualizationDesc(AppLocalizations l, MacVisualizacion mode) =>
      switch (mode) {
        MacVisualizacion.completa => l.macVisualizationCompleteDesc,
        MacVisualizacion.progresiva => l.macVisualizationProgressiveDesc,
        MacVisualizacion.porAnillos => l.macVisualizationByRingsDesc,
      };

  String _directionLabel(AppLocalizations l, MacDireccion dir) =>
      switch (dir) {
        MacDireccion.centroAfuera => l.macDirectionCenterOut,
        MacDireccion.afueraCentro => l.macDirectionOutCenter,
        MacDireccion.horario => l.macDirectionClockwise,
        MacDireccion.antihorario => l.macDirectionCounterClockwise,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.configMacdonaldTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              // Presets
              PresetsRow<MacDonaldConfig>(
                presets: MacDonaldPresets.all(l),
                onPresetSelected: (preset) => setState(() {
                  config = preset;
                }),
              ),
              const Divider(height: 24),

              // Modo de interacción
              SectionCard(
                title: l.macInteractionTitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<MacInteraccion>(
                      segments: MacInteraccion.values
                          .map((m) => ButtonSegment(
                                value: m,
                                label: Text(_interactionLabel(l, m)),
                              ))
                          .toList(),
                      selected: {config.interaccion},
                      onSelectionChanged: (s) => setState(() {
                        config = config.copyWith(interaccion: s.first);
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _interactionDesc(l, config.interaccion),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Modo de visualización
              SectionCard(
                title: l.macVisualizationTitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<MacVisualizacion>(
                      segments: MacVisualizacion.values
                          .map((m) => ButtonSegment(
                                value: m,
                                label: Text(_visualizationLabel(l, m)),
                              ))
                          .toList(),
                      selected: {config.visualizacion},
                      onSelectionChanged: (s) => setState(() {
                        config = config.copyWith(visualizacion: s.first);
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _visualizationDesc(l, config.visualizacion),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Dirección de lectura
              SectionCard(
                title: l.macDirectionTitle,
                child: SegmentedButton<MacDireccion>(
                  segments: MacDireccion.values
                      .map((d) => ButtonSegment(
                            value: d,
                            label: Text(_directionLabel(l, d)),
                          ))
                      .toList(),
                  selected: {config.direccion},
                  onSelectionChanged: (s) => setState(() {
                    config = config.copyWith(direccion: s.first);
                  }),
                ),
              ),
              const SizedBox(height: 16),

              // Tipo de contenido
              SectionCard(
                title: l.macContentTitle,
                child: SegmentedButton<MacContenido>(
                  segments: [
                    ButtonSegment(
                      value: MacContenido.letras,
                      label: Text(l.macContentLetters),
                    ),
                    ButtonSegment(
                      value: MacContenido.numeros,
                      label: Text(l.macContentNumbers),
                    ),
                  ],
                  selected: {config.contenido},
                  onSelectionChanged: (s) => setState(() {
                    config = config.copyWith(contenido: s.first);
                  }),
                ),
              ),
              const SizedBox(height: 16),

              // Número de anillos
              SectionCard(
                title: l.macRingsTitle,
                child: Slider(
                  value: config.numAnillos.toDouble(),
                  min: 2,
                  max: 5,
                  divisions: 3,
                  label: '${config.numAnillos}',
                  onChanged: (v) => setState(() {
                    config = config.copyWith(numAnillos: v.round());
                  }),
                ),
              ),
              const SizedBox(height: 16),

              // Letras por anillo
              SectionCard(
                title: l.macLettersPerRingTitle,
                child: Slider(
                  value: config.letrasPorAnillo.toDouble(),
                  min: 4,
                  max: 12,
                  divisions: 8,
                  label: '${config.letrasPorAnillo}',
                  onChanged: (v) => setState(() {
                    config = config.copyWith(letrasPorAnillo: v.round());
                  }),
                ),
              ),
              const SizedBox(height: 16),

              // Letras aleatorias
              SectionCard(
                title: l.macRandomLetters,
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: config.letrasAleatorias,
                  onChanged: (v) => setState(() {
                    config = config.copyWith(letrasAleatorias: v);
                  }),
                  title: Text(l.macRandomLetters),
                  subtitle: Text(l.macRandomLettersSubtitle),
                ),
              ),
              const SizedBox(height: 16),

              // Velocidad de revelado (solo si no es completa)
              if (config.visualizacion != MacVisualizacion.completa) ...[
                SpeedSelector(
                  value: config.velocidadRevelado,
                  onChanged: (v) => setState(() {
                    config = config.copyWith(velocidadRevelado: v);
                  }),
                ),
                const SizedBox(height: 16),
              ],

              // Duración
              DurationCard(
                value: config.duracionSegundos,
                onChanged: (v) => setState(() {
                  config = config.copyWith(duracionSegundos: v);
                }),
              ),
              const SizedBox(height: 16),

              // Tamaño de letra
              SizeCard(
                value: config.tamanoBase,
                onChanged: (v) => setState(() {
                  config = config.copyWith(tamanoBase: v);
                }),
              ),
              const SizedBox(height: 16),

              // Fijación
              FixationSelector(
                value: config.fijacion,
                onChanged: (v) => setState(() {
                  config = config.copyWith(fijacion: v);
                }),
              ),

              const Divider(height: 32),

              // Fondo (sin distractor para este test)
              SectionCard(
                title: l.backgroundTitle,
                child: SegmentedButton<Fondo>(
                  segments: [
                    ButtonSegment(
                        value: Fondo.claro, label: Text(l.backgroundLight)),
                    ButtonSegment(
                        value: Fondo.oscuro, label: Text(l.backgroundDark)),
                    ButtonSegment(
                        value: Fondo.azul, label: Text(l.backgroundBlue)),
                  ],
                  selected: {config.fondo},
                  onSelectionChanged: (s) => setState(() {
                    config = config.copyWith(fondo: s.first);
                  }),
                ),
              ),
              const SizedBox(height: 16),

              // Color de letras
              StimulusColorSelector(
                value: config.colorLetras,
                onChanged: (v) => setState(() {
                  config = config.copyWith(colorLetras: v);
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
