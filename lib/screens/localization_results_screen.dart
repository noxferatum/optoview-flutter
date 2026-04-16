import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/localization_result.dart';
import '../models/saved_result.dart';
import '../services/results_storage.dart';
import '../theme/opto_colors.dart';
import '../theme/opto_spacing.dart';
import '../utils/page_transitions.dart';
import '../widgets/design_system/opto_card.dart';
import 'localization_test.dart';

class LocalizationResultsScreen extends StatefulWidget {
  final LocalizationResult result;

  const LocalizationResultsScreen({super.key, required this.result});

  @override
  State<LocalizationResultsScreen> createState() =>
      _LocalizationResultsScreenState();
}

class _LocalizationResultsScreenState
    extends State<LocalizationResultsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l = AppLocalizations.of(context)!;
      final saved = SavedResult.fromLocalizationResult(widget.result, l);
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
      body: Column(
        children: [
          _buildTopBar(l),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      OptoSpacing.lg,
                      OptoSpacing.md,
                      OptoSpacing.sm,
                      OptoSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildStatusBanner(l, result),
                        const SizedBox(height: OptoSpacing.md),
                        _buildAccuracyCard(l, result),
                        if (result.reactionTimesMs.isNotEmpty) ...[
                          const SizedBox(height: OptoSpacing.md),
                          _buildReactionTimesCard(l, result),
                        ],
                        const SizedBox(height: OptoSpacing.md),
                        _buildGeneralStatsCard(l, result),
                      ],
                    ),
                  ),
                ),
                // Right column
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      OptoSpacing.sm,
                      OptoSpacing.md,
                      OptoSpacing.lg,
                      OptoSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildDateSection(dateFmt, result),
                        const SizedBox(height: OptoSpacing.md),
                        _buildHeatmapPlaceholder(),
                        const SizedBox(height: OptoSpacing.md),
                        _buildConfigTags(l, summary),
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

  // -- Top bar --

  Widget _buildTopBar(AppLocalizations l) {
    final colorScheme = Theme.of(context).colorScheme;
    final result = widget.result;

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: OptoSpacing.sm,
        vertical: OptoSpacing.sm,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: colorScheme.onSurface,
              ),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            const SizedBox(width: OptoSpacing.sm),
            Expanded(
              child: Text(
                l.resultsLocTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  OptoPageRoute(
                    builder: (_) => LocalizationTest(
                      config: result.config,
                      patientName: result.patientName,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.replay, size: 18),
              label: Text(l.resultsRepeat),
              style: TextButton.styleFrom(
                foregroundColor: OptoColors.localization,
              ),
            ),
            const SizedBox(width: OptoSpacing.xs),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.home, size: 18),
              label: Text(l.resultsHome),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -- Status banner --

  Widget _buildStatusBanner(AppLocalizations l, LocalizationResult result) {
    final colorScheme = Theme.of(context).colorScheme;
    final color =
        result.completedNaturally ? OptoColors.success : OptoColors.warning;
    final label =
        result.completedNaturally ? l.resultsCompleted : l.resultsStopped;
    final icon = result.completedNaturally
        ? Icons.check_circle_outline
        : Icons.stop_circle_outlined;

    return Container(
      padding: const EdgeInsets.all(OptoSpacing.md),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(OptoSpacing.radiusCard),
        border: Border.all(color: color.withAlpha(64)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: OptoSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                if (result.patientName.isNotEmpty) ...[
                  const SizedBox(height: OptoSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: OptoSpacing.xs),
                      Flexible(
                        child: Text(
                          result.patientName,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface,
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

  // -- Accuracy card --

  Widget _buildAccuracyCard(AppLocalizations l, LocalizationResult result) {
    final colorScheme = Theme.of(context).colorScheme;
    return OptoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.accuracyTitle,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: OptoSpacing.md),
          _StatRow(
            label: l.accuracyCorrect,
            value: '${result.correctTouches}',
            valueColor: OptoColors.success,
          ),
          _StatRow(
            label: l.accuracyErrors,
            value: '${result.incorrectTouches}',
            valueColor:
                result.incorrectTouches > 0 ? OptoColors.error : null,
          ),
          _StatRow(
            label: l.accuracyMissed,
            value: '${result.missedStimuli}',
            valueColor:
                result.missedStimuli > 0 ? OptoColors.warning : null,
          ),
          _StatRow(
            label: l.accuracyPercent,
            value: '${(result.accuracy * 100).toStringAsFixed(1)}%',
            valueColor: result.accuracy >= 0.8
                ? OptoColors.success
                : OptoColors.warning,
          ),
          _StatRow(
            label: l.statsStimuliShown,
            value: '${result.totalStimuliShown}',
          ),
        ],
      ),
    );
  }

  // -- Reaction times card --

  Widget _buildReactionTimesCard(
    AppLocalizations l,
    LocalizationResult result,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return OptoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.reactionTitle,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: OptoSpacing.md),
          _StatRow(
            label: l.reactionAvg,
            value: '${result.avgReactionTimeMs.toStringAsFixed(0)} ms',
          ),
          _StatRow(
            label: l.reactionBest,
            value: '${result.bestReactionTimeMs.toStringAsFixed(0)} ms',
            valueColor: OptoColors.success,
          ),
          _StatRow(
            label: l.reactionWorst,
            value: '${result.worstReactionTimeMs.toStringAsFixed(0)} ms',
          ),
        ],
      ),
    );
  }

  // -- General stats card --

  Widget _buildGeneralStatsCard(
    AppLocalizations l,
    LocalizationResult result,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return OptoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.statsTitle,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: OptoSpacing.md),
          _StatRow(
            label: l.statsActualDuration,
            value: '${result.durationActualSeconds}s',
          ),
          _StatRow(
            label: l.statsConfigDuration,
            value: '${result.config.duracionSegundos}s',
          ),
          if (result.durationActualSeconds > 0)
            _StatRow(
              label: l.statsStimuliPerMinute,
              value: result.stimuliPerMinute.toStringAsFixed(1),
            ),
        ],
      ),
    );
  }

  // -- Date section --

  Widget _buildDateSection(DateFormat dateFmt, LocalizationResult result) {
    final colorScheme = Theme.of(context).colorScheme;
    return OptoCard(
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: OptoSpacing.sm),
          Text(
            dateFmt.format(result.startedAt),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // -- Heatmap placeholder --

  Widget _buildHeatmapPlaceholder() {
    final colorScheme = Theme.of(context).colorScheme;
    return OptoCard(
      child: Column(
        children: [
          const SizedBox(height: OptoSpacing.lg),
          Icon(
            Icons.grid_on,
            size: 40,
            color: OptoColors.localization.withAlpha(64),
          ),
          const SizedBox(height: OptoSpacing.md),
          Text(
            'Datos de posicion no disponibles\npara este resultado',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: OptoSpacing.lg),
        ],
      ),
    );
  }

  // -- Config tags --

  Widget _buildConfigTags(
    AppLocalizations l,
    Map<String, String> summary,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return OptoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.configUsedTitle,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: OptoSpacing.md),
          Wrap(
            spacing: OptoSpacing.sm,
            runSpacing: OptoSpacing.sm,
            children: summary.entries.map((e) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: OptoSpacing.sm + 2,
                  vertical: OptoSpacing.xs + 2,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius:
                      BorderRadius.circular(OptoSpacing.radiusChip),
                  border: Border.all(
                    color: colorScheme.onSurfaceVariant.withAlpha(64),
                  ),
                ),
                child: Text(
                  '${e.key}: ${e.value}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// -- Stat row --

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: OptoSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
