import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../models/test_config.dart';
import '../models/localization_config.dart';
import '../models/localization_result.dart';
import '../widgets/center_fixation.dart';
import '../widgets/peripheral_stimulus.dart';
import '../widgets/background_pattern.dart';
import 'localization_results_screen.dart';

class LocalizationTest extends StatefulWidget {
  final LocalizationConfig config;
  const LocalizationTest({super.key, required this.config});

  @override
  State<LocalizationTest> createState() => _LocalizationTestState();
}

/// Datos de un estímulo activo en pantalla
class _ActiveStimulus {
  final int id;
  final double top;
  final double left;
  final Forma? forma;
  final String? text;
  final SimboloCategoria categoria;
  final EstimuloColor colorOption;
  final bool isTarget;
  final DateTime shownAt;
  final double sizePx;

  _ActiveStimulus({
    required this.id,
    required this.top,
    required this.left,
    this.forma,
    this.text,
    required this.categoria,
    required this.colorOption,
    required this.isTarget,
    required this.shownAt,
    required this.sizePx,
  });
}

/// Datos de feedback visual temporal
class _FeedbackIndicator {
  final double top;
  final double left;
  final bool isCorrect;
  final DateTime createdAt;

  _FeedbackIndicator({
    required this.top,
    required this.left,
    required this.isCorrect,
    required this.createdAt,
  });
}

class _LocalizationTestState extends State<LocalizationTest>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  Timer? _stimulusTimer;
  Timer? _endTimer;
  Timer? _countdownTimer;
  Timer? _feedbackTimer;

  late int _remaining;
  bool _isPaused = false;

  // Estímulos activos en pantalla
  final List<_ActiveStimulus> _activeStimuli = [];
  int _nextStimulusId = 0;

  // Feedback visual
  final List<_FeedbackIndicator> _feedbackIndicators = [];

  // Centro actual
  Forma? _centerForma;
  String? _centerText;
  EstimuloColor _centerColorOption = EstimuloColor.blanco;

  // Métricas
  int _totalStimuliShown = 0;
  int _correctTouches = 0;
  int _incorrectTouches = 0;
  int _missedStimuli = 0;
  final List<double> _reactionTimesMs = [];

  late final DateTime _startedAt;
  final _rand = Random();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _remaining = widget.config.duracionSegundos.clamp(1, 3600);
    _startedAt = DateTime.now();

    // Modo inmersivo y landscape
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Generar estímulo central inicial
    _generateCenterStimulus();

    _startTest();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelAllTimers();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (!_isPaused) _pauseTest();
    }
  }

  // --- Centro ---

  void _generateCenterStimulus() {
    switch (widget.config.categoria) {
      case SimboloCategoria.letras:
        const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        _centerText = letters[_rand.nextInt(letters.length)];
        _centerForma = null;
        break;
      case SimboloCategoria.numeros:
        _centerText = '${_rand.nextInt(10)}';
        _centerForma = null;
        break;
      case SimboloCategoria.formas:
        _centerText = null;
        _centerForma = widget.config.forma ??
            Forma.values[_rand.nextInt(Forma.values.length)];
        break;
    }
    _centerColorOption = _pickSolidColor();
  }

  EstimuloColor _pickSolidColor() {
    final palette = EstimuloColorTheme.solidColors;
    return palette[_rand.nextInt(palette.length)];
  }

  EstimuloColor _pickDifferentColor(EstimuloColor exclude) {
    final palette =
        EstimuloColorTheme.solidColors.where((c) => c != exclude).toList();
    if (palette.isEmpty) return exclude;
    return palette[_rand.nextInt(palette.length)];
  }

  Forma _pickDifferentForma(Forma exclude) {
    final options = Forma.values.where((f) => f != exclude).toList();
    if (options.isEmpty) return exclude;
    return options[_rand.nextInt(options.length)];
  }

  // --- Test lifecycle ---

  void _startTest() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _remaining = max(0, _remaining - 1));
    });

    _endTimer = Timer(Duration(seconds: _remaining), () {
      _finishTest(stoppedManually: false);
    });

    final periodMs = widget.config.velocidad.milliseconds * 2;
    _stimulusTimer =
        Timer.periodic(Duration(milliseconds: periodMs), (t) {
      if (!mounted || _isPaused) return;
      _spawnStimulusCycle();
    });

    // Primer ciclo inmediato
    if (!_isPaused) {
      Future.microtask(() => _spawnStimulusCycle());
    }
  }

  void _spawnStimulusCycle() {
    if (!mounted) return;

    // Cambiar centro si no es fijo
    if (!widget.config.centroFijo) {
      _generateCenterStimulus();
    }

    // Quitar estímulos anteriores no tocados
    _removeExpiredStimuli();

    final sz = MediaQuery.of(context).size;
    final sizePx = _resolveStimulusSize(sz);
    final count = widget.config.stimuliSimultaneos;

    // Generar posiciones sin solapamiento
    final positions = _generateNonOverlappingPositions(count, sz, sizePx);

    // Decidir cuántos targets vs distractores
    final stimuli = <_ActiveStimulus>[];
    for (int i = 0; i < positions.length; i++) {
      final isTarget = _decideIfTarget(i, positions.length);
      final stimulus = _createStimulus(
        positions[i],
        sizePx,
        isTarget: isTarget,
      );
      stimuli.add(stimulus);
      _totalStimuliShown++;
    }

    setState(() {
      _activeStimuli.addAll(stimuli);
    });

    // Si es por tiempo, programar desaparición
    if (widget.config.desaparicion == DisappearMode.porTiempo) {
      final onMs = widget.config.velocidad.milliseconds;
      Future.delayed(Duration(milliseconds: onMs), () {
        if (!mounted || _isPaused) return;
        _removeExpiredStimuli();
      });
    }
  }

  bool _decideIfTarget(int index, int total) {
    final modo = widget.config.modo;
    if (modo == LocalizationMode.tocarTodos) return true;

    // Al menos 1 target, el resto puede ser distractor
    if (total == 1) return true;
    if (index == 0) return true; // primer estímulo siempre target
    // 40% probabilidad de ser distractor para los demás
    return _rand.nextDouble() > 0.4;
  }

  _ActiveStimulus _createStimulus(
    Offset position,
    double sizePx, {
    required bool isTarget,
  }) {
    final id = _nextStimulusId++;
    final modo = widget.config.modo;

    Forma? forma;
    String? text;
    EstimuloColor colorOption;

    if (isTarget || modo == LocalizationMode.tocarTodos) {
      // Target: mismas propiedades que el centro
      forma = _centerForma;
      text = _centerText;
      colorOption = _centerColorOption;
    } else {
      // Distractor: depende del modo
      switch (modo) {
        case LocalizationMode.igualarCentro:
          // Cambiar forma Y color
          if (widget.config.categoria == SimboloCategoria.formas) {
            forma = _pickDifferentForma(_centerForma ?? Forma.circulo);
            text = null;
          } else {
            forma = null;
            text = _generateDifferentText();
          }
          colorOption = _pickDifferentColor(_centerColorOption);
          break;
        case LocalizationMode.mismoColor:
          // Mismo tipo de estímulo pero diferente color
          forma = _centerForma;
          text = _centerText;
          colorOption = _pickDifferentColor(_centerColorOption);
          break;
        case LocalizationMode.mismaForma:
          // Misma forma pero diferente color
          if (widget.config.categoria == SimboloCategoria.formas) {
            forma = _centerForma;
          } else {
            text = _centerText;
          }
          colorOption = _pickDifferentColor(_centerColorOption);
          break;
        case LocalizationMode.tocarTodos:
          // No debería llegar aquí
          forma = _centerForma;
          text = _centerText;
          colorOption = _centerColorOption;
          break;
      }
    }

    return _ActiveStimulus(
      id: id,
      top: position.dy,
      left: position.dx,
      forma: forma,
      text: text,
      categoria: widget.config.categoria,
      colorOption: colorOption,
      isTarget: isTarget,
      shownAt: DateTime.now(),
      sizePx: sizePx,
    );
  }

  String _generateDifferentText() {
    if (widget.config.categoria == SimboloCategoria.letras) {
      const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      String result;
      do {
        result = letters[_rand.nextInt(letters.length)];
      } while (result == _centerText && letters.length > 1);
      return result;
    } else {
      String result;
      do {
        result = '${_rand.nextInt(10)}';
      } while (result == _centerText);
      return result;
    }
  }

  void _removeExpiredStimuli() {
    if (!mounted) return;
    final toRemove = <_ActiveStimulus>[];
    for (final s in _activeStimuli) {
      if (s.isTarget) {
        _missedStimuli++;
      }
      toRemove.add(s);
    }
    if (toRemove.isNotEmpty) {
      setState(() {
        _activeStimuli.removeWhere((s) => toRemove.contains(s));
      });
    }
  }

  // --- Toque ---

  void _onStimulusTapped(_ActiveStimulus stimulus) {
    if (_isPaused) return;

    final reactionMs = DateTime.now()
        .difference(stimulus.shownAt)
        .inMicroseconds / 1000.0;

    if (stimulus.isTarget) {
      _correctTouches++;
      _reactionTimesMs.add(reactionMs);
    } else {
      _incorrectTouches++;
    }

    setState(() {
      _activeStimuli.removeWhere((s) => s.id == stimulus.id);
    });

    if (widget.config.feedbackVisual) {
      _showFeedback(
        stimulus.top + stimulus.sizePx / 2,
        stimulus.left + stimulus.sizePx / 2,
        stimulus.isTarget,
      );
    }
  }

  void _showFeedback(double top, double left, bool isCorrect) {
    final indicator = _FeedbackIndicator(
      top: top,
      left: left,
      isCorrect: isCorrect,
      createdAt: DateTime.now(),
    );

    setState(() {
      _feedbackIndicators.add(indicator);
    });

    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() {
        _feedbackIndicators
            .removeWhere((f) => f.createdAt == indicator.createdAt);
      });
    });
  }

  // --- Posicionamiento (similar a dynamic_periphery_test) ---

  List<Offset> _generateNonOverlappingPositions(
      int count, Size screenSize, double sizePx) {
    final positions = <Offset>[];
    final minSep = sizePx * 1.5;
    int attempts = 0;
    const maxAttempts = 50;

    while (positions.length < count && attempts < maxAttempts) {
      attempts++;
      final side = _resolveSide();
      final center =
          _generateCenterForSide(side, screenSize, sizePx);
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

      // Verificar no solapamiento
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

    // Si no se generaron suficientes, rellenar con el último válido
    while (positions.length < count && positions.isNotEmpty) {
      positions.add(positions.last);
    }

    return positions;
  }

  String _resolveSide() {
    return switch (widget.config.lado) {
      Lado.izquierda => 'left',
      Lado.derecha => 'right',
      Lado.arriba => 'top',
      Lado.abajo => 'bottom',
      Lado.ambos => _rand.nextBool() ? 'left' : 'right',
      Lado.aleatorio =>
        ['left', 'right', 'top', 'bottom'][_rand.nextInt(4)],
    };
  }

  Offset _generateCenterForSide(
      String side, Size screenSize, double sizePx) {
    final center =
        Offset(screenSize.width / 2, screenSize.height / 2);
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

    if (widget.config.distanciaModo == DistanciaModo.fijo) {
      pct = (widget.config.distanciaPct / 100).clamp(minPct, 1.0);
    } else {
      pct = _randRange(minPct, 1.0);
    }

    final radius = maxRadius * pct;
    final angle = _angleForSide(side);
    final target = Offset(
      center.dx + cos(angle) * radius,
      center.dy + sin(angle) * radius,
    );

    final minX = AppConstants.edgeMargin + sizePx / 2;
    final maxX =
        screenSize.width - AppConstants.edgeMargin - sizePx / 2;
    final minY = AppConstants.edgeMargin + sizePx / 2;
    final maxY =
        screenSize.height - AppConstants.edgeMargin - sizePx / 2;

    return Offset(
      target.dx.clamp(minX, maxX),
      target.dy.clamp(minY, maxY),
    );
  }

  double _angleForSide(String side) {
    const double pad = 0.35;
    double angle;

    switch (side) {
      case 'left':
        angle = _randRange(pi / 2 + pad, (3 * pi / 2) - pad);
        break;
      case 'right':
        angle = _randRange(-pi / 2 + pad, pi / 2 - pad);
        break;
      case 'top':
        angle = _randRange(pad, pi - pad);
        break;
      case 'bottom':
        angle = _randRange(pi + pad, (2 * pi) - pad);
        break;
      default:
        angle = _randRange(0, 2 * pi);
    }

    return _normalizeAngle(angle);
  }

  double _randRange(double minValue, double maxValue) {
    if (maxValue <= minValue) return minValue;
    return minValue + _rand.nextDouble() * (maxValue - minValue);
  }

  double _normalizeAngle(double angle) {
    final full = 2 * pi;
    var normalized = angle;
    while (normalized < 0) normalized += full;
    while (normalized >= full) normalized -= full;
    return normalized;
  }

  double _resolveStimulusSize(Size screenSize) {
    final shortest = screenSize.shortestSide;
    return shortest * (widget.config.tamanoPorc / 200);
  }

  Color? _outlineColorForStimulus(EstimuloColor colorOption) {
    final fondo = widget.config.fondo;
    switch (colorOption) {
      case EstimuloColor.negro:
        if (fondo == Fondo.oscuro) return Colors.white;
        break;
      case EstimuloColor.blanco:
        if (fondo == Fondo.claro) return Colors.black;
        break;
      case EstimuloColor.azul:
        if (fondo == Fondo.azul) return Colors.black;
        break;
      default:
        break;
    }
    return null;
  }

  // --- Pausa / Reanudación ---

  void _togglePause() {
    if (_isPaused) {
      _resumeFromPause();
    } else {
      _pauseTest();
    }
  }

  void _pauseTest() {
    _cancelAllTimers();
    setState(() {
      _isPaused = true;
      _activeStimuli.clear();
    });
  }

  void _resumeFromPause() {
    setState(() => _isPaused = false);
    _startTest();
  }

  // --- Fin del test ---

  void _finishTest({required bool stoppedManually}) {
    if (!mounted) return;
    _cancelAllTimers();

    // Contar estímulos no tocados como missed
    for (final s in _activeStimuli) {
      if (s.isTarget) _missedStimuli++;
    }

    final actualDuration = widget.config.duracionSegundos - _remaining;

    setState(() {
      _activeStimuli.clear();
      _remaining = 0;
    });

    final result = LocalizationResult(
      config: widget.config,
      totalStimuliShown: _totalStimuliShown,
      correctTouches: _correctTouches,
      incorrectTouches: _incorrectTouches,
      missedStimuli: _missedStimuli,
      reactionTimesMs: List.unmodifiable(_reactionTimesMs),
      durationActualSeconds: actualDuration,
      completedNaturally: !stoppedManually,
      startedAt: _startedAt,
      finishedAt: DateTime.now(),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LocalizationResultsScreen(result: result),
      ),
    );
  }

  void _cancelAllTimers() {
    _stimulusTimer?.cancel();
    _endTimer?.cancel();
    _countdownTimer?.cancel();
    _feedbackTimer?.cancel();
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    final sz = MediaQuery.of(context).size;
    final centerSizePx = _resolveStimulusSize(sz) * 0.8;

    return Scaffold(
      body: BackgroundPattern(
        fondo: widget.config.fondo,
        distractor: widget.config.fondoDistractor,
        animado: widget.config.fondoDistractorAnimado,
        child: Stack(
          children: [
            // Punto de fijación
            CenterFixation(
              tipo: widget.config.fijacion,
              fondo: widget.config.fondo,
            ),

            // Estímulo de referencia central (debajo del punto de fijación)
            if (widget.config.modo != LocalizationMode.tocarTodos)
              Positioned(
                left: sz.width / 2 - centerSizePx / 2,
                top: sz.height / 2 + 40,
                child: SizedBox(
                  width: centerSizePx,
                  height: centerSizePx,
                  child: _buildCenterReference(centerSizePx),
                ),
              ),

            // Estímulos activos
            if (!_isPaused)
              ..._activeStimuli.map((stimulus) => PeripheralStimulus(
                    key: ValueKey(stimulus.id),
                    categoria: stimulus.categoria,
                    forma: stimulus.forma,
                    text: stimulus.text,
                    size: stimulus.sizePx,
                    side: 'left', // positioning is manual via top/left
                    top: stimulus.top,
                    left: stimulus.left,
                    onTap: () => _onStimulusTapped(stimulus),
                    color: stimulus.colorOption.color,
                    outlineColor:
                        _outlineColorForStimulus(stimulus.colorOption),
                  )),

            // Indicadores de feedback
            ..._feedbackIndicators.map((f) => Positioned(
                  top: f.top - 20,
                  left: f.left - 20,
                  child: IgnorePointer(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (f.isCorrect ? Colors.green : Colors.red)
                            .withValues(alpha: 0.6),
                        border: Border.all(
                          color: f.isCorrect ? Colors.green : Colors.red,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        f.isCorrect ? Icons.check : Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                )),

            // Tiempo restante
            Positioned(
              top: 24,
              left: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Tiempo: $_remaining s  |  Aciertos: $_correctTouches',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),

            // Botones de control
            Positioned(
              top: 24,
              right: 24,
              child: Row(
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black45,
                    ),
                    onPressed: _togglePause,
                    icon: Icon(
                        _isPaused ? Icons.play_arrow : Icons.pause),
                    label:
                        Text(_isPaused ? 'Reanudar' : 'Pausar'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black45,
                    ),
                    onPressed: () =>
                        _finishTest(stoppedManually: true),
                    icon: const Icon(Icons.stop),
                    label: const Text('Terminar'),
                  ),
                ],
              ),
            ),

            // Overlay de pausa
            if (_isPaused)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.7),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.pause_circle_filled,
                          size: 80,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'PRUEBA EN PAUSA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tiempo restante: $_remaining s',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FilledButton.icon(
                              onPressed: _togglePause,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Reanudar'),
                            ),
                            const SizedBox(width: 16),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                    color: Colors.white54),
                              ),
                              onPressed: () =>
                                  _finishTest(stoppedManually: true),
                              icon: const Icon(Icons.stop),
                              label: const Text('Terminar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterReference(double size) {
    if (widget.config.categoria == SimboloCategoria.formas) {
      return _buildShapePreview(
          _centerForma ?? Forma.circulo, _centerColorOption.color, size);
    }

    return FittedBox(
      fit: BoxFit.contain,
      child: Text(
        _centerText ?? '',
        style: TextStyle(
          color: _centerColorOption.color,
          fontSize: 100,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildShapePreview(Forma forma, Color color, double size) {
    switch (forma) {
      case Forma.circulo:
        return DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: const SizedBox.expand(),
        );
      case Forma.cuadrado:
        return DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(size * 0.08),
          ),
          child: const SizedBox.expand(),
        );
      case Forma.corazon:
        return FittedBox(
          child: Icon(Icons.favorite, color: color),
        );
      case Forma.triangulo:
        return CustomPaint(
          painter: _TrianglePainter(color),
        );
      case Forma.trebol:
        return FittedBox(
          child: Icon(Icons.filter_vintage, color: color),
        );
    }
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) =>
      oldDelegate.color != color;
}
