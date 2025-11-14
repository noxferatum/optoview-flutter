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
  final Color color;
  final Color? outlineColor;

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
    required this.color,
    this.outlineColor,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = _buildStimulus(outlineColor);
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

  Widget _buildStimulus(Color? outline) {
    switch (categoria) {
      case SimboloCategoria.letras:
      case SimboloCategoria.numeros:
        return FittedBox(
          fit: BoxFit.contain,
          child: _buildTextStimulus(outline),
        );
      case SimboloCategoria.formas:
        return _buildShape(outline);
    }
  }

  Widget _buildTextStimulus(Color? outline) {
    final baseText = Text(
      text ?? '',
      style: TextStyle(
        color: color,
        fontSize: 100,
        fontWeight: FontWeight.bold,
      ),
    );

    if (outline == null) return baseText;

    final stroke = Text(
      text ?? '',
      style: TextStyle(
        fontSize: 100,
        fontWeight: FontWeight.bold,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..color = outline,
      ),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        stroke,
        baseText,
      ],
    );
  }

  Widget _buildShape(Color? outline) {
    final Color fillColor = color;
    switch (forma) {
      case Forma.circulo:
        return SizedBox.expand(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fillColor,
              shape: BoxShape.circle,
              border: outline != null
                  ? Border.all(color: outline, width: 4)
                  : null,
            ),
          ),
        );
      case Forma.cuadrado:
        return SizedBox.expand(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(size * 0.08),
              border: outline != null
                  ? Border.all(color: outline, width: 4)
                  : null,
            ),
          ),
        );
      case Forma.corazon:
        return _iconWithOutline(Icons.favorite, fillColor, outline);
      case Forma.triangulo:
        return SizedBox.expand(
          child: CustomPaint(
            painter: _TrianglePainter(fillColor, outline),
          ),
        );
      case Forma.trebol:
        return _iconWithOutline(Icons.filter_vintage, fillColor, outline);
      default:
        return SizedBox.expand(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fillColor,
              border: outline != null
                  ? Border.all(color: outline, width: 4)
                  : null,
            ),
          ),
        );
    }
  }

  Widget _iconWithOutline(IconData icon, Color fill, Color? outline) {
    if (outline == null) {
      return SizedBox.expand(
        child: FittedBox(
          child: Icon(icon, color: fill),
        ),
      );
    }

    final double outer = size;
    final double inner = size * 0.82;
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, color: outline, size: outer),
          Icon(icon, color: fill, size: inner),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  final Color? outline;
  _TrianglePainter(this.color, this.outline);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
    if (outline != null) {
      final border = Paint()
        ..color = outline!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawPath(path, border);
    }
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.outline != outline;
}
