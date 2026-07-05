import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/animated_microphone_button.dart';
import '../../presentation/controllers/voice_controller.dart';
import '../../../assistant/presentation/controllers/conversation_controller.dart';

class VoiceAssistantPage extends ConsumerWidget {
  const VoiceAssistantPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceState = ref.watch(voiceControllerProvider);
    final isListening = voiceState.status == VoiceStatus.listening;
    final isContinuous = voiceState.isContinuous;
    final theme = Theme.of(context);

    // Auto-submit recognized text when speech finishes
    ref.listen<VoiceState>(voiceControllerProvider, (previous, next) {
      if (previous?.status == VoiceStatus.listening &&
          next.status == VoiceStatus.idle) {
        final text = next.recognizedText.trim();
        if (text.isNotEmpty) {
          ref.read(conversationControllerProvider.notifier).sendMessage(text);
          if (!isContinuous) {
            context.pushReplacement('/conversation');
          } else {
            // In continuous mode, clear text after a short delay so the visualizer stays clean
            Future.delayed(const Duration(seconds: 2), () {
              if (next.status == VoiceStatus.idle) {
                ref.read(voiceControllerProvider.notifier).clearText();
              }
            });
          }
        }
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(children: [
          // ── Top bar ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(children: [
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  // Stop continuous mode when leaving
                  if (isContinuous) {
                    ref.read(voiceControllerProvider.notifier).stopListening();
                  }
                  context.pop();
                },
              ),
              const Spacer(),
              Text(
                voiceState.statusText,
                style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.keyboard_rounded),
                onPressed: () => context.pushReplacement('/conversation'),
              ),
            ]),
          ),

          // ── Center — mic button with wave animation ───────────────
          Expanded(
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Pulsing glow ring when listening
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  width: isListening ? 160 : 120,
                  height: isListening ? 160 : 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isListening
                        ? theme.colorScheme.primary.withValues(alpha: 0.15)
                        : Colors.transparent,
                    boxShadow: isListening
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 40,
                              spreadRadius: 10,
                            )
                          ]
                        : [],
                  ),
                  child: Center(
                    child: AnimatedMicrophoneButton(
                      isListening: isListening,
                      size: 96,
                      onPressed: () => ref
                              .read(voiceControllerProvider.notifier)
                              .toggleListening(),
                    ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                  ),
                ),

                const SizedBox(height: 32),

                // Wave bars indicator
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isListening
                      ? Row(
                          key: const ValueKey('waves'),
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                              7,
                              (i) => Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 2),
                                    width: 4,
                                    height: 10.0 + (i % 4) * 10,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  )
                                      .animate(onPlay: (c) => c.repeat(reverse: true))
                                      .scaleY(
                                        begin: 0.3,
                                        end: 1.0,
                                        duration: Duration(
                                            milliseconds: 300 + i * 80),
                                        curve: Curves.easeInOut,
                                      )),
                        )
                      : const SizedBox(key: ValueKey('empty'), height: 40),
                ),
              ]),
            ),
          ),

          // ── Recognized text display ───────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            child: Column(children: [
              if (voiceState.displayText.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    voiceState.displayText,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
              const SizedBox(height: 12),
              Text(
                'Tap the mic to speak',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                textAlign: TextAlign.center,
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
