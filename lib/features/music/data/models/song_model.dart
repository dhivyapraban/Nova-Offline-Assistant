import '../../domain/entities/song.dart';

/// Data model for Song with SQLite serialization.
class SongModel extends Song {
  const SongModel({
    required super.id,
    required super.title,
    required super.artist,
    super.album,
    required super.filePath,
    required super.durationMs,
    super.addedAt,
  });

  factory SongModel.fromEntity(Song song) {
    return SongModel(
      id: song.id,
      title: song.title,
      artist: song.artist,
      album: song.album,
      filePath: song.filePath,
      durationMs: song.durationMs,
      addedAt: song.addedAt,
    );
  }

  factory SongModel.fromMap(Map<String, dynamic> map) {
    return SongModel(
      id: map['id'] as String,
      title: map['title'] as String,
      artist: map['artist'] as String,
      album: map['album'] as String?,
      filePath: map['file_path'] as String,
      durationMs: map['duration_ms'] as int,
      addedAt: map['added_at'] != null
          ? DateTime.parse(map['added_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'file_path': filePath,
      'duration_ms': durationMs,
      'added_at': addedAt?.toIso8601String(),
    };
  }
}
