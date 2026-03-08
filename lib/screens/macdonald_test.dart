import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../mixins/immersive_test_mixin.dart';
import '../constants/app_constants.dart';
import '../models/test_config.dart';
import '../models/macdonald_config.dart';
import '../models/macdonald_result.dart';
import '../widgets/center_fixation.dart';
import '../widgets/test_ui/pause_overlay.dart';
import '../widgets/test_ui/test_control_buttons.dart';
import '../widgets/test_ui/test_timer_display.dart';
import '../widgets/test_ui/instruction_overlay.dart';
import '../services/config_storage.dart';
import 'macdonald_results_screen.dart';

class MacDonaldTest extends StatefulWidget {
  final MacDonaldConfig config;
  final String patientName;
  const MacDonaldTest({super.key, required this.config, required this.patientName});

  @override
  State<MacDonaldTest> createState() => _MacDonaldTestState();
}

/// Datos de una letra en la carta
class _ChartLetterData {
  final String letter;
  final int ringIndex;
  final int posIndex;
  final Offset position;
  final Color letterColor;
  bool isRevealed;
  bool isHighlighted = false;
  bool isCompleted = false;
  DateTime? revealedAt;

  _ChartLetterData({
    required this.letter,
    required this.ringIndex,
    required this.posIndex,
    required this.position,
    required this.letterColor,
    this.isRevealed = false,
    this.revealedAt,
  });
}

class _MacDonaldTestState extends State<MacDonaldTest>
    with WidgetsBindingObserver, TickerProviderStateMixin, ImmersiveTestMixin {
  Timer? _endTimer;
  Timer? _countdownTimer;
  Timer? _revealTimer;
  Timer? _fieldLetterTimer;

  late int _remaining;
  bool _isPaused = false;

  // Instrucciones y cuenta regresiva pre-test
  bool _showingInstructions = false;
  int _preCountdown = 3;
  bool _testStarted = false;

  // Letras de la carta
  final List<_ChartLetterData> _allLetters = [];
  Offset _chartCenter = Offset.zero;
  double _maxRadius = 1;

  // Eventos de posición para diagrama de puntos
  final List<LetterEvent> _letterEvents = [];

  // Índice de la siguiente letra/anillo a revelar
  int _revealIndex = 0;

  // Secuencia de revelado/resaltado
  int _highlightIndex = 0;
  List<int> _revealOrder = [];

  // Métricas
  int _totalLetrasShown = 0;
  int _correctTouches = 0;
  int _incorrectTouches = 0;
  int _missedLetras = 0;
  final List<double> _reactionTimesMs = [];
  int _anillosCompletados = 0;
  final List<double> _tiempoPorAnillo = [];
  DateTime? _anilloStartTime;

  // Para modo tocar: siguiente letra esperada
  int _nextExpectedTouchIndex = 0;

  DateTime _startedAt = DateTime.now();
  final _rand = Random();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _remaining = widget.config.duracionSegundos.clamp(
        AppConstants.minDurationSeconds, AppConstants.maxDurationSeconds);

    initImmersiveMode();

    _checkInstructions();
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

  // --- Generación de letras ---

  Color _resolveLetterColorForGeneration() {
    final colorOpt = widget.config.colorLetras;
    if (colorOpt.isRandom) {
      final palette = EstimuloColorTheme.solidColors;
      return palette[_rand.nextInt(palette.length)].color;
    }
    return colorOpt.color;
  }

  void _generateChart(Size screenSize) {
    _allLetters.clear();

    final center = Offset(screenSize.width / 2, screenSize.height / 2);
    _chartCenter = center;
    final maxRadius = min(screenSize.width, screenSize.height) * 0.42;
    _maxRadius = maxRadius;
    final numRings = widget.config.numAnillos;
    final baseLettersPerRing = widget.config.letrasPorAnillo;

    final chars = widget.config.contenido == MacContenido.numeros
        ? '0123456789'
        : 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    int letterIdx = 0;

    for (int ring = 0; ring < numRings; ring++) {
      final lettersInRing = baseLettersPerRing + ring * 2;
      final ringRadius = maxRadius * (ring + 1) / numRings;

      for (int i = 0; i < lettersInRing; i++) {
        final angle = (2 * pi * i / lettersInRing) - pi / 2;
        final x = center.dx + ringRadius * cos(angle);
        final y = center.dy + ringRadius * sin(angle);

        String letter;
        if (widget.config.letrasAleatorias) {
          letter = chars[_rand.nextInt(chars.length)];
        } else {
          letter = chars[letterIdx % chars.length];
          letterIdx++;
        }

        final isRevealed =
            widget.config.visualizacion == MacVisualizacion.completa &&
            widget.config.interaccion != MacInteraccion.deteccionCampo;

        _allLetters.add(_ChartLetterData(
          letter: letter,
          ringIndex: ring,
          posIndex: i,
          position: Offset(x, y),
          letterColor: _resolveLetterColorForGeneration(),
          isRevealed: isRevealed,
          revealedAt: isRevealed ? DateTime.now() : null,
        ));
      }
    }

    _totalLetrasShown =
        (widget.config.visualizacion == MacVisualizacion.completa &&
                widget.config.interaccion != MacInteraccion.deteccionCampo)
            ? _allLetters.length
            : 0;

    // Build reveal order based on direction
    _revealOrder = _buildRevealOrder();
  }

  /// Normaliza un ángulo atan2 a [0, 2*pi) empezando desde arriba (-pi/2).
  double _normalizedAngle(Offset pos) {
    final angle = atan2(pos.dy - _chartCenter.dy, pos.dx - _chartCenter.dx);
    return (angle + pi / 2) % (2 * pi);
  }

  List<int> _buildRevealOrder() {
    final direction = widget.config.direccion;
    final indices = List<int>.generate(_allLetters.length, (i) => i);

    switch (direction) {
      case MacDireccion.centroAfuera:
        // Anillo por anillo, del centro hacia afuera, sentido horario
        indices.sort((a, b) {
          final cmp =
              _allLetters[a].ringIndex.compareTo(_allLetters[b].ringIndex);
          if (cmp != 0) return cmp;
          return _allLetters[a].posIndex.compareTo(_allLetters[b].posIndex);
        });
      case MacDireccion.afueraCentro:
        // Anillo por anillo, de afuera hacia el centro, sentido horario
        indices.sort((a, b) {
          final cmp =
              _allLetters[b].ringIndex.compareTo(_allLetters[a].ringIndex);
          if (cmp != 0) return cmp;
          return _allLetters[a].posIndex.compareTo(_allLetters[b].posIndex);
        });
      case MacDireccion.horario:
        // Por ángulo (horario desde arriba), agrupando radialmente
        indices.sort((a, b) {
          final angleA = _normalizedAngle(_allLetters[a].position);
          final angleB = _normalizedAngle(_allLetters[b].position);
          final cmp = angleA.compareTo(angleB);
          if (cmp != 0) return cmp;
          return _allLetters[a].ringIndex.compareTo(_allLetters[b].ringIndex);
        });
      case MacDireccion.antihorario:
        // Por ángulo (antihorario desde arriba), agrupando radialmente
        indices.sort((a, b) {
          final angleA = _normalizedAngle(_allLetters[a].position);
          final angleB = _normalizedAngle(_allLetters[b].position);
          final cmp = angleB.compareTo(angleA);
          if (cmp != 0) return cmp;
          return _allLetters[a].ringIndex.compareTo(_allLetters[b].ringIndex);
        });
    }

    return indices;
  }

  // --- Instrucciones pre-test ---

  Future<void> _checkInstructions() async {
    final show = await ConfigStorage.loadShowInstructions();
    if (!mounted) return;
    if (show) {
      setState(() => _showingInstructions = true);
    } else {
      _runPreCountdown();
    }
  }

  void _dismissInstructions() {
    setState(() => _showingInstructions = false);
    _runPreCountdown();
  }

  List<String> _buildInstructions(AppLocalizations l) {
    final c = widget.config;
    final interactionInstruction = switch (c.interaccion) {
      MacInteraccion.tocarLetras => l.instructMacTouch,
      MacInteraccion.lecturaConTiempo => l.instructMacTimed,
      MacInteraccion.lecturaSecuencial => l.instructMacSequential,
      MacInteraccion.deteccionCampo => l.instructMacFieldDetection,
    };
    final contentLabel = c.contenido == MacContenido.numeros
        ? l.macContentNumbers
        : l.macContentLetters;
    return [
      l.instructFixation,
      interactionInstruction,
      if (c.interaccion != MacInteraccion.deteccionCampo) ...[
        switch (c.visualizacion) {
          MacVisualizacion.completa => l.instructMacVisComplete,
          MacVisualizacion.progresiva => l.instructMacVisProgressive,
          MacVisualizacion.porAnillos => l.instructMacVisByRings,
        },
      ],
      l.instructMacContent(contentLabel),
      l.instructDuration(c.duracionSegundos),
    ];
  }

  // --- Pre-countdown ---

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
          _startTestAfterLayout();
        }
      });
    });
  }

  void _startTestAfterLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final sz = MediaQuery.of(context).size;
      _generateChart(sz);
      setState(() {});
      _startTest();
    });
  }

  // --- Test lifecycle ---

  void _startTest() {
    // Countdown timer
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _remaining = max(0, _remaining - 1));
    });

    // End timer
    _endTimer = Timer(Duration(seconds: _remaining), () {
      _finishTest(stoppedManually: false);
    });

    _anilloStartTime = DateTime.now();

    // Start reveal/highlight logic based on mode
    _startModeLogic();
  }

  void _startModeLogic() {
    final vis = widget.config.visualizacion;
    final inter = widget.config.interaccion;

    if (inter == MacInteraccion.deteccionCampo) {
      _revealOrder.shuffle(_rand);
      _startFieldDetection();
      return;
    }

    if (vis == MacVisualizacion.completa) {
      // All letters already revealed
      if (inter == MacInteraccion.lecturaSecuencial) {
        _startSequentialHighlight();
      }
      // For tocar and lecturaConTiempo with completa, just wait for user
    } else if (vis == MacVisualizacion.progresiva) {
      _startProgressiveReveal();
    } else if (vis == MacVisualizacion.porAnillos) {
      _revealCurrentRing();
    }
  }

  void _startFieldDetection() {
    _revealIndex = 0;
    _revealNextFieldLetter();
  }

  void _revealNextFieldLetter() {
    if (!mounted || _isPaused) return;
    if (_revealIndex >= _revealOrder.length) {
      _finishTest(stoppedManually: false);
      return;
    }

    final idx = _revealOrder[_revealIndex];
    setState(() {
      _allLetters[idx].isRevealed = true;
      _allLetters[idx].revealedAt = DateTime.now();
      _totalLetrasShown++;

      // Track ring transitions
      if (_revealIndex > 0) {
        final prevIdx = _revealOrder[_revealIndex - 1];
        final prevRing = _allLetters[prevIdx].ringIndex;
        if (_allLetters[idx].ringIndex != prevRing) {
          _recordRingCompletion();
        }
      }
    });

    // Start disappear timer
    final periodMs = widget.config.velocidadRevelado.milliseconds;
    _fieldLetterTimer?.cancel();
    _fieldLetterTimer = Timer(Duration(milliseconds: periodMs), () {
      if (!mounted || _isPaused) return;
      final letter = _allLetters[idx];
      _missedLetras++;
      _letterEvents.add(LetterEvent(
        dx: (letter.position.dx - _chartCenter.dx) / _maxRadius,
        dy: (letter.position.dy - _chartCenter.dy) / _maxRadius,
        ringIndex: letter.ringIndex,
        isHit: false,
      ));
      setState(() {
        letter.isRevealed = false;
      });
      _revealIndex++;
      _revealNextFieldLetter();
    });
  }

  void _startProgressiveReveal() {
    _revealIndex = 0;
    final periodMs = widget.config.velocidadRevelado.milliseconds;

    _revealTimer = Timer.periodic(Duration(milliseconds: periodMs), (t) {
      if (!mounted || _isPaused) return;
      if (_revealIndex >= _revealOrder.length) {
        t.cancel();
        // All revealed - start highlight if sequential
        if (widget.config.interaccion == MacInteraccion.lecturaSecuencial) {
          _startSequentialHighlight();
        }
        return;
      }

      setState(() {
        final idx = _revealOrder[_revealIndex];
        _allLetters[idx].isRevealed = true;
        _allLetters[idx].revealedAt = DateTime.now();
        _totalLetrasShown++;

        // Track ring transitions
        final newRing = _allLetters[idx].ringIndex;
        if (_revealIndex > 0) {
          final prevIdx = _revealOrder[_revealIndex - 1];
          final prevRing = _allLetters[prevIdx].ringIndex;
          if (newRing != prevRing) {
            _recordRingCompletion();
          }
        }

        _revealIndex++;
      });
    });
  }

  void _revealCurrentRing() {
    final targetRing = _getRingToReveal();
    if (targetRing < 0) return;

    setState(() {
      for (final letterData in _allLetters) {
        if (letterData.ringIndex == targetRing && !letterData.isRevealed) {
          letterData.isRevealed = true;
          letterData.revealedAt = DateTime.now();
          _totalLetrasShown++;
        }
      }
    });

    _anilloStartTime = DateTime.now();

    // For sequential mode on porAnillos, highlight within the ring
    if (widget.config.interaccion == MacInteraccion.lecturaSecuencial) {
      _startSequentialHighlightForRing(targetRing);
    }
  }

  int _getRingToReveal() {
    final direction = widget.config.direccion;
    final numRings = widget.config.numAnillos;

    if (direction == MacDireccion.afueraCentro) {
      // Reveal from outer to inner
      for (int r = numRings - 1; r >= 0; r--) {
        if (_allLetters.any((l) => l.ringIndex == r && !l.isRevealed)) {
          return r;
        }
      }
    } else {
      // Default: center to outer
      for (int r = 0; r < numRings; r++) {
        if (_allLetters.any((l) => l.ringIndex == r && !l.isRevealed)) {
          return r;
        }
      }
    }
    return -1;
  }

  void _advanceToNextRing() {
    _recordRingCompletion();

    // Clear highlights
    for (final l in _allLetters) {
      l.isHighlighted = false;
    }

    _revealTimer?.cancel();

    final nextRing = _getRingToReveal();
    if (nextRing < 0) {
      // All rings done
      _finishTest(stoppedManually: false);
      return;
    }

    _revealCurrentRing();
  }

  void _startSequentialHighlight() {
    _highlightIndex = 0;
    final periodMs = widget.config.velocidadRevelado.milliseconds;

    // Clear previous highlights
    for (final l in _allLetters) {
      l.isHighlighted = false;
    }

    _revealTimer = Timer.periodic(Duration(milliseconds: periodMs), (t) {
      if (!mounted || _isPaused) return;
      if (_highlightIndex >= _revealOrder.length) {
        t.cancel();
        return;
      }

      setState(() {
        // Remove previous highlight
        for (final l in _allLetters) {
          l.isHighlighted = false;
        }

        final idx = _revealOrder[_highlightIndex];
        _allLetters[idx].isHighlighted = true;

        // Track ring changes
        if (_highlightIndex > 0) {
          final prevIdx = _revealOrder[_highlightIndex - 1];
          final prevRing = _allLetters[prevIdx].ringIndex;
          final newRing = _allLetters[idx].ringIndex;
          if (newRing != prevRing) {
            _recordRingCompletion();
          }
        }

        _highlightIndex++;
      });
    });
  }

  void _startSequentialHighlightForRing(int ring) {
    _highlightIndex = 0;

    final ringLetterIndices = <int>[];
    for (int i = 0; i < _revealOrder.length; i++) {
      if (_allLetters[_revealOrder[i]].ringIndex == ring) {
        ringLetterIndices.add(_revealOrder[i]);
      }
    }

    if (ringLetterIndices.isEmpty) return;

    final periodMs = widget.config.velocidadRevelado.milliseconds;

    _revealTimer?.cancel();
    _revealTimer = Timer.periodic(Duration(milliseconds: periodMs), (t) {
      if (!mounted || _isPaused) return;
      if (_highlightIndex >= ringLetterIndices.length) {
        t.cancel();
        // Auto-advance ring if porAnillos
        if (widget.config.visualizacion == MacVisualizacion.porAnillos) {
          _advanceToNextRing();
        }
        return;
      }

      setState(() {
        for (final l in _allLetters) {
          l.isHighlighted = false;
        }
        _allLetters[ringLetterIndices[_highlightIndex]].isHighlighted = true;
        _highlightIndex++;
      });
    });
  }

  void _recordRingCompletion() {
    _anillosCompletados++;
    if (_anilloStartTime != null) {
      final elapsed =
          DateTime.now().difference(_anilloStartTime!).inMilliseconds.toDouble();
      _tiempoPorAnillo.add(elapsed);
    }
    _anilloStartTime = DateTime.now();
  }

  // --- Touch handling (for tocarLetras mode) ---

  void _onLetterTapped(int letterIndex) {
    if (_isPaused) return;

    final inter = widget.config.interaccion;

    // Field detection mode: any visible letter can be touched
    if (inter == MacInteraccion.deteccionCampo) {
      final letter = _allLetters[letterIndex];
      if (!letter.isRevealed) return;

      _fieldLetterTimer?.cancel();
      _fieldLetterTimer = null;

      final reactionMs = letter.revealedAt != null
          ? DateTime.now().difference(letter.revealedAt!).inMicroseconds / 1000.0
          : 0.0;

      _correctTouches++;
      _reactionTimesMs.add(reactionMs);
      _letterEvents.add(LetterEvent(
        dx: (letter.position.dx - _chartCenter.dx) / _maxRadius,
        dy: (letter.position.dy - _chartCenter.dy) / _maxRadius,
        ringIndex: letter.ringIndex,
        isHit: true,
      ));

      setState(() {
        letter.isRevealed = false;
      });

      _revealIndex++;
      _revealNextFieldLetter();
      return;
    }

    if (inter != MacInteraccion.tocarLetras) return;

    final letter = _allLetters[letterIndex];
    if (!letter.isRevealed || letter.isCompleted) return;

    final reactionMs = letter.revealedAt != null
        ? DateTime.now().difference(letter.revealedAt!).inMicroseconds / 1000.0
        : 0.0;

    // In touch mode, check if this is the expected next letter in order
    if (_revealOrder.isNotEmpty && _nextExpectedTouchIndex < _revealOrder.length) {
      final expectedIdx = _revealOrder[_nextExpectedTouchIndex];
      if (letterIndex == expectedIdx) {
        _correctTouches++;
        _reactionTimesMs.add(reactionMs);
        _nextExpectedTouchIndex++;

        // Track ring transitions
        if (_nextExpectedTouchIndex > 1 &&
            _nextExpectedTouchIndex <= _revealOrder.length) {
          final prevIdx = _revealOrder[_nextExpectedTouchIndex - 2];
          if (_allLetters[prevIdx].ringIndex != letter.ringIndex) {
            _recordRingCompletion();
          }
        }
      } else {
        _incorrectTouches++;
      }
    } else {
      // Fallback: any touch on unrevealed letter
      _correctTouches++;
      _reactionTimesMs.add(reactionMs);
    }

    setState(() {
      letter.isCompleted = true;
    });

    // Check if all letters completed
    if (_allLetters.every((l) => !l.isRevealed || l.isCompleted)) {
      _recordRingCompletion();
      _finishTest(stoppedManually: false);
    }
  }

  // --- Next ring button (for lecturaConTiempo + porAnillos) ---

  void _onNextRingPressed() {
    if (widget.config.visualizacion == MacVisualizacion.porAnillos &&
        widget.config.interaccion == MacInteraccion.lecturaConTiempo) {
      _advanceToNextRing();
    }
  }

  // --- Pause / Resume ---

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
    });
  }

  void _resumeFromPause() {
    setState(() => _isPaused = false);

    // Restart countdown and end timers
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _remaining = max(0, _remaining - 1));
    });
    _endTimer = Timer(Duration(seconds: _remaining), () {
      _finishTest(stoppedManually: false);
    });
    _anilloStartTime ??= DateTime.now();

    // Resume mode logic only if not yet fully revealed/highlighted
    _resumeModeLogic();
  }

  void _resumeModeLogic() {
    final vis = widget.config.visualizacion;
    final inter = widget.config.interaccion;

    if (inter == MacInteraccion.deteccionCampo) {
      if (_revealIndex < _revealOrder.length) {
        _revealNextFieldLetter();
      }
      return;
    }

    if (vis == MacVisualizacion.completa) {
      if (inter == MacInteraccion.lecturaSecuencial &&
          _highlightIndex < _revealOrder.length) {
        _startSequentialHighlight();
      }
    } else if (vis == MacVisualizacion.progresiva) {
      if (_revealIndex < _revealOrder.length) {
        _startProgressiveReveal();
      } else if (inter == MacInteraccion.lecturaSecuencial &&
          _highlightIndex < _revealOrder.length) {
        _startSequentialHighlight();
      }
    } else if (vis == MacVisualizacion.porAnillos) {
      final currentRing = _getRingToReveal();
      if (currentRing >= 0) {
        // Ring already revealed, just restart highlight if sequential
        if (inter == MacInteraccion.lecturaSecuencial) {
          _startSequentialHighlightForRing(currentRing);
        }
      }
    }
  }

  // --- Finish ---

  void _finishTest({required bool stoppedManually}) {
    if (!mounted) return;
    _cancelAllTimers();

    // Count untouched letters as missed (for tocarLetras mode only)
    if (widget.config.interaccion == MacInteraccion.tocarLetras) {
      for (final l in _allLetters) {
        if (l.isRevealed && !l.isCompleted) {
          _missedLetras++;
        }
      }
    }

    // Record final ring if needed
    if (_anilloStartTime != null && _tiempoPorAnillo.length < _anillosCompletados + 1) {
      _recordRingCompletion();
    }

    final actualDuration = widget.config.duracionSegundos - _remaining;

    setState(() {
      _remaining = 0;
    });

    final result = MacDonaldResult(
      config: widget.config,
      patientName: widget.patientName,
      completedNaturally: !stoppedManually,
      durationActualSeconds: actualDuration,
      startedAt: _startedAt,
      finishedAt: DateTime.now(),
      totalLetrasShown: _totalLetrasShown,
      correctTouches: _correctTouches,
      incorrectTouches: _incorrectTouches,
      missedLetras: _missedLetras,
      reactionTimesMs: List.unmodifiable(_reactionTimesMs),
      anillosCompletados: _anillosCompletados,
      tiempoPorAnillo: List.unmodifiable(_tiempoPorAnillo),
      letterEvents: List.unmodifiable(_letterEvents),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MacDonaldResultsScreen(result: result),
      ),
    );
  }

  void _cancelAllTimers() {
    _endTimer?.cancel();
    _endTimer = null;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _revealTimer?.cancel();
    _revealTimer = null;
    _fieldLetterTimer?.cancel();
    _fieldLetterTimer = null;
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final sz = MediaQuery.of(context).size;
    final letterSizePx = sz.shortestSide * (widget.config.tamanoBase / 200);

    return Scaffold(
      body: Container(
        color: widget.config.fondo.baseColor,
        child: Stack(
          children: [
            // Center fixation
            CenterFixation(
              tipo: widget.config.fijacion,
              fondo: widget.config.fondo,
            ),

            // Letters
            if (_testStarted)
              ..._allLetters.asMap().entries.map((entry) {
                final idx = entry.key;
                final letter = entry.value;

                if (!letter.isRevealed) return const SizedBox.shrink();

                return Positioned(
                  left: letter.position.dx - letterSizePx / 2,
                  top: letter.position.dy - letterSizePx / 2,
                  child: _ChartLetter(
                    letter: letter.letter,
                    size: letterSizePx,
                    color: letter.letterColor,
                    isHighlighted: letter.isHighlighted,
                    isCompleted: letter.isCompleted,
                    isDark: widget.config.fondo.isDark,
                    onTap: (widget.config.interaccion ==
                                MacInteraccion.tocarLetras ||
                            widget.config.interaccion ==
                                MacInteraccion.deteccionCampo)
                        ? () => _onLetterTapped(idx)
                        : null,
                  ),
                );
              }),

            // Timer display
            TestTimerDisplay(text: l.testTimeRemaining(_remaining)),

            // Control buttons
            TestControlButtons(
              isPaused: _isPaused,
              onTogglePause: _togglePause,
              onStop: () => _finishTest(stoppedManually: true),
            ),

            // Next ring button (for lecturaConTiempo + porAnillos)
            if (_testStarted &&
                !_isPaused &&
                widget.config.interaccion ==
                    MacInteraccion.lecturaConTiempo &&
                widget.config.visualizacion == MacVisualizacion.porAnillos)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: FilledButton.icon(
                    onPressed: _onNextRingPressed,
                    icon: const Icon(Icons.skip_next),
                    label: Text(l.macNextRing),
                  ),
                ),
              ),

            // Pause overlay
            if (_isPaused)
              PauseOverlay(
                remainingSeconds: _remaining,
                onResume: _togglePause,
                onStop: () => _finishTest(stoppedManually: true),
              ),

            // Pre-test countdown
            if (!_testStarted && !_showingInstructions)
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
            if (_showingInstructions)
              InstructionOverlay(
                title: l.configMacdonaldTitle,
                instructions: _buildInstructions(l),
                onStart: _dismissInstructions,
              ),
          ],
        ),
      ),
    );
  }
}

/// Widget for individual chart letter
class _ChartLetter extends StatelessWidget {
  final String letter;
  final double size;
  final Color color;
  final bool isHighlighted;
  final bool isCompleted;
  final bool isDark;
  final VoidCallback? onTap;

  const _ChartLetter({
    required this.letter,
    required this.size,
    required this.color,
    required this.isHighlighted,
    required this.isCompleted,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    BoxBorder? border;

    if (isCompleted) {
      bgColor = Colors.green.withValues(alpha: 0.3);
      textColor = Colors.green;
      border = Border.all(color: Colors.green, width: 2);
    } else if (isHighlighted) {
      bgColor = Colors.amber.withValues(alpha: 0.3);
      textColor = Colors.amber;
      border = Border.all(color: Colors.amber, width: 2);
    } else {
      bgColor = Colors.transparent;
      textColor = color;
      border = null;
    }

    final widget = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(size * 0.15),
        border: border,
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Padding(
          padding: EdgeInsets.all(size * 0.1),
          child: Text(
            letter,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 100,
            ),
          ),
        ),
      ),
    );

    if (onTap != null && !isCompleted) {
      return GestureDetector(
        onTap: onTap,
        child: widget,
      );
    }

    return widget;
  }
}
