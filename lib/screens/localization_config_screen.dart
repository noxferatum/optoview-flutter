import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/localization_config.dart';
import '../models/localization_presets.dart';
import '../services/config_storage.dart';
import '../theme/opto_colors.dart';
import '../utils/page_transitions.dart';

import '../widgets/config/side_selector.dart';
import '../widgets/config/symbol_selector.dart';
import '../widgets/config/speed_selector.dart';
import '../widgets/config/distance_selector.dart';
import '../widgets/config/background_selector.dart';
import '../widgets/config/section_card.dart';
import '../widgets/config/duration_card.dart';
import '../widgets/config/size_card.dart';
import '../widgets/config/presets_row.dart';
import '../widgets/config_shared/config_bottom_bar.dart';

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
    final saved = await ConfigStorage.loadLocalizationConfig();
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
    ConfigStorage.saveLocalizationConfig(config);
    ConfigStorage.savePatientName(_patientController.text.trim());
    Navigator.push(
      context,
      OptoPageRoute(
        builder: (_) => LocalizationTest(
          config: config,
          patientName: _patientController.text.trim(),
        ),
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

  String _buildSummary(AppLocalizations l) {
    return '${_locModeLabel(l, config.modo)} · ${config.lado.name} · ${config.velocidad.name} · ${config.duracionSegundos}s';
  }

  Widget _buildAppBar(AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        color: OptoColors.surfaceDark,
        border: Border(bottom: BorderSide(color: OptoColors.surfaceVariantDark)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: OptoColors.onSurfaceDark),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            l.configLocalizationTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: OptoColors.onSurfaceDark,
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
        backgroundColor: OptoColors.backgroundDark,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: OptoColors.backgroundDark,
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            _buildAppBar(l),
            const _LocConfigTabBar(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildGeneralTab(l),
                  _buildModoTab(l),
                  _buildEstimuloTab(l),
                  _buildVisualTab(l),
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
                  PresetsRow<LocalizationConfig>(
                    presets: LocalizationPresets.all,
                    onPresetSelected: (preset) => setState(() {
                      config = preset;
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  SideSelector(
                    value: config.lado,
                    onChanged: (v) => setState(() {
                      config = config.copyWith(lado: v);
                    }),
                  ),
                  const SizedBox(height: 16),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab 2: Modo ─────────────────────────────────────────────────────

  Widget _buildModoTab(AppLocalizations l) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
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
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab 3: Estímulo ─────────────────────────────────────────────────

  Widget _buildEstimuloTab(AppLocalizations l) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  SpeedSelector(
                    value: config.velocidad,
                    onChanged: (v) => setState(() {
                      config = config.copyWith(velocidad: v);
                    }),
                  ),
                  const SizedBox(height: 16),
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
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  SizeCard(
                    value: config.tamanoPorc,
                    onChanged: (v) => setState(() {
                      config = config.copyWith(tamanoPorc: v);
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

  // ── Tab 4: Visual ───────────────────────────────────────────────────

  Widget _buildVisualTab(AppLocalizations l) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
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
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  DurationCard(
                    value: config.duracionSegundos,
                    onChanged: (v) => setState(() {
                      config = config.copyWith(duracionSegundos: v);
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
}

// ── Tab Bar ─────────────────────────────────────────────────────────────

class _LocConfigTabBar extends StatelessWidget {
  const _LocConfigTabBar();

  @override
  Widget build(BuildContext context) {
    return const TabBar(
      labelColor: OptoColors.primary,
      unselectedLabelColor: OptoColors.onSurfaceVariantDark,
      indicatorColor: OptoColors.primary,
      indicatorSize: TabBarIndicatorSize.label,
      tabs: [
        Tab(icon: Icon(Icons.tune), text: 'General'),
        Tab(icon: Icon(Icons.touch_app), text: 'Modo'),
        Tab(icon: Icon(Icons.auto_awesome), text: 'Estímulo'),
        Tab(icon: Icon(Icons.visibility), text: 'Visual'),
      ],
    );
  }
}
