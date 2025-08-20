// lib/screens/dynamic_periphery_test.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/test_config.dart';
import '../widgets/center_fixation.dart';
import '../widgets/peripheral_stimulus.dart';

class DynamicPeripheryTest extends StatefulWidget {
  final TestConfig config;

  const DynamicPeripheryTest({super.key, required this.config});

  @override
  State<DynamicPeripheryTest> createState() => _DynamicPeripheryTestState();
}

class _DynamicPeripheryTestState extends State<DynamicPeripheryTest>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  Timer? _stimulusTimer;   // alterna mostrar/ocultar estímulo
  Timer? _endTimer;        // fin de prueba
  Timer? _countdownTimer;  // actualiza cuenta atrás

  bool _showStimulus = false;
  late int _remaining; // segundos restantes

  // Movimiento:
  AnimationController? _moveCtrl;
  double _currentTop = 0;
  double _currentLeft = 0;

  // Símbolo elegido para la aparición actual:
  String? _currentText;  // letras/números
  Forma? _currentForma;  // formas

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
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _pauseTimers();
    } else if (state == AppLifecycleState.resumed) {
      _resumeTimers();
    }
  }

  // Mapeo de velocidades (nuevo más lento en general):
  // rápida = 1200ms (equivale a "lenta" antigua)
  // media  = 1800ms
  // lenta  = 2500ms
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
    // Countdown global
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _remaining = max(0, _remaining - 1);
      });
    });

    // Fin de prueba
    _endTimer = Timer(Duration(seconds: _remaining), _finishTest);

    // Aparición rítmica del estímulo
    final onMs = _velocidadMs(widget.config.velocidad);  // visible
    final offMs = _velocidadMs(widget.config.velocidad); // oculto
    final period = onMs + offMs;

    _stimulusTimer = Timer.periodic(Duration(milliseconds: period), (t) async {
      if (!mounted) return;

      // Elegir lado según config
      final Lado side = switch (widget.config.lado) {
        Lado.izquierda => Lado.izquierda,
        Lado.derecha => Lado.derecha,
        Lado.arriba => Lado.arriba,
        Lado.abajo => Lado.abajo,
        Lado.ambos => Lado.values[_rand.nextInt(4)], // cualquiera de los 4 (sin 'ambos')
      };

      // Elegir símbolo UNA sola vez por aparición
      _chooseSymbolOnceForThisAppearance();

      if (widget.config.movimiento == Movimiento.fijo) {
        await _showFixed(onMs, side);
      } else {
        // Movimiento según el lado: vertical para izq/der, horizontal para arriba/abajo
        if (side == Lado.izquierda || side == Lado.derecha) {
          await _runVerticalMovement(onMs, side);
        } else {
          await _runHorizontalMovement(onMs, side);
        }
      }
      // offMs queda como tiempo "apagado"
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
            widget.config.forma ?? Forma.values[_rand.nextInt(Forma.values.length)];
        break;
    }
  }

  Future<void> _showFixed(int onMs, Lado side) async {
    final sz = MediaQuery.of(context).size;
    // ESCALA NUEVA: 100% nuevo = 50% antiguo -> /200
    final sizePx = sz.shortestSide * (widget.config.tamanoPorc / 200);
    const margin = 32.0;

    // Posición según lado
    switch (side) {
      case Lado.izquierda:
        _currentLeft = margin;
        _currentTop = (sz.height / 2) - (sizePx / 2);
        break;
      case Lado.derecha:
        _currentLeft = sz.width - sizePx - margin;
        _currentTop = (sz.height / 2) - (sizePx / 2);
        break;
      case Lado.arriba:
        _currentTop = margin;
        _currentLeft = (sz.width / 2) - (sizePx / 2);
        break;
      case Lado.abajo:
        _currentTop = sz.height - sizePx - margin;
        _currentLeft = (sz.width / 2) - (sizePx / 2);
        break;
      case Lado.ambos:
        break;
    }

    setState(() => _showStimulus = true);
    await Future.delayed(Duration(milliseconds: onMs));
    if (!mounted) return;
    setState(() => _showStimulus = false);
  }

  Future<void> _runVerticalMovement(int onMs, Lado side) async {
    final sz = MediaQuery.of(context).size;
    // ESCALA NUEVA: 100% nuevo = 50% antiguo -> /200
    final sizePx = sz.shortestSide * (widget.config.tamanoPorc / 200);
    const margin = 32.0;

    // left fijo según lado; top animado
    _currentLeft = side == Lado.izquierda
        ? margin
        : sz.width - sizePx - margin;

    final topStart = margin;
    final topEnd = max(margin, sz.height - sizePx - margin);
    final upToDown = _rand.nextBool();

    _disposeMoveCtrl();
    _moveCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: onMs),
    );

    final curved = CurvedAnimation(parent: _moveCtrl!, curve: Curves.linear);
    final tween = Tween<double>(
      begin: upToDown ? topStart : topEnd,
      end: upToDown ? topEnd : topStart,
    );
    final Animation<double> anim = tween.animate(curved);

    _currentTop = tween.begin!;
    anim.addListener(() {
      if (!mounted) return;
      setState(() => _currentTop = anim.value);
    });

    setState(() => _showStimulus = true);

    try {
      await _moveCtrl!.forward().orCancel;
    } catch (_) {}

    if (!mounted) return;
    setState(() => _showStimulus = false);
  }

  Future<void> _runHorizontalMovement(int onMs, Lado side) async {
    final sz = MediaQuery.of(context).size;
    // ESCALA NUEVA: 100% nuevo = 50% antiguo -> /200
    final sizePx = sz.shortestSide * (widget.config.tamanoPorc / 200);
    const margin = 32.0;

    // top fijo según lado; left animado
    _currentTop = side == Lado.arriba
        ? margin
        : sz.height - sizePx - margin;

    final leftStart = margin;
    final leftEnd = max(margin, sz.width - sizePx - margin);
    final leftToRight = _rand.nextBool();

    _disposeMoveCtrl();
    _moveCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: onMs),
    );

    final curved = CurvedAnimation(parent: _moveCtrl!, curve: Curves.linear);
    final tween = Tween<double>(
      begin: leftToRight ? leftStart : leftEnd,
      end: leftToRight ? leftEnd : leftStart,
    );
    final Animation<double> anim = tween.animate(curved);

    _currentLeft = tween.begin!;
    anim.addListener(() {
      if (!mounted) return;
      setState(() => _currentLeft = anim.value);
    });

    setState(() => _showStimulus = true);

    try {
      await _moveCtrl!.forward().orCancel;
    } catch (_) {}

    if (!mounted) return;
    setState(() => _showStimulus = false);
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
    _stimulusTimer = null;
    _endTimer = null;
    _countdownTimer = null;
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
    // Tamaño también se usa para centrar en algunos cálculos internos.
    final sizePx =
        MediaQuery.of(context).size.shortestSide * (widget.config.tamanoPorc / 200);

    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.black),
          const CenterFixation(),
          if (_showStimulus)
            PeripheralStimulus(
              categoria: widget.config.categoria,
              forma: _currentForma,
              text: _currentText,
              size: sizePx,
              top: _currentTop,
              left: _currentLeft,
              onTap: () {},
            ),

          // HUD
          Positioned(
            top: 24,
            left: 24,
            child: _HudBadge(text: 'Tiempo: $_remaining s'),
          ),
          Positioned(
            top: 24,
            right: 24,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white.withOpacity(0.12),
              ),
              onPressed: _finishTest,
              icon: const Icon(Icons.stop),
              label: const Text('Terminar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _HudBadge extends StatelessWidget {
  final String text;
  const _HudBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}
