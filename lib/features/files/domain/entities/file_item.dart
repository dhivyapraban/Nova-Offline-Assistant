/// The type of a file determined by its extension.
enum FileType { pdf, docx, ppt, image, audio, video, other }

/// Represents a file found on the device.
class FileItem {
  final String id;
  final String name;
  final String path;
  final String extension;
  final int sizeBytes;
  final DateTime modifiedAt;
  final bool isFavorite;
  final FileType type;

  const FileItem({
    required this.id,
    required this.name,
    required this.path,
    required this.extension,
    required this.sizeBytes,
    required this.modifiedAt,
    this.isFavorite = false,
    required this.type,
  });

  FileItem copyWith({
    String? id,
    String? name,
    String? path,
    String? extension,
    int? sizeBytes,
    DateTime? modifiedAt,
    bool? isFavorite,
    FileType? type,
  }) {
    return FileItem(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      extension: extension ?? this.extension,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      type: type ?? this.type,
    );
  }

  /// Returns a human-readable file size string.
  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    if (sizeBytes < 1024 * 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
