import 'dart:math';
import 'package:flutter/painting.dart';
import '../constants/app_constants.dart';
import '../models/test_config.dart';

/// Rango numérico (min, max).
class StimulusRange {
  final double min;
  final double max;
  const StimulusRange(this.min, this.max);
}

/// Lógica de posicionamiento de estímulos periféricos.
///
/// Encapsula las funciones de posición usadas por ambos tests
/// (estimulación dinámica y localización periférica).
class StimulusPositioning {
  final Random _rand;
  final DistanciaModo distanciaModo;
  final double distanciaPct;

  StimulusPositioning({
    required Random random,
    required this.distanciaModo,
    required this.distanciaPct,
  }) : _rand = random;

  /// Resuelve el lado (String) según el enum [Lado].
  String resolveSide(Lado lado) {
    return switch (lado) {
      Lado.izquierda => 'left',
      Lado.derecha => 'right',
      Lado.arriba => 'top',
      Lado.abajo => 'bottom',
      Lado.ambos => _rand.nextBool() ? 'left' : 'right',
      Lado.aleatorio =>
        ['left', 'right', 'top', 'bottom'][_rand.nextInt(4)],
    };
  }

  /// Calcula el top-left (Offset) para posicionar un estímulo de [sizePx]
  /// en el [side] de la pantalla de tamaño [screenSize].
  Offset resolveTopLeftForSide(
      String side, Size screenSize, double sizePx) {
    final centerOffset = generateCenterForSide(side, screenSize, sizePx);
    final minLeft = AppConstants.edgeMargin;
    final maxLeft =
        max(minLeft, screenSize.width - sizePx - AppConstants.edgeMargin);
    final minTop = AppConstants.edgeMargin;
    final maxTop =
        max(minTop, screenSize.height - sizePx - AppConstants.edgeMargin);

    return Offset(
      (centerOffset.dx - sizePx / 2).clamp(minLeft, maxLeft),
      (centerOffset.dy - sizePx / 2).clamp(minTop, maxTop),
    );
  }

  /// Genera el centro (punto medio) para un estímulo en [side].
  Offset generateCenterForSide(
      String side, Size screenSize, double sizePx) {
    final center = Offset(screenSize.width / 2, screenSize.height / 2);
    final maxRadius = min(screenSize.width, screenSize.height) / 2 -
        AppConstants.edgeMargin -
        sizePx / 2;
    if (maxRadius <= 0) return center;

    final safeRadius = min(
      maxRadius,
      max(AppConstants.centerClearance, sizePx * 0.75),
    );
    final minPct = (safeRadius / maxRadius).clamp(0.0, 1.0);
    double pct;

    if (distanciaModo == DistanciaModo.fijo) {
      pct = (distanciaPct / 100).clamp(minPct, 1.0);
    } else {
      pct = randRange(minPct, 1.0);
    }

    final radius = maxRadius * pct;
    final angle = angleForSide(side);
    final target = Offset(
      center.dx + cos(angle) * radius,
      center.dy + sin(angle) * radius,
    );

    final minX = AppConstants.edgeMargin + sizePx / 2;
    final maxX = screenSize.width - AppConstants.edgeMargin - sizePx / 2;
    final minY = AppConstants.edgeMargin + sizePx / 2;
    final maxY = screenSize.height - AppConstants.edgeMargin - sizePx / 2;

    return Offset(
      target.dx.clamp(minX, maxX),
      target.dy.clamp(minY, maxY),
    );
  }

  /// Ángulo aleatorio restringido al [side] indicado.
  double angleForSide(String side) {
    const double pad = 0.35;
    double angle;

    switch (side) {
      case 'left':
        angle = randRange(pi / 2 + pad, (3 * pi / 2) - pad);
        break;
      case 'right':
        angle = randRange(-pi / 2 + pad, pi / 2 - pad);
        break;
      case 'top':
        angle = randRange(pad, pi - pad);
        break;
      case 'bottom':
        angle = randRange(pi + pad, (2 * pi) - pad);
        break;
      default:
        angle = randRange(0, 2 * pi);
    }

    return normalizeAngle(angle);
  }

  /// Valor aleatorio en el rango [minValue, maxValue].
  double randRange(double minValue, double maxValue) {
    if (maxValue <= minValue) return minValue;
    return minValue + _rand.nextDouble() * (maxValue - minValue);
  }

  /// Normaliza [angle] al rango [0, 2π).
  double normalizeAngle(double angle) {
    final full = 2 * pi;
    var normalized = angle;
    while (normalized < 0) normalized += full;
    while (normalized >= full) normalized -= full;
    return normalized;
  }

  /// Límites horizontales para movimiento.
  StimulusRange horizontalBoundsForSide(
      String side, double width, double sizePx) {
    final center = width / 2;
    final gap = _centerGap(sizePx);
    double minLeft = AppConstants.edgeMargin;
    double maxLeft = width - sizePx - AppConstants.edgeMargin;

    if (side == 'right') {
      final limit = center + gap - sizePx / 2;
      minLeft = max(minLeft, limit);
    } else if (side == 'left') {
      final limit = center - gap - sizePx / 2;
      maxLeft = min(maxLeft, limit);
    }

    if (minLeft > maxLeft) {
      final fallback = (minLeft + maxLeft) / 2;
      minLeft = fallback;
      maxLeft = fallback;
    }

    return StimulusRange(minLeft, maxLeft);
  }

  /// Límites verticales para movimiento.
  StimulusRange verticalBoundsForSide(
      String side, double height, double sizePx) {
    final center = height / 2;
    final gap = _centerGap(sizePx);
    double minTop = AppConstants.edgeMargin;
    double maxTop = height - sizePx - AppConstants.edgeMargin;

    if (side == 'bottom') {
      final limit = center + gap - sizePx / 2;
      minTop = max(minTop, limit);
    } else if (side == 'top') {
      final limit = center - gap - sizePx / 2;
      maxTop = min(maxTop, limit);
    }

    if (minTop > maxTop) {
      final fallback = (minTop + maxTop) / 2;
      minTop = fallback;
      maxTop = fallback;
    }

    return StimulusRange(minTop, maxTop);
  }

  double _centerGap(double sizePx) =>
      (sizePx / 2) + AppConstants.centerClearance;

  /// Tamaño del estímulo en píxeles según la configuración.
  double resolveStimulusSize(
    Size screenSize,
    double tamanoPorc, {
    bool tamanoAleatorio = false,
  }) {
    final shortest = screenSize.shortestSide;
    final basePx = shortest * (tamanoPorc / 200);
    if (!tamanoAleatorio) return basePx;

    final double minPct = (tamanoPorc * 0.7)
        .clamp(AppConstants.minSizePercent, AppConstants.maxSizePercent);
    final double maxPct = (tamanoPorc * 1.3)
        .clamp(AppConstants.minSizePercent, AppConstants.maxSizePercent);
    if ((maxPct - minPct).abs() < 0.1) return basePx;
    final double pct = minPct + _rand.nextDouble() * (maxPct - minPct);
    return shortest * (pct / 200);
  }

  /// Genera [count] posiciones sin solapamiento dentro de [screenSize].
  List<Offset> generateNonOverlappingPositions(
    int count,
    Size screenSize,
    double sizePx,
    Lado lado,
  ) {
    final positions = <Offset>[];
    final minSep = sizePx * 1.5;
    int attempts = 0;
    const maxAttempts = 50;

    while (positions.length < count && attempts < maxAttempts) {
      attempts++;
      final side = resolveSide(lado);
      final center = generateCenterForSide(side, screenSize, sizePx);
      final topLeft = Offset(
        (center.dx - sizePx / 2).clamp(
            AppConstants.edgeMargin,
            max(AppConstants.edgeMargin,
                screenSize.width - sizePx - AppConstants.edgeMargin)),
        (center.dy - sizePx / 2).clamp(
            AppConstants.edgeMargin,
            max(AppConstants.edgeMargin,
                screenSize.height - sizePx - AppConstants.edgeMargin)),
      );

      bool overlaps = false;
      for (final existing in positions) {
        final dist = (topLeft - existing).distance;
        if (dist < minSep) {
          overlaps = true;
          break;
        }
      }
      if (!overlaps) {
        positions.add(topLeft);
      }
    }

    // Rellenar con el último válido si no se generaron suficientes
    while (positions.length < count && positions.isNotEmpty) {
      positions.add(positions.last);
    }

    return positions;
  }
}
