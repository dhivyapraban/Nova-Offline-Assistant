import 'package:flutter/material.dart';

/// Small inline voice visualizer for voice messages
class VoiceVisualizer extends StatelessWidget {
  final bool isActive;

  const VoiceVisualizer({super.key, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 1),
          width: 3,
          height: isActive ? 12.0 + (i % 3) * 6 : 6,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
