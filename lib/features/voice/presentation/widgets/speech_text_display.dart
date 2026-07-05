import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Animated text display for recognized speech.
///
/// Shows text with a typing/fade-in animation effect.
class SpeechTextDisplay extends StatelessWidget {
  final String text;
  final bool isPartial;
  final Color textColor;
  final Color partialColor;

  const SpeechTextDisplay({
    super.key,
    required this.text,
    this.isPartial = false,
    required this.textColor,
    required this.partialColor,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPartial)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.hearing_rounded,
                  size: 14,
                  color: partialColor,
                ),
                const SizedBox(width: 6),
                Text(
                  'Hearing...',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: partialColor,
                        letterSpacing: 1,
                      ),
                ),
              ],
            ).animate().fadeIn(duration: 200.ms),
          if (isPartial) const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isPartial ? partialColor : textColor,
                  fontStyle: isPartial ? FontStyle.italic : FontStyle.normal,
                  height: 1.4,
                ),
          )
              .animate(
                key: ValueKey('$text-$isPartial'),
              )
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.1, end: 0, duration: 300.ms),
        ],
      ),
    )
        .animate(
          key: ValueKey(text.isNotEmpty),
        )
        .fadeIn(duration: 300.ms)
        .scaleXY(begin: 0.95, end: 1.0, duration: 300.ms);
  }
}
