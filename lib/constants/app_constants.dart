import 'package:flutter/material.dart';

abstract final class AppConstants {
  // Colores corporativos
  static const Color optoviewBlue = Color(0xFF3F6FB2);
  static const Color optoviewBluePattern = Color(0xFF8ABFF5);

  // Layout del test
  static const double edgeMargin = 32.0;
  static const double centerClearance = 110.0;

  // Slider de tamaño
  static const double minSizePercent = 5.0;
  static const double maxSizePercent = 35.0;

  // Slider de duración
  static const int minDurationSeconds = 10;
  static const int maxDurationSeconds = 300;

  // Slider de distancia
  static const double minDistancePercent = 10.0;
  static const double maxDistancePercent = 100.0;
}
