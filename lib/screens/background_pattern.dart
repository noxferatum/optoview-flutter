import 'dart:math';
import 'package:flutter/material.dart';
import '../models/test_config.dart';

class BackgroundPattern extends StatelessWidget {
  final Fondo fondo;
  final bool distractor;
  final Widget child;

  const BackgroundPattern({
    super.key,
    required this.fondo,
    required this.distractor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bool oscuro = fondo == Fondo.oscuro;
    final Color baseColor = oscuro ? Colors.black : Colors.white;

    return Container(
      color: baseColor,
      child: distractor
          ? CustomPaint(
              painter: _DistractorPainter(oscuro: oscuro),
              child: child,
            )
          : child,
    );
  }
}

class _DistractorPainter extends CustomPainter {
  final bool oscuro;
  final Random _rand = Random();

  _DistractorPainter({required this.oscuro});

  @override
  void paint(Canvas canvas, Size size) {
    final double step = 80.0;
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Capa semitransparente para mezcla más suave
    canvas.saveLayer(Offset.zero & size, Paint());

    for (double y = 0; y < size.height; y += step) {
      for (double x = 0; x < size.width; x += step) {
        // Pequeñas variaciones para evitar patrón robótico
        final offsetX = x + _rand.nextDouble() * 10 - 5;
        final offsetY = y + _rand.nextDouble() * 10 - 5;

        final double radius = 2 + _rand.nextDouble() * 3;
        final double opacity = 0.04 + _rand.nextDouble() * 0.03;

        paint.color =
            (oscuro ? Colors.white : Colors.black).withOpacity(opacity);

        // Dibuja puntos y alguna línea ocasional
        if (_rand.nextDouble() > 0.15) {
          canvas.drawCircle(Offset(offsetX, offsetY), radius, paint);
        } else {
          canvas.drawLine(
            Offset(offsetX, offsetY),
            Offset(offsetX + 10, offsetY + 10),
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
  bool shouldRepaint(covariant _DistractorPainter oldDelegate) =>
      oldDelegate.oscuro != oscuro;
}
