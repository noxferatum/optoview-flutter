import 'package:flutter/material.dart';
import 'opto_colors.dart';
import 'opto_spacing.dart';

abstract final class OptoTheme {
  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: OptoColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      surface: OptoColors.surfaceDark,
      surfaceContainerHighest: OptoColors.surfaceVariantDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: OptoColors.backgroundDark,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OptoSpacing.radiusCard),
          side: BorderSide(color: OptoColors.surfaceVariantDark),
        ),
        color: OptoColors.surfaceDark,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: WidgetStatePropertyAll(3),
        radius: const Radius.circular(2),
        thumbColor: WidgetStatePropertyAll(OptoColors.scrollThumb),
        trackColor: WidgetStatePropertyAll(Colors.transparent),
        thumbVisibility: WidgetStatePropertyAll(false),
        interactive: true,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w300),
        headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: OptoColors.primary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OptoSpacing.radiusCard),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: WidgetStatePropertyAll(3),
        radius: const Radius.circular(2),
        thumbColor: WidgetStatePropertyAll(OptoColors.primary.withAlpha(128)),
        trackColor: WidgetStatePropertyAll(Colors.transparent),
        thumbVisibility: WidgetStatePropertyAll(false),
        interactive: true,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w300),
        headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
