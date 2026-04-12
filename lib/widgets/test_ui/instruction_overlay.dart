import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/opto_colors.dart';

/// Overlay de instrucciones con cuenta regresiva integrada.
///
/// Muestra el título del test, pasos numerados y un anillo de cuenta
/// regresiva de 3 segundos. Al terminar la cuenta, dispara
/// [onCountdownComplete] para iniciar el test directamente.
class InstructionOverlay extends StatefulWidget {
  const InstructionOverlay({
    super.key,
    required this.testTitle,
    required this.instructions,
    required this.onCountdownComplete,
  });

  final String testTitle;
  final List<String> instructions;
  final VoidCallback onCountdownComplete;

  @override
  State<InstructionOverlay> createState() => _InstructionOverlayState();
}

class _InstructionOverlayState extends State<InstructionOverlay>
    with SingleTickerProviderStateMixin {
  int _countdown = 3;
  late final AnimationController _ringController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..forward();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          t.cancel();
          widget.onCountdownComplete();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Positioned.fill(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            color: const Color(0xFF0F1216).withAlpha(230),
            alignment: Alignment.center,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: OptoColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: OptoColors.surfaceVariantDark),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: OptoColors.primary.withAlpha(31),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.info_outline, size: 18, color: OptoColors.peripheral),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.testTitle,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: OptoColors.onSurfaceDark),
                            ),
                            Text(
                              l.instructionsTitle,
                              style: const TextStyle(fontSize: 12, color: OptoColors.onSurfaceVariantDark),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Steps
                  ...widget.instructions.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: OptoColors.primary.withAlpha(38),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${e.key + 1}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: OptoColors.peripheral),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  e.value,
                                  style: const TextStyle(fontSize: 13, height: 1.5, color: OptoColors.onSurfaceDark),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 12),
                  // Countdown ring
                  AnimatedBuilder(
                    animation: _ringController,
                    builder: (context, _) {
                      return Column(
                        children: [
                          SizedBox(
                            width: 72,
                            height: 72,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: _ringController.value,
                                  strokeWidth: 3,
                                  backgroundColor: OptoColors.surfaceVariantDark,
                                  valueColor: const AlwaysStoppedAnimation(OptoColors.primary),
                                ),
                                Text(
                                  '$_countdown',
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w300,
                                    color: OptoColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l.instructionsStart,
                            style: const TextStyle(fontSize: 11, color: OptoColors.onSurfaceVariantDark),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
