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
  Timer? _countdownTimer;  // cuenta atrás

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

  // Velocidades nuevas (más lentas en general):
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
    // Cuenta atrás global
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _remaining = max(0, _remaining - 1));
    });

    // Fin de prueba
    _endTimer = Timer(Duration(seconds: _remaining), _finishTest);

    // Aparición rítmica
    final onMs = _velocidadMs(widget.config.velocidad);
    final offMs = _velocidadMs(widget.config.velocidad);
    final period = onMs + offMs;

    _stimulusTimer = Timer.periodic(Duration(milliseconds: period), (t) async {
      if (!mounted) return;

      // Elegir lado para esta aparición
      final Lado side = switch (widget.config.lado) {
        Lado.izquierda => Lado.izquierda,
        Lado.derecha => Lado.derecha,
        Lado.arriba => Lado.arriba,
        Lado.abajo => Lado.abajo,
        Lado.ambos => Lado.values[_rand.nextInt(4)], // 0..3 (sin 'ambos')
      };

      // Elegir distancia (0–100%)
      final double distPct = widget.config.distanciaModo == DistanciaModo.aleatoria
          ? _rand.nextDouble() * 100
          : widget.config.distanciaPct;

      // Elegir símbolo UNA vez para esta aparición
      _chooseSymbolOnceForThisAppearance();

      if (widget.config.movimiento == Movimiento.fijo) {
        await _showFixed(onMs, side, distPct);
      } else {
        if (side == Lado.izquierda || side == Lado.derecha) {
          await _runVerticalMovement(onMs, side, distPct);
        } else {
          await _runHorizontalMovement(onMs, side, distPct);
        }
      }
      // offMs queda como tiempo apagado
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

  // ======== Posicionamiento respecto al centro ========

  /// Tamaño del estímulo (escala nueva: 100% nuevo = 50% antiguo -> /200)
  double _sizePx(Size sz) =>
      sz.shortestSide * (widget.config.tamanoPorc / 200);

  /// Márgenes para no tocar los bordes
  static const double _margin = 32.0;

  /// Calcula la posición fija (left/top) a una distancia porcentual del centro
  /// hacia el lado indicado.
  (double left, double top) _fixedPositionForSide(
      Size sz, double sizePx, Lado side, double distPct) {
    final centerX = sz.width / 2;
    final centerY = sz.height / 2;

    // Distancias máximas permitidas desde el centro hasta cada borde (dejando margen y radio del símbolo)
    final maxLeft = (centerX - _margin) - (sizePx / 2);
    final maxRight = (sz.width - _margin - (sizePx / 2)) - centerX;
    final maxUp = (centerY - _margin) - (sizePx / 2);
    final maxDown = (sz.height - _margin - (sizePx / 2)) - centerY;

    // Convertimos porcentaje a píxeles en cada eje
    final dxLeft = maxLeft * (distPct / 100);
    final dxRight = maxRight * (distPct / 100);
    final dyUp = maxUp * (distPct / 100);
    final dyDown = maxDown * (distPct / 100);

    switch (side) {
      case Lado.izquierda:
        return (centerX - (sizePx / 2) - dxLeft, centerY - (sizePx / 2));
      case Lado.derecha:
        return (centerX - (sizePx / 2) + dxRight, centerY - (sizePx / 2));
      case Lado.arriba:
        return (centerX - (sizePx / 2), centerY - (sizePx / 2) - dyUp);
      case Lado.abajo:
        return (centerX - (sizePx / 2), centerY - (sizePx / 2) + dyDown);
      case Lado.ambos:
        return (centerX - (sizePx / 2), centerY - (sizePx / 2));
    }
  }

  Future<void> _showFixed(int onMs, Lado side, double distPct) async {
    final sz = MediaQuery.of(context).size;
    final sizePx = _sizePx(sz);

    final (left, top) = _fixedPositionForSide(sz, sizePx, side, distPct);
    _currentLeft = left;
    _currentTop = top;

    setState(() => _showStimulus = true);
    await Future.delayed(Duration(milliseconds: onMs));
    if (!mounted) return;
    setState(() => _showStimulus = false);
  }

  Future<void> _runVerticalMovement(int onMs, Lado side, double distPct) async {
    final sz = MediaQuery.of(context).size;
    final sizePx = _sizePx(sz);

    // left fijo según distancia al centro; top animado
    final (left, _) = _fixedPositionForSide(sz, sizePx, side, distPct);
    _currentLeft = left;

    final topStart = _margin;
    final topEnd = max(_margin, sz.height - sizePx - _margin);
    final upToDown = _rand.nextBool();

    _disposeMoveCtrl();
    _moveCtrl = AnimationController(vsync: this, duration: Duration(milliseconds: onMs));
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

  Future<void> _runHorizontalMovement(int onMs, Lado side, double distPct) async {
    final sz = MediaQuery.of(context).size;
    final sizePx = _sizePx(sz);

    // top fijo según distancia al centro; left animado
    final (_, top) = _fixedPositionForSide(sz, sizePx, side, distPct);
    _currentTop = top;

    final leftStart = _margin;
    final leftEnd = max(_margin, sz.width - sizePx - _margin);
    final leftToRight = _rand.nextBool();

    _disposeMoveCtrl();
    _moveCtrl = AnimationController(vsync: this, duration: Duration(milliseconds: onMs));
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
    final sizePx = _sizePx(MediaQuery.of(context).size);

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
