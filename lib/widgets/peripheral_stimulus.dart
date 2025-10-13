import 'package:flutter/material.dart';
import '../models/test_config.dart';

class PeripheralStimulus extends StatelessWidget {
  final SimboloCategoria categoria;
  final Forma? forma;
  final String? text;
  final double size;
  final String side; // left, right, top, bottom
  final double top;
  final double left;
  final VoidCallback onTap;

  const PeripheralStimulus({
    super.key,
    required this.categoria,
    this.forma,
    this.text,
    required this.size,
    required this.side,
    required this.top,
    required this.left,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = _buildStimulus();
    final screen = MediaQuery.of(context).size;

    // Calculamos posición según lado, pero si el test controla `top`/`left`, los usamos directamente
    double? posTop = top;
    double? posLeft = left;
    double? posRight;

    switch (side) {
      case 'left':
        posLeft = left == 0 ? 40 : left;
        break;
      case 'right':
        posLeft = screen.width - size - 40;
        break;
      case 'top':
        posTop = 50;
        break;
      case 'bottom':
        posTop = screen.height - size - 100;
        break;
    }

    return Positioned(
      top: posTop,
      left: posLeft,
      right: posRight,
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
    const color = Colors.redAccent;

    switch (forma) {
      case Forma.circulo:
        return Container(
          decoration: const BoxDecoration(color: color, shape: BoxShape.circle),
        );
      case Forma.cuadrado:
        return Container(color: color);
      case Forma.corazon:
        return const Icon(Icons.favorite, color: color);
      case Forma.triangulo:
        return CustomPaint(painter: _TrianglePainter(color));
      case Forma.trebol:
        return const Icon(Icons.filter_vintage, color: color);
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
