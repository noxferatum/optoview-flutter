import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/macdonald_config.dart';
import '../models/macdonald_result.dart';
import '../models/saved_result.dart';
import '../services/results_storage.dart';
import 'macdonald_test.dart';

class MacDonaldResultsScreen extends StatefulWidget {
  final MacDonaldResult result;

  const MacDonaldResultsScreen({super.key, required this.result});

  @override
  State<MacDonaldResultsScreen> createState() =>
      _MacDonaldResultsScreenState();
}

class _MacDonaldResultsScreenState extends State<MacDonaldResultsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l = AppLocalizations.of(context)!;
      final saved = SavedResult.fromMacDonaldResult(widget.result, l);
      ResultsStorage.save(saved);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final result = widget.result;
    final summary = result.config.localizedSummary(l);
    final isTouchMode =
        result.config.interaccion == MacInteraccion.tocarLetras ||
        result.config.interaccion == MacInteraccion.deteccionCampo;
    final isFieldDetection =
        result.config.interaccion == MacInteraccion.deteccionCampo;
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

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

                  // Mapas de aciertos y fallos (solo detección de campo)
                  if (isFieldDetection && result.letterEvents.isNotEmpty) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            elevation: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Text(
                                    l.macHitMapTitle,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  AspectRatio(
                                    aspectRatio: 1,
                                    child: CustomPaint(
                                      painter: _HitMapPainter(
                                        events: result.letterEvents
                                            .where((e) => e.isHit)
                                            .toList(),
                                        dotColor: Colors.greenAccent,
                                        numRings: result.config.numAnillos,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Card(
                            elevation: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Text(
                                    l.macMissMapTitle,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  AspectRatio(
                                    aspectRatio: 1,
                                    child: CustomPaint(
                                      painter: _HitMapPainter(
                                        events: result.letterEvents
                                            .where((e) => !e.isHit)
                                            .toList(),
                                        dotColor: Colors.redAccent,
                                        numRings: result.config.numAnillos,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

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

class _HitMapPainter extends CustomPainter {
  final List<LetterEvent> events;
  final Color dotColor;
  final int numRings;

  _HitMapPainter({
    required this.events,
    required this.dotColor,
    required this.numRings,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 4;

    // Anillos concéntricos
    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= numRings; i++) {
      final r = radius * i / numRings;
      canvas.drawCircle(center, r, ringPaint);
    }

    // Cruz central
    final axisPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      axisPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      axisPaint,
    );

    // Puntos
    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    for (final e in events) {
      final x = center.dx + e.dx * radius;
      final y = center.dy + e.dy * radius;
      canvas.drawCircle(Offset(x, y), 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HitMapPainter oldDelegate) =>
      oldDelegate.events != events ||
      oldDelegate.dotColor != dotColor ||
      oldDelegate.numRings != numRings;
}
