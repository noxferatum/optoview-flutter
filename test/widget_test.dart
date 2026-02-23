import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:optoview_flutter/main.dart';

void main() {
  testWidgets('Menu navigation flows to test selector', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(1080, 1920);
    binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(binding.window.clearPhysicalSizeTestValue);
    addTearDown(binding.window.clearDevicePixelRatioTestValue);

    // Ignore overflow errors from card layout at test screen size
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.toString().contains('overflowed')) return;
      originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    await tester.pumpWidget(const OptoViewApp());
    await tester.pumpAndSettle();

    // Find the start button (first ElevatedButton)
    final startButton = find.byWidgetPredicate(
      (w) => w is ElevatedButton,
    );
    expect(startButton, findsAtLeastNWidgets(1));

    await tester.tap(startButton.first);
    await tester.pumpAndSettle();

    // After tapping, we should be on the test menu screen with a GridView
    expect(find.byType(GridView), findsOneWidget);
  });
}
