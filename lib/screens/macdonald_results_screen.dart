import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/macdonald_config.dart';
import '../models/macdonald_result.dart';
import 'macdonald_test.dart';

class MacDonaldResultsScreen extends StatelessWidget {
  final MacDonaldResult result;

  const MacDonaldResultsScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final summary = result.config.localizedSummary(l);
    final isTouchMode =
        result.config.interaccion == MacInteraccion.tocarLetras;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.resultsMacTitle),
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

                  // Precisión (solo modo tocar)
                  if (isTouchMode)
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
                              value: '${result.missedLetras}',
                              valueColor: result.missedLetras > 0
                                  ? Colors.orangeAccent
                                  : null,
                            ),
                            _StatRow(
                              label: l.accuracyPercent,
                              value:
                                  '${(result.accuracy * 100).toStringAsFixed(1)}%',
                              valueColor: result.accuracy >= 0.8
                                  ? Colors.greenAccent
                                  : Colors.orangeAccent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (isTouchMode) const SizedBox(height: 16),

                  // Tiempos de reacción (solo modo tocar)
                  if (isTouchMode && result.reactionTimesMs.isNotEmpty)
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
                  if (isTouchMode && result.reactionTimesMs.isNotEmpty)
                    const SizedBox(height: 16),

                  // Tiempos por anillo
                  if (result.tiempoPorAnillo.isNotEmpty)
                    Card(
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l.macStatsTimePerRing,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...result.tiempoPorAnillo.asMap().entries.map(
                                  (e) => _StatRow(
                                    label: l.macRingLabel(e.key + 1),
                                    value:
                                        '${(e.value / 1000).toStringAsFixed(1)}s',
                                  ),
                                ),
                            if (result.tiempoPorAnillo.length > 1)
                              _StatRow(
                                label: l.macStatsAvgPerRing,
                                value:
                                    '${(result.tiempoPorAnillo.reduce((a, b) => a + b) / result.tiempoPorAnillo.length / 1000).toStringAsFixed(1)}s',
                              ),
                          ],
                        ),
                      ),
                    ),
                  if (result.tiempoPorAnillo.isNotEmpty)
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
                          _StatRow(
                            label: l.macStatsLettersShown,
                            value: '${result.totalLetrasShown}',
                          ),
                          _StatRow(
                            label: l.macStatsRingsCompleted,
                            value: '${result.anillosCompletados}',
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
                            (e) => _StatRow(label: e.key, value: e.value),
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
                              builder: (_) => MacDonaldTest(
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
                          var count = 0;
                          Navigator.of(context).popUntil((_) => count++ >= 2);
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
