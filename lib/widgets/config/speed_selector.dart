import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/test_config.dart';
import 'section_card.dart';

class SpeedSelector extends StatelessWidget {
  final Velocidad value;
  final ValueChanged<Velocidad> onChanged;

  const SpeedSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SectionCard(
      title: l.speedTitle,
      child: SegmentedButton<Velocidad>(
        segments: [
          ButtonSegment(value: Velocidad.lenta, label: Text(l.speedSlow)),
          ButtonSegment(value: Velocidad.media, label: Text(l.speedMedium)),
          ButtonSegment(value: Velocidad.rapida, label: Text(l.speedFast)),
        ],
        selected: {value},
        onSelectionChanged: (s) => onChanged(s.first),
      ),
    );
  }
}
