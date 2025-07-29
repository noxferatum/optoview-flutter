import 'package:flutter/material.dart';
import 'dynamic_periphery_test.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  String selectedSide = 'both';
  int speed = 1000; // milisegundos

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Configuration'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedSide,
              decoration: const InputDecoration(labelText: 'Stimulus side'),
              items: const [
                DropdownMenuItem(value: 'left', child: Text('Left')),
                DropdownMenuItem(value: 'right', child: Text('Right')),
                DropdownMenuItem(value: 'both', child: Text('Both')),
              ],
              onChanged: (value) => setState(() => selectedSide = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: speed,
              decoration: const InputDecoration(labelText: 'Stimulus speed'),
              items: const [
                DropdownMenuItem(value: 1500, child: Text('Slow')),
                DropdownMenuItem(value: 1000, child: Text('Medium')),
                DropdownMenuItem(value: 500, child: Text('Fast')),
              ],
              onChanged: (value) => setState(() => speed = value!),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DynamicPeripheryTest(
                      side: selectedSide,
                      interval: speed,
                    ),
                  ),
                );
              },
              child: const Text('Run Test'),
            ),
          ],
        ),
      ),
    );
  }
}
