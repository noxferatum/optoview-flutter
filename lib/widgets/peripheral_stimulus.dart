// lib/widgets/peripheral_stimulus.dart
import 'package:flutter/material.dart';
import '../models/test_config.dart';

/// Renderiza el estímulo periférico en una coordenada absoluta [top], [left].
/// - Para letras/números, usa [text].
/// - Para formas, usa [forma].
class PeripheralStimulus extends StatelessWidget {
  final SimboloCategoria categoria;
  final Forma? forma;       // usado cuando categoria == formas
  final String? text;       // usado cuando categoria == letras|numeros
  final double size;
  final double top;         // posición vertical en px
  final double left;        // posición horizontal en px
  final VoidCallback onTap;

  const PeripheralStimulus({
    super.key,
    required this.categoria,
    required this.forma,
    required this.text,
    required this.size,
    required this.top,
    required this.left,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: onTap,
        child: _buildSymbol(),
      ),
    );
  }

  Widget _buildSymbol() {
    switch (categoria) {
      case SimboloCategoria.letras:
      case SimboloCategoria.numeros:
        final String value = (text ?? '').isNotEmpty ? text! : '?';
        return Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: size,
            fontWeight: FontWeight.bold,
          ),
        );
      case SimboloCategoria.formas:
        return _buildForma(forma ?? Forma.circulo);
    }
  }

  Widget _buildForma(Forma f) {
    switch (f) {
      case Forma.cuadrado:
        return Container(width: size, height: size, color: Colors.white);
      case Forma.corazon:
        return Icon(Icons.favorite, color: Colors.red, size: size);
      case Forma.triangulo:
        return Icon(Icons.change_history, color: Colors.white, size: size);
      case Forma.trebol:
        return Icon(Icons.filter_vintage, color: Colors.green, size: size);
      case Forma.circulo:
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        );
    }
  }
}
