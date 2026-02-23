import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../mixins/immersive_test_mixin.dart';
import '../models/test_config.dart';
import '../models/localization_config.dart';
import '../models/localization_result.dart';
import '../utils/stimulus_positioning.dart';
import '../utils/stimulus_color_utils.dart';
import '../widgets/peripheral_stimulus.dart';
import '../widgets/background_pattern.dart';
import '../widgets/test_ui/pause_overlay.dart';
import '../widgets/test_ui/test_control_buttons.dart';
import '../widgets/test_ui/test_timer_display.dart';
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
    with WidgetsBindingObserver, TickerProviderStateMixin, ImmersiveTestMixin {
  Timer? _stimulusTimer;
  Timer? _endTimer;
  Timer? _countdownTimer;
  Timer? _feedbackTimer;

  late int _remaining;
  bool _isPaused = false;

  // Cuenta regresiva pre-test
  int _preCountdown = 3;
  bool _testStarted = false;

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

  DateTime _startedAt = DateTime.now();
  final _rand = Random();
  late final StimulusPositioning _positioning;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _remaining = widget.config.duracionSegundos.clamp(1, 3600);

    _positioning = StimulusPositioning(
      random: _rand,
      distanciaModo: widget.config.distanciaModo,
      distanciaPct: widget.config.distanciaPct,
    );

    initImmersiveMode();

    // Generar estímulo central inicial
    _generateCenterStimulus();

    _runPreCountdown();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelAllTimers();
    disposeImmersiveMode();

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

  /// Elige un color que no esté en la lista de excluidos (para distractores únicos)
  EstimuloColor _pickUniqueColor(List<EstimuloColor> exclude) {
    final available = EstimuloColorTheme.solidColors
        .where((c) => !exclude.contains(c))
        .toList();
    if (available.isEmpty) {
      return _pickDifferentColor(_centerColorOption);
    }
    return available[_rand.nextInt(available.length)];
  }

  /// Elige una forma que no esté en la lista de excluidas (para distractores únicos)
  Forma _pickUniqueForma(List<Forma> exclude) {
    final available =
        Forma.values.where((f) => !exclude.contains(f)).toList();
    if (available.isEmpty) {
      return _pickDifferentForma(_centerForma ?? Forma.circulo);
    }
    return available[_rand.nextInt(available.length)];
  }

  // --- Test lifecycle ---

  void _runPreCountdown() {
    _preCountdown = 3;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _preCountdown--;
        if (_preCountdown <= 0) {
          t.cancel();
          _testStarted = true;
          _startedAt = DateTime.now();
          _startTest();
        }
      });
    });
  }

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
    final sizePx = _positioning.resolveStimulusSize(sz, widget.config.tamanoPorc);
    final count = widget.config.stimuliSimultaneos;

    // Generar posiciones sin solapamiento
    final positions = _positioning.generateNonOverlappingPositions(
        count, sz, sizePx, widget.config.lado);

    // Decidir cuántos targets vs distractores
    final stimuli = <_ActiveStimulus>[];
    final usedDistractorColors = <EstimuloColor>[];
    final usedDistractorFormas = <Forma>[];

    for (int i = 0; i < positions.length; i++) {
      final isTarget = _decideIfTarget(i, positions.length);
      final stimulus = _createStimulus(
        positions[i],
        sizePx,
        isTarget: isTarget,
        usedDistractorColors: usedDistractorColors,
        usedDistractorFormas: usedDistractorFormas,
      );
      if (!isTarget) {
        usedDistractorColors.add(stimulus.colorOption);
        if (stimulus.forma != null) usedDistractorFormas.add(stimulus.forma!);
      }
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

    if (total == 1) {
      return _rand.nextBool();
    }

    // Con múltiples: exactamente 1 target, el resto distractores
    return index == 0;
  }

  _ActiveStimulus _createStimulus(
    Offset position,
    double sizePx, {
    required bool isTarget,
    required List<EstimuloColor> usedDistractorColors,
    required List<Forma> usedDistractorFormas,
  }) {
    final id = _nextStimulusId++;
    final modo = widget.config.modo;

    Forma? forma;
    String? text;
    EstimuloColor colorOption;

    if (isTarget || modo == LocalizationMode.tocarTodos) {
      forma = _centerForma;
      text = _centerText;
      colorOption = _centerColorOption;
    } else {
      final excludeColors = [_centerColorOption, ...usedDistractorColors];
      final excludeFormas = [
        if (_centerForma != null) _centerForma!,
        ...usedDistractorFormas,
      ];

      switch (modo) {
        case LocalizationMode.igualarCentro:
          if (widget.config.categoria == SimboloCategoria.formas) {
            forma = _pickUniqueForma(excludeFormas);
            text = null;
          } else {
            forma = null;
            text = _generateDifferentText();
          }
          colorOption = _pickUniqueColor(excludeColors);
          break;
        case LocalizationMode.mismoColor:
          if (widget.config.categoria == SimboloCategoria.formas) {
            forma = _centerForma;
          } else {
            text = _centerText;
          }
          colorOption = _pickUniqueColor(excludeColors);
          break;
        case LocalizationMode.mismaForma:
          if (widget.config.categoria == SimboloCategoria.formas) {
            forma = _pickUniqueForma(excludeFormas);
          } else {
            text = _generateDifferentText();
          }
          colorOption = _pickUniqueColor(excludeColors);
          break;
        case LocalizationMode.tocarTodos:
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
    final l = AppLocalizations.of(context)!;
    final sz = MediaQuery.of(context).size;
    final centerSizePx = _positioning.resolveStimulusSize(
            sz, widget.config.tamanoPorc) *
        1.3;

    return Scaffold(
      body: BackgroundPattern(
        fondo: widget.config.fondo,
        distractor: widget.config.fondoDistractor,
        animado: widget.config.fondoDistractorAnimado,
        child: Stack(
          children: [
            // El centro SIEMPRE muestra el estímulo de referencia
            Center(
              child: Container(
                width: centerSizePx,
                height: centerSizePx,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: _buildCenterReference(centerSizePx - 16),
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
                    top: stimulus.top,
                    left: stimulus.left,
                    onTap: () => _onStimulusTapped(stimulus),
                    color: stimulus.colorOption.color,
                    outlineColor: outlineColorForStimulus(
                        stimulus.colorOption, widget.config.fondo),
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

            TestTimerDisplay(
              text: l.testTimeAndHits(_remaining, _correctTouches),
            ),
            TestControlButtons(
              isPaused: _isPaused,
              onTogglePause: _togglePause,
              onStop: () => _finishTest(stoppedManually: true),
            ),
            if (_isPaused)
              PauseOverlay(
                remainingSeconds: _remaining,
                onResume: _togglePause,
                onStop: () => _finishTest(stoppedManually: true),
              ),
            if (!_testStarted)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.8),
                  child: Center(
                    child: Text(
                      '$_preCountdown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 120,
                        fontWeight: FontWeight.bold,
                      ),
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
