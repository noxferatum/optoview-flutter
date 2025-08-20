// lib/screens/menu_screen.dart
import 'package:flutter/material.dart';
import '../models/test_config.dart';
import 'config_screen.dart';
import 'dynamic_periphery_test.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Optometría - Menú')),
      body: Center(
        child: FilledButton(
          child: const Text('Configurar prueba'),
          onPressed: () async {
            final cfg = await Navigator.push<TestConfig>(
              context,
              MaterialPageRoute(builder: (_) => const ConfigScreen()),
            );
            if (cfg != null) {
              // Ir directamente a la prueba con la configuración elegida
              // (o guárdala para usarla más tarde).
              // ignore: use_build_context_synchronously
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DynamicPeripheryTest(config: cfg),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
