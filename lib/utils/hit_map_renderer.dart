import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../models/macdonald_result.dart';

/// Renderiza un mapa de aciertos/fallos a PNG para incrustar en el PDF.
///
/// Usa [dart:ui] directamente (PictureRecorder + Canvas), sin necesidad de
/// montar un widget tree, por lo que el coste de memoria es solo el del PNG
/// resultante (~pocos KB).
Future<Uint8List> renderHitMapToPng({
  required List<LetterEvent> events,
  required Color dotColor,
  required int numRings,
  double size = 400,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size, size));

  // Fondo oscuro (coherente con el tema de la app)
  canvas.drawRect(
    Rect.fromLTWH(0, 0, size, size),
    Paint()..color = const Color(0xFF303030),
  );

  final center = Offset(size / 2, size / 2);
  final radius = size / 2 - 8;

  // Anillos concentricos
  final ringPaint = Paint()
    ..color = const Color(0x26FFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  for (int i = 1; i <= numRings; i++) {
    canvas.drawCircle(center, radius * i / numRings, ringPaint);
  }

  // Cruz central
  final axisPaint = Paint()
    ..color = const Color(0x33FFFFFF)
    ..strokeWidth = 0.8;
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

  final dotRadius = max(4.0, size / 80);
  for (final e in events) {
    canvas.drawCircle(
      Offset(center.dx + e.dx * radius, center.dy + e.dy * radius),
      dotRadius,
      dotPaint,
    );
  }

  final picture = recorder.endRecording();
  final image = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
