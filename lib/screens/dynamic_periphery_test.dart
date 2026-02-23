import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../mixins/immersive_test_mixin.dart';
import '../models/test_config.dart';
import '../models/test_result.dart';
import '../utils/stimulus_positioning.dart';
import '../utils/stimulus_color_utils.dart';
import '../widgets/center_fixation.dart';
import '../widgets/peripheral_stimulus.dart';
import '../widgets/background_pattern.dart';
import '../widgets/test_ui/pause_overlay.dart';
import '../widgets/test_ui/test_control_buttons.dart';
import '../widgets/test_ui/test_timer_display.dart';
import 'test_results_screen.dart';

class DynamicPeripheryTest extends StatefulWidget {
  final TestConfig config;
  const DynamicPeripheryTest({super.key, required this.config});

  @override
  State<DynamicPeripheryTest> createState() => _DynamicPeripheryTestState();
}

class _DynamicPeripheryTestState extends State<DynamicPeripheryTest>
    with WidgetsBindingObserver, TickerProviderStateMixin, ImmersiveTestMixin {
  Timer? _stimulusTimer;
  Timer? _endTimer;
  Timer? _countdownTimer;

  bool _showStimulus = false;
  late int _remaining;
  AnimationController? _moveCtrl;
  double _currentTop = 0;
  double _currentLeft = 0;

  String? _currentText;
  Forma? _currentForma;
  EstimuloColor _currentColorOption = EstimuloColor.rojo;
  double _currentSizePx = 0;
  final _rand = Random();
  late final StimulusPositioning _positioning;

  // Pausa
  bool _isPaused = false;

  // Cuenta regresiva pre-test
  int _preCountdown = 3;
  bool _testStarted = false;

  // Conteo de estímulos
  int _stimuliShown = 0;
  DateTime _startedAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _remaining = widget.config.duracionSegundos.clamp(1, 3600);
    _currentColorOption = _resolveStimulusColorOption();

    _positioning = StimulusPositioning(
      random: _rand,
      distanciaModo: widget.config.distanciaModo,
      distanciaPct: widget.config.distanciaPct,
    );

    initImmersiveMode();

    _runPreCountdown();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelAllTimers();
    _disposeMoveCtrl();
    disposeImmersiveMode();

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

    final onMs = widget.config.velocidad.milliseconds;
    final offMs = widget.config.velocidad.milliseconds;
    final period = onMs + offMs;

    _stimulusTimer =
        Timer.periodic(Duration(milliseconds: period), (t) async {
      if (!mounted || _isPaused) return;

      final lado = _positioning.resolveSide(widget.config.lado);

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
    _currentSizePx = _positioning.resolveStimulusSize(
      sz,
      widget.config.tamanoPorc,
      tamanoAleatorio: widget.config.tamanoAleatorio,
    );
    final sizePx = _currentSizePx;
    final offset = _positioning.resolveTopLeftForSide(side, sz, sizePx);
    _currentLeft = offset.dx;
    _currentTop = offset.dy;

    setState(() {
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
    _currentSizePx = _positioning.resolveStimulusSize(
      sz,
      widget.config.tamanoPorc,
      tamanoAleatorio: widget.config.tamanoAleatorio,
    );
    final sizePx = _currentSizePx;
    final isVertical = movimiento == Movimiento.vertical;
    final forward = _rand.nextBool();
    final baseOffset = _positioning.resolveTopLeftForSide(side, sz, sizePx);

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
      final bounds =
          _positioning.verticalBoundsForSide(side, sz.height, sizePx);
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
      final bounds =
          _positioning.horizontalBoundsForSide(side, sz.width, sizePx);
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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
                top: _currentTop,
                left: _currentLeft,
                onTap: () {},
                color: _currentColorOption.color,
                outlineColor: outlineColorForStimulus(
                    _currentColorOption, widget.config.fondo),
              ),
            TestTimerDisplay(text: l.testTimeRemaining(_remaining)),
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
}
