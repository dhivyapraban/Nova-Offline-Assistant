import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Custom animated sine wave visualizer for voice UI background.
///
/// Renders multiple layered sine waves with varying amplitude,
/// frequency, and phase that animate smoothly.
class VoiceWaveAnimation extends StatefulWidget {
  final bool isActive;
  final Color color;
  final int waveCount;
  final double height;

  const VoiceWaveAnimation({
    super.key,
    this.isActive = false,
    required this.color,
    this.waveCount = 4,
    this.height = 200,
  });

  @override
  State<VoiceWaveAnimation> createState() => _VoiceWaveAnimationState();
}

class _VoiceWaveAnimationState extends State<VoiceWaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(VoiceWaveAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(double.infinity, widget.height),
          painter: _WavePainter(
            animation: _controller.value,
            color: widget.color,
            waveCount: widget.waveCount,
            isActive: widget.isActive,
          ),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double animation;
  final Color color;
  final int waveCount;
  final bool isActive;

  _WavePainter({
    required this.animation,
    required this.color,
    required this.waveCount,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;

    for (int i = 0; i < waveCount; i++) {
      final paint = Paint()
        ..color = color.withValues(
          alpha: isActive ? (0.15 - i * 0.03) : (0.05 - i * 0.01),
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = isActive ? 2.0 - i * 0.3 : 1.0
        ..strokeCap = StrokeCap.round;

      final path = Path();
      final frequency = 1.5 + i * 0.5;
      final amplitudeBase = isActive ? (30.0 - i * 5.0) : (8.0 - i * 1.5);
      final phaseOffset = i * 0.8;

      path.moveTo(0, centerY);

      for (double x = 0; x <= size.width; x += 1) {
        final normalizedX = x / size.width;
        // Windowing function to taper edges
        final window =
            math.sin(normalizedX * math.pi);
        final amplitude = amplitudeBase * window;

        final y = centerY +
            amplitude *
                math.sin(
                  (normalizedX * frequency * 2 * math.pi) +
                      (animation * 2 * math.pi) +
                      phaseOffset,
                );
        path.lineTo(x, y);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) =>
      animation != oldDelegate.animation ||
      isActive != oldDelegate.isActive;
}
