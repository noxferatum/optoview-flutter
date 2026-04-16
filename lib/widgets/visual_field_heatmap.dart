import 'package:flutter/material.dart';
import '../theme/opto_colors.dart';
import '../theme/opto_spacing.dart';

/// Mapa de campo visual interactivo con hits y misses.
/// Las posiciones están normalizadas [0..1] donde (0.5, 0.5) es el centro.
class VisualFieldHeatmap extends StatelessWidget {
  const VisualFieldHeatmap({
    super.key,
    required this.hits,
    required this.misses,
    this.compact = false,
  });

  final List<Offset> hits;
  final List<Offset> misses;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(OptoSpacing.radiusCard),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('MAPA DEL CAMPO VISUAL',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: colorScheme.onSurfaceVariant)),
              Row(children: [
                _LegendDot(color: OptoColors.success, label: 'Acierto'),
                const SizedBox(width: 12),
                _LegendDot(color: OptoColors.error, label: 'Fallo'),
              ]),
            ],
          ),
          const SizedBox(height: 12),
          // Heatmap area
          AspectRatio(
            aspectRatio: compact ? 2.0 : 16 / 10,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: CustomPaint(
                painter: _HeatmapPainter(
                  hits: hits,
                  misses: misses,
                  gridColor: colorScheme.outlineVariant,
                ),
                size: Size.infinite,
              ),
            ),
          ),
          // Stats
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: colorScheme.outlineVariant))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _HeatmapStat(value: '${hits.length}', label: 'Aciertos', color: OptoColors.success),
                _HeatmapStat(value: '${misses.length}', label: 'Fallos', color: OptoColors.error),
                _HeatmapStat(
                  value: hits.isEmpty && misses.isEmpty ? '-' : '${(hits.length / (hits.length + misses.length) * 100).round()}%',
                  label: 'Precisión',
                  color: OptoColors.peripheral,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  _HeatmapPainter({
    required this.hits,
    required this.misses,
    required this.gridColor,
  });
  final List<Offset> hits;
  final List<Offset> misses;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor.withAlpha(204)
      ..strokeWidth = 1;

    // Grid lines
    for (final f in [0.25, 0.5, 0.75]) {
      canvas.drawLine(Offset(0, size.height * f), Offset(size.width, size.height * f), gridPaint);
      canvas.drawLine(Offset(size.width * f, 0), Offset(size.width * f, size.height), gridPaint);
    }

    // Crosshair
    final center = Offset(size.width / 2, size.height / 2);
    final crossPaint = Paint()
      ..color = Colors.white.withAlpha(77)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(center.dx - 6, center.dy), Offset(center.dx + 6, center.dy), crossPaint);
    canvas.drawLine(Offset(center.dx, center.dy - 6), Offset(center.dx, center.dy + 6), crossPaint);

    // Hits
    for (final p in hits) {
      final pos = Offset(p.dx * size.width, p.dy * size.height);
      canvas.drawCircle(pos, 5, Paint()..color = OptoColors.success.withAlpha(153));
      canvas.drawCircle(pos, 5, Paint()
        ..color = OptoColors.success
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5);
    }

    // Misses
    for (final p in misses) {
      final pos = Offset(p.dx * size.width, p.dy * size.height);
      canvas.drawCircle(pos, 4, Paint()..color = OptoColors.error.withAlpha(102));
      canvas.drawCircle(pos, 4, Paint()
        ..color = OptoColors.error
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5);
    }
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter old) =>
      old.hits != hits || old.misses != misses || old.gridColor != gridColor;
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _HeatmapStat extends StatelessWidget {
  const _HeatmapStat({required this.value, required this.label, required this.color});
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
