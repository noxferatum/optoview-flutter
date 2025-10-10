import 'package:flutter/material.dart';
import '../models/test_config.dart';

class PeripheralStimulus extends StatelessWidget {
  final SimboloCategoria categoria;
  final Forma? forma;
  final String? text;
  final double size;
  final String side; // left, right, top, bottom
  final double top;
  final VoidCallback onTap;

  const PeripheralStimulus({
    super.key,
    required this.categoria,
    this.forma,
    this.text,
    required this.size,
    required this.side,
    required this.top,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = _buildStimulus();

    return Positioned(
      top: side == 'top'
          ? 50
          : side == 'bottom'
              ? MediaQuery.of(context).size.height - size - 100
              : top,
      left: side == 'left'
          ? 40
          : side == 'right'
              ? MediaQuery.of(context).size.width - size - 40
              : null,
      right: side == 'right' ? 40 : null,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(width: size, height: size, child: content),
      ),
    );
  }

  Widget _buildStimulus() {
    switch (categoria) {
      case SimboloCategoria.letras:
      case SimboloCategoria.numeros:
        return FittedBox(
          fit: BoxFit.contain,
          child: Text(
            text ?? '',
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 100,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case SimboloCategoria.formas:
        return _buildShape();
    }
  }

  Widget _buildShape() {
    Color color = Colors.redAccent;

    switch (forma) {
      case Forma.circulo:
        return Container(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        );
      case Forma.cuadrado:
        return Container(
          color: color,
        );
      case Forma.corazon:
        return Icon(Icons.favorite, color: color, size: size);
      case Forma.triangulo:
        return CustomPaint(
          painter: _TrianglePainter(color),
        );
      case Forma.trebol:
        return Icon(Icons.filter_vintage, color: color, size: size);
      default:
        return Container(color: color);
    }
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) =>
      oldDelegate.color != color;
}
