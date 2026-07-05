import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nova_assistant/core/utils/extensions.dart';
import 'music_library_page.dart';

class NowPlayingPage extends ConsumerWidget {
  const NowPlayingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(musicControllerProvider);
    final theme = Theme.of(context);
    final song = state.currentSong;

    return Scaffold(
      appBar: AppBar(title: const Text('Now Playing'), centerTitle: true),
      body: song == null
        ? const Center(child: Text('No song playing'))
        : Padding(padding: const EdgeInsets.all(24),
          child: Column(children: [
            const Spacer(),
            // Album art placeholder
            Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary.withValues(alpha: 0.2),
                    theme.colorScheme.secondary.withValues(alpha: 0.2)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2))),
              child: Icon(Icons.music_note_rounded, size: 80,
                color: theme.colorScheme.primary.withValues(alpha: 0.5)),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

            const Spacer(),

            // Song info
            Text(song.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(song.artist, style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),

            const SizedBox(height: 32),

            // Seek bar
            Column(children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6)),
                child: Slider(
                  value: state.duration.inSeconds > 0
                    ? state.position.inSeconds / state.duration.inSeconds : 0,
                  onChanged: (v) => ref.read(musicControllerProvider.notifier)
                    .seek(Duration(seconds: (v * state.duration.inSeconds).round())),
                ),
              ),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(state.position.formatted, style: theme.textTheme.bodySmall),
                  Text(state.duration.formatted, style: theme.textTheme.bodySmall),
                ])),
            ]),

            const SizedBox(height: 24),

            // Controls
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              IconButton(icon: const Icon(Icons.shuffle_rounded), onPressed: () {}),
              IconButton(icon: const Icon(Icons.skip_previous_rounded), iconSize: 40, onPressed: () {}),
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.primary),
                child: IconButton(
                  icon: Icon(state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: theme.colorScheme.onPrimary), iconSize: 36,
                  onPressed: () => ref.read(musicControllerProvider.notifier).togglePlayPause()),
              ),
              IconButton(icon: const Icon(Icons.skip_next_rounded), iconSize: 40, onPressed: () {}),
              IconButton(icon: const Icon(Icons.repeat_rounded), onPressed: () {}),
            ]),

            const Spacer(),
          ])),
    );
  }
}
