// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/menu_screen.dart';
import 'screens/config_screen.dart';

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

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Configuration'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Configuration options will go here.'),
      ),
    );
  }
}
