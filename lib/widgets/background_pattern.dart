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

  _DistractorPainter({required this.oscuro});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (oscuro ? Colors.white : Colors.black).withOpacity(0.06)
      ..style = PaintingStyle.fill;

    const double step = 60;
    for (double y = 0; y < size.height; y += step) {
      for (double x = 0; x < size.width; x += step) {
        canvas.drawCircle(Offset(x + 10, y + 10), 5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DistractorPainter oldDelegate) =>
      oldDelegate.oscuro != oscuro;
}
