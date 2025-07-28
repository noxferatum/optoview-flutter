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
            // Aquí irá la navegación a la pantalla de configuración
          },
          child: const Text('Start Test'),
        ),
      ),
    );
  }
}
