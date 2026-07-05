import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/voice_controller.dart';
import '../../../assistant/presentation/controllers/conversation_controller.dart';
import '../../../../core/services/platform_channel_service.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';

class GoogleAssistantOverlay extends ConsumerStatefulWidget {
  const GoogleAssistantOverlay({super.key});

  @override
  ConsumerState<GoogleAssistantOverlay> createState() => _GoogleAssistantOverlayState();
}

class _GoogleAssistantOverlayState extends ConsumerState<GoogleAssistantOverlay> {
  bool _hasExecuted = false;
  Timer? _silenceTimer;

  @override
  void initState() {
    super.initState();
    // Start listening automatically as soon as the overlay opens
    Future.microtask(() async {
      // Terminate background service to release mic lock
      try {
        await PlatformChannelService.instance.stopWakeWordService();
      } catch (_) {}
      
      ref.read(voiceControllerProvider.notifier).startListening();
      _startSilenceTimer();
    });
  }

  void _startSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        final voiceState = ref.read(voiceControllerProvider);
        // Only close if they haven't said anything yet and are not actively speaking
        if (voiceState.recognizedText.trim().isEmpty && voiceState.displayText.trim().isEmpty) {
          Navigator.pop(context);
        }
      }
    });
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    ref.read(voiceControllerProvider.notifier).stopListening();
    
    // Automatically restart background service if toggle is enabled
    final settings = ref.read(settingsControllerProvider).valueOrNull;
    if (settings?.wakeWordEnabled == true) {
      PlatformChannelService.instance.startWakeWordService().catchError((_) {});
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceControllerProvider);
    final isListening = voiceState.status == VoiceStatus.listening;
    final theme = Theme.of(context);

    // Auto-close overlay when speech finishes and is processed
    ref.listen(voiceControllerProvider, (prev, next) {
      // Reset the silence timer if speech output text changes
      if (next.displayText != prev?.displayText) {
        _startSilenceTimer();
      }

      if (prev?.status == VoiceStatus.listening && next.status == VoiceStatus.idle) {
        final text = next.recognizedText.trim();
        if (text.isNotEmpty && !_hasExecuted) {
          _hasExecuted = true;
          _silenceTimer?.cancel();
          
          // Dispatch intent
          ref.read(conversationControllerProvider.notifier).sendMessage(text);
          
          // Show execution feedback, then dismiss overlay panel
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              Navigator.pop(context);
              ref.read(voiceControllerProvider.notifier).clearText();
            }
          });
        }
      }
    });

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? const Color(0xE0121212)
                : const Color(0xE0FFFFFF),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top drag indicator line
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              const SizedBox(height: 24),

              // Assistant status / Speech result text
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: Text(
                  voiceState.displayText.isEmpty
                      ? (isListening ? "Listening..." : "How can I help?")
                      : voiceState.displayText,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 36),

              // Google Assistant style glowing colored dots
              if (isListening)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _pulseDot(const Color(0xFF4285F4), 0),
                    _pulseDot(const Color(0xFFEA4335), 1),
                    _pulseDot(const Color(0xFFFBBC05), 2),
                    _pulseDot(const Color(0xFF34A853), 3),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    Icons.mic_rounded,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pulseDot(Color color, int delayIndex) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 1,
          )
        ]
      ),
    )
    .animate(onPlay: (controller) => controller.repeat(reverse: true))
    .scale(
      begin: const Offset(0.7, 0.7),
      end: const Offset(1.3, 1.3),
      duration: 350.ms,
      delay: (delayIndex * 120).ms,
      curve: Curves.easeInOut,
    );
  }
}
