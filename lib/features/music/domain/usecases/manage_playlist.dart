import '../entities/playlist.dart';
import '../repositories/music_repository.dart';

/// Manages playlist CRUD operations.
class ManagePlaylist {
  final MusicRepository _repository;

  ManagePlaylist(this._repository);

  Future<List<Playlist>> getPlaylists() async {
    return await _repository.getPlaylists();
  }

  Future<Playlist> createPlaylist(String name) async {
    return await _repository.createPlaylist(name);
  }

  Future<void> addSong(String playlistId, String songId) async {
    return await _repository.addToPlaylist(playlistId, songId);
  }

  Future<void> removeSong(String playlistId, String songId) async {
    return await _repository.removeFromPlaylist(playlistId, songId);
  }

  Future<void> deletePlaylist(String playlistId) async {
    return await _repository.deletePlaylist(playlistId);
  }
}
