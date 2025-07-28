import 'package:flutter/material.dart';

class CenterFixation extends StatelessWidget {
  const CenterFixation({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 100,
        height: 100,
        child: Image(
          image: AssetImage('assets/images/smile.png'),
        ),
      ),
    );
  }
}
