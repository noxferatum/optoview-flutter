import 'package:flutter/material.dart';
import '../models/test_config.dart';

class CenterFixation extends StatelessWidget {
  final Fijacion tipo;
  final Fondo fondo;

  const CenterFixation({
    super.key,
    required this.tipo,
    required this.fondo,
  });

  @override
  Widget build(BuildContext context) {
    final bool oscuro = fondo.isDark;
    final Color colorPrincipal = oscuro ? Colors.white : Colors.black;
    final Color borde = oscuro ? Colors.black54 : Colors.white70;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildFixation(borde, isShadow: true),
          _buildFixation(colorPrincipal),
        ],
      ),
    );
  }

  Widget _buildFixation(Color color, {bool isShadow = false}) {
    const double mainSize = 64.0;
    final double shadowOffset = isShadow ? 2.0 : 0.0;

    switch (tipo) {
      case Fijacion.cara:
        return Transform.translate(
          offset: Offset(shadowOffset, shadowOffset),
          child: Icon(Icons.face, color: color, size: mainSize),
        );
      case Fijacion.ojo:
        return Transform.translate(
          offset: Offset(shadowOffset, shadowOffset),
          child: Icon(Icons.remove_red_eye, color: color, size: mainSize),
        );
      case Fijacion.punto:
        return Transform.translate(
          offset: Offset(shadowOffset, shadowOffset),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: isShadow
                  ? []
                  : [
                      BoxShadow(
                        color: color.withValues(alpha: 0.6),
                        blurRadius: 4,
                        spreadRadius: 2,
                      )
                    ],
            ),
          ),
        );
      case Fijacion.trebol:
        return Transform.translate(
          offset: Offset(shadowOffset, shadowOffset),
          child: Icon(Icons.filter_vintage, color: color, size: mainSize),
        );
      case Fijacion.cruz:
        return Transform.translate(
          offset: Offset(shadowOffset, shadowOffset),
          child: Icon(Icons.add, color: color, size: mainSize * 1.2),
        );
    }
  }
}
