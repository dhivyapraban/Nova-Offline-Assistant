import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Animated dots or pulse indicator showing active listening state.
class ListeningIndicator extends StatelessWidget {
  final bool isListening;
  final Color color;

  const ListeningIndicator({
    super.key,
    required this.isListening,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (!isListening) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          )
              .animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              )
              .scaleXY(
                begin: 0.5,
                end: 1.2,
                duration: 600.ms,
                delay: Duration(milliseconds: index * 200),
                curve: Curves.easeInOut,
              )
              .fadeIn(
                duration: 300.ms,
                delay: Duration(milliseconds: index * 100),
              ),
        );
      }),
    );
  }
}
