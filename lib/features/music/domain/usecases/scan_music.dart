import '../entities/song.dart';
import '../repositories/music_repository.dart';

/// Scans the device storage for audio files and returns them.
class ScanMusic {
  final MusicRepository _repository;

  ScanMusic(this._repository);

  Future<List<Song>> call() async {
    return await _repository.scanMusic();
  }
}
