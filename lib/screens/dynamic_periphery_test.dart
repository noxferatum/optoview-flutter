import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import '../widgets/center_fixation.dart';
import '../widgets/peripheral_stimulus.dart';

class DynamicPeripheryTest extends StatefulWidget {
  final String side; // 'left', 'right', 'both'
  final int interval; // milliseconds

  const DynamicPeripheryTest({
    super.key,
    required this.side,
    required this.interval,
  });

  @override
  State<DynamicPeripheryTest> createState() => _DynamicPeripheryTestState();
}

class _DynamicPeripheryTestState extends State<DynamicPeripheryTest> {
  bool _showStimulus = false;
  String _stimulusSide = 'left';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTest();
  }

  void _startTest() {
    _timer = Timer.periodic(Duration(milliseconds: widget.interval * 2), (_) async {
      if (!mounted) return;

      final random = Random();
      String side = widget.side;
      if (side == 'both') {
        side = random.nextBool() ? 'left' : 'right';
      }

      setState(() {
        _stimulusSide = side;
        _showStimulus = true;
      });

      await Future.delayed(Duration(milliseconds: widget.interval));

      if (mounted) {
        setState(() => _showStimulus = false);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.black),
          const CenterFixation(),
          if (_showStimulus) PeripheralStimulus(side: _stimulusSide),
        ],
      ),
    );
  }
}
