import 'package:flutter/material.dart';

class PeripheralStimulus extends StatelessWidget {
  final String side;
  final String symbol;
  final double size;
  final VoidCallback onTap;

  const PeripheralStimulus({
    super.key,
    required this.side,
    required this.symbol,
    required this.size,
    required this.onTap,
  });

  Widget _buildSymbol() {
    switch (symbol) {
      case 'letter':
        return Text(
          'A',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.8,
            fontWeight: FontWeight.bold,
          ),
        );
      case 'face':
        return const Icon(Icons.face, color: Colors.white, size: 40);
      case 'circle':
      default:
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

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Positioned(
      top: height / 2 - size / 2,
      left: side == 'left' ? 50 : null,
      right: side == 'right' ? 50 : null,
      child: GestureDetector(
        onTap: onTap,
        child: _buildSymbol(),
      ),
    );
  }
}
