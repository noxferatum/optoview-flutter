import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/localization_result.dart';
import 'localization_test.dart';

class LocalizationResultsScreen extends StatelessWidget {
  final LocalizationResult result;

  const LocalizationResultsScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final summary = result.config.summaryMap;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.resultsLocTitle),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                // Estado
                Icon(
                  result.completedNaturally
                      ? Icons.check_circle_outline
                      : Icons.stop_circle_outlined,
                  size: 64,
                  color: result.completedNaturally
                      ? Colors.greenAccent
                      : Colors.orangeAccent,
                ),
                const SizedBox(height: 12),
                Text(
                  result.completedNaturally
                      ? l.resultsCompleted
                      : l.resultsStopped,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),

                // Precisión
                Card(
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l.accuracyTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _StatRow(
                          label: l.accuracyCorrect,
                          value: '${result.correctTouches}',
                          valueColor: Colors.greenAccent,
                        ),
                        _StatRow(
                          label: l.accuracyErrors,
                          value: '${result.incorrectTouches}',
                          valueColor: result.incorrectTouches > 0
                              ? Colors.redAccent
                              : null,
                        ),
                        _StatRow(
                          label: l.accuracyMissed,
                          value: '${result.missedStimuli}',
                          valueColor: result.missedStimuli > 0
                              ? Colors.orangeAccent
                              : null,
                        ),
                        _StatRow(
                          label: l.accuracyPercent,
                          value: '${(result.accuracy * 100).toStringAsFixed(1)}%',
                          valueColor: result.accuracy >= 0.8
                              ? Colors.greenAccent
                              : Colors.orangeAccent,
                        ),
                        _StatRow(
                          label: l.statsStimuliShown,
                          value: '${result.totalStimuliShown}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tiempos de reacción
                if (result.reactionTimesMs.isNotEmpty)
                  Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l.reactionTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _StatRow(
                            label: l.reactionAvg,
                            value:
                                '${result.avgReactionTimeMs.toStringAsFixed(0)} ms',
                          ),
                          _StatRow(
                            label: l.reactionBest,
                            value:
                                '${result.bestReactionTimeMs.toStringAsFixed(0)} ms',
                            valueColor: Colors.greenAccent,
                          ),
                          _StatRow(
                            label: l.reactionWorst,
                            value:
                                '${result.worstReactionTimeMs.toStringAsFixed(0)} ms',
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Estadísticas generales
                Card(
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l.statsTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
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
                            value: result.stimuliPerMinute
                                .toStringAsFixed(1),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Configuración usada
                Card(
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l.configUsedTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...summary.entries.map(
                          (e) =>
                              _StatRow(label: e.key, value: e.value),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Acciones
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => LocalizationTest(
                              config: result.config,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.replay),
                      label: Text(l.resultsRepeat),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).popUntil(
                          (route) => route.isFirst,
                        );
                      },
                      icon: const Icon(Icons.home),
                      label: Text(l.resultsHome),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
          ),
        ],
      ),
    );
  }
}
