import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../models/test_config.dart';
import '../models/test_result.dart';
import '../widgets/center_fixation.dart';
import '../widgets/peripheral_stimulus.dart';
import '../widgets/background_pattern.dart';
import 'test_results_screen.dart';

class DynamicPeripheryTest extends StatefulWidget {
  final TestConfig config;
  const DynamicPeripheryTest({super.key, required this.config});

  @override
  State<DynamicPeripheryTest> createState() => _DynamicPeripheryTestState();
}

class _Range {
  final double min;
  final double max;
  const _Range(this.min, this.max);
}

class _DynamicPeripheryTestState extends State<DynamicPeripheryTest>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  Timer? _stimulusTimer;
  Timer? _endTimer;
  Timer? _countdownTimer;

  bool _showStimulus = false;
  String _stimulusSide = 'left';
  late int _remaining;
  AnimationController? _moveCtrl;
  double _currentTop = 0;
  double _currentLeft = 0;

  String? _currentText;
  Forma? _currentForma;
  EstimuloColor _currentColorOption = EstimuloColor.rojo;
  double _currentSizePx = 0;
  final _rand = Random();

  // Pausa
  bool _isPaused = false;

  // Conteo de estímulos
  int _stimuliShown = 0;
  late final DateTime _startedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _remaining = widget.config.duracionSegundos.clamp(1, 3600);
    _currentColorOption = _resolveStimulusColorOption();
    _startedAt = DateTime.now();

    // Modo inmersivo y landscape
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _startTest();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelAllTimers();
    _disposeMoveCtrl();

    // Restaurar UI del sistema
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);

    super.dispose();
  }

  void _disposeMoveCtrl() {
    _moveCtrl?.stop();
    _moveCtrl?.dispose();
    _moveCtrl = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (!_isPaused) _pauseTest();
    }
    // No auto-reanudar: el usuario debe tocar "Reanudar"
  }

  void _startTest() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _remaining = max(0, _remaining - 1));
    });

    _endTimer = Timer(Duration(seconds: _remaining), () {
      _finishTest(stoppedManually: false);
    });

    final onMs = widget.config.velocidad.milliseconds;
    final offMs = widget.config.velocidad.milliseconds;
    final period = onMs + offMs;

    _stimulusTimer =
        Timer.periodic(Duration(milliseconds: period), (t) async {
      if (!mounted || _isPaused) return;

      final lado = switch (widget.config.lado) {
        Lado.izquierda => 'left',
        Lado.derecha => 'right',
        Lado.arriba => 'top',
        Lado.abajo => 'bottom',
        Lado.ambos => _rand.nextBool() ? 'left' : 'right',
        Lado.aleatorio =>
          ['left', 'right', 'top', 'bottom'][_rand.nextInt(4)],
      };

      _chooseSymbolOnceForThisAppearance();
      _stimuliShown++;

      final movimiento = widget.config.movimiento == Movimiento.aleatorio
          ? (_rand.nextBool() ? Movimiento.horizontal : Movimiento.vertical)
          : widget.config.movimiento;

      if (movimiento == Movimiento.fijo) {
        await _showFixed(onMs, lado);
      } else {
        await _runMovement(onMs, lado, movimiento);
      }
    });
  }

  void _chooseSymbolOnceForThisAppearance() {
    switch (widget.config.categoria) {
      case SimboloCategoria.letras:
        const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        _currentText = letters[_rand.nextInt(letters.length)];
        _currentForma = null;
        break;
      case SimboloCategoria.numeros:
        _currentText = '${_rand.nextInt(10)}';
        _currentForma = null;
        break;
      case SimboloCategoria.formas:
        _currentText = null;
        _currentForma = widget.config.forma ??
            Forma.values[_rand.nextInt(Forma.values.length)];
        break;
    }
    _currentColorOption = _resolveStimulusColorOption();
  }

  Future<void> _showFixed(int onMs, String side) async {
    final sz = MediaQuery.of(context).size;
    _currentSizePx = _resolveStimulusSize(sz);
    final sizePx = _currentSizePx;
    final offset = _resolveTopLeftForSide(side, sz, sizePx);
    _currentLeft = offset.dx;
    _currentTop = offset.dy;

    setState(() {
      _stimulusSide = side;
      _showStimulus = true;
    });

    await Future.delayed(Duration(milliseconds: onMs));
    if (!mounted) return;
    setState(() => _showStimulus = false);
  }

  Future<void> _runMovement(
    int onMs,
    String side,
    Movimiento movimiento,
  ) async {
    final sz = MediaQuery.of(context).size;
    _currentSizePx = _resolveStimulusSize(sz);
    final sizePx = _currentSizePx;
    final isVertical = movimiento == Movimiento.vertical;
    final forward = _rand.nextBool();
    final baseOffset = _resolveTopLeftForSide(side, sz, sizePx);

    _currentLeft = baseOffset.dx;
    _currentTop = baseOffset.dy;

    _disposeMoveCtrl();
    _moveCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: onMs),
    );

    final curved =
        CurvedAnimation(parent: _moveCtrl!, curve: Curves.linear);
    late Animation<double> anim;

    if (isVertical) {
      final bounds = _verticalBoundsForSide(side, sz.height, sizePx);
      final travel = min(120.0, (bounds.max - bounds.min) / 2);
      var topStart = max(bounds.min, baseOffset.dy - travel);
      var topEnd = min(bounds.max, baseOffset.dy + travel);
      if ((topEnd - topStart).abs() < 8) {
        final mid = (bounds.min + bounds.max) / 2;
        topStart = mid - 4;
        topEnd = mid + 4;
      }
      anim = Tween<double>(
        begin: forward ? topStart : topEnd,
        end: forward ? topEnd : topStart,
      ).animate(curved)
        ..addListener(() {
          if (mounted) setState(() => _currentTop = anim.value);
        });
    } else {
      final bounds = _horizontalBoundsForSide(side, sz.width, sizePx);
      final travel = min(120.0, (bounds.max - bounds.min) / 2);
      var leftStart = max(bounds.min, baseOffset.dx - travel);
      var leftEnd = min(bounds.max, baseOffset.dx + travel);
      if ((leftEnd - leftStart).abs() < 8) {
        final mid = (bounds.min + bounds.max) / 2;
        leftStart = mid - 4;
        leftEnd = mid + 4;
      }
      anim = Tween<double>(
        begin: forward ? leftStart : leftEnd,
        end: forward ? leftEnd : leftStart,
      ).animate(curved)
        ..addListener(() {
          if (mounted) setState(() => _currentLeft = anim.value);
        });
    }

    setState(() {
      _stimulusSide = side;
      _showStimulus = true;
    });

    try {
      await _moveCtrl!.forward().orCancel;
    } catch (_) {}

    if (mounted) setState(() => _showStimulus = false);
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
    _moveCtrl?.stop();
    setState(() {
      _isPaused = true;
      _showStimulus = false;
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
    _disposeMoveCtrl();

    final actualDuration = widget.config.duracionSegundos - _remaining;

    setState(() {
      _showStimulus = false;
      _remaining = 0;
    });

    final result = TestResult(
      config: widget.config,
      totalStimuliShown: _stimuliShown,
      durationActualSeconds: actualDuration,
      completedNaturally: !stoppedManually,
      startedAt: _startedAt,
      finishedAt: DateTime.now(),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => TestResultsScreen(result: result),
      ),
    );
  }

  void _cancelAllTimers() {
    _stimulusTimer?.cancel();
    _endTimer?.cancel();
    _countdownTimer?.cancel();
  }

  Offset _resolveTopLeftForSide(
      String side, Size screenSize, double sizePx) {
    final centerOffset =
        _generateCenterForSide(side, screenSize, sizePx);
    final minLeft = AppConstants.edgeMargin;
    final maxLeft = max(
        minLeft, screenSize.width - sizePx - AppConstants.edgeMargin);
    final minTop = AppConstants.edgeMargin;
    final maxTop = max(
        minTop, screenSize.height - sizePx - AppConstants.edgeMargin);

    return Offset(
      (centerOffset.dx - sizePx / 2).clamp(minLeft, maxLeft),
      (centerOffset.dy - sizePx / 2).clamp(minTop, maxTop),
    );
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

  _Range _horizontalBoundsForSide(
    String side,
    double width,
    double sizePx,
  ) {
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

    return _Range(minLeft, maxLeft);
  }

  _Range _verticalBoundsForSide(
    String side,
    double height,
    double sizePx,
  ) {
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

    return _Range(minTop, maxTop);
  }

  double _centerGap(double sizePx) =>
      (sizePx / 2) + AppConstants.centerClearance;

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
    while (normalized < 0) {
      normalized += full;
    }
    while (normalized >= full) {
      normalized -= full;
    }
    return normalized;
  }

  double _resolveStimulusSize(Size screenSize) {
    final shortest = screenSize.shortestSide;
    final basePct = widget.config.tamanoPorc;
    final basePx = shortest * (basePct / 200);
    if (!widget.config.tamanoAleatorio) return basePx;

    final double minPct = (basePct * 0.7)
        .clamp(AppConstants.minSizePercent, AppConstants.maxSizePercent);
    final double maxPct = (basePct * 1.3)
        .clamp(AppConstants.minSizePercent, AppConstants.maxSizePercent);
    if ((maxPct - minPct).abs() < 0.1) return basePx;
    final double pct =
        minPct + _rand.nextDouble() * (maxPct - minPct);
    return shortest * (pct / 200);
  }

  double _layoutSizePx(Size sz) {
    if (_currentSizePx > 0) return _currentSizePx;
    return sz.shortestSide * (widget.config.tamanoPorc / 200);
  }

  EstimuloColor _resolveStimulusColorOption() {
    final EstimuloColor option = widget.config.estimuloColor;
    if (!option.isRandom) return option;
    final palette = EstimuloColorTheme.solidColors;
    if (palette.isEmpty) return option;
    return palette[_rand.nextInt(palette.length)];
  }

  Color? _outlineColorForStimulus() {
    final fondo = widget.config.fondo;
    switch (_currentColorOption) {
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

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.of(context).size;
    final sizePx = _layoutSizePx(mediaSize);

    return Scaffold(
      body: BackgroundPattern(
        fondo: widget.config.fondo,
        distractor: widget.config.fondoDistractor,
        animado: widget.config.fondoDistractorAnimado,
        child: Stack(
          children: [
            CenterFixation(
              tipo: widget.config.fijacion,
              fondo: widget.config.fondo,
            ),
            if (_showStimulus && !_isPaused)
              PeripheralStimulus(
                categoria: widget.config.categoria,
                forma: _currentForma,
                text: _currentText,
                size: sizePx,
                side: _stimulusSide,
                top: _currentTop,
                left: _currentLeft,
                onTap: () {},
                color: _currentColorOption.color,
                outlineColor: _outlineColorForStimulus(),
              ),
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
                  'Tiempo restante: $_remaining s',
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
}
