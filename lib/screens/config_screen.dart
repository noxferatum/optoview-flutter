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
