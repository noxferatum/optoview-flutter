import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/localization_config.dart';
import '../models/localization_presets.dart';
import '../services/config_storage.dart';

import '../widgets/config/side_selector.dart';
import '../widgets/config/symbol_selector.dart';
import '../widgets/config/speed_selector.dart';
import '../widgets/config/distance_selector.dart';
import '../widgets/config/background_selector.dart';
import '../widgets/config/section_card.dart';
import '../widgets/config/duration_card.dart';
import '../widgets/config/size_card.dart';
import '../widgets/config/presets_row.dart';

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

  String _locModeLabel(AppLocalizations l, LocalizationMode mode) =>
      switch (mode) {
        LocalizationMode.tocarTodos => l.locModeTouchAll,
        LocalizationMode.igualarCentro => l.locModeMatchCenter,
        LocalizationMode.mismoColor => l.locModeSameColor,
        LocalizationMode.mismaForma => l.locModeSameShape,
      };

  String _locModeDescription(AppLocalizations l, LocalizationMode mode) =>
      switch (mode) {
        LocalizationMode.tocarTodos => l.locModeTouchAllDesc,
        LocalizationMode.igualarCentro => l.locModeMatchCenterDesc,
        LocalizationMode.mismoColor => l.locModeSameColorDesc,
        LocalizationMode.mismaForma => l.locModeSameShapeDesc,
      };

  String _disappearLabel(AppLocalizations l, DisappearMode mode) =>
      switch (mode) {
        DisappearMode.porTiempo => l.locDisappearByTime,
        DisappearMode.esperarToque => l.locDisappearWaitTouch,
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
      appBar: AppBar(title: Text(l.configLocalizationTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
          children: [
            // Presets
            PresetsRow<LocalizationConfig>(
              presets: LocalizationPresets.all,
              onPresetSelected: (preset) => setState(() {
                config = preset;
              }),
            ),
            const Divider(height: 24),

            // Modo de localización
            SectionCard(
              title: l.locModeTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<LocalizationMode>(
                    segments: LocalizationMode.values
                        .map((m) => ButtonSegment(
                              value: m,
                              label: Text(_locModeLabel(l, m)),
                            ))
                        .toList(),
                    selected: {config.modo},
                    onSelectionChanged: (s) => setState(() {
                      config = config.copyWith(modo: s.first);
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _locModeDescription(l, config.modo),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Opciones de localización
            SectionCard(
              title: l.locInteractionTitle,
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: config.centroFijo,
                    onChanged: (v) => setState(() {
                      config = config.copyWith(centroFijo: v);
                    }),
                    title: Text(l.locCenterFixed),
                    subtitle: Text(
                      config.centroFijo
                          ? l.locCenterFixedOn
                          : l.locCenterFixedOff,
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: config.feedbackVisual,
                    onChanged: (v) => setState(() {
                      config = config.copyWith(feedbackVisual: v);
                    }),
                    title: Text(l.locFeedback),
                    subtitle: Text(l.locFeedbackSubtitle),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(l.locDisappearTitle,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<DisappearMode>(
                    segments: DisappearMode.values
                        .map((m) => ButtonSegment(
                              value: m,
                              label: Text(_disappearLabel(l, m)),
                            ))
                        .toList(),
                    selected: {config.desaparicion},
                    onSelectionChanged: (s) => setState(() {
                      config = config.copyWith(desaparicion: s.first);
                    }),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(l.locSimultaneousTitle,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
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
              onChanged: (v) => setState(() {
                config = config.copyWith(tamanoPorc: v);
              }),
            ),

            const Divider(height: 32),

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
