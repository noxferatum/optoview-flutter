import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class InstructionOverlay extends StatelessWidget {
  final String title;
  final List<String> instructions;
  final VoidCallback onStart;

  const InstructionOverlay({
    super.key,
    required this.title,
    required this.instructions,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.85),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...instructions.map(
                      (text) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('\u2022  ',
                                style: TextStyle(fontSize: 16)),
                            Expanded(
                              child: Text(text,
                                  style: theme.textTheme.bodyLarge),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: onStart,
                      icon: const Icon(Icons.play_arrow),
                      label: Text(l.instructionsStart),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
