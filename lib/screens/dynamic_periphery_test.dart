import 'package:flutter/material.dart';
import '../models/test_config.dart';
import '../widgets/center_fixation.dart';
import '../widgets/background_pattern.dart';

class DynamicPeripheryTest extends StatefulWidget {
  final TestConfig config;
  const DynamicPeripheryTest({super.key, required this.config});

  @override
  State<DynamicPeripheryTest> createState() => _DynamicPeripheryTestState();
}

class _DynamicPeripheryTestState extends State<DynamicPeripheryTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundPattern(
        fondo: widget.config.fondo,
        distractor: widget.config.fondoDistractor,
        child: Stack(
          children: [
            CenterFixation(
              tipo: widget.config.fijacion,
              fondo: widget.config.fondo,
            ),
            // ... aquí sigue tu lógica del estímulo periférico ...
          ],
        ),
      ),
    );
  }
}
