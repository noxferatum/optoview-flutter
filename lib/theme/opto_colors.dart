import 'package:flutter/material.dart';

abstract final class OptoColors {
  // Brand
  static const Color primary = Color(0xFF3F6FB2);
  static const Color primaryPattern = Color(0xFF8ABFF5);

  // Dark mode surfaces
  static const Color backgroundDark = Color(0xFF0F1216);
  static const Color surfaceDark = Color(0xFF1A1E24);
  static const Color surfaceVariantDark = Color(0xFF242930);

  // Dark mode text
  static const Color onSurfaceDark = Color(0xFFE8ECF0);
  static const Color onSurfaceVariantDark = Color(0xFF8A94A0);
  static const Color subtleDark = Color(0xFF5A6270);

  // Semantic
  static const Color success = Color(0xFF4CAF7D);
  static const Color warning = Color(0xFFE5A84B);
  static const Color error = Color(0xFFD4544E);

  // Test type accents
  static const Color peripheral = Color(0xFF5B8FD2);
  static const Color localization = Color(0xFF9B7BFF);
  static const Color macdonald = Color(0xFF4CAF7D);

  // Scrollbar
  static const Color scrollThumb = Color(0x803F6FB2); // primary @ 50%
}
