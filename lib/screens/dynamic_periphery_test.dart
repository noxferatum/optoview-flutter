import 'package:flutter/material.dart';
import '../widgets/center_fixation.dart';

class DynamicPeripheryTest extends StatelessWidget {
  const DynamicPeripheryTest({super.key});

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
        ],
      ),
    );
  }
}
