import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/field_detection_config.dart';
import '../services/config_storage.dart';
import '../theme/opto_colors.dart';
import '../theme/opto_spacing.dart';
import '../utils/page_transitions.dart';
import '../widgets/config_shared/config_bottom_bar.dart';
import '../widgets/design_system/opto_card.dart';
import '../widgets/design_system/opto_section_header.dart';
import 'field_detection_test.dart';

class FieldDetectionConfigScreen extends StatefulWidget {
  const FieldDetectionConfigScreen({super.key});

  @override
  State<FieldDetectionConfigScreen> createState() =>
      _FieldDetectionConfigScreenState();
}

class _FieldDetectionConfigScreenState
    extends State<FieldDetectionConfigScreen> {
  final _patientController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPatientName();
  }

  @override
  void dispose() {
    _patientController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientName() async {
    final name = await ConfigStorage.loadPatientName();
    if (mounted) {
      setState(() => _patientController.text = name);
    }
  }

  void _startTest() {
    ConfigStorage.savePatientName(_patientController.text.trim());
    Navigator.push(
      context,
      OptoPageRoute(
        builder: (_) => FieldDetectionTest(
          config: FieldDetectionConfig.standard,
          patientName: _patientController.text.trim(),
        ),
      ),
    );
  }

  String _buildSummary(AppLocalizations l) {
    final c = FieldDetectionConfig.standard;
    return '${c.numAnillos} ${l.summaryKeyRings.toLowerCase()} · ${c.totalLetras} letras · ${c.tamanoBase.toStringAsFixed(0)}%';
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
            l.configFieldDetectionTitle,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final summary = FieldDetectionConfig.standard.localizedSummary(l);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(l),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(OptoSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Descripción
                    OptoCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: OptoColors.fieldDetection.withAlpha(38),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.visibility,
                              color: OptoColors.fieldDetection,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: OptoSpacing.md),
                          Expanded(
                            child: Text(
                              l.configFieldDetectionDescription,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: OptoSpacing.md),

                    // Resumen de configuración (sólo lectura)
                    const OptoSectionHeader(title: 'Configuración'),
                    const SizedBox(height: OptoSpacing.sm),
                    OptoCard(
                      child: Column(
                        children: summary.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: OptoSpacing.xs,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    entry.key,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    entry.value,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: OptoSpacing.md),

                    // Nombre del paciente
                    OptoSectionHeader(title: l.patientName),
                    const SizedBox(height: OptoSpacing.sm),
                    TextField(
                      controller: _patientController,
                      decoration: InputDecoration(
                        hintText: l.patientNameHint,
                        prefixIcon: const Icon(Icons.person),
                        border: const OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ],
                ),
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
}
