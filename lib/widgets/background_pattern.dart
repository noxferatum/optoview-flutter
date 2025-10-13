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
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    if (widget.animado && widget.distractor) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant BackgroundPattern oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 🔹 Si se activa/desactiva la animación, gestionamos el controller
    if (widget.animado && widget.distractor) {
      if (!_controller.isAnimating) _controller.repeat(reverse: true);
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool oscuro = widget.fondo == Fondo.oscuro;
    final Color baseColor = oscuro ? Colors.black : Colors.white;

    return Container(
      color: baseColor,
      child: widget.distractor
          ? AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final offsetX = widget.animado ? _controller.value * 20 : 0.0;
                final offsetY = widget.animado ? _controller.value * 15 : 0.0;

                return CustomPaint(
                  painter: _DistractorPainter(
                    oscuro: oscuro,
                    offsetX: offsetX,
                    offsetY: offsetY,
                  ),
                  child: widget.child,
                );
              },
            )
          : widget.child,
    );
  }
}

class _DistractorPainter extends CustomPainter {
  final bool oscuro;
  final double offsetX;
  final double offsetY;
  final Random _rand = Random();

  _DistractorPainter({
    required this.oscuro,
    required this.offsetX,
    required this.offsetY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double step = 80.0;
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Capa semitransparente para suavizar el patrón
    canvas.saveLayer(Offset.zero & size, Paint());

    for (double y = 0; y < size.height; y += step) {
      for (double x = 0; x < size.width; x += step) {
        final double radius = 2 + _rand.nextDouble() * 3;
        final double opacity = 0.04 + _rand.nextDouble() * 0.03;

        paint.color =
            (oscuro ? Colors.white : Colors.black).withOpacity(opacity);

        // Offset animado
        final offset = Offset(
          x + offsetX + _rand.nextDouble() * 4 - 2,
          y + offsetY + _rand.nextDouble() * 4 - 2,
        );

        // Alterna entre puntos y líneas tenues
        if (_rand.nextDouble() > 0.15) {
          canvas.drawCircle(offset, radius, paint);
        } else {
          canvas.drawLine(
            Offset(offset.dx, offset.dy),
            Offset(offset.dx + 10, offset.dy + 10),
            paint
              ..strokeWidth = 0.5
              ..style = PaintingStyle.stroke,
          );
        }
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DistractorPainter old) =>
      old.oscuro != oscuro ||
      old.offsetX != offsetX ||
      old.offsetY != offsetY;
}
