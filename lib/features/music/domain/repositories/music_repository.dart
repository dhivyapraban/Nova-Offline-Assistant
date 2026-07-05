import '../entities/song.dart';
import '../entities/playlist.dart';

/// Abstract contract for music data operations.
abstract class MusicRepository {
  Future<List<Song>> scanMusic();
  Future<List<Song>> getAllSongs();
  Future<List<Song>> searchSongs(String query);
  Future<List<Playlist>> getPlaylists();
  Future<Playlist> createPlaylist(String name);
  Future<void> addToPlaylist(String playlistId, String songId);
  Future<void> removeFromPlaylist(String playlistId, String songId);
  Future<void> deletePlaylist(String playlistId);
}
