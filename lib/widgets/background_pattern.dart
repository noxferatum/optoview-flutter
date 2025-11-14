import 'dart:math';
import 'package:flutter/material.dart';
import '../models/test_config.dart';

class BackgroundPattern extends StatefulWidget {
  final Fondo fondo;
  final bool distractor;
  final bool animado;
  final Widget child;

  const BackgroundPattern({
    super.key,
    required this.fondo,
    required this.distractor,
    required this.animado,
    required this.child,
  });

  @override
  State<BackgroundPattern> createState() => _BackgroundPatternState();
}

class _BackgroundPatternState extends State<BackgroundPattern>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _patternSeed = Random().nextInt(1 << 31);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    );

    if (widget.animado && widget.distractor) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant BackgroundPattern oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.animado && widget.distractor) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      _controller.stop();
    }

    if ((widget.distractor && !oldWidget.distractor) ||
        widget.fondo != oldWidget.fondo) {
      _patternSeed = Random().nextInt(1 << 31);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.distractor) {
      return Container(color: widget.fondo.baseColor, child: widget.child);
    }

    return Container(
      color: widget.fondo.baseColor,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          final offsetX =
              widget.animado ? (_controller.value - 0.5) * 80 : 0.0;
          final offsetY =
              widget.animado ? (_controller.value - 0.5) * 60 : 0.0;

          return CustomPaint(
            painter: _DistractorPainter(
              patternColor: widget.fondo.patternColor,
              offsetX: offsetX,
              offsetY: offsetY,
              seed: _patternSeed,
            ),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _DistractorPainter extends CustomPainter {
  static const List<String> _glyphs = [
    'A',
    'E',
    'K',
    'H',
    'T',
    'X',
    'O',
    '+',
    '#'
  ];

  final Color patternColor;
  final double offsetX;
  final double offsetY;
  final int seed;

  _DistractorPainter({
    required this.patternColor,
    required this.offsetX,
    required this.offsetY,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(seed);
    const double cell = 120.0;

    for (double y = -cell; y < size.height + cell; y += cell) {
      for (double x = -cell; x < size.width + cell; x += cell) {
        final glyph = _glyphs[rand.nextInt(_glyphs.length)];
        final double jitterX = rand.nextDouble() * 14 - 7;
        final double jitterY = rand.nextDouble() * 14 - 7;
        final double fontSize = cell * (0.45 + rand.nextDouble() * 0.2);
        final double opacity = 0.06 + rand.nextDouble() * 0.1;
        final double rotation = (rand.nextDouble() - 0.5) * pi / 10;

        final textPainter = TextPainter(
          text: TextSpan(
            text: glyph,
            style: TextStyle(
              fontSize: fontSize,
              color: patternColor.withValues(alpha: opacity),
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final posX = x + offsetX + jitterX;
        final posY = y + offsetY + jitterY;

        canvas.save();
        canvas.translate(posX, posY);
        canvas.rotate(rotation);
        textPainter.paint(
          canvas,
          Offset(-textPainter.width / 2, -textPainter.height / 2),
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DistractorPainter oldDelegate) {
    return oldDelegate.patternColor != patternColor ||
        oldDelegate.offsetX != offsetX ||
        oldDelegate.offsetY != offsetY ||
        oldDelegate.seed != seed;
  }
}
