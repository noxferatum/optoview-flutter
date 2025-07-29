import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../widgets/center_fixation.dart';
import '../widgets/peripheral_stimulus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DynamicPeripheryTest extends StatefulWidget {
  final String side;
  final int interval;
  final String symbol;
  final double size;
  final int duration;

  const DynamicPeripheryTest({
    super.key,
    required this.side,
    required this.interval,
    required this.symbol,
    required this.size,
    required this.duration,
  });

  @override
  State<DynamicPeripheryTest> createState() => _DynamicPeripheryTestState();
}

class _DynamicPeripheryTestState extends State<DynamicPeripheryTest> {
  bool _showStimulus = false;
  String _stimulusSide = 'left';
  Timer? _timer;
  int correctTaps = 0;
  int totalStimuli = 0;
  bool _tapExpected = false;

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
        _tapExpected = true;
        totalStimuli += 1;
      });

      await Future.delayed(Duration(milliseconds: widget.duration));

      if (mounted) {
        setState(() {
          _showStimulus = false;
          _tapExpected = false;
        });
      }
    });
  }

  void _registerTap() {
    if (_tapExpected) {
      setState(() {
        correctTaps += 1;
        _tapExpected = false;
      });
    }
  }

  void _endTest() {
    _timer?.cancel();
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.testCompleted),
        content: Text('${loc.correctTaps}: $correctTaps / $totalStimuli'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _startTest();
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
          if (_showStimulus)
            PeripheralStimulus(
              side: _stimulusSide,
              symbol: widget.symbol,
              size: widget.size,
              onTap: _registerTap,
            ),
          Positioned(
            bottom: 32,
            right: 32,
            child: ElevatedButton(
              onPressed: _endTest,
              child: const Text('End Test'),
            ),
          ),
        ],
      ),
    );
  }
}
