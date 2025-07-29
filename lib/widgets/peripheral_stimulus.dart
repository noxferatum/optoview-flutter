import 'package:flutter/material.dart';

class PeripheralStimulus extends StatelessWidget {
  final String side;

  const PeripheralStimulus({super.key, required this.side});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Positioned(
      top: size.height / 2 - 25,
      left: side == 'left' ? 50 : null,
      right: side == 'right' ? 50 : null,
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
      ),
    );
  }
}
