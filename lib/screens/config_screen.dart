import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dynamic_periphery_test.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  String selectedSide = 'both';
  int speed = 1000;
  double size = 50;
  int duration = 1000;
  String symbol = 'circle';

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.configTitle),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              value: selectedSide,
              decoration: InputDecoration(labelText: loc.selectSide),
              items: [
                DropdownMenuItem(value: 'left', child: Text(loc.left)),
                DropdownMenuItem(value: 'right', child: Text(loc.right)),
                DropdownMenuItem(value: 'both', child: Text(loc.both)),
              ],
              onChanged: (value) => setState(() => selectedSide = value!),
            ),
            DropdownButtonFormField<int>(
              value: speed,
              decoration: InputDecoration(labelText: loc.selectSpeed),
              items: [
                DropdownMenuItem(value: 1500, child: Text(loc.slow)),
                DropdownMenuItem(value: 1000, child: Text(loc.medium)),
                DropdownMenuItem(value: 500, child: Text(loc.fast)),
              ],
              onChanged: (value) => setState(() => speed = value!),
            ),
            DropdownButtonFormField<String>(
              value: symbol,
              decoration: InputDecoration(labelText: loc.selectSymbol),
              items: [
                DropdownMenuItem(value: 'circle', child: Text(loc.symbolCircle)),
                DropdownMenuItem(value: 'letter', child: Text(loc.symbolLetter)),
                DropdownMenuItem(value: 'face', child: Text(loc.symbolFace)),
              ],
              onChanged: (value) => setState(() => symbol = value!),
            ),
            Slider(
              value: size,
              label: '${size.round()} px',
              min: 20,
              max: 150,
              divisions: 13,
              onChanged: (val) => setState(() => size = val),
            ),
            Slider(
              value: duration.toDouble(),
              label: '${duration}ms',
              min: 200,
              max: 2000,
              divisions: 18,
              onChanged: (val) => setState(() => duration = val.toInt()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DynamicPeripheryTest(
                      side: selectedSide,
                      interval: speed,
                      symbol: symbol,
                      size: size,
                      duration: duration,
                    ),
                  ),
                );
              },
              child: Text(loc.runTest),
            ),
          ],
        ),
      ),
    );
  }
}
