import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated microphone button with pulsing glow effect
class AnimatedMicrophoneButton extends StatefulWidget {
  final bool isListening;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final double size;

  const AnimatedMicrophoneButton({
    super.key,
    this.isListening = false,
    required this.onPressed,
    this.onLongPress,
    this.size = 72,
  });

  @override
  State<AnimatedMicrophoneButton> createState() => _AnimatedMicrophoneButtonState();
}

class _AnimatedMicrophoneButtonState extends State<AnimatedMicrophoneButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeOut),
    );

    if (widget.isListening) {
      _startAnimations();
    }
  }

  @override
  void didUpdateWidget(AnimatedMicrophoneButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening != oldWidget.isListening) {
      if (widget.isListening) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  void _startAnimations() {
    _pulseController.repeat(reverse: true);
    _waveController.repeat();
  }

  void _stopAnimations() {
    _pulseController.stop();
    _pulseController.reset();
    _waveController.stop();
    _waveController.reset();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return SizedBox(
      width: widget.size * 1.8,
      height: widget.size * 1.8,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Wave rings (visible when listening)
          if (widget.isListening) ...[
            AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(widget.size * 1.8, widget.size * 1.8),
                  painter: _WaveRingPainter(
                    progress: _waveAnimation.value,
                    color: primaryColor,
                  ),
                );
              },
            ),
          ],

          // Pulse effect
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = widget.isListening ? _pulseAnimation.value : 1.0;
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: widget.isListening
                    ? LinearGradient(
                        colors: [
                          primaryColor,
                          primaryColor.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: widget.isListening ? null : primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: widget.isListening ? 0.5 : 0.3),
                    blurRadius: widget.isListening ? 24 : 12,
                    spreadRadius: widget.isListening ? 4 : 0,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  onLongPress: widget.onLongPress,
                  customBorder: const CircleBorder(),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        widget.isListening ? Icons.stop_rounded : Icons.mic_rounded,
                        key: ValueKey(widget.isListening),
                        color: theme.colorScheme.onPrimary,
                        size: widget.size * 0.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _WaveRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < 3; i++) {
      final ringProgress = (progress + i * 0.33) % 1.0;
      final radius = maxRadius * 0.4 + (maxRadius * 0.6 * ringProgress);
      final opacity = (1.0 - ringProgress) * 0.4;

      final paint = Paint()
        ..color = color.withValues(alpha: math.max(0, opacity))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_WaveRingPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
