import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../mixins/immersive_test_mixin.dart';
import '../models/field_detection_config.dart';
import '../models/field_detection_result.dart';
import '../models/macdonald_config.dart' show MacContenido;
import '../models/macdonald_result.dart' show LetterEvent;
import '../models/test_config.dart';
import '../services/config_storage.dart';
import '../utils/page_transitions.dart';
import '../widgets/center_fixation.dart';
import '../widgets/test_ui/instruction_overlay.dart';
import '../widgets/test_ui/pause_overlay.dart';
import '../widgets/test_ui/test_control_buttons.dart';
import 'field_detection_results_screen.dart';

class FieldDetectionTest extends StatefulWidget {
  final FieldDetectionConfig config;
  final String patientName;

  const FieldDetectionTest({
    super.key,
    required this.config,
    required this.patientName,
  });

  @override
  State<FieldDetectionTest> createState() => _FieldDetectionTestState();
}

class _FieldLetterData {
  final String letter;
  final int ringIndex;
  final int posIndex;
  final Offset position;
  bool isRevealed = false;
  DateTime? revealedAt;

  _FieldLetterData({
    required this.letter,
    required this.ringIndex,
    required this.posIndex,
    required this.position,
  });
}

class _FieldDetectionTestState extends State<FieldDetectionTest>
    with WidgetsBindingObserver, ImmersiveTestMixin {
  Timer? _letterTimer;
  Timer? _preCountdownTimer;

  // Pre-test state
  bool _showingInstructions = false;
  int _preCountdown = 3;
  bool _testStarted = false;

  // Letters
  final List<_FieldLetterData> _allLetters = [];
  Offset _chartCenter = Offset.zero;
  double _maxRadius = 1;
  List<int> _revealOrder = [];
  int _revealIndex = 0;

  // Metrics
  int _totalLetrasShown = 0;
  int _correctCount = 0;
  int _missedCount = 0;
  final List<double> _reactionTimesMs = [];
  final List<LetterEvent> _letterEvents = [];
  final List<double> _tiempoPorAnillo = [];
  int? _currentRingIndex;
  DateTime? _ringStartedAt;

  bool _isPaused = false;
  late DateTime _startedAt;
  DateTime? _firstLetterAt;
  final _rand = Random();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initImmersiveMode();
    _startedAt = DateTime.now();
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
      if (!_isPaused && _testStarted) _pauseTest();
    }
  }

  // --- Instructions / countdown ---

  Future<void> _checkInstructions() async {
    final show = await ConfigStorage.loadShowInstructions();
    if (!mounted) return;
    if (show) {
      setState(() => _showingInstructions = true);
    } else {
      _runPreCountdown();
    }
  }

  void _handleInstructionsComplete() {
    setState(() {
      _showingInstructions = false;
      _testStarted = true;
    });
    _startedAt = DateTime.now();
    _startTestAfterLayout();
  }

  List<String> _buildInstructions(AppLocalizations l) {
    return [
      l.instructFixation,
      l.instructFieldDetection,
      l.instructFieldDetectionRings,
    ];
  }

  void _runPreCountdown() {
    _preCountdown = 3;
    _preCountdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
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
      _revealNextLetter();
    });
  }

  // --- Chart generation ---

  void _generateChart(Size screenSize) {
    _allLetters.clear();
    final center = Offset(screenSize.width / 2, screenSize.height / 2);
    _chartCenter = center;
    final maxRadius = min(screenSize.width, screenSize.height) * 0.42;
    _maxRadius = maxRadius;
    final numRings = widget.config.numAnillos;
    final base = widget.config.letrasPorAnilloBase;

    final chars = widget.config.contenido == MacContenido.numeros
        ? '0123456789'
        : 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    int letterIdx = 0;
    for (int ring = 0; ring < numRings; ring++) {
      final lettersInRing = base + 2 * ring;
      final ringRadius = maxRadius * (ring + 1) / numRings;
      for (int i = 0; i < lettersInRing; i++) {
        final angle = (2 * pi * i / lettersInRing) - pi / 2;
        final x = center.dx + ringRadius * cos(angle);
        final y = center.dy + ringRadius * sin(angle);
        final letter = widget.config.letrasAleatorias
            ? chars[_rand.nextInt(chars.length)]
            : chars[letterIdx % chars.length];
        letterIdx++;
        _allLetters.add(_FieldLetterData(
          letter: letter,
          ringIndex: ring,
          posIndex: i,
          position: Offset(x, y),
        ));
      }
    }

    _revealOrder = List<int>.generate(_allLetters.length, (i) => i)
      ..shuffle(_rand);
  }

  // --- Main loop ---

  void _revealNextLetter() {
    if (!mounted || _isPaused) return;
    if (_revealIndex >= _revealOrder.length) {
      _finishTest(stoppedManually: false);
      return;
    }

    final idx = _revealOrder[_revealIndex];
    final letter = _allLetters[idx];

    if (_currentRingIndex == null) {
      _currentRingIndex = letter.ringIndex;
      _ringStartedAt = DateTime.now();
    } else if (letter.ringIndex != _currentRingIndex) {
      _recordRingDuration();
      _currentRingIndex = letter.ringIndex;
      _ringStartedAt = DateTime.now();
    }

    setState(() {
      letter.isRevealed = true;
      letter.revealedAt = DateTime.now();
      _firstLetterAt ??= letter.revealedAt;
      _totalLetrasShown++;
    });

    final periodMs = widget.config.velocidad.milliseconds;
    _letterTimer?.cancel();
    _letterTimer = Timer(Duration(milliseconds: periodMs), () {
      if (!mounted || _isPaused) return;
      _missedCount++;
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
      _revealNextLetter();
    });
  }

  void _onLetterTapped(int idx) {
    if (_isPaused || _revealIndex >= _revealOrder.length) return;
    if (idx != _revealOrder[_revealIndex]) return;

    final letter = _allLetters[idx];
    if (!letter.isRevealed) return;

    _letterTimer?.cancel();
    _letterTimer = null;

    final reactionMs = letter.revealedAt != null
        ? DateTime.now().difference(letter.revealedAt!).inMicroseconds / 1000.0
        : 0.0;

    _correctCount++;
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
    _revealNextLetter();
  }

  void _recordRingDuration() {
    if (_ringStartedAt != null) {
      final elapsed =
          DateTime.now().difference(_ringStartedAt!).inMilliseconds.toDouble();
      _tiempoPorAnillo.add(elapsed);
    }
  }

  // --- Pause / resume / stop ---

  void _togglePause() {
    if (_isPaused) {
      setState(() => _isPaused = false);
      _revealNextLetter();
    } else {
      _pauseTest();
    }
  }

  void _pauseTest() {
    _letterTimer?.cancel();
    _letterTimer = null;
    setState(() {
      _isPaused = true;
      if (_revealIndex < _revealOrder.length) {
        _allLetters[_revealOrder[_revealIndex]].isRevealed = false;
      }
    });
  }

  void _finishTest({required bool stoppedManually}) {
    if (!mounted) return;
    _cancelAllTimers();
    _recordRingDuration();

    final finishedAt = DateTime.now();
    final totalDurationMs = _firstLetterAt != null
        ? finishedAt.difference(_firstLetterAt!).inMilliseconds
        : 0;

    final result = FieldDetectionResult(
      config: widget.config,
      patientName: widget.patientName,
      completedNaturally: !stoppedManually,
      startedAt: _startedAt,
      finishedAt: finishedAt,
      totalLetrasShown: _totalLetrasShown,
      correctCount: _correctCount,
      missedCount: _missedCount,
      reactionTimesMs: List.unmodifiable(_reactionTimesMs),
      letterEvents: List.unmodifiable(_letterEvents),
      tiempoPorAnillo: List.unmodifiable(_tiempoPorAnillo),
      totalDurationMs: totalDurationMs,
    );

    Navigator.of(context).pushReplacement(
      OptoPageRoute(
        builder: (_) => FieldDetectionResultsScreen(result: result),
      ),
    );
  }

  void _cancelAllTimers() {
    _letterTimer?.cancel();
    _letterTimer = null;
    _preCountdownTimer?.cancel();
    _preCountdownTimer = null;
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final sz = MediaQuery.of(context).size;
    final letterSizePx = sz.shortestSide * (widget.config.tamanoBase / 200);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Scaffold(
        body: Container(
          color: widget.config.fondo.baseColor,
          child: Stack(
            children: [
              CenterFixation(
                tipo: widget.config.fijacion,
                fondo: widget.config.fondo,
              ),

              if (_testStarted)
                ..._allLetters.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final letter = entry.value;
                  if (!letter.isRevealed) return const SizedBox.shrink();
                  return Positioned(
                    left: letter.position.dx - letterSizePx / 2,
                    top: letter.position.dy - letterSizePx / 2,
                    child: GestureDetector(
                      onTap: () => _onLetterTapped(idx),
                      child: SizedBox(
                        width: letterSizePx,
                        height: letterSizePx,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            letter.letter,
                            style: TextStyle(
                              color: widget.config.colorLetras.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 100,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),

              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    l.fieldDetectionLetterCounter(
                      _revealIndex.clamp(0, _revealOrder.length),
                      _revealOrder.isEmpty
                          ? widget.config.totalLetras
                          : _revealOrder.length,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              TestControlButtons(
                isPaused: _isPaused,
                onTogglePause: _togglePause,
                onStop: () => _finishTest(stoppedManually: true),
              ),

              if (_isPaused)
                PauseOverlay(
                  remainingSeconds: 0,
                  elapsedSeconds: 0,
                  stimuliShown: _totalLetrasShown,
                  onResume: _togglePause,
                  onStop: () => _finishTest(stoppedManually: true),
                ),

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
                  testTitle: l.configFieldDetectionTitle,
                  instructions: _buildInstructions(l),
                  onCountdownComplete: _handleInstructionsComplete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
