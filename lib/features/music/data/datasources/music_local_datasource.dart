import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import 'package:nova_assistant/core/services/database_service.dart';
import '../models/song_model.dart';
import '../models/playlist_model.dart';

/// Local datasource for music feature using device storage and SQLite.
class MusicLocalDatasource {
  static const _songsTable = 'songs';
  static const _playlistsTable = 'playlists';

  static const _audioExtensions = [
    '.mp3', '.m4a', '.aac', '.wav', '.flac', '.ogg', '.wma', '.opus',
  ];

  /// Ensures the required database tables exist.
  Future<void> ensureTables() async {
    final db = await DatabaseService.instance.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_songsTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        artist TEXT NOT NULL DEFAULT 'Unknown',
        album TEXT,
        file_path TEXT NOT NULL UNIQUE,
        duration_ms INTEGER NOT NULL DEFAULT 0,
        added_at TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_playlistsTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        song_ids TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL
      )
    ''');
  }

  /// Scans common music directories for audio files and persists them.
  Future<List<SongModel>> scanMusic() async {
    await ensureTables();
    final db = await DatabaseService.instance.database;
    const uuid = Uuid();

    final directories = <Directory>[];

    // Add common music directories
    try {
      final extDir = await getExternalStorageDirectory();
      if (extDir != null) {
        // Navigate up to the root external storage
        final rootPath = extDir.path.split('Android').first;
        final musicDir = Directory('${rootPath}Music');
        final downloadDir = Directory('${rootPath}Download');
        if (await musicDir.exists()) directories.add(musicDir);
        if (await downloadDir.exists()) directories.add(downloadDir);
      }
    } catch (_) {}

    // Also try app documents directory
    try {
      final appDir = await getApplicationDocumentsDirectory();
      directories.add(appDir);
    } catch (_) {}

    final songs = <SongModel>[];

    for (final dir in directories) {
      try {
        await for (final entity in dir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            final ext = entity.path.split('.').last.toLowerCase();
            if (_audioExtensions.contains('.$ext')) {
              final fileName = entity.path.split(Platform.pathSeparator).last;
              final titleWithoutExt = fileName.contains('.')
                  ? fileName.substring(0, fileName.lastIndexOf('.'))
                  : fileName;

              // Parse artist from filename pattern "Artist - Title"
              String title = titleWithoutExt;
              String artist = 'Unknown';
              if (titleWithoutExt.contains(' - ')) {
                final parts = titleWithoutExt.split(' - ');
                artist = parts.first.trim();
                title = parts.sublist(1).join(' - ').trim();
              }

              final song = SongModel(
                id: uuid.v4(),
                title: title,
                artist: artist,
                filePath: entity.path,
                durationMs: 0,
                addedAt: DateTime.now(),
              );

              // Insert or ignore if already exists
              await db.insert(
                _songsTable,
                song.toMap(),
                conflictAlgorithm: ConflictAlgorithm.ignore,
              );
              songs.add(song);
            }
          }
        }
      } catch (_) {
        // Skip inaccessible directories
      }
    }

    return songs;
  }

  Future<List<SongModel>> getAllSongs() async {
    await ensureTables();
    final db = await DatabaseService.instance.database;
    final maps = await db.query(_songsTable, orderBy: 'title ASC');
    return maps.map((m) => SongModel.fromMap(m)).toList();
  }

  Future<List<SongModel>> searchSongs(String query) async {
    await ensureTables();
    final db = await DatabaseService.instance.database;
    final maps = await db.query(
      _songsTable,
      where: 'title LIKE ? OR artist LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'title ASC',
    );
    return maps.map((m) => SongModel.fromMap(m)).toList();
  }

  Future<List<PlaylistModel>> getPlaylists() async {
    await ensureTables();
    final db = await DatabaseService.instance.database;
    final maps = await db.query(_playlistsTable, orderBy: 'created_at DESC');
    return maps.map((m) => PlaylistModel.fromMap(m)).toList();
  }

  Future<PlaylistModel> createPlaylist(String name) async {
    await ensureTables();
    final db = await DatabaseService.instance.database;
    final playlist = PlaylistModel(
      id: const Uuid().v4(),
      name: name,
      songIds: [],
      createdAt: DateTime.now(),
    );
    await db.insert(_playlistsTable, playlist.toMap());
    return playlist;
  }

  Future<void> addToPlaylist(String playlistId, String songId) async {
    await ensureTables();
    final db = await DatabaseService.instance.database;
    final maps = await db.query(
      _playlistsTable,
      where: 'id = ?',
      whereArgs: [playlistId],
    );
    if (maps.isEmpty) return;
    final playlist = PlaylistModel.fromMap(maps.first);
    if (playlist.songIds.contains(songId)) return;
    final updatedIds = [...playlist.songIds, songId];
    await db.update(
      _playlistsTable,
      {'song_ids': updatedIds.join(',')},
      where: 'id = ?',
      whereArgs: [playlistId],
    );
  }

  Future<void> removeFromPlaylist(String playlistId, String songId) async {
    await ensureTables();
    final db = await DatabaseService.instance.database;
    final maps = await db.query(
      _playlistsTable,
      where: 'id = ?',
      whereArgs: [playlistId],
    );
    if (maps.isEmpty) return;
    final playlist = PlaylistModel.fromMap(maps.first);
    final updatedIds = playlist.songIds.where((id) => id != songId).toList();
    await db.update(
      _playlistsTable,
      {'song_ids': updatedIds.join(',')},
      where: 'id = ?',
      whereArgs: [playlistId],
    );
  }

  Future<void> deletePlaylist(String playlistId) async {
    await ensureTables();
    final db = await DatabaseService.instance.database;
    await db.delete(
      _playlistsTable,
      where: 'id = ?',
      whereArgs: [playlistId],
    );
  }
}
