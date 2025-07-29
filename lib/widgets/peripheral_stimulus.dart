// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/menu_screen.dart';

void main() {
  runApp(const OptoViewApp());
}

class OptoViewApp extends StatelessWidget {
  const OptoViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OptoView',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MenuScreen(),
    );
  }
}

// lib/screens/menu_screen.dart
import 'package:flutter/material.dart';
import 'config_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OptoView Menu'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ConfigScreen()),
            );
          },
          child: const Text('Start Test'),
        ),
      ),
    );
  }
}

// lib/screens/config_screen.dart
import 'package:flutter/material.dart';
import 'dynamic_periphery_test.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Configuration'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DynamicPeripheryTest()),
            );
          },
          child: const Text('Run Dynamic Periphery Test'),
        ),
      ),
    );
  }
}

// lib/screens/dynamic_periphery_test.dart
import 'package:flutter/material.dart';
import '../widgets/center_fixation.dart';
import '../widgets/peripheral_stimulus.dart';

class DynamicPeripheryTest extends StatefulWidget {
  const DynamicPeripheryTest({super.key});

  @override
  State<DynamicPeripheryTest> createState() => _DynamicPeripheryTestState();
}

class _DynamicPeripheryTestState extends State<DynamicPeripheryTest> {
  bool _showStimulus = false;

  @override
  void initState() {
    super.initState();
    _triggerStimulus();
  }

  void _triggerStimulus() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() => _showStimulus = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() => _showStimulus = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
          ),
          const CenterFixation(),
          if (_showStimulus) const PeripheralStimulus(side: 'left'),
        ],
      ),
    );
  }
}

// lib/widgets/center_fixation.dart
import 'package:flutter/material.dart';

class CenterFixation extends StatelessWidget {
  const CenterFixation({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 100,
        height: 100,
        child: Image(image: AssetImage('assets/images/smile.png')),
      ),
    );
  }
}

// lib/widgets/peripheral_stimulus.dart
import 'package:flutter/material.dart';

class PeripheralStimulus extends StatelessWidget {
  final String side; // 'left' or 'right'

  const PeripheralStimulus({super.key, required this.side});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Positioned(
      top: height / 2 - 25,
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
