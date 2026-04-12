import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/test_config.dart';
import '../models/test_presets.dart';
import '../services/config_storage.dart';
import '../theme/opto_colors.dart';
import '../utils/page_transitions.dart';

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
import '../widgets/config_shared/config_bottom_bar.dart';

import 'dynamic_periphery_test.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  TestConfig config = TestPresets.standard;
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
    final saved = await ConfigStorage.loadConfig();
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
    ConfigStorage.saveConfig(config);
    ConfigStorage.savePatientName(_patientController.text.trim());
    Navigator.push(
      context,
      OptoPageRoute(
        builder: (_) => DynamicPeripheryTest(
          config: config,
          patientName: _patientController.text.trim(),
        ),
      ),
    );
  }

  String _buildSummary(AppLocalizations l) {
    return '${config.lado.name} · ${config.categoria.name} · ${config.velocidad.name} · ${config.duracionSegundos}s';
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
            l.configPeripheralTitle,
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
            // Custom app bar
            _buildAppBar(l),

            // Tab bar
            const _ConfigTabBar(),

            // Tab content
            Expanded(
              child: TabBarView(
                children: [
                  _buildGeneralTab(l),
                  _buildStimulusTab(l),
                  _buildVisualTab(l),
                  _buildTimeTab(l),
                ],
              ),
            ),

            // Bottom bar
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
                  PresetsRow<TestConfig>(
                    presets: TestPresets.all,
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
                  SideSelector(
                    value: config.lado,
                    onChanged: (v) => setState(() {
                      config = config.copyWith(lado: v);
                    }),
                  ),
                  const SizedBox(height: 16),
                  SpeedSelector(
                    value: config.velocidad,
                    onChanged: (v) => setState(() {
                      config = config.copyWith(velocidad: v);
                    }),
                  ),
                  const SizedBox(height: 16),
                  MovementSelector(
                    value: config.movimiento,
                    onChanged: (m) => setState(() {
                      config = config.copyWith(movimiento: m);
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

  // ── Tab 2: Estímulo ─────────────────────────────────────────────────

  Widget _buildStimulusTab(AppLocalizations l) {
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
                  StimulusColorSelector(
                    value: config.estimuloColor,
                    onChanged: (value) => setState(() {
                      config = config.copyWith(estimuloColor: value);
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
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Right column
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

class _ConfigTabBar extends StatelessWidget {
  const _ConfigTabBar();

  @override
  Widget build(BuildContext context) {
    return const TabBar(
      labelColor: OptoColors.primary,
      unselectedLabelColor: OptoColors.onSurfaceVariantDark,
      indicatorColor: OptoColors.primary,
      indicatorSize: TabBarIndicatorSize.label,
      tabs: [
        Tab(icon: Icon(Icons.tune), text: 'General'),
        Tab(icon: Icon(Icons.auto_awesome), text: 'Estímulo'),
        Tab(icon: Icon(Icons.visibility), text: 'Visual'),
        Tab(icon: Icon(Icons.timer), text: 'Tiempo'),
      ],
    );
  }
}
