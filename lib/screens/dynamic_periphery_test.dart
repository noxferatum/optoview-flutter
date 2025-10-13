import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/test_config.dart';
import '../widgets/center_fixation.dart';
import '../widgets/peripheral_stimulus.dart';
import '../widgets/background_pattern.dart';

class DynamicPeripheryTest extends StatefulWidget {
  final TestConfig config;
  const DynamicPeripheryTest({super.key, required this.config});

  @override
  State<DynamicPeripheryTest> createState() => _DynamicPeripheryTestState();
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
  final _rand = Random();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _remaining = widget.config.duracionSegundos.clamp(1, 3600);
    _startTest();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelAllTimers();
    _disposeMoveCtrl();
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
      _pauseTimers();
    } else if (state == AppLifecycleState.resumed) {
      _resumeTimers();
    }
  }

  int _velocidadMs(Velocidad v) {
    switch (v) {
      case Velocidad.rapida:
        return 1200;
      case Velocidad.media:
        return 1800;
      case Velocidad.lenta:
        return 2500;
    }
  }

  void _startTest() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _remaining = max(0, _remaining - 1));
    });

    _endTimer = Timer(Duration(seconds: _remaining), _finishTest);

    final onMs = _velocidadMs(widget.config.velocidad);
    final offMs = _velocidadMs(widget.config.velocidad);
    final period = onMs + offMs;

    _stimulusTimer = Timer.periodic(Duration(milliseconds: period), (t) async {
      if (!mounted) return;

      // Lado aleatorio si corresponde
      final lado = switch (widget.config.lado) {
        Lado.izquierda => 'left',
        Lado.derecha => 'right',
        Lado.arriba => 'top',
        Lado.abajo => 'bottom',
        Lado.ambos => _rand.nextBool() ? 'left' : 'right',
        Lado.aleatorio => ['left', 'right', 'top', 'bottom'][_rand.nextInt(4)],
      };

      _chooseSymbolOnceForThisAppearance();

      // Elegir tipo de movimiento (si aleatorio)
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
        _currentForma =
            widget.config.forma ??
            Forma.values[_rand.nextInt(Forma.values.length)];
        break;
    }
  }

  Future<void> _showFixed(int onMs, String side) async {
    final sz = MediaQuery.of(context).size;
    final sizePx = sz.shortestSide * (widget.config.tamanoPorc / 200);
    _currentTop = (sz.height / 2) - (sizePx / 2);
    _currentLeft = (sz.width / 2) - (sizePx / 2);

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
    final sizePx = sz.shortestSide * (widget.config.tamanoPorc / 200);
    const margin = 32.0;

    final isVertical = movimiento == Movimiento.vertical;
    final forward = _rand.nextBool();

    _disposeMoveCtrl();
    _moveCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: onMs),
    );

    final curved = CurvedAnimation(parent: _moveCtrl!, curve: Curves.linear);
    late Animation<double> anim;

    if (isVertical) {
      final topStart = margin;
      final topEnd = max(margin, sz.height - sizePx - margin);
      anim =
          Tween<double>(
            begin: forward ? topStart : topEnd,
            end: forward ? topEnd : topStart,
          ).animate(curved)..addListener(() {
            if (mounted) setState(() => _currentTop = anim.value);
          });
    } else {
      final leftStart = margin;
      final leftEnd = max(margin, sz.width - sizePx - margin);
      anim =
          Tween<double>(
            begin: forward ? leftStart : leftEnd,
            end: forward ? leftEnd : leftStart,
          ).animate(curved)..addListener(() {
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

  void _finishTest() {
    if (!mounted) return;
    _cancelAllTimers();
    _disposeMoveCtrl();
    setState(() {
      _showStimulus = false;
      _remaining = 0;
    });

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Prueba completada'),
        content: const Text('La duración configurada ha finalizado.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).maybePop();
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _cancelAllTimers() {
    _stimulusTimer?.cancel();
    _endTimer?.cancel();
    _countdownTimer?.cancel();
  }

  void _pauseTimers() {
    _cancelAllTimers();
    _moveCtrl?.stop();
  }

  void _resumeTimers() {
    if (_remaining > 0) {
      _startTest();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizePx =
        MediaQuery.of(context).size.shortestSide *
        (widget.config.tamanoPorc / 200);

    return Scaffold(
      body: BackgroundPattern(
        fondo: widget.config.fondo,
        distractor: widget.config.fondoDistractor,
        animado: widget.config.fondoDistractorAnimado, // 🔹 añadido
        child: Stack(
          children: [
            CenterFixation(
              tipo: widget.config.fijacion,
              fondo: widget.config.fondo,
            ),
            if (_showStimulus)
              PeripheralStimulus(
                categoria: widget.config.categoria,
                forma: _currentForma,
                text: _currentText,
                size: sizePx,
                side: _stimulusSide,
                top: _currentTop,
                left: _currentLeft,
                onTap: () {},
              ),
            Positioned(
              top: 24,
              left: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Tiempo restante: $_remaining s',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            Positioned(
              top: 24,
              right: 24,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black45,
                ),
                onPressed: _finishTest,
                icon: const Icon(Icons.stop),
                label: const Text('Terminar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
