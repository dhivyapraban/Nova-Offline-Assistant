import '../../domain/entities/song.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/repositories/music_repository.dart';
import '../datasources/music_local_datasource.dart';

/// Concrete implementation of [MusicRepository] using local datasource.
class MusicRepositoryImpl implements MusicRepository {
  final MusicLocalDatasource _datasource;

  MusicRepositoryImpl(this._datasource);

  @override
  Future<List<Song>> scanMusic() async {
    return await _datasource.scanMusic();
  }

  @override
  Future<List<Song>> getAllSongs() async {
    return await _datasource.getAllSongs();
  }

  @override
  Future<List<Song>> searchSongs(String query) async {
    return await _datasource.searchSongs(query);
  }

  @override
  Future<List<Playlist>> getPlaylists() async {
    return await _datasource.getPlaylists();
  }

  @override
  Future<Playlist> createPlaylist(String name) async {
    return await _datasource.createPlaylist(name);
  }

  @override
  Future<void> addToPlaylist(String playlistId, String songId) async {
    return await _datasource.addToPlaylist(playlistId, songId);
  }

  @override
  Future<void> removeFromPlaylist(String playlistId, String songId) async {
    return await _datasource.removeFromPlaylist(playlistId, songId);
  }

  @override
  Future<void> deletePlaylist(String playlistId) async {
    return await _datasource.deletePlaylist(playlistId);
  }
}
