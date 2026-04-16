import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/test_config.dart';
import '../models/macdonald_config.dart';
import '../models/macdonald_presets.dart';
import '../services/config_storage.dart';
import '../theme/opto_colors.dart';
import '../utils/page_transitions.dart';

import '../widgets/config/speed_selector.dart';
import '../widgets/config/section_card.dart';
import '../widgets/config/duration_card.dart';
import '../widgets/config/size_card.dart';
import '../widgets/config/fixation_selector.dart';
import '../widgets/config/stimulus_color_selector.dart';
import '../widgets/config/presets_row.dart';
import '../widgets/config_shared/config_bottom_bar.dart';

import 'macdonald_test.dart';

class MacDonaldConfigScreen extends StatefulWidget {
  const MacDonaldConfigScreen({super.key});

  @override
  State<MacDonaldConfigScreen> createState() => _MacDonaldConfigScreenState();
}

class _MacDonaldConfigScreenState extends State<MacDonaldConfigScreen> {
  MacDonaldConfig config = MacDonaldPresets.standard;
  bool _isLoading = true;
  bool _showInstructions = true;
  final _patientController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedConfig();
  }

  @override
  void dispose() {
    _patientController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedConfig() async {
    final saved = await ConfigStorage.loadMacDonaldConfig();
    final name = await ConfigStorage.loadPatientName();
    final showInstr = await ConfigStorage.loadShowInstructions();
    if (mounted) {
      setState(() {
        if (saved != null) config = saved;
        _patientController.text = name;
        _showInstructions = showInstr;
        _isLoading = false;
      });
    }
  }

  void _startTest() {
    ConfigStorage.saveMacDonaldConfig(config);
    ConfigStorage.savePatientName(_patientController.text.trim());
    Navigator.push(
      context,
      OptoPageRoute(
        builder: (_) => MacDonaldTest(
          config: config,
          patientName: _patientController.text.trim(),
        ),
      ),
    );
  }

  String _interactionLabel(AppLocalizations l, MacInteraccion mode) =>
      switch (mode) {
        MacInteraccion.tocarLetras => l.macInteractionTouch,
        MacInteraccion.lecturaConTiempo => l.macInteractionTimed,
        MacInteraccion.lecturaSecuencial => l.macInteractionSequential,
        MacInteraccion.deteccionCampo => l.macInteractionFieldDetection,
      };

  String _interactionDesc(AppLocalizations l, MacInteraccion mode) =>
      switch (mode) {
        MacInteraccion.tocarLetras => l.macInteractionTouchDesc,
        MacInteraccion.lecturaConTiempo => l.macInteractionTimedDesc,
        MacInteraccion.lecturaSecuencial => l.macInteractionSequentialDesc,
        MacInteraccion.deteccionCampo => l.macInteractionFieldDetectionDesc,
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

  String _buildSummary(AppLocalizations l) {
    return '${_interactionLabel(l, config.interaccion)} · ${config.contenido.name} · ${config.numAnillos} anillos · ${config.duracionSegundos}s';
  }

  Widget _buildAppBar(AppLocalizations l) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            l.configMacdonaldTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
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
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            _buildAppBar(l),
            const _MacDonaldConfigTabBar(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildGeneralTab(l),
                  _buildCartaTab(l),
                  _buildVisualTab(l),
                  _buildTimeTab(l),
                ],
              ),
            ),
            ConfigBottomBar(
              summary: _buildSummary(l),
              onStart: _startTest,
              startLabel: l.startTest,
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab 1: General ──────────────────────────────────────────────────

  Widget _buildGeneralTab(AppLocalizations l) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column
            Expanded(
              child: Column(
                children: [
                  TextField(
                    controller: _patientController,
                    decoration: InputDecoration(
                      labelText: l.patientName,
                      hintText: l.patientNameHint,
                      prefixIcon: const Icon(Icons.person),
                      border: const OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  SwitchListTile(
                    value: _showInstructions,
                    onChanged: (v) {
                      setState(() => _showInstructions = v);
                      ConfigStorage.saveShowInstructions(v);
                    },
                    title: Text(l.showInstructions),
                    subtitle: Text(l.showInstructionsSubtitle),
                    secondary: const Icon(Icons.info_outline),
                  ),
                  const SizedBox(height: 16),
                  PresetsRow<MacDonaldConfig>(
                    presets: MacDonaldPresets.all(l),
                    onPresetSelected: (preset) => setState(() {
                      config = preset;
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Right column
            Expanded(
              child: Column(
                children: [
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab 2: Carta ────────────────────────────────────────────────────

  Widget _buildCartaTab(AppLocalizations l) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column
            Expanded(
              child: Column(
                children: [
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
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Right column
            Expanded(
              child: Column(
                children: [
                  if (config.interaccion != MacInteraccion.deteccionCampo) ...[
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
                  ],
                  if (config.visualizacion != MacVisualizacion.completa ||
                      config.interaccion == MacInteraccion.deteccionCampo)
                    SpeedSelector(
                      value: config.velocidadRevelado,
                      onChanged: (v) => setState(() {
                        config = config.copyWith(velocidadRevelado: v);
                      }),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab 3: Visual ───────────────────────────────────────────────────

  Widget _buildVisualTab(AppLocalizations l) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column
            Expanded(
              child: Column(
                children: [
                  FixationSelector(
                    value: config.fijacion,
                    onChanged: (v) => setState(() {
                      config = config.copyWith(fijacion: v);
                    }),
                  ),
                  const SizedBox(height: 16),
                  StimulusColorSelector(
                    value: config.colorLetras,
                    onChanged: (v) => setState(() {
                      config = config.copyWith(colorLetras: v);
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Right column
            Expanded(
              child: Column(
                children: [
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
                  SizeCard(
                    value: config.tamanoBase,
                    onChanged: (v) => setState(() {
                      config = config.copyWith(tamanoBase: v);
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab 4: Tiempo ───────────────────────────────────────────────────

  Widget _buildTimeTab(AppLocalizations l) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: DurationCard(
              value: config.duracionSegundos,
              onChanged: (v) => setState(() {
                config = config.copyWith(duracionSegundos: v);
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Tab Bar ─────────────────────────────────────────────────────────────

class _MacDonaldConfigTabBar extends StatelessWidget {
  const _MacDonaldConfigTabBar();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TabBar(
      labelColor: OptoColors.primary,
      unselectedLabelColor: colorScheme.onSurfaceVariant,
      indicatorColor: OptoColors.primary,
      indicatorSize: TabBarIndicatorSize.label,
      tabs: const [
        Tab(icon: Icon(Icons.tune), text: 'General'),
        Tab(icon: Icon(Icons.grid_view), text: 'Carta'),
        Tab(icon: Icon(Icons.visibility), text: 'Visual'),
        Tab(icon: Icon(Icons.timer), text: 'Tiempo'),
      ],
    );
  }
}
