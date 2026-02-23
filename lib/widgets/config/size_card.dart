import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../l10n/app_localizations.dart';

/// Card con slider para configurar el tamaño del estímulo.
///
/// Si [isRandom] y [onRandomChanged] se proporcionan, muestra un SwitchListTile
/// para activar la variación aleatoria del tamaño.
class SizeCard extends StatelessWidget {
  final double value;
  final bool isRandom;
  final ValueChanged<double> onChanged;
  final ValueChanged<bool>? onRandomChanged;

  const SizeCard({
    super.key,
    required this.value,
    this.isRandom = false,
    required this.onChanged,
    this.onRandomChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.sizeTitle,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            Slider(
              value: value,
              min: AppConstants.minSizePercent,
              max: AppConstants.maxSizePercent,
              divisions: 30,
              label: '${value.toStringAsFixed(0)}%',
              onChanged: isRandom ? null : onChanged,
            ),
            if (onRandomChanged != null)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: isRandom,
                onChanged: onRandomChanged,
                title: Text(l.sizeRandomToggle),
                subtitle: Text(l.sizeRandomSubtitle),
              ),
          ],
        ),
      ),
    );
  }
}
