import '../entities/song.dart';
import '../repositories/music_repository.dart';

/// Retrieves song information before playback.
/// Actual audio playback is handled by the controller layer using just_audio.
class PlaySong {
  final MusicRepository _repository;

  PlaySong(this._repository);

  Future<List<Song>> getAllSongs() async {
    return await _repository.getAllSongs();
  }

  Future<List<Song>> searchSongs(String query) async {
    return await _repository.searchSongs(query);
  }
}
