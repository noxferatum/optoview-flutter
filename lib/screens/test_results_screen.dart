import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/test_result.dart';
import '../models/saved_result.dart';
import '../services/results_storage.dart';
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
    final theme = Theme.of(context);
    final result = widget.result;
    final summary = result.config.localizedSummary(l);
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(l.resultsTitle),
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
                if (result.patientName.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        result.patientName,
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  dateFmt.format(result.startedAt),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 24),

                // Estadísticas
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
                          label: l.statsStimuliShown,
                          value: '${result.totalStimuliShown}',
                        ),
                        if (result.durationActualSeconds > 0)
                          _StatRow(
                            label: l.statsStimuliPerMinute,
                            value: result.stimuliPerMinute.toStringAsFixed(1),
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
                            builder: (_) => DynamicPeripheryTest(
                              config: result.config,
                              patientName: result.patientName,
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

  const _StatRow({required this.label, required this.value});

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
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
