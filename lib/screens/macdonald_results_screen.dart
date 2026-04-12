import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/macdonald_config.dart';
import '../models/macdonald_result.dart';
import '../models/saved_result.dart';
import '../services/results_storage.dart';
import '../theme/opto_colors.dart';
import '../theme/opto_spacing.dart';
import '../utils/page_transitions.dart';
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
    final result = widget.result;
    final summary = result.config.localizedSummary(l);
    final isTouchMode =
        result.config.interaccion == MacInteraccion.tocarLetras ||
        result.config.interaccion == MacInteraccion.deteccionCampo;
    final isFieldDetection =
        result.config.interaccion == MacInteraccion.deteccionCampo;
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
                        if (isTouchMode) ...[
                          const SizedBox(height: OptoSpacing.md),
                          _buildAccuracyCard(l, result),
                        ],
                        if (isTouchMode &&
                            result.reactionTimesMs.isNotEmpty) ...[
                          const SizedBox(height: OptoSpacing.md),
                          _buildReactionTimesCard(l, result),
                        ],
                        if (result.tiempoPorAnillo.isNotEmpty) ...[
                          const SizedBox(height: OptoSpacing.md),
                          _buildRingTimesCard(l, result),
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
                        // Date
                        _buildDateRow(dateFmt, result),
                        if (isFieldDetection &&
                            result.letterEvents.isNotEmpty) ...[
                          const SizedBox(height: OptoSpacing.md),
                          _buildHitMissMaps(l, result),
                        ],
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

  Widget _buildTopBar(
    BuildContext context,
    AppLocalizations l,
    MacDonaldResult result,
  ) {
    return Container(
      color: OptoColors.surfaceDark,
      padding: const EdgeInsets.symmetric(
        horizontal: OptoSpacing.sm,
        vertical: OptoSpacing.xs,
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
                l.resultsMacTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: OptoColors.onSurfaceDark,
                ),
              ),
            ),
            _TopBarButton(
              icon: Icons.replay,
              label: l.resultsRepeat,
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  OptoPageRoute(
                    builder: (_) => MacDonaldTest(
                      config: result.config,
                      patientName: result.patientName,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: OptoSpacing.sm),
            _TopBarButton(
              icon: Icons.home,
              label: l.resultsHome,
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }

  // -- Status banner --

  Widget _buildStatusBanner(AppLocalizations l, MacDonaldResult result) {
    final isComplete = result.completedNaturally;
    final color = isComplete ? OptoColors.success : OptoColors.warning;
    final icon = isComplete
        ? Icons.check_circle_outline
        : Icons.stop_circle_outlined;
    final text = isComplete ? l.resultsCompleted : l.resultsStopped;

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
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                if (result.patientName.isNotEmpty) ...[
                  const SizedBox(height: OptoSpacing.xs),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 14,
                          color: OptoColors.onSurfaceVariantDark),
                      const SizedBox(width: OptoSpacing.xs),
                      Text(
                        result.patientName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: OptoColors.onSurfaceVariantDark,
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

  Widget _buildAccuracyCard(AppLocalizations l, MacDonaldResult result) {
    return _SectionCard(
      title: l.accuracyTitle,
      children: [
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
          value: '${result.missedLetras}',
          valueColor:
              result.missedLetras > 0 ? OptoColors.warning : null,
        ),
        _StatRow(
          label: l.accuracyPercent,
          value: '${(result.accuracy * 100).toStringAsFixed(1)}%',
          valueColor: result.accuracy >= 0.8
              ? OptoColors.success
              : OptoColors.warning,
        ),
      ],
    );
  }

  // -- Reaction times card --

  Widget _buildReactionTimesCard(
      AppLocalizations l, MacDonaldResult result) {
    return _SectionCard(
      title: l.reactionTitle,
      children: [
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
    );
  }

  // -- Ring times card --

  Widget _buildRingTimesCard(AppLocalizations l, MacDonaldResult result) {
    return _SectionCard(
      title: l.macStatsTimePerRing,
      children: [
        ...result.tiempoPorAnillo.asMap().entries.map(
              (e) => _StatRow(
                label: l.macRingLabel(e.key + 1),
                value: '${(e.value / 1000).toStringAsFixed(1)}s',
              ),
            ),
        if (result.tiempoPorAnillo.length > 1)
          _StatRow(
            label: l.macStatsAvgPerRing,
            value:
                '${(result.tiempoPorAnillo.reduce((a, b) => a + b) / result.tiempoPorAnillo.length / 1000).toStringAsFixed(1)}s',
          ),
      ],
    );
  }

  // -- General stats card --

  Widget _buildGeneralStatsCard(
      AppLocalizations l, MacDonaldResult result) {
    return _SectionCard(
      title: l.statsTitle,
      children: [
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
    );
  }

  // -- Date row --

  Widget _buildDateRow(DateFormat dateFmt, MacDonaldResult result) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OptoSpacing.md,
        vertical: OptoSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: OptoColors.surfaceDark,
        borderRadius: BorderRadius.circular(OptoSpacing.radiusCard),
        border: Border.all(color: OptoColors.surfaceVariantDark),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 16,
              color: OptoColors.onSurfaceVariantDark),
          const SizedBox(width: OptoSpacing.sm),
          Text(
            dateFmt.format(result.startedAt),
            style: const TextStyle(
              fontSize: 13,
              color: OptoColors.onSurfaceDark,
            ),
          ),
        ],
      ),
    );
  }

  // -- Hit/Miss maps --

  Widget _buildHitMissMaps(AppLocalizations l, MacDonaldResult result) {
    return Row(
      children: [
        Expanded(
          child: _buildMapCard(
            title: l.macHitMapTitle,
            events: result.letterEvents.where((e) => e.isHit).toList(),
            dotColor: OptoColors.success,
            numRings: result.config.numAnillos,
          ),
        ),
        const SizedBox(width: OptoSpacing.sm),
        Expanded(
          child: _buildMapCard(
            title: l.macMissMapTitle,
            events:
                result.letterEvents.where((e) => !e.isHit).toList(),
            dotColor: OptoColors.error,
            numRings: result.config.numAnillos,
          ),
        ),
      ],
    );
  }

  Widget _buildMapCard({
    required String title,
    required List<LetterEvent> events,
    required Color dotColor,
    required int numRings,
  }) {
    return Container(
      padding: const EdgeInsets.all(OptoSpacing.md),
      decoration: BoxDecoration(
        color: OptoColors.surfaceDark,
        borderRadius: BorderRadius.circular(OptoSpacing.radiusCard),
        border: Border.all(color: OptoColors.surfaceVariantDark),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: OptoColors.onSurfaceDark,
            ),
          ),
          const SizedBox(height: OptoSpacing.sm),
          AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: _HitMapPainter(
                events: events,
                dotColor: dotColor,
                numRings: numRings,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -- Config tags --

  Widget _buildConfigTags(
      AppLocalizations l, Map<String, String> summary) {
    return Container(
      padding: const EdgeInsets.all(OptoSpacing.md),
      decoration: BoxDecoration(
        color: OptoColors.surfaceDark,
        borderRadius: BorderRadius.circular(OptoSpacing.radiusCard),
        border: Border.all(color: OptoColors.surfaceVariantDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.configUsedTitle,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: OptoColors.onSurfaceDark,
            ),
          ),
          const SizedBox(height: OptoSpacing.sm),
          Wrap(
            spacing: OptoSpacing.sm,
            runSpacing: OptoSpacing.sm,
            children: summary.entries.map((e) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: OptoSpacing.sm + 2,
                  vertical: OptoSpacing.xs + 1,
                ),
                decoration: BoxDecoration(
                  color: OptoColors.surfaceVariantDark,
                  borderRadius:
                      BorderRadius.circular(OptoSpacing.radiusChip),
                ),
                child: Text(
                  '${e.key}: ${e.value}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: OptoColors.onSurfaceVariantDark,
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

// -- Top bar button --

class _TopBarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _TopBarButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: OptoColors.onSurfaceDark),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          color: OptoColors.onSurfaceDark,
        ),
      ),
    );
  }
}

// -- Section card --

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(OptoSpacing.md),
      decoration: BoxDecoration(
        color: OptoColors.surfaceDark,
        borderRadius: BorderRadius.circular(OptoSpacing.radiusCard),
        border: Border.all(color: OptoColors.surfaceVariantDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: OptoColors.onSurfaceDark,
            ),
          ),
          const SizedBox(height: OptoSpacing.sm),
          ...children,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: OptoSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: OptoColors.onSurfaceVariantDark,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? OptoColors.onSurfaceDark,
            ),
          ),
        ],
      ),
    );
  }
}

// -- Hit map painter --

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
      ..color = Colors.white.withAlpha(38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= numRings; i++) {
      final r = radius * i / numRings;
      canvas.drawCircle(center, r, ringPaint);
    }

    // Cruz central
    final axisPaint = Paint()
      ..color = Colors.white.withAlpha(51)
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
