import '../../domain/entities/file_item.dart';

/// Data model for FileItem with SQLite serialization.
class FileItemModel extends FileItem {
  const FileItemModel({
    required super.id,
    required super.name,
    required super.path,
    required super.extension,
    required super.sizeBytes,
    required super.modifiedAt,
    super.isFavorite,
    required super.type,
  });

  factory FileItemModel.fromEntity(FileItem item) {
    return FileItemModel(
      id: item.id,
      name: item.name,
      path: item.path,
      extension: item.extension,
      sizeBytes: item.sizeBytes,
      modifiedAt: item.modifiedAt,
      isFavorite: item.isFavorite,
      type: item.type,
    );
  }

  factory FileItemModel.fromMap(Map<String, dynamic> map) {
    return FileItemModel(
      id: map['id'] as String,
      name: map['name'] as String,
      path: map['path'] as String,
      extension: map['extension'] as String,
      sizeBytes: map['size_bytes'] as int,
      modifiedAt: DateTime.parse(map['modified_at'] as String),
      isFavorite: (map['is_favorite'] as int) == 1,
      type: FileType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => FileType.other,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'extension': extension,
      'size_bytes': sizeBytes,
      'modified_at': modifiedAt.toIso8601String(),
      'is_favorite': isFavorite ? 1 : 0,
      'type': type.name,
    };
  }
}
