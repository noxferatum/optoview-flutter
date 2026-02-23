import 'package:flutter/services.dart';

/// Mixin que gestiona el modo inmersivo y la orientación landscape
/// para las pantallas de test.
///
/// Uso:
/// ```dart
/// class _MyTestState extends State<MyTest>
///     with WidgetsBindingObserver, TickerProviderStateMixin, ImmersiveTestMixin {
///   @override
///   void initState() {
///     super.initState();
///     initImmersiveMode();
///     ...
///   }
///
///   @override
///   void dispose() {
///     disposeImmersiveMode();
///     super.dispose();
///   }
/// }
/// ```
mixin ImmersiveTestMixin {
  /// Activa modo inmersivo sticky y fuerza landscape.
  void initImmersiveMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// Restaura la UI del sistema y orientaciones.
  void disposeImmersiveMode() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }
}
