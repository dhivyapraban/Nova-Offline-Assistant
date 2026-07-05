/// Represents a music track available on the device.
class Song {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String filePath;
  final int durationMs;
  final DateTime? addedAt;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    required this.filePath,
    required this.durationMs,
    this.addedAt,
  });

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? filePath,
    int? durationMs,
    DateTime? addedAt,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      filePath: filePath ?? this.filePath,
      durationMs: durationMs ?? this.durationMs,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
