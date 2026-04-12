import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/test_result.dart';
import '../models/saved_result.dart';
import '../services/results_storage.dart';
import '../theme/opto_colors.dart';
import '../theme/opto_spacing.dart';
import '../utils/page_transitions.dart';
import 'dynamic_periphery_test.dart';

class TestResultsScreen extends StatefulWidget {
  final TestResult result;

  const TestResultsScreen({super.key, required this.result});

  @override
  State<TestResultsScreen> createState() => _TestResultsScreenState();
}

class _TestResultsScreenState extends State<TestResultsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l = AppLocalizations.of(context)!;
      final saved = SavedResult.fromTestResult(widget.result, l);
      ResultsStorage.save(saved);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final result = widget.result;
    final summary = result.config.localizedSummary(l);
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      backgroundColor: OptoColors.backgroundDark,
      body: Column(
        children: [
          _buildTopBar(context, l, result),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT COLUMN -- stats
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(OptoSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusBanner(l, result),
                        const SizedBox(height: OptoSpacing.md),
                        _buildSectionLabel(l.statsTitle),
                        const SizedBox(height: OptoSpacing.sm),
                        _buildStatsGrid(l, result),
                        const SizedBox(height: OptoSpacing.md),
                        _buildSectionLabel(l.configUsedTitle),
                        const SizedBox(height: OptoSpacing.sm),
                        _buildConfigTags(summary),
                      ],
                    ),
                  ),
                ),
                // RIGHT COLUMN -- heatmap placeholder
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(OptoSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDateRow(dateFmt, result),
                        const SizedBox(height: OptoSpacing.md),
                        _buildHeatmapPlaceholder(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top bar
  // ---------------------------------------------------------------------------

  Widget _buildTopBar(
    BuildContext context,
    AppLocalizations l,
    TestResult result,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OptoSpacing.sm,
        vertical: OptoSpacing.xs,
      ),
      decoration: const BoxDecoration(
        color: OptoColors.surfaceDark,
        border: Border(
          bottom: BorderSide(color: OptoColors.surfaceVariantDark),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: OptoColors.onSurfaceDark),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            const SizedBox(width: OptoSpacing.sm),
            Expanded(
              child: Text(
                l.resultsTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: OptoColors.onSurfaceDark,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildGlassButton(
                  icon: Icons.replay,
                  label: l.resultsRepeat,
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      OptoPageRoute(
                        builder: (_) => DynamicPeripheryTest(
                          config: result.config,
                          patientName: result.patientName,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: OptoSpacing.sm),
                _buildGlassButton(
                  icon: Icons.home,
                  label: l.resultsHome,
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(OptoSpacing.radiusChip),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: OptoSpacing.md,
            vertical: OptoSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: OptoColors.primary.withAlpha(31),
            borderRadius: BorderRadius.circular(OptoSpacing.radiusChip),
            border: Border.all(color: OptoColors.primary.withAlpha(51)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: OptoColors.primaryPattern),
              const SizedBox(width: OptoSpacing.xs),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: OptoColors.primaryPattern,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Status banner
  // ---------------------------------------------------------------------------

  Widget _buildStatusBanner(AppLocalizations l, TestResult result) {
    final isComplete = result.completedNaturally;
    final statusColor = isComplete ? OptoColors.success : OptoColors.warning;
    final statusText = isComplete ? l.resultsCompleted : l.resultsStopped;
    final statusIcon = isComplete
        ? Icons.check_circle_outline
        : Icons.stop_circle_outlined;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(OptoSpacing.md),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(31),
        borderRadius: BorderRadius.circular(OptoSpacing.radiusCard),
        border: Border.all(color: statusColor.withAlpha(51)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          const SizedBox(width: OptoSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
                if (result.patientName.isNotEmpty) ...[
                  const SizedBox(height: OptoSpacing.xs),
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 14,
                        color: OptoColors.onSurfaceVariantDark,
                      ),
                      const SizedBox(width: OptoSpacing.xs),
                      Flexible(
                        child: Text(
                          result.patientName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: OptoColors.onSurfaceVariantDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section label
  // ---------------------------------------------------------------------------

  Widget _buildSectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
        color: OptoColors.onSurfaceVariantDark,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Stats grid
  // ---------------------------------------------------------------------------

  Widget _buildStatsGrid(AppLocalizations l, TestResult result) {
    return Wrap(
      spacing: OptoSpacing.sm,
      runSpacing: OptoSpacing.sm,
      children: [
        _StatBox(
          label: l.statsActualDuration,
          value: '${result.durationActualSeconds}s',
          icon: Icons.timer,
        ),
        _StatBox(
          label: l.statsConfigDuration,
          value: '${result.config.duracionSegundos}s',
          icon: Icons.settings,
        ),
        _StatBox(
          label: l.statsStimuliShown,
          value: '${result.totalStimuliShown}',
          icon: Icons.visibility,
        ),
        if (result.durationActualSeconds > 0)
          _StatBox(
            label: l.statsStimuliPerMinute,
            value: result.stimuliPerMinute.toStringAsFixed(1),
            icon: Icons.speed,
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Config tags
  // ---------------------------------------------------------------------------

  Widget _buildConfigTags(Map<String, String> summary) {
    return Wrap(
      spacing: OptoSpacing.sm,
      runSpacing: OptoSpacing.sm,
      children: summary.entries.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: OptoSpacing.sm,
            vertical: OptoSpacing.xs + 2,
          ),
          decoration: BoxDecoration(
            color: OptoColors.surfaceDark,
            borderRadius: BorderRadius.circular(OptoSpacing.radiusChip),
            border: Border.all(color: OptoColors.surfaceVariantDark),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: OptoColors.onSurfaceVariantDark,
                ),
              ),
              const SizedBox(width: OptoSpacing.xs),
              Container(
                width: 1,
                height: 12,
                color: OptoColors.surfaceVariantDark,
              ),
              const SizedBox(width: OptoSpacing.xs),
              Text(
                entry.value,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: OptoColors.onSurfaceDark,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Date row
  // ---------------------------------------------------------------------------

  Widget _buildDateRow(DateFormat dateFmt, TestResult result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(OptoSpacing.md),
      decoration: BoxDecoration(
        color: OptoColors.surfaceDark,
        borderRadius: BorderRadius.circular(OptoSpacing.radiusCard),
        border: Border.all(color: OptoColors.surfaceVariantDark),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today,
            size: 16,
            color: OptoColors.onSurfaceVariantDark,
          ),
          const SizedBox(width: OptoSpacing.sm),
          Text(
            dateFmt.format(result.startedAt),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: OptoColors.onSurfaceDark,
            ),
          ),
          const SizedBox(width: OptoSpacing.md),
          const Icon(
            Icons.arrow_forward,
            size: 14,
            color: OptoColors.subtleDark,
          ),
          const SizedBox(width: OptoSpacing.md),
          Text(
            dateFmt.format(result.finishedAt),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: OptoColors.onSurfaceDark,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Heatmap placeholder
  // ---------------------------------------------------------------------------

  Widget _buildHeatmapPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(OptoSpacing.xl),
      decoration: BoxDecoration(
        color: OptoColors.surfaceDark,
        borderRadius: BorderRadius.circular(OptoSpacing.radiusCard),
        border: Border.all(color: OptoColors.surfaceVariantDark),
      ),
      child: Column(
        children: [
          Icon(
            Icons.grid_off_rounded,
            size: 48,
            color: OptoColors.subtleDark.withAlpha(128),
          ),
          const SizedBox(height: OptoSpacing.md),
          const Text(
            'No hay datos de posicion para este test',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: OptoColors.onSurfaceVariantDark,
            ),
          ),
          const SizedBox(height: OptoSpacing.xs),
          const Text(
            'Los mapas de calor estan disponibles para los tests de localizacion y MacDonald',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: OptoColors.subtleDark,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// _StatBox
// =============================================================================

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(OptoSpacing.md),
      decoration: BoxDecoration(
        color: OptoColors.surfaceDark,
        borderRadius: BorderRadius.circular(OptoSpacing.radiusCard),
        border: Border.all(color: OptoColors.surfaceVariantDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: OptoColors.primary),
          const SizedBox(height: OptoSpacing.sm),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: OptoColors.onSurfaceDark,
            ),
          ),
          const SizedBox(height: OptoSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: OptoColors.onSurfaceVariantDark,
            ),
          ),
        ],
      ),
    );
  }
}
