import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/macdonald_result.dart';
import '../models/saved_result.dart';
import '../services/export_service.dart';
import '../services/results_storage.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<SavedResult> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    final results = await ResultsStorage.loadAll();
    if (mounted) {
      setState(() {
        _results = results;
        _isLoading = false;
      });
    }
  }

  void _confirmDeleteAll(AppLocalizations l) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.historyClearAllTitle),
        content: Text(l.historyClearAllMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.historyCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ResultsStorage.deleteAll();
              setState(() => _results.clear());
            },
            child: Text(l.historyClearAllConfirm),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(SavedResult result, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.historyDeleteTitle),
        content: Text(l.historyDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.historyCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ResultsStorage.delete(result.id);
              setState(() => _results.removeWhere((r) => r.id == result.id));
            },
            child: Text(l.historyDelete),
          ),
        ],
      ),
    );
  }

  void _showPatientSummaryExport(AppLocalizations l) {
    // Group results by patient name
    final patients = <String, List<SavedResult>>{};
    for (final r in _results) {
      final name = r.patientName.isNotEmpty ? r.patientName : '-';
      patients.putIfAbsent(name, () => []).add(r);
    }

    if (patients.length == 1) {
      // Only one patient (or no names) → show format picker directly
      _showFormatPicker(patients.keys.first, patients.values.first, l);
      return;
    }

    // Multiple patients → show patient selector
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l.exportSelectPatient,
                style: Theme.of(context).textTheme.titleMedium),
          ),
          ...patients.entries.map(
            (e) => ListTile(
              leading: const Icon(Icons.person),
              title: Text(e.key),
              subtitle: Text('${e.value.length} resultados'),
              onTap: () {
                Navigator.pop(ctx);
                _showFormatPicker(e.key, e.value, l);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFormatPicker(
      String patientName, List<SavedResult> results, AppLocalizations l) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.exportPatientReport(patientName),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ExportService.exportPatientSummaryPdf(
                        context, patientName, results, l);
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: Text(l.exportPdf),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ExportService.exportPatientSummaryExcel(
                        patientName, results, l);
                  },
                  icon: const Icon(Icons.table_chart),
                  label: Text(l.exportExcel),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ExportService.exportPatientSummaryCsv(
                        patientName, results, l);
                  },
                  icon: const Icon(Icons.description),
                  label: Text(l.exportCsv),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDetail(SavedResult result, AppLocalizations l) {
    final theme = Theme.of(context);
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollController) => Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                l.historyDetailTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _testTypeLabel(result.testType, l),
                style: theme.textTheme.titleMedium,
              ),
              if (result.patientName.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16),
                    const SizedBox(width: 4),
                    Text(result.patientName),
                  ],
                ),
              ],
              const SizedBox(height: 4),
              Text(
                dateFmt.format(result.startedAt),
                style: theme.textTheme.bodySmall,
              ),
              const Divider(height: 24),

              // Métricas
              _DetailRow(
                label: l.statsActualDuration,
                value: '${result.durationActualSeconds}s',
              ),
              _DetailRow(
                label: l.statsStimuliShown,
                value: '${result.totalStimuliShown}',
              ),
              if (result.correctTouches != null)
                _DetailRow(
                  label: l.accuracyCorrect,
                  value: '${result.correctTouches}',
                ),
              if (result.incorrectTouches != null)
                _DetailRow(
                  label: l.accuracyErrors,
                  value: '${result.incorrectTouches}',
                ),
              if (result.missedStimuli != null)
                _DetailRow(
                  label: l.accuracyMissed,
                  value: '${result.missedStimuli}',
                ),
              if (result.accuracy != null)
                _DetailRow(
                  label: l.accuracyPercent,
                  value: '${(result.accuracy! * 100).toStringAsFixed(1)}%',
                ),
              if (result.avgReactionTimeMs != null)
                _DetailRow(
                  label: l.reactionAvg,
                  value: '${result.avgReactionTimeMs!.toStringAsFixed(0)} ms',
                ),
              if (result.bestReactionTimeMs != null)
                _DetailRow(
                  label: l.reactionBest,
                  value: '${result.bestReactionTimeMs!.toStringAsFixed(0)} ms',
                ),
              if (result.worstReactionTimeMs != null)
                _DetailRow(
                  label: l.reactionWorst,
                  value: '${result.worstReactionTimeMs!.toStringAsFixed(0)} ms',
                ),
              if (result.stimuliPerMinute != null)
                _DetailRow(
                  label: l.statsStimuliPerMinute,
                  value: result.stimuliPerMinute!.toStringAsFixed(1),
                ),
              if (result.anillosCompletados != null)
                _DetailRow(
                  label: l.macStatsRingsCompleted,
                  value: '${result.anillosCompletados}',
                ),
              if (result.tiempoPorAnillo != null) ...[
                const SizedBox(height: 8),
                ...result.tiempoPorAnillo!.asMap().entries.map(
                      (e) => _DetailRow(
                        label: l.macRingLabel(e.key + 1),
                        value: '${(e.value / 1000).toStringAsFixed(1)}s',
                      ),
                    ),
              ],

              // Mapas de aciertos/fallos (MacDonald tocarLetras)
              if (result.letterEvents != null &&
                  result.letterEvents!.isNotEmpty) ...[
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(l.macHitMapTitle,
                              style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          AspectRatio(
                            aspectRatio: 1,
                            child: CustomPaint(
                              painter: _HitMapPainter(
                                events: result.letterEvents!
                                    .where((e) => e.isHit)
                                    .toList(),
                                dotColor: Colors.greenAccent,
                                numRings: result.anillosCompletados ?? 3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        children: [
                          Text(l.macMissMapTitle,
                              style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          AspectRatio(
                            aspectRatio: 1,
                            child: CustomPaint(
                              painter: _HitMapPainter(
                                events: result.letterEvents!
                                    .where((e) => !e.isHit)
                                    .toList(),
                                dotColor: Colors.redAccent,
                                numRings: result.anillosCompletados ?? 3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              // Config summary
              if (result.configSummary.isNotEmpty) ...[
                const Divider(height: 24),
                Text(
                  l.configUsedTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...result.configSummary.entries.map(
                  (e) => _DetailRow(label: e.key, value: e.value),
                ),
              ],

              // Export buttons
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => ExportService.exportResultPdf(context, result, l),
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: Text(l.exportPdf),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => ExportService.exportResultExcel(result, l),
                    icon: const Icon(Icons.table_chart, size: 18),
                    label: Text(l.exportExcel),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => ExportService.exportResultCsv(result, l),
                    icon: const Icon(Icons.description, size: 18),
                    label: Text(l.exportCsv),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _testTypeLabel(String type, AppLocalizations l) => switch (type) {
        'peripheral' => l.historyTestPeripheral,
        'localization' => l.historyTestLocalization,
        'macdonald' => l.historyTestMacdonald,
        _ => type,
      };

  IconData _testTypeIcon(String type) => switch (type) {
        'peripheral' => Icons.blur_on,
        'localization' => Icons.touch_app,
        'macdonald' => Icons.grid_on,
        _ => Icons.science,
      };

  String _keyMetric(SavedResult r) {
    if (r.accuracy != null) {
      return '${(r.accuracy! * 100).toStringAsFixed(0)}%';
    }
    if (r.stimuliPerMinute != null) {
      return '${r.stimuliPerMinute!.toStringAsFixed(0)}/min';
    }
    return '${r.durationActualSeconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l.historyTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.historyTitle),
        actions: [
          if (_results.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.summarize),
              tooltip: l.exportPatientSummary,
              onPressed: () => _showPatientSummaryExport(l),
            ),
          if (_results.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: l.historyClearAll,
              onPressed: () => _confirmDeleteAll(l),
            ),
        ],
      ),
      body: _results.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.history, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    l.historyEmpty,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _results.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                final r = _results[index];
                return Dismissible(
                  key: ValueKey(r.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) async {
                    _confirmDelete(r, l);
                    return false;
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(_testTypeIcon(r.testType)),
                    ),
                    title: Text(
                      r.patientName.isNotEmpty
                          ? r.patientName
                          : _testTypeLabel(r.testType, l),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${_testTypeLabel(r.testType, l)} - ${dateFmt.format(r.startedAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      _keyMetric(r),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    onTap: () => _showDetail(r, l),
                  ),
                );
              },
            ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(width: 8),
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

    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= numRings; i++) {
      final r = radius * i / numRings;
      canvas.drawCircle(center, r, ringPaint);
    }

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
