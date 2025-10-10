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
    final bool oscuro = fondo == Fondo.oscuro;
    final Color color = oscuro ? Colors.white : Colors.black;

    return Center(
      child: _buildFixation(color),
    );
  }

  Widget _buildFixation(Color color) {
    switch (tipo) {
      case Fijacion.cara:
        return Icon(Icons.face, color: color, size: 64);
      case Fijacion.ojo:
        return Icon(Icons.remove_red_eye, color: color, size: 64);
      case Fijacion.punto:
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        );
      case Fijacion.trebol:
        return Icon(Icons.filter_vintage, color: color, size: 64);
      case Fijacion.cruz:
        return Icon(Icons.add, color: color, size: 64);
    }
  }
}
