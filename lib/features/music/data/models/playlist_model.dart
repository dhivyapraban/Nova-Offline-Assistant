import '../../domain/entities/playlist.dart';

/// Data model for Playlist with SQLite serialization.
class PlaylistModel extends Playlist {
  const PlaylistModel({
    required super.id,
    required super.name,
    required super.songIds,
    required super.createdAt,
  });

  factory PlaylistModel.fromEntity(Playlist playlist) {
    return PlaylistModel(
      id: playlist.id,
      name: playlist.name,
      songIds: List.from(playlist.songIds),
      createdAt: playlist.createdAt,
    );
  }

  factory PlaylistModel.fromMap(Map<String, dynamic> map) {
    final songIdsRaw = map['song_ids'] as String? ?? '';
    return PlaylistModel(
      id: map['id'] as String,
      name: map['name'] as String,
      songIds: songIdsRaw.isEmpty ? [] : songIdsRaw.split(','),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'song_ids': songIds.join(','),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
