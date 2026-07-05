import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

final musicControllerProvider = StateNotifierProvider<MusicController, MusicState>((ref) {
  return MusicController();
});

class MusicState {
  final List<SongInfo> songs;
  final SongInfo? currentSong;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool isLoading;

  const MusicState({this.songs = const [], this.currentSong, this.isPlaying = false,
    this.position = Duration.zero, this.duration = Duration.zero, this.isLoading = false});

  MusicState copyWith({List<SongInfo>? songs, SongInfo? currentSong, bool? isPlaying,
    Duration? position, Duration? duration, bool? isLoading}) {
    return MusicState(songs: songs ?? this.songs, currentSong: currentSong ?? this.currentSong,
      isPlaying: isPlaying ?? this.isPlaying, position: position ?? this.position,
      duration: duration ?? this.duration, isLoading: isLoading ?? this.isLoading);
  }
}

class SongInfo {
  final String path;
  final String title;
  final String artist;
  final Duration duration;
  SongInfo({required this.path, required this.title, this.artist = 'Unknown Artist', this.duration = Duration.zero});
}

class MusicController extends StateNotifier<MusicState> {
  final AudioPlayer _player = AudioPlayer();
  MusicController() : super(const MusicState()) {
    _player.positionStream.listen((pos) { if (mounted) state = state.copyWith(position: pos); });
    _player.durationStream.listen((dur) { if (mounted && dur != null) state = state.copyWith(duration: dur); });
    _player.playerStateStream.listen((ps) {
      if (mounted) state = state.copyWith(isPlaying: ps.playing);
    });
  }

  Future<void> playSong(SongInfo song) async {
    try {
      state = state.copyWith(currentSong: song, isLoading: true);
      await _player.setFilePath(song.path);
      await _player.play();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) { await _player.pause(); }
    else { await _player.play(); }
  }

  Future<void> seek(Duration position) => _player.seek(position);
  Future<void> stop() async { await _player.stop(); state = state.copyWith(currentSong: null, isPlaying: false); }
  void setSongs(List<SongInfo> songs) => state = state.copyWith(songs: songs);

  @override
  void dispose() { _player.dispose(); super.dispose(); }
}

class MusicLibraryPage extends ConsumerWidget {
  const MusicLibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicState = ref.watch(musicControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Music'),
        actions: [
          IconButton(icon: const Icon(Icons.folder_open_rounded), tooltip: 'Scan for music',
            onPressed: () {
              // Placeholder - would scan device for audio files
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Music scanning requires storage permission. Grant it in Settings.')));
            }),
        ]),
      body: Column(children: [
        // Search
        Padding(padding: const EdgeInsets.all(16), child: TextField(
          decoration: InputDecoration(hintText: 'Search songs...', prefixIcon: const Icon(Icons.search_rounded),
            filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
        )),

        Expanded(
          child: musicState.songs.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.music_note_rounded, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text('No songs found', style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                const SizedBox(height: 8),
                Text('Tap the folder icon to scan for music', style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3))),
              ]))
            : ListView.builder(
                itemCount: musicState.songs.length,
                itemBuilder: (context, i) {
                  final song = musicState.songs[i];
                  final isCurrent = musicState.currentSong?.path == song.path;
                  return ListTile(
                    leading: Container(width: 48, height: 48,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
                        gradient: isCurrent ? LinearGradient(colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.3),
                          theme.colorScheme.secondary.withValues(alpha: 0.3)]) : null,
                        color: isCurrent ? null : theme.colorScheme.surfaceContainerHighest),
                      child: Icon(Icons.music_note_rounded, color: isCurrent ? theme.colorScheme.primary : null)),
                    title: Text(song.title, style: TextStyle(
                      color: isCurrent ? theme.colorScheme.primary : null, fontWeight: isCurrent ? FontWeight.bold : null)),
                    subtitle: Text(song.artist),
                    onTap: () => ref.read(musicControllerProvider.notifier).playSong(song),
                  ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: i * 30));
                }),
        ),

        // Mini player
        if (musicState.currentSong != null)
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              border: Border(top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)))),
            child: ListTile(
              leading: Container(width: 40, height: 40,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), gradient: LinearGradient(
                  colors: [theme.colorScheme.primary.withValues(alpha: 0.3), theme.colorScheme.secondary.withValues(alpha: 0.3)])),
                child: const Icon(Icons.music_note_rounded)),
              title: Text(musicState.currentSong!.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(musicState.currentSong!.artist, maxLines: 1),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: Icon(musicState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                  onPressed: () => ref.read(musicControllerProvider.notifier).togglePlayPause()),
                IconButton(icon: const Icon(Icons.fullscreen_rounded),
                  onPressed: () => context.push('/music/now-playing')),
              ]),
            ),
          ).animate().slideY(begin: 1, duration: 300.ms),
      ]),
    );
  }
}
